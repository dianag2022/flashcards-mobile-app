import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../config/feature_flags.dart';
import '../models/flashcard.dart';
import '../models/reinforcement_item.dart';
import '../models/study_insights.dart';
import '../models/subtopic.dart';
import '../models/topic.dart';

class ContentService {
  ContentService({required ApiClient client}) : _client = client;

  final ApiClient _client;

  static const icons = [
    Icons.psychology_outlined,
    Icons.biotech_outlined,
    Icons.groups_outlined,
    Icons.monitor_heart_outlined,
    Icons.lightbulb_outline,
    Icons.menu_book_outlined,
  ];

  Future<List<Topic>> listTopics() async {
    final json = await _client.get('/api/decks', auth: true);
    final decks = json['decks'];
    if (decks is! List) return const [];

    return [
      for (var i = 0; i < decks.length; i++)
        if (decks[i] is Map<String, dynamic>)
          Topic.fromDeck(
            decks[i] as Map<String, dynamic>,
            icon: icons[i % icons.length],
          ),
    ];
  }

  Future<List<Subtopic>> listSubtopics(String deckId) async {
    final json = await _client.get(
      '/api/admin/decks/$deckId/categories',
      auth: true,
    );
    final categories = json['categories'];
    if (categories is! List) return const [];

    return [
      for (final item in categories)
        if (item is Map<String, dynamic>) Subtopic.fromJson(item),
    ];
  }

  Future<List<Flashcard>> listFlashcards(String deckId, {String? tag}) async {
    final json = await _client.get('/api/decks/$deckId/flashcards', auth: true);
    return _parseFlashcards(json, tag: tag);
  }

  Future<List<Flashcard>> listFlashcardsInCategory({
    required String deckId,
    required String categoryId,
    String? tag,
  }) async {
    final json = await _client.get(
      '/api/decks/$deckId/categories/$categoryId/flashcards',
      auth: true,
    );
    return _parseFlashcards(json, tag: tag);
  }

  Future<List<Flashcard>> listReinforcement({
    required String deckId,
    String? categoryId,
  }) async {
    final items = await listReinforcementItems(
      deckId: deckId,
      categoryId: categoryId,
    );
    return [for (final item in items) item.flashcard];
  }

  Future<List<ReinforcementItem>> listReinforcementItems({
    required String deckId,
    String? categoryId,
  }) async {
    final path = categoryId == null
        ? '/api/progress/decks/$deckId/reinforcement'
        : '/api/progress/decks/$deckId/categories/$categoryId/reinforcement';
    final json = await _client.get(path, auth: true);
    final cards = json['cards'];
    if (cards is! List) return const [];

    return [
      for (final item in cards)
        if (item is Map<String, dynamic> &&
            item['flashcard'] is Map<String, dynamic>)
          ReinforcementItem(
            flashcard: Flashcard.fromJson(
              item['flashcard'] as Map<String, dynamic>,
            ),
            lastResult: item['progress'] is Map<String, dynamic>
                ? (item['progress'] as Map<String, dynamic>)['lastResult']
                    as String?
                : null,
            mastered: item['progress'] is Map<String, dynamic>
                ? (item['progress'] as Map<String, dynamic>)['mastered']
                        as bool? ??
                    false
                : false,
          ),
    ];
  }

  Future<StudyInsights?> loadStudyInsights(List<Topic> decks) async {
    if (!FeatureFlags.homeProgressInsights || decks.isEmpty) return null;

    var anySuccess = false;
    final due = <Flashcard>[];
    var unmasteredCount = 0;
    final unmasteredByCategory = <String, int>{};
    final unmasteredByDeck = <String, int>{};
    final totalCards = decks.fold<int>(0, (sum, deck) => sum + deck.cardCount);

    await Future.wait([
      for (final deck in decks)
        () async {
          try {
            final items = await listReinforcementItems(deckId: deck.id);
            anySuccess = true;
            unmasteredCount += items.length;
            unmasteredByDeck[deck.id] = items.length;
            for (final item in items) {
              if (item.isIncorrect) due.add(item.flashcard);
              final categoryId = item.flashcard.categoryId;
              if (categoryId.isEmpty) continue;
              unmasteredByCategory[categoryId] =
                  (unmasteredByCategory[categoryId] ?? 0) + 1;
            }
          } catch (_) {}
        }(),
    ]);

    if (!anySuccess) return null;

    return StudyInsights(
      dueCards: due,
      unmasteredCount: unmasteredCount,
      totalCards: totalCards,
      unmasteredByCategory: unmasteredByCategory,
      unmasteredByDeck: unmasteredByDeck,
    );
  }

  Future<void> recordAnswer({
    required String cardId,
    required bool correct,
  }) async {
    await _client.post(
      '/api/progress/cards/$cardId',
      auth: true,
      body: {'result': correct ? 'correct' : 'incorrect'},
    );
  }

  List<Flashcard> _parseFlashcards(Map<String, dynamic> json, {String? tag}) {
    final cards = json['flashcards'];
    if (cards is! List) return const [];

    return [
      for (final card in cards)
        if (card is Map<String, dynamic>) Flashcard.fromJson(card, tag: tag),
    ];
  }
}
