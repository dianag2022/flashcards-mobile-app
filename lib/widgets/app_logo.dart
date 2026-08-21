import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.white = false,
    this.width = 180,
  });

  final bool white;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      white ? 'assets/logos/logo_white.svg' : 'assets/logos/logo_full.svg',
      width: width,
      fit: BoxFit.contain,
    );
  }
}
