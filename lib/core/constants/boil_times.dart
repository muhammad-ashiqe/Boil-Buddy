import '../models/egg_config.dart';

/// Boil time matrix from PRD Section 5.2
/// Keyed by "size_style" (fridge base times; room temp subtracts 45s).
/// Cannot use EggConfig as a const map key because it has a custom == operator
/// (Dart const maps require primitive equality — enums, int, String, etc.).
const Map<String, Duration> _kBoilTimesFridge = {
  // Small
  'small_soft':    Duration(minutes: 5, seconds: 30),
  'small_medium':  Duration(minutes: 7, seconds: 0),
  'small_hard':    Duration(minutes: 9, seconds: 0),
  // Medium
  'medium_soft':   Duration(minutes: 6, seconds: 0),
  'medium_medium': Duration(minutes: 8, seconds: 0),
  'medium_hard':   Duration(minutes: 10, seconds: 0),
  // Large
  'large_soft':    Duration(minutes: 6, seconds: 30),
  'large_medium':  Duration(minutes: 9, seconds: 0),
  'large_hard':    Duration(minutes: 11, seconds: 0),
};

/// Returns boil duration for the given egg configuration.
/// Room temp eggs subtract 45 seconds from the fridge base time.
/// Adds 30 seconds for each additional egg in the pot.
Duration getBoilDuration(EggConfig config) {
  if (config.customTime != null) {
    return config.customTime!;
  }

  final key = '${config.size.name}_${config.style.name}';
  final base = _kBoilTimesFridge[key] ?? const Duration(minutes: 8); // safe fallback

  Duration adjusted = base;

  if (config.temp == EggTemp.room) {
    // PRD: subtract 30–60 seconds; we use 45s midpoint
    adjusted = adjusted - const Duration(seconds: 45);
  }

  if (config.eggCount > 1) {
    adjusted = adjusted + Duration(seconds: 30 * (config.eggCount - 1));
  }

  // Don't go below 3 minutes
  return adjusted < const Duration(minutes: 3)
      ? const Duration(minutes: 3)
      : adjusted;
}
