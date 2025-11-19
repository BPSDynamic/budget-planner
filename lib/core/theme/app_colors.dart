import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF8B5CF6); // Lighter Purple
  static const Color primaryDark = Color(0xFF6D28D9); // Darker Purple
  static const Color secondary = Color(0xFF10B981); // Green for income
  static const Color backgroundLight = Color(0xFFF3F4F6);
  static const Color surfaceLight = Colors.white;
  static const Color textLight = Color(0xFF1F2937);
  static const Color textSecondaryLight = Color(0xFF6B7280);

  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color textDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFC4B5FD), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
