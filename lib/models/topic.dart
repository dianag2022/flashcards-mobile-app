import 'package:flutter/material.dart';

class Topic {
  const Topic({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.cardCount = 0,
    this.progress = 0,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final int cardCount;
  final double progress;

  factory Topic.fromDeck(Map<String, dynamic> json, {required IconData icon}) {
    return Topic(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Tema',
      subtitle: json['description'] as String? ?? '',
      icon: icon,
      cardCount: json['cardCount'] as int? ?? 0,
    );
  }
}
