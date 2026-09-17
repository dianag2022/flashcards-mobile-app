import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../api/api_exception.dart';
import '../models/flashcard.dart';
import '../models/in_progress_session.dart';
import '../models/recent_study.dart';
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
  var _roundFinished = false;

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
      final cards = (!config.resume && config.mode == StudyMode.adaptive)
          ? _maybeShuffle(config.presetCards!)
          : config.presetCards!;
      if (mounted) {
        setState(() {
          _cards = cards;
          _allCards = config.allCards ?? cards;
          if (config.resume) {
            _index = config.resumeIndex.clamp(0, cards.isEmpty ? 0 : cards.length - 1);
            _knownCount = config.resumeKnownCount;
            _missed
              ..clear()
              ..addAll(config.resumeMissed);
          }
        });
      }
      await _trackStudy(cards);
      await _persistProgress();
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
    final shuffledPool = _maybeShuffle(pool);
    final shuffledReinforcement = _maybeShuffle(reinforcement);
    final cards = switch (config.mode) {
      StudyMode.reviewIncorrect when shuffledReinforcement.isNotEmpty => [
          ...shuffledReinforcement,
          ..._maybeShuffle(
            shuffledPool
                .where((card) => !reinforcementIds.contains(card.id))
                .toList(),
          ),
        ],
      StudyMode.reviewIncorrect => shuffledPool,
      StudyMode.adaptive =>
        (shuffledReinforcement.isEmpty ? shuffledPool : shuffledReinforcement)
            .take(20)
            .toList(),
      StudyMode.groupsOf10 => _slice(shuffledPool, config.roundIndex, 10),
      StudyMode.groupsOf20 => _slice(shuffledPool, config.roundIndex, 20),
      StudyMode.viewAll => shuffledPool,
    };

    if (mounted) {
      setState(() {
        _cards = cards;
        _allCards = shuffledPool;
      });
    }
    await _trackStudy(cards);
    await _persistProgress();
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

  Future<void> _persistProgress() async {
    if (!widget.config.trackActivity || _roundFinished || _cards.isEmpty) {
      return;
    }
    await AppScope.of(context).activity.saveInProgress(
      InProgressSession(
        scope: RecentStudy.fromSession(
          deck: widget.config.deck,
          subtopic: widget.config.subtopic,
        ),
        mode: widget.config.mode,
        order: widget.config.order,
        roundIndex: widget.config.roundIndex,
        cardIndex: _index,
        knownCount: _knownCount,
        roundCards: _cards,
        allCards: _allCards,
        missedCards: List<Flashcard>.from(_missed),
      ),
    );
  }

  List<Flashcard> _maybeShuffle(List<Flashcard> cards) {
    if (widget.config.order != CardOrder.random || cards.length < 2) {
      return cards;
    }
    final copy = List<Flashcard>.from(cards)..shuffle();
    return copy;
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
    if (_answering || _showingAnswer || _flipController.isAnimating) return;
    _flipController.forward();
  }

  void _toggleFlip() {
    if (_answering || _flipController.isAnimating) return;
    if (_flipController.value > 0.5) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
  }

  void _onFlipDragStart() {
    if (_answering) return;
    _flipController.stop();
  }

  void _onFlipDragUpdate(double deltaDx) {
    if (_answering) return;
    final width = MediaQuery.sizeOf(context).width.clamp(1.0, 4000.0);
    _flipController.value =
        (_flipController.value - deltaDx / (width * 0.85)).clamp(0.0, 1.0);
  }

  void _onFlipDragEnd(double velocityDx) {
    if (_answering) return;
    const fling = 700.0;
    if (velocityDx <= -fling) {
      _flipController.forward();
    } else if (velocityDx >= fling) {
      _flipController.reverse();
    } else if (_flipController.value >= 0.5) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
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
      _roundFinished = true;
      await AppScope.of(context).activity.saveInProgress(
        InProgressSession(
          scope: RecentStudy.fromSession(
            deck: widget.config.deck,
            subtopic: widget.config.subtopic,
          ),
          mode: widget.config.mode,
          order: widget.config.order,
          roundIndex: widget.config.roundIndex,
          cardIndex: _index,
          knownCount: _knownCount,
          roundCards: _cards,
          allCards: _allCards,
          missedCards: List<Flashcard>.from(_missed),
        ),
      );
      if (!mounted) return;
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
    await _persistProgress();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && !_roundFinished) _persistProgress();
      },
      child: Scaffold(
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
                  onToggleFlip: _toggleFlip,
                  onFlipDragStart: _onFlipDragStart,
                  onFlipDragUpdate: _onFlipDragUpdate,
                  onFlipDragEnd: _onFlipDragEnd,
                  onKnew: () => _answer(true),
                  onUnknown: () => _answer(false),
                  answering: _answering,
                );
              },
            ),
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
    required this.onToggleFlip,
    required this.onFlipDragStart,
    required this.onFlipDragUpdate,
    required this.onFlipDragEnd,
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
  final VoidCallback onToggleFlip;
  final VoidCallback onFlipDragStart;
  final ValueChanged<double> onFlipDragUpdate;
  final ValueChanged<double> onFlipDragEnd;
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
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: onBack,
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
            behavior: HitTestBehavior.opaque,
            onTap: answering ? null : onToggleFlip,
            onHorizontalDragStart: answering
                ? null
                : (_) => onFlipDragStart(),
            onHorizontalDragUpdate: answering
                ? null
                : (details) => onFlipDragUpdate(details.delta.dx),
            onHorizontalDragEnd: answering
                ? null
                : (details) =>
                    onFlipDragEnd(details.primaryVelocity ?? 0),
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
            onPressed: answering ? null : onFlipToAnswer,
          ),
          const SizedBox(height: 12),
          const Text(
            'Desliza o toca la tarjeta para girar',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ] else ...[
          const Text(
            'Desliza o toca la tarjeta para volver a la pregunta',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
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
