import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const _prefBox = 'preferences';
  static const _entitleBox = 'entitlements';

  static const keySoundEnabled = 'soundEnabled';
  static const keyHapticsEnabled = 'hapticsEnabled';
  static const keySelectedSkin = 'selectedSkin';

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


}
