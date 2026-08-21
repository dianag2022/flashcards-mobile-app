class AuthSession {
  const AuthSession({
    required this.uid,
    required this.email,
    required this.idToken,
    required this.refreshToken,
    required this.expiresAt,
    this.role,
    this.displayName,
  });

  final String uid;
  final String email;
  final String idToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String? role;
  final String? displayName;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  AuthSession copyWith({
    String? uid,
    String? email,
    String? idToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? role,
    String? displayName,
  }) {
    return AuthSession(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      idToken: idToken ?? this.idToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
    );
  }

  factory AuthSession.fromJson(
    Map<String, dynamic> json, {
    String? displayName,
    AuthSession? previous,
  }) {
    final expiresIn = int.tryParse('${json['expiresIn'] ?? 3600}') ?? 3600;
    return AuthSession(
      uid: json['uid'] as String? ?? previous?.uid ?? '',
      email: json['email'] as String? ?? previous?.email ?? '',
      idToken: json['idToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? previous?.refreshToken ?? '',
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn - 30)),
      role: json['role'] as String? ?? previous?.role,
      displayName: displayName ?? previous?.displayName,
    );
  }

  Map<String, String> toStorage() {
    return {
      'uid': uid,
      'email': email,
      'idToken': idToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
      'role': role ?? '',
      'displayName': displayName ?? '',
    };
  }

  factory AuthSession.fromStorage(Map<String, String> data) {
    return AuthSession(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      idToken: data['idToken'] ?? '',
      refreshToken: data['refreshToken'] ?? '',
      expiresAt: DateTime.tryParse(data['expiresAt'] ?? '') ?? DateTime.now(),
      role: (data['role'] ?? '').isEmpty ? null : data['role'],
      displayName:
          (data['displayName'] ?? '').isEmpty ? null : data['displayName'],
    );
  }
}
