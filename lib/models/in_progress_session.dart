import 'flashcard.dart';
import 'recent_study.dart';
import 'study_mode.dart';
import 'subtopic.dart';
import 'topic.dart';

class InProgressSession {
  const InProgressSession({
    required this.scope,
    required this.mode,
    required this.order,
    required this.roundIndex,
    required this.cardIndex,
    required this.knownCount,
    required this.roundCards,
    required this.allCards,
    this.missedCards = const [],
    this.updatedAt,
  });

  final RecentStudy scope;
  final StudyMode mode;
  final CardOrder order;
  final int roundIndex;
  final int cardIndex;
  final int knownCount;
  final List<Flashcard> roundCards;
  final List<Flashcard> allCards;
  final List<Flashcard> missedCards;
  final DateTime? updatedAt;

  String get key => '${scope.key}:${mode.name}';

  String get headline => scope.headline;

  int get totalInRound => roundCards.length;

  double get progress {
    if (totalInRound <= 0) return 0;
    return (cardIndex / totalInRound).clamp(0.0, 1.0);
  }

  String get progressLabel {
    if (totalInRound <= 0) return 'Sesión pendiente';
    final current = (cardIndex + 1).clamp(1, totalInRound);
    if (mode.usesRounds) {
      return 'Ronda ${roundIndex + 1} · tarjeta $current de $totalInRound';
    }
    return 'Tarjeta $current de $totalInRound';
  }

  Topic toDeck() => scope.toDeck();

  Subtopic? toSubtopic() => scope.toSubtopic();

  Map<String, dynamic> toJson() {
    return {
      'scope': scope.toJson(),
      'mode': mode.name,
      'order': order.name,
      'roundIndex': roundIndex,
      'cardIndex': cardIndex,
      'knownCount': knownCount,
      'roundCards': [for (final card in roundCards) card.toJson()],
      'allCards': [for (final card in allCards) card.toJson()],
      'missedCards': [for (final card in missedCards) card.toJson()],
      'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory InProgressSession.fromJson(Map<String, dynamic> json) {
    return InProgressSession(
      scope: RecentStudy.fromJson(
        json['scope'] is Map<String, dynamic>
            ? json['scope'] as Map<String, dynamic>
            : const <String, dynamic>{},
      ),
      mode: _modeFrom(json['mode'] as String?),
      order: _orderFrom(json['order'] as String?),
      roundIndex: json['roundIndex'] as int? ?? 0,
      cardIndex: json['cardIndex'] as int? ?? 0,
      knownCount: json['knownCount'] as int? ?? 0,
      roundCards: _cardsFrom(json['roundCards']),
      allCards: _cardsFrom(json['allCards']),
      missedCards: _cardsFrom(json['missedCards']),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }

  static List<Flashcard> _cardsFrom(Object? raw) {
    if (raw is! List) return const [];
    return [
      for (final item in raw)
        if (item is Map<String, dynamic>) Flashcard.fromJson(item, tag: item['tag'] as String?),
    ];
  }

  static StudyMode _modeFrom(String? name) {
    return StudyMode.values.firstWhere(
      (value) => value.name == name,
      orElse: () => StudyMode.viewAll,
    );
  }

  static CardOrder _orderFrom(String? name) {
    return CardOrder.values.firstWhere(
      (value) => value.name == name,
      orElse: () => CardOrder.fixed,
    );
  }
}
