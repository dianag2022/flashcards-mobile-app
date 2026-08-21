import 'package:flutter/material.dart';

import 'flashcard.dart';

class Topic {
  const Topic({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.progress,
    required this.cards,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final double progress;
  final List<Flashcard> cards;
}
