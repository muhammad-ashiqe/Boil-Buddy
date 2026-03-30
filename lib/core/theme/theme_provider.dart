import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/hive_service.dart';
import 'app_color_scheme.dart';

class ThemeNotifier extends StateNotifier<AppColorScheme> {
  ThemeNotifier() : super(_loadSavedTheme());

  static AppColorScheme _loadSavedTheme() {
    final id = HiveService.themeId;

    // Check if it's the custom theme
    if (id == 'custom') {
      final p  = HiveService.customPrimary;
      final bg = HiveService.customBackground;
      final ac = HiveService.customAccent;
      if (p != null && bg != null && ac != null) {
        return _buildCustomScheme(
          Color(p),
          Color(bg),
          Color(ac),
        );
      }
    }

    // Find matching preset
    return AppColorScheme.presets.firstWhere(
      (t) => t.id == id,
      orElse: () => AppColorScheme.presets.first,
    );
  }

  /// Switch to a preset theme.
  Future<void> setTheme(AppColorScheme scheme) async {
    await HiveService.setThemeId(scheme.id);
    state = scheme;
  }

  /// Save and apply a custom theme built from palette swatches.
  Future<void> setCustomTheme({
    required Color primary,
    required Color background,
    required Color accent,
  }) async {
    await HiveService.setThemeId('custom');
    await HiveService.setCustomThemeColors(
      primary.value,
      background.value,
      accent.value,
    );
    state = _buildCustomScheme(primary, background, accent);
  }

  static AppColorScheme _buildCustomScheme(
      Color primary, Color background, Color accent) {
    // Determine if dark background
    final luminance = background.computeLuminance();
    final isDark = luminance < 0.3;
    return AppColorScheme(
      id: 'custom',
      name: 'My Theme',
      emoji: '🎨',
      primary: primary,
      background: background,
      surface: isDark ? const Color(0xFF2C2C2E) : Colors.white,
      textDark: isDark ? Colors.white : const Color(0xFF1A1A1A),
      textMedium: isDark
          ? Colors.white.withOpacity(0.7)
          : primary.withOpacity(0.7),
      accent: accent,
      softBorder: isDark
          ? Colors.white.withOpacity(0.12)
          : primary.withOpacity(0.2),
      brightness: isDark ? Brightness.dark : Brightness.light,
    );
  }
}

final themeProvider =
    StateNotifierProvider<ThemeNotifier, AppColorScheme>((ref) {
  return ThemeNotifier();
});
