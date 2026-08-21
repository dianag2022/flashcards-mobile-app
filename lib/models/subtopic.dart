import 'package:flutter/material.dart';

import 'topic.dart';

class Subtopic {
  const Subtopic({
    required this.id,
    required this.deckId,
    required this.title,
    required this.description,
    this.cardCount = 0,
  });

  final String id;
  final String deckId;
  final String title;
  final String description;
  final int cardCount;

  factory Subtopic.fromJson(Map<String, dynamic> json) {
    return Subtopic(
      id: json['id'] as String? ?? '',
      deckId: json['deckId'] as String? ?? '',
      title: json['title'] as String? ?? 'Subtema',
      description: json['description'] as String? ?? '',
      cardCount: json['cardCount'] as int? ?? 0,
    );
  }

  Topic asTopic({required IconData icon}) {
    return Topic(
      id: id,
      title: title,
      subtitle: description,
      icon: icon,
      cardCount: cardCount,
    );
  }
}
