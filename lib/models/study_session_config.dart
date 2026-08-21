import 'flashcard.dart';
import 'study_mode.dart';
import 'subtopic.dart';
import 'topic.dart';

class StudySessionConfig {
  const StudySessionConfig({
    required this.deck,
    required this.mode,
    this.subtopic,
    this.roundIndex = 0,
    this.presetCards,
    this.allCards,
    this.trackActivity = true,
  });

  final Topic deck;
  final Subtopic? subtopic;
  final StudyMode mode;
  final int roundIndex;
  final List<Flashcard>? presetCards;
  final List<Flashcard>? allCards;
  final bool trackActivity;

  String get title => subtopic?.title ?? deck.title;

  StudySessionConfig copyWith({
    int? roundIndex,
    List<Flashcard>? presetCards,
    List<Flashcard>? allCards,
  }) {
    return StudySessionConfig(
      deck: deck,
      subtopic: subtopic,
      mode: mode,
      roundIndex: roundIndex ?? this.roundIndex,
      presetCards: presetCards ?? this.presetCards,
      allCards: allCards ?? this.allCards,
      trackActivity: trackActivity,
    );
  }
}
