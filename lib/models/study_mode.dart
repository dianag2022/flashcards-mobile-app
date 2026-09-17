import 'package:flutter/material.dart';

enum StudyMode {
  viewAll,
  groupsOf10,
  groupsOf20,
  reviewIncorrect,
  adaptive,
}

extension StudyModeX on StudyMode {
  String get title {
    switch (this) {
      case StudyMode.viewAll:
        return 'Ver todas';
      case StudyMode.groupsOf10:
        return 'Grupos de 10';
      case StudyMode.groupsOf20:
        return 'Grupos de 20';
      case StudyMode.reviewIncorrect:
        return 'Repasar incorrectas primero';
      case StudyMode.adaptive:
        return 'Práctica adaptativa';
    }
  }

  String get description {
    switch (this) {
      case StudyMode.viewAll:
        return 'Estudia todas las flashcards de una vez.';
      case StudyMode.groupsOf10:
        return 'Repasa de 10 en 10, con un resumen al final de cada grupo.';
      case StudyMode.groupsOf20:
        return 'Igual que grupos de 10, en tandas de 20.';
      case StudyMode.reviewIncorrect:
        return 'Empieza por las que aún no dominas.';
      case StudyMode.adaptive:
        return 'Rondas de 20 centradas en lo que fallaste, hasta dominar el tema.';
    }
  }

  String descriptionFor({required bool entireTopic}) {
    switch (this) {
      case StudyMode.reviewIncorrect:
        return entireTopic
            ? 'Empieza por las que aún no dominas de todos los subtemas.'
            : 'Empieza por las que aún no dominas de este subtema.';
      case StudyMode.adaptive:
        return entireTopic
            ? 'Rondas de 20 centradas en lo que fallaste, hasta dominar el tema.'
            : 'Rondas de 20 centradas en lo que fallaste de este subtema.';
      default:
        return description;
    }
  }

  IconData get icon {
    switch (this) {
      case StudyMode.viewAll:
        return Icons.auto_stories_outlined;
      case StudyMode.groupsOf10:
        return Icons.view_agenda_outlined;
      case StudyMode.groupsOf20:
        return Icons.grid_view_outlined;
      case StudyMode.reviewIncorrect:
        return Icons.replay_outlined;
      case StudyMode.adaptive:
        return Icons.auto_awesome_outlined;
    }
  }

  int? get groupSize {
    switch (this) {
      case StudyMode.groupsOf10:
        return 10;
      case StudyMode.groupsOf20:
      case StudyMode.adaptive:
        return 20;
      default:
        return null;
    }
  }

  bool get usesRounds =>
      this == StudyMode.groupsOf10 ||
      this == StudyMode.groupsOf20 ||
      this == StudyMode.adaptive;
}

enum CardOrder {
  fixed,
  random,
}

extension CardOrderX on CardOrder {
  String get title {
    switch (this) {
      case CardOrder.fixed:
        return 'Orden fijo';
      case CardOrder.random:
        return 'Orden aleatorio';
    }
  }

  String get description {
    switch (this) {
      case CardOrder.fixed:
        return 'Las tarjetas aparecen en el orden original del tema.';
      case CardOrder.random:
        return 'Mezcla las tarjetas al empezar cada sesión.';
    }
  }

  IconData get icon {
    switch (this) {
      case CardOrder.fixed:
        return Icons.format_list_numbered_rounded;
      case CardOrder.random:
        return Icons.shuffle_rounded;
    }
  }
}
