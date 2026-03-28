import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/egg_config.dart';
import '../../../core/constants/boil_times.dart';
import 'timer_provider.dart';

class EggSettingsNotifier extends StateNotifier<EggConfig> {
  final Ref _ref;

  EggSettingsNotifier(this._ref)
      : super(const EggConfig(
          size: EggSize.medium,
          temp: EggTemp.fridge,
          style: EggStyle.medium,
        ));

  void setSize(EggSize size) {
    state = state.copyWith(size: size);
    _notifyTimer();
  }

  void setTemp(EggTemp temp) {
    state = state.copyWith(temp: temp);
    _notifyTimer();
  }

  void setStyle(EggStyle style) {
    state = state.copyWith(style: style);
    _notifyTimer();
  }

  void _notifyTimer() {
    _ref.read(timerProvider.notifier).updateConfig(state);
  }

  Duration get currentDuration => getBoilDuration(state);
}

final eggSettingsProvider =
    StateNotifierProvider<EggSettingsNotifier, EggConfig>((ref) {
  return EggSettingsNotifier(ref);
});

final computedDurationProvider = Provider<Duration>((ref) {
  final config = ref.watch(eggSettingsProvider);
  return getBoilDuration(config);
});
