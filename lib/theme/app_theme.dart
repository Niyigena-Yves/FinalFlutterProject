import 'package:flutter/material.dart';

/// Central design tokens. Keeping these in one place means every screen
/// pulls from the same palette/spacing scale instead of hardcoding values —
/// this is what lets the whole app read as intentionally designed rather
/// than a generic CRUD scaffold.
class AppColors {
  static const primary = Color(0xFF6C4CF1); // indigo/purple
  static const primaryDark = Color(0xFF4E31D9);
  static const accentPink = Color(0xFFEE86C6);
  static const accentOrange = Color(0xFFFFB199);
  static const background = Color(0xFFF7F7FB);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF7A7A8C);
  static const success = Color(0xFF34C471);
  static const warning = Color(0xFFF5A623);
  static const danger = Color(0xFFE0446B);

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accentPink, accentOrange],
  );
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        background: AppColors.background,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF0EEFB),
        labelStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),
    );
  }
}
