import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const _prefBox = 'preferences';
  static const _entitleBox = 'entitlements';

  static const keySoundEnabled = 'soundEnabled';
  static const keyHapticsEnabled = 'hapticsEnabled';
  static const keySelectedSkin = 'selectedSkin';
  static const keyThemeId = 'themeId';
  static const keyCustomPrimary = 'customPrimary';
  static const keyCustomBackground = 'customBackground';
  static const keyCustomAccent = 'customAccent';

  static late Box _prefs;
  static late Box _entitlements;

  static Future<void> init() async {
    _prefs = await Hive.openBox(_prefBox);
    _entitlements = await Hive.openBox(_entitleBox);
  }



  // --- Sound ---
  static bool get soundEnabled =>
      _prefs.get(keySoundEnabled, defaultValue: true) as bool;

  static Future<void> setSoundEnabled(bool value) async {
    await _prefs.put(keySoundEnabled, value);
  }

  // --- Haptics ---
  static bool get hapticsEnabled =>
      _prefs.get(keyHapticsEnabled, defaultValue: true) as bool;

  static Future<void> setHapticsEnabled(bool value) async {
    await _prefs.put(keyHapticsEnabled, value);
  }

  // --- Skin ---
  static String get selectedSkin =>
      _prefs.get(keySelectedSkin, defaultValue: 'classic') as String;

  static Future<void> setSelectedSkin(String skinId) async {
    await _prefs.put(keySelectedSkin, skinId);
  }

  // --- Theme ---
  static String get themeId =>
      _prefs.get(keyThemeId, defaultValue: 'classic_red') as String;

  static Future<void> setThemeId(String id) async {
    await _prefs.put(keyThemeId, id);
  }

  static int? get customPrimary => _prefs.get(keyCustomPrimary) as int?;
  static int? get customBackground => _prefs.get(keyCustomBackground) as int?;
  static int? get customAccent => _prefs.get(keyCustomAccent) as int?;

  static Future<void> setCustomThemeColors(int primary, int background, int accent) async {
    await _prefs.put(keyCustomPrimary, primary);
    await _prefs.put(keyCustomBackground, background);
    await _prefs.put(keyCustomAccent, accent);
  }
}
