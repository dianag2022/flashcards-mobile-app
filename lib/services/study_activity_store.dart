import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/in_progress_session.dart';
import '../models/recent_study.dart';
import '../models/study_mode.dart';
import '../models/subtopic.dart';
import '../models/topic.dart';

class StudyActivityStore extends ChangeNotifier {
  RecentStudy? lastStudy;
  List<RecentStudy> recent = const [];
  List<InProgressSession> pending = const [];
  int streak = 0;
  DateTime? updatedAt;
  DateTime? insightsAt;

  String? _uid;

  static const _maxPending = 8;

  String get _lastKey => 'study.$_uid.last';
  String get _recentKey => 'study.$_uid.recent';
  String get _pendingKey => 'study.$_uid.pending';
  String get _dateKey => 'study.$_uid.lastDate';
  String get _streakKey => 'study.$_uid.streak';

  InProgressSession? get latestPending =>
      pending.isEmpty ? null : pending.first;

  Future<void> load(String? uid) async {
    _uid = uid;
    lastStudy = null;
    recent = const [];
    pending = const [];
    streak = 0;
    if (uid == null || uid.isEmpty) {
      updatedAt = DateTime.now();
      insightsAt = updatedAt;
      notifyListeners();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final lastRaw = prefs.getString(_lastKey);
    if (lastRaw != null && lastRaw.isNotEmpty) {
      final decoded = jsonDecode(lastRaw);
      if (decoded is Map<String, dynamic>) {
        lastStudy = RecentStudy.fromJson(decoded);
      }
    }

    final recentRaw = prefs.getString(_recentKey);
    if (recentRaw != null && recentRaw.isNotEmpty) {
      final decoded = jsonDecode(recentRaw);
      if (decoded is List) {
        recent = [
          for (final item in decoded)
            if (item is Map<String, dynamic>) RecentStudy.fromJson(item),
        ];
      }
    }

    streak = prefs.getInt(_streakKey) ?? 0;
    final lastDate = DateTime.tryParse(prefs.getString(_dateKey) ?? '');
    if (lastDate != null && _dayGap(lastDate, DateTime.now()) > 1) {
      streak = 0;
      await prefs.setInt(_streakKey, 0);
    }

    final pendingRaw = prefs.getString(_pendingKey);
    if (pendingRaw != null && pendingRaw.isNotEmpty) {
      final decoded = jsonDecode(pendingRaw);
      if (decoded is List) {
        pending = [
          for (final item in decoded)
            if (item is Map<String, dynamic>) InProgressSession.fromJson(item),
        ];
      }
    }

    updatedAt = DateTime.now();
    insightsAt = updatedAt;
    notifyListeners();
  }

  Future<void> record({
    required Topic deck,
    Subtopic? subtopic,
  }) async {
    if (_uid == null || _uid!.isEmpty) return;

    final entry = RecentStudy.fromSession(deck: deck, subtopic: subtopic);
    lastStudy = entry;
    recent = [
      entry,
      ...recent.where((item) => item.key != entry.key),
    ].take(3).toList();

    final prefs = await SharedPreferences.getInstance();
    final today = _dateOnly(DateTime.now());
    final lastDate = DateTime.tryParse(prefs.getString(_dateKey) ?? '');
    if (lastDate == null) {
      streak = 1;
    } else {
      final gap = _dayGap(lastDate, today);
      if (gap == 0) {
        if (streak <= 0) streak = 1;
      } else if (gap == 1) {
        streak += 1;
      } else {
        streak = 1;
      }
    }

    await prefs.setString(_lastKey, jsonEncode(entry.toJson()));
    await prefs.setString(
      _recentKey,
      jsonEncode([for (final item in recent) item.toJson()]),
    );
    await prefs.setString(_dateKey, _dateOnly(today).toIso8601String());
    await prefs.setInt(_streakKey, streak);

    updatedAt = DateTime.now();
    insightsAt = updatedAt;
    notifyListeners();
  }

  Future<void> saveInProgress(InProgressSession session) async {
    if (_uid == null || _uid!.isEmpty) return;
    if (session.roundCards.isEmpty) return;

    final saved = InProgressSession(
      scope: session.scope,
      mode: session.mode,
      order: session.order,
      roundIndex: session.roundIndex,
      cardIndex: session.cardIndex.clamp(0, session.roundCards.length - 1),
      knownCount: session.knownCount,
      roundCards: session.roundCards,
      allCards: session.allCards,
      missedCards: session.missedCards,
      updatedAt: DateTime.now(),
    );

    pending = [
      saved,
      ...pending.where((item) => item.key != saved.key),
    ].take(_maxPending).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _pendingKey,
      jsonEncode([for (final item in pending) item.toJson()]),
    );
    updatedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> completeSession({
    required Topic deck,
    Subtopic? subtopic,
    required StudyMode mode,
  }) async {
    if (_uid == null || _uid!.isEmpty) return;
    final key =
        '${RecentStudy.fromSession(deck: deck, subtopic: subtopic).key}:${mode.name}';
    pending = [for (final item in pending) if (item.key != key) item];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _pendingKey,
      jsonEncode([for (final item in pending) item.toJson()]),
    );
    updatedAt = DateTime.now();
    insightsAt = updatedAt;
    notifyListeners();
  }

  Future<void> clearMemory() async {
    _uid = null;
    lastStudy = null;
    recent = const [];
    pending = const [];
    streak = 0;
    updatedAt = DateTime.now();
    insightsAt = updatedAt;
    notifyListeners();
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static int _dayGap(DateTime from, DateTime to) {
    return _dateOnly(to).difference(_dateOnly(from)).inDays;
  }
}
