import 'flashcard.dart';

class StudyInsights {
  const StudyInsights({
    required this.dueCards,
    required this.unmasteredCount,
    required this.totalCards,
    this.unmasteredByCategory = const {},
    this.unmasteredByDeck = const {},
  });

  final List<Flashcard> dueCards;
  final int unmasteredCount;
  final int totalCards;
  final Map<String, int> unmasteredByCategory;
  final Map<String, int> unmasteredByDeck;

  int get dueCount => dueCards.length;

  double get mastery {
    if (totalCards <= 0) return 0;
    return ((totalCards - unmasteredCount) / totalCards).clamp(0.0, 1.0);
  }

  double progressFor({
    required String? categoryId,
    required String deckId,
    required int cardCount,
  }) {
    if (cardCount <= 0) return 0;
    final pending = categoryId == null || categoryId.isEmpty
        ? (unmasteredByDeck[deckId] ?? 0)
        : (unmasteredByCategory[categoryId] ?? 0);
    return ((cardCount - pending) / cardCount).clamp(0.0, 1.0);
  }
}
