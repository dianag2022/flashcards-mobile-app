import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../models/study_mode.dart';
import '../models/study_session_config.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';
import '../widgets/ui_bits.dart';
import 'flashcard_session_screen.dart';

class SessionResultsScreen extends StatefulWidget {
  const SessionResultsScreen({
    super.key,
    required this.config,
    required this.knownCount,
    required this.total,
    this.missedCards = const [],
  });

  final StudySessionConfig config;
  final int knownCount;
  final int total;
  final List<Flashcard> missedCards;

  @override
  State<SessionResultsScreen> createState() => _SessionResultsScreenState();
}

class _SessionResultsScreenState extends State<SessionResultsScreen> {
  var _loadingNext = false;

  int get _toReview => widget.total - widget.knownCount;
  double get _accuracy =>
      widget.total == 0 ? 0 : widget.knownCount / widget.total;

  bool get _isRound => widget.config.mode.usesRounds;

  List<Flashcard>? get _nextGroup {
    final size = widget.config.mode.groupSize;
    final all = widget.config.allCards;
    if (size == null || all == null || widget.config.mode == StudyMode.adaptive) {
      return null;
    }
    final start = (widget.config.roundIndex + 1) * size;
    if (start >= all.length) return null;
    return all.skip(start).take(size).toList();
  }

  String get _headline {
    if (_accuracy >= 0.8) return '¡Excelente trabajo!';
    if (_accuracy >= 0.4) return '¡Vas muy bien!';
    return 'Sigue practicando';
  }

  String get _message {
    if (widget.config.mode == StudyMode.adaptive && widget.missedCards.isEmpty) {
      return 'No fallaste ninguna en esta ronda. Comprobaremos si ya dominas el resto.';
    }
    if (_accuracy >= 0.8) {
      return 'Dominas gran parte de este contenido. Un último repaso te dejará aún más seguro.';
    }
    if (_accuracy >= 0.4) {
      return 'Sigue repasando para fortalecer los conceptos que aún no dominas.';
    }
    return 'Cada sesión cuenta. Vuelve a intentarlo y verás cómo se afianzan las ideas.';
  }

  String get _screenTitle {
    if (!_isRound) return 'Sesión completada';
    return 'Ronda ${widget.config.roundIndex + 1} completada';
  }

  Future<void> _continueAdaptive() async {
    setState(() => _loadingNext = true);

    List<Flashcard> next;
    if (widget.missedCards.isNotEmpty) {
      next = widget.missedCards;
    } else {
      try {
        next = await AppScope.of(context).content.listReinforcement(
          deckId: widget.config.deck.id,
          categoryId: widget.config.subtopic?.id,
        );
      } catch (_) {
        if (!mounted) return;
        setState(() => _loadingNext = false);
        return;
      }
    }

    if (!mounted) return;

    if (next.isEmpty) {
      setState(() => _loadingNext = false);
      _showMastered();
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => FlashcardSessionScreen(
          config: widget.config.copyWith(
            roundIndex: widget.config.roundIndex + 1,
            presetCards: next.take(20).toList(),
            allCards: widget.config.allCards,
          ),
        ),
      ),
    );
  }

  void _continueGroup() {
    final next = _nextGroup;
    if (next == null || next.isEmpty) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => FlashcardSessionScreen(
          config: widget.config.copyWith(
            roundIndex: widget.config.roundIndex + 1,
            presetCards: next,
            allCards: widget.config.allCards,
          ),
        ),
      ),
    );
  }

  void _retry() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => FlashcardSessionScreen(
          config: StudySessionConfig(
            deck: widget.config.deck,
            subtopic: widget.config.subtopic,
            mode: widget.config.mode,
          ),
        ),
      ),
    );
  }

  void _showMastered() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events_outlined,
                color: AppColors.tealDeep,
                size: 40,
              ),
              const SizedBox(height: 12),
              const Text(
                '¡Tema dominado!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Completaste tres aciertos seguidos en todas las flashcards de este contenido.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              GradientButton(
                label: 'Volver',
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(this.context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final percent = (_accuracy * 100).round();
    final nextGroup = _nextGroup;
    final showNextGroup = nextGroup != null && nextGroup.isNotEmpty;
    final showNextAdaptive = widget.config.mode == StudyMode.adaptive;
    final primaryLabel = showNextAdaptive
        ? (widget.missedCards.isEmpty
            ? 'Comprobar dominio'
            : 'Siguiente ronda')
        : showNextGroup
            ? 'Siguiente grupo'
            : 'Reintentar';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      _screenTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.tealDeep,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CircularIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Tu progreso',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView(
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TagBadge(
                            label: _isRound ? 'RONDA' : 'RESULTADOS',
                            background: AppColors.badgeResultsBg,
                            foreground: AppColors.badgeResultsFg,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${widget.knownCount} de ${widget.total}',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: AppColors.tealDeep,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Respondiste correctamente ${widget.knownCount} de ${widget.total} flashcards.',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Precisión',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '$percent%',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.tealDeep,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ThinProgressBar(
                            value: _accuracy,
                            fillColor: AppColors.teal,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.feedbackBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.tealDeep,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _headline,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _message,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Correctas',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${widget.knownCount} respuestas',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Para repasar',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '$_toReview conceptos',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GradientButton(
                label: primaryLabel,
                isLoading: _loadingNext,
                onPressed: showNextAdaptive
                    ? _continueAdaptive
                    : showNextGroup
                        ? _continueGroup
                        : _retry,
              ),
              if (showNextGroup || showNextAdaptive) ...[
                const SizedBox(height: 10),
                SecondaryButton(
                  label: 'Reintentar desde el inicio',
                  foreground: AppColors.tealDeep,
                  borderColor: Colors.transparent,
                  onPressed: _retry,
                ),
              ],
              const SizedBox(height: 10),
              SecondaryButton(
                label: 'Volver',
                foreground: AppColors.tealDeep,
                borderColor: Colors.transparent,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
