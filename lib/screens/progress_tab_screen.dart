import 'package:flutter/material.dart';

import '../api/api_exception.dart';
import '../models/topic.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../widgets/ui_bits.dart';

class ProgressTabScreen extends StatefulWidget {
  const ProgressTabScreen({super.key});

  @override
  State<ProgressTabScreen> createState() => _ProgressTabScreenState();
}

class _ProgressTabScreenState extends State<ProgressTabScreen> {
  Future<List<Topic>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= AppScope.of(context).content.listTopics();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Topic>>(
        future: _future,
        builder: (context, snapshot) {
          final topics = snapshot.data ?? const <Topic>[];
          final totalCards = topics.fold<int>(0, (sum, t) => sum + t.cardCount);

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            children: [
              const Text(
                'Tu progreso',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Así avanzas en cada área de estudio.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 22),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.teal),
                  ),
                )
              else if (snapshot.hasError)
                Text(
                  snapshot.error is ApiException
                      ? (snapshot.error! as ApiException).message
                      : 'No se pudo cargar el progreso.',
                  style: const TextStyle(color: AppColors.textMuted),
                )
              else ...[
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TagBadge(
                        label: 'GENERAL',
                        background: AppColors.badgeResultsBg,
                        foreground: AppColors.badgeResultsFg,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$totalCards',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppColors.tealDeep,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        totalCards == 1
                            ? 'Hay 1 flashcard publicada para estudiar.'
                            : 'Hay $totalCards flashcards publicadas para estudiar.',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                for (final topic in topics) ...[
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Row(
                      children: [
                        Icon(topic.icon, color: AppColors.tealDeep, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            topic.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          topic.cardCount == 1
                              ? '1 tarjeta'
                              : '${topic.cardCount} tarjetas',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.tealDeep,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ],
          );
        },
      );
  }
}
