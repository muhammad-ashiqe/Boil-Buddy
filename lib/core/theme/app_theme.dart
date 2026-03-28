import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── New Palette: Deep Maroon / Red / Cream ─────────────────────────────
  static const Color darkMaroon   = Color(0xFF2D0000); // darkest — headeraccents
  static const Color deepRed      = Color(0xFF8B0000); // primary actions / buttons
  static const Color brightRed    = Color(0xFFA80000); // interactive highlights
  static const Color cream        = Color(0xFFFAEBD7); // background / softWhite

  // ── Semantic aliases (used across other files) ─────────────────────────
  /// Background colour (replaces softWhite)
  static const Color softWhite    = cream;
  /// Primary brand colour (replaces kitchenBlue)
  static const Color kitchenBlue  = brightRed;
  /// Deeper brand colour (replaces deepBlue)
  static const Color deepBlue     = deepRed;
  /// Warm accent (replaces warmYellow — now a lighter red-tinted cream)
  static const Color warmYellow   = Color(0xFFD4A090);
  /// Egg shell tone
  static const Color eggShell     = Color(0xFFFFF0E8);
  /// Soft bubble tint (replaces bubbleBlue)
  static const Color bubbleBlue   = Color(0xFFEAB8B8);
  /// Dividers / borders
  static const Color softGrey     = Color(0xFFE0D5D5);
  /// Primary text
  static const Color textDark     = Color(0xFF1A0000);
  /// Secondary text
  static const Color textMedium   = Color(0xFF6B3030);
  /// Success state (soft green kept for contrast)
  static const Color successGreen = Color(0xFF4CAF50);
  /// Heat / urgency accent
  static const Color accentOrange = Color(0xFFCC3300);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: deepRed,
        brightness: Brightness.light,
        primary: deepRed,
        secondary: brightRed,
        surface: cream,
        background: cream,
      ),
      scaffoldBackgroundColor: cream,
      textTheme: GoogleFonts.nunitoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w800,
            color: darkMaroon,
            letterSpacing: -2,
          ),
          displayMedium: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: darkMaroon,
          ),
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: darkMaroon,
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: darkMaroon,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: darkMaroon,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: textDark,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textMedium,
          ),
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deepRed,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: deepRed.withOpacity(0.4),
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
        color: Colors.white,
        elevation: 4,
        shadowColor: darkMaroon.withOpacity(0.10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: darkMaroon),
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: darkMaroon,
        ),
      ),
      iconTheme: const IconThemeData(color: darkMaroon, size: 24),
    );
  }
}
