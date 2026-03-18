import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF0B1020);
  static const Color surface = Color(0xFF121A2B);
  static const Color surfaceAlt = Color(0xFF182235);
  static const Color primary = Color(0xFF7C9BFF);
  static const Color secondary = Color(0xFF4BE3C2);
  static const Color textPrimary = Color(0xFFF3F6FF);
  static const Color textMuted = Color(0xFF98A4C0);
  static const Color border = Color(0xFF26324A);

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? textPrimary
                : textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        hintStyle: const TextStyle(color: textMuted),
        labelStyle: const TextStyle(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: background,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      dividerColor: border,
    );
  }
}