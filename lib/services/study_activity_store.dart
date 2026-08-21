import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recent_study.dart';
import '../models/subtopic.dart';
import '../models/topic.dart';

class StudyActivityStore extends ChangeNotifier {
  RecentStudy? lastStudy;
  List<RecentStudy> recent = const [];
  int streak = 0;
  DateTime? updatedAt;

  String? _uid;

  String get _lastKey => 'study.$_uid.last';
  String get _recentKey => 'study.$_uid.recent';
  String get _dateKey => 'study.$_uid.lastDate';
  String get _streakKey => 'study.$_uid.streak';

  Future<void> load(String? uid) async {
    _uid = uid;
    lastStudy = null;
    recent = const [];
    streak = 0;
    if (uid == null || uid.isEmpty) {
      updatedAt = DateTime.now();
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

    updatedAt = DateTime.now();
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
    notifyListeners();
  }

  Future<void> clearMemory() async {
    _uid = null;
    lastStudy = null;
    recent = const [];
    streak = 0;
    updatedAt = DateTime.now();
    notifyListeners();
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static int _dayGap(DateTime from, DateTime to) {
    return _dateOnly(to).difference(_dateOnly(from)).inDays;
  }
}
