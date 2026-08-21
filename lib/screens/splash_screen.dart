import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../widgets/app_logo.dart';
import 'login_screen.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var _navigated = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    final delay = Future<void>.delayed(const Duration(milliseconds: 1800));
    await AppScope.of(context).restoreSession();
    await delay;
    if (!mounted || _navigated) return;
    _navigated = true;

    final signedIn = AppScope.of(context).isSignedIn;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) =>
            signedIn ? const MainShell() : const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: AppColors.splashGradient),
        child: SizedBox.expand(
          child: Center(
            child: AppLogo(white: true, width: 236),
          ),
        ),
      ),
    );
  }
}
