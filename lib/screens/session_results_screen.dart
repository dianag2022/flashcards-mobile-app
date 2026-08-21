import 'package:flutter/material.dart';

import '../models/topic.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';
import '../widgets/ui_bits.dart';
import 'flashcard_session_screen.dart';

class SessionResultsScreen extends StatelessWidget {
  const SessionResultsScreen({
    super.key,
    required this.topic,
    required this.knownCount,
    required this.total,
  });

  final Topic topic;
  final int knownCount;
  final int total;

  int get _toReview => total - knownCount;
  double get _accuracy => total == 0 ? 0 : knownCount / total;

  String get _headline {
    if (_accuracy >= 0.8) return '¡Excelente trabajo!';
    if (_accuracy >= 0.4) return '¡Vas muy bien!';
    return 'Sigue practicando';
  }

  String get _message {
    if (_accuracy >= 0.8) {
      return 'Dominas gran parte de este tema. Un último repaso te dejará aún más seguro.';
    }
    if (_accuracy >= 0.4) {
      return 'Sigue repasando para fortalecer los conceptos que aún no dominas.';
    }
    return 'Cada sesión cuenta. Vuelve a intentarlo y verás cómo se afianzan las ideas.';
  }

  @override
  Widget build(BuildContext context) {
    final percent = (_accuracy * 100).round();

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
                    const Text(
                      'Sesión completada',
                      style: TextStyle(
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
                          const TagBadge(
                            label: 'RESULTADOS',
                            background: AppColors.badgeResultsBg,
                            foreground: AppColors.badgeResultsFg,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '$knownCount de $total',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: AppColors.tealDeep,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Respondiste correctamente $knownCount de $total flashcards.',
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
                                  '$knownCount respuestas',
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
                label: 'Reintentar',
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => FlashcardSessionScreen(topic: topic),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              SecondaryButton(
                label: 'Volver a temas',
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
