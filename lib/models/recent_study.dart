import 'package:flutter/material.dart';

import 'subtopic.dart';
import 'topic.dart';

class RecentStudy {
  const RecentStudy({
    required this.deckId,
    required this.deckTitle,
    this.deckSubtitle = '',
    this.deckCardCount = 0,
    this.subtopicId,
    this.subtopicTitle,
    this.subtopicDescription = '',
    this.subtopicCardCount = 0,
    this.studiedAt,
  });

  final String deckId;
  final String deckTitle;
  final String deckSubtitle;
  final int deckCardCount;
  final String? subtopicId;
  final String? subtopicTitle;
  final String subtopicDescription;
  final int subtopicCardCount;
  final DateTime? studiedAt;

  String get headline {
    final subtopic = subtopicTitle;
    if (subtopic == null || subtopic.isEmpty) return deckTitle;
    return '$subtopic — $deckTitle';
  }

  String get shortTitle => subtopicTitle?.isNotEmpty == true
      ? subtopicTitle!
      : deckTitle;

  String get key => subtopicId?.isNotEmpty == true
      ? 'c:$subtopicId'
      : 'd:$deckId';

  Topic toDeck({IconData icon = Icons.menu_book_outlined}) {
    return Topic(
      id: deckId,
      title: deckTitle,
      subtitle: deckSubtitle,
      icon: icon,
      cardCount: deckCardCount,
    );
  }

  Subtopic? toSubtopic() {
    final id = subtopicId;
    if (id == null || id.isEmpty) return null;
    return Subtopic(
      id: id,
      deckId: deckId,
      title: subtopicTitle ?? 'Subtema',
      description: subtopicDescription,
      cardCount: subtopicCardCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deckId': deckId,
      'deckTitle': deckTitle,
      'deckSubtitle': deckSubtitle,
      'deckCardCount': deckCardCount,
      'subtopicId': subtopicId,
      'subtopicTitle': subtopicTitle,
      'subtopicDescription': subtopicDescription,
      'subtopicCardCount': subtopicCardCount,
      'studiedAt': studiedAt?.toIso8601String(),
    };
  }

  factory RecentStudy.fromJson(Map<String, dynamic> json) {
    return RecentStudy(
      deckId: json['deckId'] as String? ?? '',
      deckTitle: json['deckTitle'] as String? ?? '',
      deckSubtitle: json['deckSubtitle'] as String? ?? '',
      deckCardCount: json['deckCardCount'] as int? ?? 0,
      subtopicId: json['subtopicId'] as String?,
      subtopicTitle: json['subtopicTitle'] as String?,
      subtopicDescription: json['subtopicDescription'] as String? ?? '',
      subtopicCardCount: json['subtopicCardCount'] as int? ?? 0,
      studiedAt: DateTime.tryParse(json['studiedAt'] as String? ?? ''),
    );
  }

  factory RecentStudy.fromSession({
    required Topic deck,
    Subtopic? subtopic,
  }) {
    return RecentStudy(
      deckId: deck.id,
      deckTitle: deck.title,
      deckSubtitle: deck.subtitle,
      deckCardCount: deck.cardCount,
      subtopicId: subtopic?.id,
      subtopicTitle: subtopic?.title,
      subtopicDescription: subtopic?.description ?? '',
      subtopicCardCount: subtopic?.cardCount ?? 0,
      studiedAt: DateTime.now(),
    );
  }
}
