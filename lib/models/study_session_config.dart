import 'flashcard.dart';
import 'in_progress_session.dart';
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
    this.order = CardOrder.fixed,
    this.resume = false,
    this.resumeIndex = 0,
    this.resumeKnownCount = 0,
    this.resumeMissed = const [],
  });

  final Topic deck;
  final Subtopic? subtopic;
  final StudyMode mode;
  final int roundIndex;
  final List<Flashcard>? presetCards;
  final List<Flashcard>? allCards;
  final bool trackActivity;
  final CardOrder order;
  final bool resume;
  final int resumeIndex;
  final int resumeKnownCount;
  final List<Flashcard> resumeMissed;

  String get title => subtopic?.title ?? deck.title;

  factory StudySessionConfig.fromInProgress(InProgressSession session) {
    return StudySessionConfig(
      deck: session.toDeck(),
      subtopic: session.toSubtopic(),
      mode: session.mode,
      order: session.order,
      roundIndex: session.roundIndex,
      presetCards: session.roundCards,
      allCards: session.allCards.isEmpty ? session.roundCards : session.allCards,
      resume: true,
      resumeIndex: session.cardIndex,
      resumeKnownCount: session.knownCount,
      resumeMissed: session.missedCards,
    );
  }

  StudySessionConfig copyWith({
    int? roundIndex,
    List<Flashcard>? presetCards,
    List<Flashcard>? allCards,
    bool? resume,
    int? resumeIndex,
    int? resumeKnownCount,
    List<Flashcard>? resumeMissed,
  }) {
    return StudySessionConfig(
      deck: deck,
      subtopic: subtopic,
      mode: mode,
      roundIndex: roundIndex ?? this.roundIndex,
      presetCards: presetCards ?? this.presetCards,
      allCards: allCards ?? this.allCards,
      trackActivity: trackActivity,
      order: order,
      resume: resume ?? false,
      resumeIndex: resumeIndex ?? 0,
      resumeKnownCount: resumeKnownCount ?? 0,
      resumeMissed: resumeMissed ?? const [],
    );
  }
}
