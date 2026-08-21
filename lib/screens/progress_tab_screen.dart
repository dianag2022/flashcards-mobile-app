import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../widgets/ui_bits.dart';

class ProgressTabScreen extends StatelessWidget {
  const ProgressTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const overall = 0.48;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
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
          const AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TagBadge(
                  label: 'GENERAL',
                  background: AppColors.badgeResultsBg,
                  foreground: AppColors.badgeResultsFg,
                ),
                SizedBox(height: 16),
                Text(
                  '48%',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tealDeep,
                    height: 1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Completaste casi la mitad del temario de repaso.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dominio total',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '48%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.tealDeep,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ThinProgressBar(value: overall, fillColor: AppColors.teal),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final topic in MockData.topics) ...[
            AppCard(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                        '${(topic.progress * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.tealDeep,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ThinProgressBar(
                    value: topic.progress,
                    fillColor: AppColors.teal,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
