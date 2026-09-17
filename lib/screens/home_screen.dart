import 'package:flutter/material.dart';

import '../api/api_exception.dart';
import '../models/in_progress_session.dart';
import '../models/recent_study.dart';
import '../models/study_insights.dart';
import '../models/study_mode.dart';
import '../models/study_session_config.dart';
import '../models/topic.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';
import '../widgets/ui_bits.dart';
import 'deck_detail_screen.dart';
import 'flashcard_session_screen.dart';
import 'study_mode_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeDashboard {
  const _HomeDashboard({
    required this.topics,
    this.insights,
  });

  final List<Topic> topics;
  final StudyInsights? insights;
}

class _HomeScreenState extends State<HomeScreen> {
  Future<_HomeDashboard>? _future;
  DateTime? _activityStamp;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final stamp = AppScope.of(context).activity.insightsAt;
    if (_future == null || stamp != _activityStamp) {
      _activityStamp = stamp;
      _future = _load();
    }
  }

  Future<_HomeDashboard> _load() async {
    final content = AppScope.of(context).content;
    final topics = await content.listTopics();
    final insights = await content.loadStudyInsights(topics);
    return _HomeDashboard(topics: topics, insights: insights);
  }

  void _openContinue({
    required List<Topic> topics,
    required InProgressSession? pending,
    required RecentStudy? lastStudy,
    required Topic? featured,
  }) {
    if (pending != null) {
      _resume(pending);
      return;
    }
    if (lastStudy != null) {
      final deck = topics.where((topic) => topic.id == lastStudy.deckId);
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => StudyModeScreen(
            deck: deck.isEmpty ? lastStudy.toDeck() : deck.first,
            subtopic: lastStudy.toSubtopic(),
          ),
        ),
      );
      return;
    }
    if (featured == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DeckDetailScreen(deck: featured),
      ),
    );
  }

  void _resume(InProgressSession session) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FlashcardSessionScreen(
          config: StudySessionConfig.fromInProgress(session),
        ),
      ),
    );
  }

  void _openRecent(RecentStudy item, List<Topic> topics) {
    final match = topics.where((topic) => topic.id == item.deckId);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StudyModeScreen(
          deck: match.isEmpty ? item.toDeck() : match.first,
          subtopic: item.toSubtopic(),
        ),
      ),
    );
  }

  void _openReview(StudyInsights insights) {
    if (insights.dueCards.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FlashcardSessionScreen(
          config: StudySessionConfig(
            deck: const Topic(
              id: 'review',
              title: 'Repaso',
              subtitle: 'Tarjetas que aún no dominas',
              icon: Icons.replay_outlined,
            ),
            mode: StudyMode.reviewIncorrect,
            presetCards: insights.dueCards,
            trackActivity: false,
          ),
        ),
      ),
    );
  }

  String _streakLabel(int streak) {
    if (streak <= 0) return 'Empieza hoy';
    if (streak == 1) return '1 día';
    return '$streak días';
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final session = controller.session;
    final activity = controller.activity;
    final greeting = session?.displayName?.isNotEmpty == true
        ? 'Hola, ${session!.displayName}'
        : 'Inicio';

    return FutureBuilder<_HomeDashboard>(
        future: _future,
        builder: (context, snapshot) {
          final data = snapshot.data;
          final topics = data?.topics ?? const <Topic>[];
          final featured = topics.isEmpty ? null : topics.first;
          final lastStudy = activity.lastStudy;
          final insights = data?.insights;
          final latestPending = activity.latestPending;
          final otherPending = activity.pending.length > 1
              ? activity.pending.sublist(1)
              : const <InProgressSession>[];

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Un espacio de calma para seguir avanzando.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 22),
              if (snapshot.connectionState == ConnectionState.waiting &&
                  data == null)
                const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.teal),
                  ),
                )
              else if (snapshot.hasError)
                Text(
                  snapshot.error is ApiException
                      ? (snapshot.error! as ApiException).message
                      : 'No se pudo cargar el contenido.',
                  style: const TextStyle(color: AppColors.textMuted),
                )
              else ...[
                _ContinueCard(
                  pending: latestPending,
                  lastStudy: lastStudy,
                  featured: featured,
                  onStudy: () => _openContinue(
                    topics: topics,
                    pending: latestPending,
                    lastStudy: lastStudy,
                    featured: featured,
                  ),
                ),
                if (otherPending.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  const Text(
                    'En curso',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final session in otherPending) ...[
                    _PendingSessionCard(
                      session: session,
                      onTap: () => _resume(session),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
                if (insights != null) ...[
                  const SizedBox(height: 14),
                  _DueReviewCard(
                    count: insights.dueCount,
                    onTap: () => _openReview(insights),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          label: 'Dominio',
                          value: '${(insights.mastery * 100).round()}%',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          label: 'Progreso',
                          value: _streakLabel(activity.streak),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 14),
                  _MetricCard(
                    label: 'Progreso',
                    value: _streakLabel(activity.streak),
                  ),
                ],
                if (activity.recent.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  const Text(
                    'Temas recientes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 132,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: activity.recent.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final item = activity.recent[index];
                        final progress = insights?.progressFor(
                              categoryId: item.subtopicId,
                              deckId: item.deckId,
                              cardCount: item.subtopicId == null
                                  ? item.deckCardCount
                                  : item.subtopicCardCount,
                            ) ??
                            0;
                        return _RecentTopicCard(
                          item: item,
                          progress: progress,
                          onTap: () => _openRecent(item, topics),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ],
          );
        },
      );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.pending,
    required this.lastStudy,
    required this.featured,
    required this.onStudy,
  });

  final InProgressSession? pending;
  final RecentStudy? lastStudy;
  final Topic? featured;
  final VoidCallback onStudy;

  @override
  Widget build(BuildContext context) {
    if (pending == null && lastStudy == null && featured == null) {
      return const Text(
        'Aún no hay temas publicados.',
        style: TextStyle(color: AppColors.textMuted),
      );
    }

    final session = pending;
    final title = session?.headline ?? lastStudy?.headline ?? featured!.title;
    final subtitle = session != null
        ? '${session.mode.title} · ${session.progressLabel}'
        : lastStudy == null
            ? (featured!.subtitle.isEmpty
                ? 'Retoma este tema y sigue repasando.'
                : featured!.subtitle)
            : lastStudy!.subtopicTitle == null
                ? 'Retoma este tema y sigue repasando.'
                : 'Retoma este subtema y sigue repasando.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TagBadge(
            label: session != null ? 'EN CURSO' : 'CONTINUAR',
            background: Colors.white,
            foreground: AppColors.tealDeep,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.white,
            ),
          ),
          if (session != null) ...[
            const SizedBox(height: 14),
            ThinProgressBar(
              value: session.progress,
              height: 5,
              trackColor: Colors.white24,
              fillColor: Colors.white,
            ),
          ],
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 168,
              child: SecondaryButton(
                label: session != null ? 'Continuar' : 'Estudiar ahora',
                height: 44,
                background: Colors.white,
                borderColor: Colors.white,
                foreground: AppColors.tealDeep,
                onPressed: onStudy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingSessionCard extends StatelessWidget {
  const _PendingSessionCard({
    required this.session,
    required this.onTap,
  });

  final InProgressSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8F4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              session.mode.icon,
              color: AppColors.tealDeep,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.headline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${session.mode.title} · ${session.progressLabel}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                ThinProgressBar(
                  value: session.progress,
                  height: 5,
                  fillColor: AppColors.teal,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.iconMuted,
          ),
        ],
      ),
    );
  }
}

class _DueReviewCard extends StatelessWidget {
  const _DueReviewCard({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: count == 0 ? null : onTap,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8F4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.replay_outlined,
              color: AppColors.tealDeep,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Para repasar',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  count == 0
                      ? 'Nada pendiente por ahora'
                      : count == 1
                          ? '1 tarjeta por reforzar'
                          : '$count tarjetas por reforzar',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (count > 0)
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.iconMuted,
            ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.tealDeep,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTopicCard extends StatelessWidget {
  const _RecentTopicCard({
    required this.item,
    required this.progress,
    required this.onTap,
  });

  final RecentStudy item;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.shortTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            ThinProgressBar(
              value: progress,
              height: 5,
              fillColor: AppColors.teal,
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.tealDeep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
