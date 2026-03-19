import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF040814);
  static const Color backgroundSoft = Color(0xFF091224);

  static const Color surface = Color(0xB2142033);
  static const Color surfaceAlt = Color(0xE0111B2D);

  static const Color primary = Color(0xFF6FA8FF);
  static const Color cyan = Color(0xFF3FD6FF);
  static const Color violet = Color(0xFF7B61FF);

  static const Color textPrimary = Color(0xFFF4F7FF);
  static const Color textMuted = Color(0xFFAEB9D6);
  static const Color textSoft = Color(0xFF7D8AA8);

  static const Color border = Color(0xFF223657);
  static const Color borderStrong = Color(0xFF31517E);

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: background,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      dividerColor: border,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: cyan,
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
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(
            color: border,
            width: 1,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: const Color(0x00000000),
        height: 82,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? textPrimary
                : textSoft,
            fontSize: 11.5,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w700,
            letterSpacing: -0.1,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? textPrimary
                : textSoft,
            size: 23,
          ),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt.withOpacity(0.92),
        hintStyle: const TextStyle(
          color: textSoft,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: textMuted,
          fontSize: 14,
        ),
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
          borderSide: const BorderSide(
            color: primary,
            width: 1.3,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textPrimary,
          disabledBackgroundColor: primary.withOpacity(0.35),
          disabledForegroundColor: textPrimary.withOpacity(0.7),
          minimumSize: const Size.fromHeight(58),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size.fromHeight(56),
          side: BorderSide(
            color: borderStrong.withOpacity(0.9),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF0C172B),
        contentTextStyle: const TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}