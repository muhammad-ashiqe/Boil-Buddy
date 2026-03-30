import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color_scheme.dart';

class AppTheme {
  // ── Static constants (Classic Red — default) ────────────────────────────
  static const Color darkMaroon   = Color(0xFF2D0000);
  static const Color deepRed      = Color(0xFF8B0000);
  static const Color brightRed    = Color(0xFFA80000);
  static const Color cream        = Color(0xFFFAEBD7);

  static const Color softWhite    = cream;
  static const Color kitchenBlue  = brightRed;
  static const Color deepBlue     = deepRed;
  static const Color warmYellow   = Color(0xFFD4A090);
  static const Color eggShell     = Color(0xFFFFF0E8);
  static const Color bubbleBlue   = Color(0xFFEAB8B8);
  static const Color softGrey     = Color(0xFFE0D5D5);
  static const Color textDark     = Color(0xFF1A0000);
  static const Color textMedium   = Color(0xFF6B3030);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color accentOrange = Color(0xFFCC3300);

  // ── Classic Red fallback (used before theme provider is ready) ──────────
  static ThemeData get lightTheme =>
      buildTheme(AppColorScheme.presets.first);

  // ── Dynamic theme factory ───────────────────────────────────────────────
  static ThemeData buildTheme(AppColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: scheme.primary,
      brightness: scheme.brightness,
      primary: scheme.primary,
      secondary: scheme.accent,
      surface: scheme.surface,
      background: scheme.background,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scheme.background,
      textTheme: GoogleFonts.nunitoTextTheme(
        TextTheme(
          displayLarge: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w800,
            color: scheme.textDark,
            letterSpacing: -2,
          ),
          displayMedium: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: scheme.textDark,
          ),
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: scheme.textDark,
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: scheme.textDark,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: scheme.textDark,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: scheme.textDark,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: scheme.textMedium,
          ),
          labelLarge: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: scheme.primary.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: scheme.surface,
        elevation: 4,
        shadowColor: scheme.textDark.withOpacity(0.10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: scheme.textDark),
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: scheme.textDark,
        ),
      ),
      iconTheme: IconThemeData(color: isDark ? scheme.textDark : darkMaroon, size: 24),
      dialogTheme: DialogTheme(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}

