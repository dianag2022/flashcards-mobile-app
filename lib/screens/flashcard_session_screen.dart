import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../api/api_exception.dart';
import '../models/flashcard.dart';
import '../models/study_mode.dart';
import '../models/study_session_config.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';
import '../widgets/ui_bits.dart';
import 'session_results_screen.dart';

class FlashcardSessionScreen extends StatefulWidget {
  const FlashcardSessionScreen({super.key, required this.config});

  final StudySessionConfig config;

  @override
  State<FlashcardSessionScreen> createState() => _FlashcardSessionScreenState();
}

class _FlashcardSessionScreenState extends State<FlashcardSessionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;
  Future<List<Flashcard>>? _future;
  List<Flashcard> _cards = const [];
  List<Flashcard> _allCards = const [];
  final _missed = <Flashcard>[];
  var _index = 0;
  var _knownCount = 0;
  var _answering = false;

  Flashcard get _card => _cards[_index];
  bool get _showingAnswer => _flipController.value > 0.5;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _loadCards();
  }

  Future<List<Flashcard>> _fetchPool() {
    final content = AppScope.of(context).content;
    final config = widget.config;
    final tag = (config.subtopic?.title ?? 'REPASO').toUpperCase();
    if (config.subtopic != null) {
      return content.listFlashcardsInCategory(
        deckId: config.deck.id,
        categoryId: config.subtopic!.id,
        tag: tag,
      );
    }
    return content.listFlashcards(config.deck.id, tag: tag);
  }

  Future<List<Flashcard>> _loadCards() async {
    final config = widget.config;
    if (config.presetCards != null) {
      final cards = config.presetCards!;
      if (mounted) {
        setState(() {
          _cards = cards;
          _allCards = config.allCards ?? cards;
        });
      }
      await _trackStudy(cards);
      return cards;
    }

    final content = AppScope.of(context).content;
    final pool = await _fetchPool();
    var reinforcement = const <Flashcard>[];
    if (config.mode == StudyMode.reviewIncorrect ||
        config.mode == StudyMode.adaptive) {
      try {
        reinforcement = await content.listReinforcement(
          deckId: config.deck.id,
          categoryId: config.subtopic?.id,
        );
      } catch (_) {
        reinforcement = const [];
      }
    }

    final reinforcementIds = reinforcement.map((card) => card.id).toSet();
    final cards = switch (config.mode) {
      StudyMode.reviewIncorrect when reinforcement.isNotEmpty => [
          ...reinforcement,
          ...pool.where((card) => !reinforcementIds.contains(card.id)),
        ],
      StudyMode.reviewIncorrect => pool,
      StudyMode.adaptive =>
        (reinforcement.isEmpty ? pool : reinforcement).take(20).toList(),
      StudyMode.groupsOf10 => _slice(pool, config.roundIndex, 10),
      StudyMode.groupsOf20 => _slice(pool, config.roundIndex, 20),
      StudyMode.viewAll => pool,
    };

    if (mounted) {
      setState(() {
        _cards = cards;
        _allCards = pool;
      });
    }
    await _trackStudy(cards);
    return cards;
  }

  Future<void> _trackStudy(List<Flashcard> cards) async {
    if (!widget.config.trackActivity ||
        widget.config.roundIndex > 0 ||
        cards.isEmpty) {
      return;
    }
    await AppScope.of(context).activity.record(
      deck: widget.config.deck,
      subtopic: widget.config.subtopic,
    );
  }

  List<Flashcard> _slice(List<Flashcard> cards, int roundIndex, int size) {
    final start = roundIndex * size;
    if (start >= cards.length) return const [];
    return cards.skip(start).take(size).toList();
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipToAnswer() {
    if (_showingAnswer || _flipController.isAnimating) return;
    _flipController.forward();
  }

  void _flipToQuestion() {
    if (!_showingAnswer || _flipController.isAnimating) return;
    _flipController.reverse();
  }

  Future<void> _answer(bool knewIt) async {
    if (_answering) return;
    setState(() => _answering = true);

    if (knewIt) {
      _knownCount += 1;
    } else {
      _missed.add(_card);
    }

    try {
      await AppScope.of(context).content.recordAnswer(
        cardId: _card.id,
        correct: knewIt,
      );
    } catch (_) {
      // Keep the session moving even if progress fails to save.
    }

    if (!mounted) return;

    final isLast = _index >= _cards.length - 1;
    if (isLast) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => SessionResultsScreen(
            config: widget.config.copyWith(allCards: _allCards),
            knownCount: _knownCount,
            total: _cards.length,
            missedCards: List<Flashcard>.from(_missed),
          ),
        ),
      );
      return;
    }

    setState(() {
      _index += 1;
      _answering = false;
      _flipController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: FutureBuilder<List<Flashcard>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.teal),
                );
              }
              if (snapshot.hasError) {
                return _MessageBody(
                  title: widget.config.title,
                  message: snapshot.error is ApiException
                      ? (snapshot.error! as ApiException).message
                      : 'No se pudieron cargar las flashcards.',
                  onBack: () => Navigator.of(context).pop(),
                );
              }
              if (_cards.isEmpty) {
                return _MessageBody(
                  title: widget.config.title,
                  message: widget.config.mode == StudyMode.adaptive
                      ? 'Ya dominas este contenido. No hay tarjetas pendientes.'
                      : 'Este tema todavía no tiene flashcards publicadas.',
                  onBack: () => Navigator.of(context).pop(),
                );
              }
              return _SessionBody(
                topicTitle: widget.config.roundIndex > 0
                    ? '${widget.config.title} · Ronda ${widget.config.roundIndex + 1}'
                    : widget.config.mode.usesRounds
                        ? '${widget.config.title} · Ronda 1'
                        : widget.config.title,
                index: _index,
                total: _cards.length,
                card: _card,
                flipValue: _flipController.value,
                onBack: () => Navigator.of(context).pop(),
                onFlipToAnswer: _flipToAnswer,
                onFlipToQuestion: _flipToQuestion,
                onKnew: () => _answer(true),
                onUnknown: () => _answer(false),
                answering: _answering,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MessageBody extends StatelessWidget {
  const _MessageBody({
    required this.title,
    required this.message,
    required this.onBack,
  });

  final String title;
  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: CircularIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: onBack,
          ),
        ),
        const Spacer(),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMuted),
        ),
        const Spacer(),
      ],
    );
  }
}

class _SessionBody extends StatelessWidget {
  const _SessionBody({
    required this.topicTitle,
    required this.index,
    required this.total,
    required this.card,
    required this.flipValue,
    required this.onBack,
    required this.onFlipToAnswer,
    required this.onFlipToQuestion,
    required this.onKnew,
    required this.onUnknown,
    this.answering = false,
  });

  final String topicTitle;
  final int index;
  final int total;
  final Flashcard card;
  final double flipValue;
  final VoidCallback onBack;
  final VoidCallback onFlipToAnswer;
  final VoidCallback onFlipToQuestion;
  final VoidCallback onKnew;
  final VoidCallback onUnknown;
  final bool answering;

  @override
  Widget build(BuildContext context) {
    final progress = (index + 1) / total;
    final angle = flipValue * math.pi;
    final showBack = angle > math.pi / 2;

    return Column(
      children: [
        SizedBox(
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  topicTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: CircularIconButton(
                  icon: showBack
                      ? Icons.close_rounded
                      : Icons.arrow_back_ios_new_rounded,
                  onPressed: showBack ? onFlipToQuestion : onBack,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          '${index + 1} de $total',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        ThinProgressBar(value: progress, height: 5),
        const SizedBox(height: 22),
        Expanded(
          child: GestureDetector(
            onTap: showBack ? null : onFlipToAnswer,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateY(angle),
              child: showBack
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: _AnswerCard(card: card),
                    )
                  : _QuestionCard(card: card),
            ),
          ),
        ),
        const SizedBox(height: 22),
        if (!showBack) ...[
          GradientButton(
            label: 'Ver respuesta',
            icon: Icons.visibility_outlined,
            onPressed: onFlipToAnswer,
          ),
          const SizedBox(height: 12),
          const Text(
            'Toca la tarjeta o el botón para girar',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ] else
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'No lo sabía',
                  onPressed: answering ? () {} : onUnknown,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientButton(
                  label: 'Lo sabía',
                  isLoading: answering,
                  onPressed: answering ? null : onKnew,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.card});

  final Flashcard card;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
      child: Column(
        children: [
          TagBadge(label: card.tag),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  card.question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({required this.card});

  final Flashcard card;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      child: Column(
        children: [
          const TagBadge(
            label: 'RESPUESTA',
            background: AppColors.badgeAnswerBg,
            foreground: AppColors.badgeAnswerFg,
          ),
          const SizedBox(height: 22),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.answer,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (card.explanation.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      card.explanation,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
