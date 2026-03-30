import 'package:flutter/material.dart';

/// Holds all color tokens for a single app theme.
class AppColorScheme {
  final String id;
  final String name;
  final String emoji;
  final Color primary;      // main action color (buttons, badges, accents)
  final Color background;   // scaffold / card background
  final Color surface;      // card / container surface
  final Color textDark;     // primary text
  final Color textMedium;   // secondary text
  final Color accent;       // heat/urgency accent
  final Color softBorder;   // dividers, borders
  final Brightness brightness;

  const AppColorScheme({
    required this.id,
    required this.name,
    required this.emoji,
    required this.primary,
    required this.background,
    required this.surface,
    required this.textDark,
    required this.textMedium,
    required this.accent,
    required this.softBorder,
    this.brightness = Brightness.light,
  });

  AppColorScheme copyWith({
    String? id,
    String? name,
    String? emoji,
    Color? primary,
    Color? background,
    Color? surface,
    Color? textDark,
    Color? textMedium,
    Color? accent,
    Color? softBorder,
    Brightness? brightness,
  }) {
    return AppColorScheme(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      primary: primary ?? this.primary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textDark: textDark ?? this.textDark,
      textMedium: textMedium ?? this.textMedium,
      accent: accent ?? this.accent,
      softBorder: softBorder ?? this.softBorder,
      brightness: brightness ?? this.brightness,
    );
  }

  // ── 10 Preset Themes ──────────────────────────────────────────────────────

  static const List<AppColorScheme> presets = [
    _classicRed,
    _midnightNavy,
    _forestGreen,
    _sunsetOrange,
    _royalPurple,
    _oceanTeal,
    _roseGold,
    _candyPink,
    _goldenHour,
  ];

  // 1. Classic Red (default)
  static const AppColorScheme _classicRed = AppColorScheme(
    id: 'classic_red',
    name: 'Classic Red',
    emoji: '🍳',
    primary: Color(0xFF8B0000),
    background: Color(0xFFFAEBD7),
    surface: Color(0xFFFFFFFF),
    textDark: Color(0xFF1A0000),
    textMedium: Color(0xFF6B3030),
    accent: Color(0xFFCC3300),
    softBorder: Color(0xFFE0D5D5),
  );

  // 2. Midnight Navy
  static const AppColorScheme _midnightNavy = AppColorScheme(
    id: 'midnight_navy',
    name: 'Midnight Navy',
    emoji: '🌙',
    primary: Color(0xFF1A237E),
    background: Color(0xFFE8EAF6),
    surface: Color(0xFFFFFFFF),
    textDark: Color(0xFF0D1333),
    textMedium: Color(0xFF3949AB),
    accent: Color(0xFF3F51B5),
    softBorder: Color(0xFFD1D8F5),
  );

  // 3. Forest Green
  static const AppColorScheme _forestGreen = AppColorScheme(
    id: 'forest_green',
    name: 'Forest Green',
    emoji: '🌿',
    primary: Color(0xFF1B5E20),
    background: Color(0xFFE8F5E9),
    surface: Color(0xFFFFFFFF),
    textDark: Color(0xFF0A2E0D),
    textMedium: Color(0xFF388E3C),
    accent: Color(0xFF2E7D32),
    softBorder: Color(0xFFC8E6C9),
  );

  // 4. Sunset Orange
  static const AppColorScheme _sunsetOrange = AppColorScheme(
    id: 'sunset_orange',
    name: 'Sunset Orange',
    emoji: '🌅',
    primary: Color(0xFFBF360C),
    background: Color(0xFFFFF3E0),
    surface: Color(0xFFFFFFFF),
    textDark: Color(0xFF3E1400),
    textMedium: Color(0xFFE64A19),
    accent: Color(0xFFFF5722),
    softBorder: Color(0xFFFFCCBC),
  );

  // 5. Royal Purple
  static const AppColorScheme _royalPurple = AppColorScheme(
    id: 'royal_purple',
    name: 'Royal Purple',
    emoji: '👑',
    primary: Color(0xFF4A148C),
    background: Color(0xFFF3E5F5),
    surface: Color(0xFFFFFFFF),
    textDark: Color(0xFF1A0033),
    textMedium: Color(0xFF7B1FA2),
    accent: Color(0xFF6A1B9A),
    softBorder: Color(0xFFE1BEE7),
  );

  // 6. Ocean Teal
  static const AppColorScheme _oceanTeal = AppColorScheme(
    id: 'ocean_teal',
    name: 'Ocean Teal',
    emoji: '🌊',
    primary: Color(0xFF004D40),
    background: Color(0xFFE0F2F1),
    surface: Color(0xFFFFFFFF),
    textDark: Color(0xFF001A18),
    textMedium: Color(0xFF00796B),
    accent: Color(0xFF00897B),
    softBorder: Color(0xFFB2DFDB),
  );

  // 7. Rose Gold
  static const AppColorScheme _roseGold = AppColorScheme(
    id: 'rose_gold',
    name: 'Rose Gold',
    emoji: '🌸',
    primary: Color(0xFFA0495A),
    background: Color(0xFFFCE4EC),
    surface: Color(0xFFFFFFFF),
    textDark: Color(0xFF3D0020),
    textMedium: Color(0xFFC2185B),
    accent: Color(0xFFAD1457),
    softBorder: Color(0xFFF8BBD9),
  );

  // 8. Charcoal Dark
  static const AppColorScheme _charcoalDark = AppColorScheme(
    id: 'charcoal_dark',
    name: 'Charcoal Dark',
    emoji: '🖤',
    primary: Color(0xFFB0BEC5),
    background: Color(0xFF1C1C1E),
    surface: Color(0xFF2C2C2E),
    textDark: Color(0xFFECEFF1),
    textMedium: Color(0xFF90A4AE),
    accent: Color(0xFF78909C),
    softBorder: Color(0xFF37474F),
    brightness: Brightness.dark,
  );

  // 9. Candy Pink
  static const AppColorScheme _candyPink = AppColorScheme(
    id: 'candy_pink',
    name: 'Candy Pink',
    emoji: '🍬',
    primary: Color(0xFFC2185B),
    background: Color(0xFFFFF0F5),
    surface: Color(0xFFFFFFFF),
    textDark: Color(0xFF3D0020),
    textMedium: Color(0xFFE91E63),
    accent: Color(0xFFD81B60),
    softBorder: Color(0xFFFCE4EC),
  );

  // 10. Golden Hour
  static const AppColorScheme _goldenHour = AppColorScheme(
    id: 'golden_hour',
    name: 'Golden Hour',
    emoji: '✨',
    primary: Color(0xFFF57F17),
    background: Color(0xFFFFFDE7),
    surface: Color(0xFFFFFFFF),
    textDark: Color(0xFF3E2000),
    textMedium: Color(0xFFF9A825),
    accent: Color(0xFFFFA000),
    softBorder: Color(0xFFFFF9C4),
  );

  // ── Curated palette for Custom Theme picker ────────────────────────────────
  // 40 beautiful colors in 8 rows of 5
  static const List<Color> customPalette = [
    // Reds & Pinks
    Color(0xFF8B0000), Color(0xFFC62828), Color(0xFFE53935),
    Color(0xFFF48FB1), Color(0xFFF06292),
    // Purples
    Color(0xFF4A148C), Color(0xFF6A1B9A), Color(0xFF7B1FA2),
    Color(0xFF9C27B0), Color(0xFFCE93D8),
    // Blues
    Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1E88E5),
    Color(0xFF42A5F5), Color(0xFF90CAF9),
    // Teals & Greens
    Color(0xFF004D40), Color(0xFF00695C), Color(0xFF00897B),
    Color(0xFF26A69A), Color(0xFF80CBC4),
    // Greens
    Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C),
    Color(0xFF66BB6A), Color(0xFFA5D6A7),
    // Oranges & Yellows
    Color(0xFFE65100), Color(0xFFBF360C), Color(0xFFF57C00),
    Color(0xFFFFA000), Color(0xFFFDD835),
    // Rose Golds & Browns
    Color(0xFFA0495A), Color(0xFFC2185B), Color(0xFFA1887F),
    Color(0xFF795548), Color(0xFF5D4037),
    // Neutrals & Darks
    Color(0xFF212121), Color(0xFF37474F), Color(0xFF546E7A),
    Color(0xFF78909C), Color(0xFFB0BEC5),
  ];
}
