import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF060B14);
  static const Color surface = Color(0xCC0B1424);
  static const Color surfaceAlt = Color(0xB3142034);

  static const Color primary = Color(0xFF2F6BFF);
  static const Color cyan = Color(0xFF38D4FF);
  static const Color violet = Color(0xFF7A63FF);

  static const Color textPrimary = Color(0xFFF5F7FB);
  static const Color textSoft = Color(0xFFB8C2D9);
  static const Color textMuted = Color(0xFF8B96AE);

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);

    final colorScheme = ColorScheme.dark(
      primary: primary,
      secondary: cyan,
      tertiary: violet,
      surface: background,
    );

    return base.copyWith(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: colorScheme,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      dividerColor: Colors.white.withValues(alpha: 0.08),
      textTheme: _textTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF101A2D),
        contentTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(
          color: textSoft,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: textMuted.withValues(alpha: 0.92),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        prefixStyle: const TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: cyan.withValues(alpha: 0.70),
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.redAccent.withValues(alpha: 0.75),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.redAccent.withValues(alpha: 0.9),
            width: 1.2,
          ),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: const TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(
            const Color(0xFF0B1424),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primary.withValues(alpha: 0.45),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.8),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.10),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? textPrimary : textMuted,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: cyan,
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        color: textPrimary,
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        color: textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        color: textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.45,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      bodySmall: base.bodySmall?.copyWith(
        color: textSoft,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}