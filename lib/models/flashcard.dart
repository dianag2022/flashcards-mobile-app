class Flashcard {
  const Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.deckId = '',
    this.categoryId = '',
    this.tag = 'REPASO',
    this.explanation = '',
  });

  final String id;
  final String deckId;
  final String categoryId;
  final String question;
  final String answer;
  final String tag;
  final String explanation;

  factory Flashcard.fromJson(Map<String, dynamic> json, {String? tag}) {
    return Flashcard(
      id: json['id'] as String? ?? '',
      deckId: json['deckId'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      question: json['front'] as String? ?? '',
      answer: json['back'] as String? ?? '',
      tag: tag ?? 'REPASO',
      explanation: json['explanation'] as String? ?? '',
    );
  }
}
