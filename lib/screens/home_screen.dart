import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';
import '../widgets/ui_bits.dart';
import 'flashcard_session_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final featured = MockData.topics.first;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        children: [
          const Text(
            'Inicio',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Un espacio de calma para seguir avanzando.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TagBadge(
                  label: 'CONTINUAR',
                  background: Colors.white,
                  foreground: AppColors.tealDeep,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Teorías psicológicas',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Retoma donde lo dejaste y refuerza conductismo, psicoanálisis y más.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 168,
                    child: SecondaryButton(
                      label: 'Estudiar ahora',
                      height: 44,
                      background: Colors.white,
                      borderColor: Colors.white,
                      foreground: AppColors.tealDeep,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                FlashcardSessionScreen(topic: featured),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Tu racha de estudio',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: _StatMini(
                  label: 'Hoy',
                  value: '12 min',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatMini(
                  label: 'Racha',
                  value: '4 días',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  const _StatMini({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
