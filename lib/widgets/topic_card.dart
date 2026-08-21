import 'package:flutter/material.dart';

import '../models/topic.dart';
import '../theme/app_colors.dart';
import 'ui_bits.dart';

class TopicCard extends StatelessWidget {
  const TopicCard({
    super.key,
    required this.topic,
    required this.onTap,
  });

  final Topic topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percent = (topic.progress * 100).round();

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(topic.icon, color: AppColors.tealDeep, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      topic.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.iconMuted,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ThinProgressBar(
                  value: topic.progress,
                  height: 5,
                  fillColor: AppColors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                topic.progress > 0
                    ? '$percent%'
                    : topic.cardCount == 1
                        ? '1 tarjeta'
                        : '${topic.cardCount} tarjetas',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.tealDeep,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
