import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../models/topic.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';
import '../widgets/ui_bits.dart';
import 'session_results_screen.dart';

class FlashcardSessionScreen extends StatefulWidget {
  const FlashcardSessionScreen({super.key, required this.topic});

  final Topic topic;

  @override
  State<FlashcardSessionScreen> createState() => _FlashcardSessionScreenState();
}

class _FlashcardSessionScreenState extends State<FlashcardSessionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;
  var _index = 0;
  var _knownCount = 0;

  List<Flashcard> get _cards => widget.topic.cards;
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

  void _answer(bool knewIt) {
    if (knewIt) _knownCount += 1;

    final isLast = _index >= _cards.length - 1;
    if (isLast) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => SessionResultsScreen(
            topic: widget.topic,
            knownCount: _knownCount,
            total: _cards.length,
          ),
        ),
      );
      return;
    }

    setState(() {
      _index += 1;
      _flipController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_index + 1) / _cards.length;
    final angle = _flipController.value * math.pi;
    final showBack = angle > math.pi / 2;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            children: [
              SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Text(
                        widget.topic.title,
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
                        onPressed: showBack
                            ? _flipToQuestion
                            : () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                '${_index + 1} de ${_cards.length}',
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
                  onTap: showBack ? null : _flipToAnswer,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0012)
                      ..rotateY(angle),
                    child: showBack
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(math.pi),
                            child: _AnswerCard(card: _card),
                          )
                        : _QuestionCard(card: _card),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              if (!showBack) ...[
                GradientButton(
                  label: 'Ver respuesta',
                  icon: Icons.visibility_outlined,
                  onPressed: _flipToAnswer,
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
                        onPressed: () => _answer(false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        label: 'Lo sabía',
                        onPressed: () => _answer(true),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
