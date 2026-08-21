import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color teal = Color(0xFF2ECFB4);
  static const Color tealDeep = Color(0xFF1AAF98);
  static const Color blue = Color(0xFF5BA5D6);
  static const Color blueDeep = Color(0xFF4A90C4);

  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textMuted = Color(0xFF6B7280);

  static const Color border = Color(0xFFE6E8EC);
  static const Color inputFill = Color(0xFFF3F4F6);
  static const Color iconMuted = Color(0xFFA1A1AA);

  static const Color link = Color(0xFF3B82C4);
  static const Color navInactive = Color(0xFF9CA3AF);

  static const Color badgeAnswerBg = Color(0xFFD8F6EF);
  static const Color badgeAnswerFg = Color(0xFF1A9B8A);
  static const Color badgeResultsBg = Color(0xFFDCEAF7);
  static const Color badgeResultsFg = Color(0xFF3B82C4);
  static const Color feedbackBg = Color(0xFFE7F7F3);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF2ECFB4), Color(0xFF5BA5D6)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2ECFB4), Color(0xFF5BA5D6)],
  );
}
