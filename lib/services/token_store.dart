import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_session.dart';

class TokenStore {
  static const _keys = [
    'uid',
    'email',
    'idToken',
    'refreshToken',
    'expiresAt',
    'role',
    'displayName',
  ];

  Future<void> save(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final data = session.toStorage();
    for (final entry in data.entries) {
      await prefs.setString(entry.key, entry.value);
    }
  }

  Future<AuthSession?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');
    if (refreshToken == null || refreshToken.isEmpty) return null;
    return AuthSession.fromStorage({
      for (final key in _keys) key: prefs.getString(key) ?? '',
    });
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in _keys) {
      await prefs.remove(key);
    }
  }
}
