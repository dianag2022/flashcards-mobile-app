import 'package:flutter/material.dart';

import '../api/api_exception.dart';
import '../models/subtopic.dart';
import '../models/topic.dart';
import '../services/content_service.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../widgets/topic_card.dart';
import '../widgets/ui_bits.dart';
import 'study_mode_screen.dart';

class DeckDetailScreen extends StatefulWidget {
  const DeckDetailScreen({super.key, required this.deck});

  final Topic deck;

  @override
  State<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends State<DeckDetailScreen> {
  Future<List<Subtopic>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= AppScope.of(context).content.listSubtopics(widget.deck.id);
  }

  void _reload() {
    setState(() {
      _future = AppScope.of(context).content.listSubtopics(widget.deck.id);
    });
  }

  void _openMode({Subtopic? subtopic}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StudyModeScreen(
          deck: widget.deck,
          subtopic: subtopic,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<List<Subtopic>>(
          future: _future,
          builder: (context, snapshot) {
            final subtopics = snapshot.data ?? const <Subtopic>[];

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: CircularIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.deck.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.deck.subtitle.isEmpty
                      ? 'Elige un subtema o estudia todo el contenido.'
                      : widget.deck.subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 22),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.teal),
                    ),
                  )
                else if (snapshot.hasError)
                  _Message(
                    message: snapshot.error is ApiException
                        ? (snapshot.error! as ApiException).message
                        : 'No se pudieron cargar los subtemas.',
                    onRetry: _reload,
                  )
                else if (subtopics.isEmpty) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TagBadge(label: 'TEMA COMPLETO'),
                        const SizedBox(height: 12),
                        Text(
                          widget.deck.cardCount == 1
                              ? '1 flashcard publicada'
                              : '${widget.deck.cardCount} flashcards publicadas',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Este tema no tiene subtemas. Puedes estudiarlo completo.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _StudyAllCard(onTap: () => _openMode()),
                ] else ...[
                  _StudyAllCard(onTap: () => _openMode()),
                  const SizedBox(height: 20),
                  const Text(
                    'Subtemas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < subtopics.length; i++) ...[
                    TopicCard(
                      topic: subtopics[i].asTopic(
                        icon: ContentService.icons[i % ContentService.icons.length],
                      ),
                      onTap: () => _openMode(subtopic: subtopics[i]),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StudyAllCard extends StatelessWidget {
  const _StudyAllCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: const Row(
        children: [
          Icon(Icons.layers_outlined, color: AppColors.tealDeep),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estudiar todo el tema',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Incluye todas las flashcards publicadas.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.iconMuted),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMuted),
        ),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
      ],
    );
  }
}
