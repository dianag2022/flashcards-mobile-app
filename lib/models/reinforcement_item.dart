import 'flashcard.dart';

class ReinforcementItem {
  const ReinforcementItem({
    required this.flashcard,
    this.lastResult,
    this.mastered = false,
  });

  final Flashcard flashcard;
  final String? lastResult;
  final bool mastered;

  bool get isIncorrect => lastResult == 'incorrect';
}
