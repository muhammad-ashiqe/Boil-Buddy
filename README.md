# Boil Buddy: Perfect Egg Timer 🥚

**Internal Codename:** Boil Buddy  
**Platform:** Android (Google Play Store)  
**Stack:** Flutter 3.x · Dart · Riverpod · Hive

---

## Getting Started

### 1. Prerequisites
- Flutter SDK ≥ 3.3.0 installed and on PATH  
- Android Studio / VS Code with Flutter extension  
- Android emulator or physical device (minSdk 21)

### 2. Install dependencies
```bash
cd boil_buddy
flutter pub get
```

### 3. Run (debug)
```bash
flutter run
```

### 4. Build debug APK
```bash
flutter build apk --debug
```

---
## Project Structure

```
lib/
  core/
    constants/      # boil_times.dart, app_strings.dart
    models/         # egg_config.dart
    theme/          # app_theme.dart
  features/
    timer/
      providers/    # timer_provider.dart, settings_provider.dart
      screens/      # home_screen.dart
      widgets/      # egg_animation.dart, egg_selector.dart, timer_display.dart, start_stop_button.dart
    reward/
      screens/      # reward_modal.dart
    settings/
      screens/      # settings_screen.dart
    wardrobe/
      screens/      # wardrobe_screen.dart
  services/
    audio_service.dart
    notification_service.dart
    ad_service.dart
    iap_service.dart
    hive_service.dart
  shared/
    widgets/        # app_banner_ad.dart
  main.dart
assets/
  audio/            # boiling.mp3, alarm.mp3 (replace placeholders)
  data/             # egg_facts.json (50 facts)
  rive/             # egg_character.riv (replace placeholder)
```

---

## Boil Time Algorithm

| Size   | Soft  | Medium | Hard  |
|--------|-------|--------|-------|
| Small  | 5:30  | 7:00   | 9:00  |
| Medium | 6:00  | 8:00   | 10:00 |
| Large  | 6:30  | 9:00   | 11:00 |

**Room temp:** subtract 45 seconds from the above.

---

## Key Packages

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `hive_flutter` | Local storage |
| `google_mobile_ads` | Banner + rewarded ads |
| `purchases_flutter` | RevenueCat IAP |
| `flutter_local_notifications` | Background alarm |
| `wakelock_plus` | Screen on during timer |
| `audioplayers` | Boiling ASMR + alarm |
| `vibration` | Haptic tick + completion pulse |
| `rive` | Egg character animation |
| `confetti` | Post-boil celebration |

---

*PRD version: 1.1 — Ready for Development*
