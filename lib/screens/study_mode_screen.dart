import 'package:flutter/material.dart';

import '../models/study_mode.dart';
import '../models/study_session_config.dart';
import '../models/subtopic.dart';
import '../models/topic.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';
import '../widgets/ui_bits.dart';
import 'flashcard_session_screen.dart';

class StudyModeScreen extends StatefulWidget {
  const StudyModeScreen({
    super.key,
    required this.deck,
    this.subtopic,
  });

  final Topic deck;
  final Subtopic? subtopic;

  @override
  State<StudyModeScreen> createState() => _StudyModeScreenState();
}

class _StudyModeScreenState extends State<StudyModeScreen> {
  StudyMode _mode = StudyMode.viewAll;
  CardOrder _order = CardOrder.fixed;

  String get _scopeTitle => widget.subtopic?.title ?? widget.deck.title;

  void _start() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FlashcardSessionScreen(
          config: StudySessionConfig(
            deck: widget.deck,
            subtopic: widget.subtopic,
            mode: _mode,
            order: _order,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: CircularIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cómo quieres estudiar',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _scopeTitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    for (final mode in StudyMode.values) ...[
                      _ModeCard(
                        mode: mode,
                        selected: _mode == mode,
                        entireTopic: widget.subtopic == null,
                        onTap: () => setState(() => _mode = mode),
                      ),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 8),
                    const Text(
                      'Orden de las tarjetas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final order in CardOrder.values) ...[
                      _OrderCard(
                        order: order,
                        selected: _order == order,
                        onTap: () => setState(() => _order = order),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
              GradientButton(
                label: 'Empezar',
                onPressed: _start,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.mode,
    required this.selected,
    required this.entireTopic,
    required this.onTap,
  });

  final StudyMode mode;
  final bool selected;
  final bool entireTopic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFE8F8F4) : AppColors.inputFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              mode.icon,
              color: selected ? AppColors.tealDeep : AppColors.iconMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mode.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mode.descriptionFor(entireTopic: entireTopic),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            selected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_off_rounded,
            color: selected ? AppColors.tealDeep : AppColors.iconMuted,
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.selected,
    required this.onTap,
  });

  final CardOrder order;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFE8F8F4) : AppColors.inputFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              order.icon,
              color: selected ? AppColors.tealDeep : AppColors.iconMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  order.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            selected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_off_rounded,
            color: selected ? AppColors.tealDeep : AppColors.iconMuted,
          ),
        ],
      ),
    );
  }
}
