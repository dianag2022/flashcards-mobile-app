import 'package:flutter/material.dart';

import '../api/api_exception.dart';
import '../models/topic.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../widgets/topic_card.dart';
import 'deck_detail_screen.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  Future<List<Topic>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= AppScope.of(context).content.listTopics();
  }

  void _reload() {
    setState(() {
      _future = AppScope.of(context).content.listTopics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Topic>>(
        future: _future,
        builder: (context, snapshot) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            children: [
              const Text(
                'Selecciona un tema',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '¿Qué área de la psicología estudiarás hoy?',
                style: TextStyle(
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
                _StatusMessage(
                  message: snapshot.error is ApiException
                      ? (snapshot.error! as ApiException).message
                      : 'No se pudieron cargar los temas.',
                  onRetry: _reload,
                )
              else if ((snapshot.data ?? const <Topic>[]).isEmpty)
                const _StatusMessage(
                  message: 'Aún no hay temas publicados.',
                )
              else
                for (final topic in snapshot.data!) ...[
                  TopicCard(
                    topic: topic,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => DeckDetailScreen(deck: topic),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
            ],
          );
        },
      );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 36),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ],
      ),
    );
  }
}
