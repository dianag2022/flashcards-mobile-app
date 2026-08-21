import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/app_logo.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';

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
    Future<void>.delayed(const Duration(milliseconds: 2200), _goToLogin);
  }

  void _goToLogin() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _goToLogin,
        behavior: HitTestBehavior.opaque,
        child: const DecoratedBox(
          decoration: BoxDecoration(gradient: AppColors.splashGradient),
          child: SizedBox.expand(
            child: Center(
              child: AppLogo(white: true, width: 236),
            ),
          ),
        ),
      ),
    );
  }
}
