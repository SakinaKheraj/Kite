import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF151A24);
  static const Color surfaceLight = Color(0xFF1E2536);

  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryVariant = Color(0xFF8B5CF6); // Purple
  static const Color secondary = Color(0xFF10B981); // Emerald

  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  static const Color border = Color(0xFF2A3447);
  static const Color borderFocus = Color(0xFF6366F1);

  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryVariant],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
