import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../models/auth_session.dart';
import 'token_store.dart';

class AuthService {
  AuthService({
    ApiClient? client,
    TokenStore? tokenStore,
  }) : _tokens = tokenStore ?? TokenStore() {
    _client = client ?? ApiClient(tokenProvider: currentIdToken);
  }

  late final ApiClient _client;
  final TokenStore _tokens;
  AuthSession? _session;

  AuthSession? get session => _session;

  Future<String?> currentIdToken() async {
    final session = _session;
    if (session == null) return null;
    if (!session.isExpired) return session.idToken;
    try {
      await refresh();
      return _session?.idToken;
    } on ApiException {
      return session.idToken;
    }
  }

  Future<AuthSession?> restore() async {
    final stored = await _tokens.read();
    if (stored == null) {
      _session = null;
      return null;
    }
    _session = stored;
    if (stored.isExpired) {
      try {
        return await refresh();
      } on ApiException {
        await signOut(revoke: false);
        return null;
      }
    }
    return stored;
  }

  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final json = await _client.post(
      '/api/auth/sign-in',
      body: {'email': email.trim(), 'password': password},
    );
    return _persist(AuthSession.fromJson(json));
  }

  Future<AuthSession> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final json = await _client.post(
      '/api/auth/sign-up',
      body: {'email': email.trim(), 'password': password},
    );
    return _persist(
      AuthSession.fromJson(json, displayName: displayName),
    );
  }

  Future<AuthSession> refresh() async {
    final current = _session;
    if (current == null || current.refreshToken.isEmpty) {
      throw const ApiException(message: 'No hay sesión activa.');
    }
    final json = await _client.post(
      '/api/auth/refresh-token',
      body: {'refreshToken': current.refreshToken},
    );
    return _persist(AuthSession.fromJson(json, previous: current));
  }

  Future<void> signOut({bool revoke = true}) async {
    final token = _session?.idToken;
    if (revoke && token != null && token.isNotEmpty) {
      try {
        await _client.post('/api/auth/sign-out', auth: true);
      } catch (_) {}
    }
    _session = null;
    await _tokens.clear();
  }

  Future<AuthSession> _persist(AuthSession session) async {
    _session = session;
    await _tokens.save(session);
    return session;
  }
}
