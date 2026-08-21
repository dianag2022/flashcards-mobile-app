import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../models/auth_session.dart';
import '../services/auth_service.dart';
import '../services/content_service.dart';
import '../services/study_activity_store.dart';

class AppScope extends StatefulWidget {
  const AppScope({super.key, required this.child});

  final Widget child;

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_AppInherited>();
    assert(scope != null, 'AppScope not found');
    return scope!.controller;
  }

  @override
  State<AppScope> createState() => _AppScopeState();
}

class _AppScopeState extends State<AppScope> {
  late final AppController controller;

  @override
  void initState() {
    super.initState();
    final auth = AuthService();
    controller = AppController(
      auth: auth,
      content: ContentService(
        client: ApiClient(tokenProvider: auth.currentIdToken),
      ),
      activity: StudyActivityStore(),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AppInherited(
      controller: controller,
      child: widget.child,
    );
  }
}

class _AppInherited extends InheritedNotifier<AppController> {
  const _AppInherited({
    required this.controller,
    required super.child,
  }) : super(notifier: controller);

  final AppController controller;
}

class AppController extends ChangeNotifier {
  AppController({
    required AuthService auth,
    required ContentService content,
    required StudyActivityStore activity,
  })  : _auth = auth,
        _content = content,
        _activity = activity {
    _activity.addListener(notifyListeners);
  }

  final AuthService _auth;
  final ContentService _content;
  final StudyActivityStore _activity;

  AuthSession? get session => _auth.session;
  bool get isSignedIn => session != null;
  ContentService get content => _content;
  StudyActivityStore get activity => _activity;

  Future<void> restoreSession() async {
    await _auth.restore();
    await _activity.load(session?.uid);
    notifyListeners();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signIn(email: email, password: password);
    await _activity.load(session?.uid);
    notifyListeners();
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await _auth.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
    await _activity.load(session?.uid);
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on ApiException {
      await _auth.signOut(revoke: false);
    }
    await _activity.clearMemory();
    notifyListeners();
  }

  @override
  void dispose() {
    _activity.removeListener(notifyListeners);
    _activity.dispose();
    super.dispose();
  }
}
