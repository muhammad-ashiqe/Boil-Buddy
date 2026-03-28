import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:vibration/vibration.dart';

import '../../../core/models/egg_config.dart';
import '../../../core/constants/boil_times.dart';
import '../../../services/audio_service.dart';
import '../../../services/notification_service.dart';
import '../../../services/hive_service.dart';

enum TimerStatus { idle, running, paused, complete }

enum AnimationState { chilling, warming, boiling, panic, celebrate }

class TimerState {
  final TimerStatus status;
  final Duration totalDuration;
  final Duration remaining;
  final AnimationState animationState;
  final EggConfig config;

  const TimerState({
    required this.status,
    required this.totalDuration,
    required this.remaining,
    required this.animationState,
    required this.config,
  });

  double get progressFraction {
    if (totalDuration.inSeconds == 0) return 0;
    final elapsed = totalDuration.inSeconds - remaining.inSeconds;
    return (elapsed / totalDuration.inSeconds).clamp(0.0, 1.0);
  }

  bool get isRunning => status == TimerStatus.running;
  bool get isComplete => status == TimerStatus.complete;
  bool get isIdle => status == TimerStatus.idle;

  TimerState copyWith({
    TimerStatus? status,
    Duration? totalDuration,
    Duration? remaining,
    AnimationState? animationState,
    EggConfig? config,
  }) {
    return TimerState(
      status: status ?? this.status,
      totalDuration: totalDuration ?? this.totalDuration,
      remaining: remaining ?? this.remaining,
      animationState: animationState ?? this.animationState,
      config: config ?? this.config,
    );
  }
}

class TimerNotifier extends StateNotifier<TimerState> {
  final Ref _ref;
  Timer? _ticker;

  TimerNotifier(this._ref)
      : super(
          TimerState(
            status: TimerStatus.idle,
            totalDuration: const Duration(minutes: 8),
            remaining: const Duration(minutes: 8),
            animationState: AnimationState.chilling,
            config: const EggConfig(
              size: EggSize.medium,
              temp: EggTemp.fridge,
              style: EggStyle.medium,
            ),
          ),
        );

  void updateConfig(EggConfig config) {
    if (state.status == TimerStatus.running) return;
    final duration = getBoilDuration(config);
    state = state.copyWith(
      config: config,
      totalDuration: duration,
      remaining: duration,
      status: TimerStatus.idle,
      animationState: AnimationState.chilling,
    );
  }

  Future<void> start() async {
    if (state.status == TimerStatus.running) return;

    // Enable wakelock
    await WakelockPlus.enable();

    // Start audio if enabled
    final soundOn = HiveService.soundEnabled;
    if (soundOn) {
      AudioService.instance.playBoiling();
    }

    // Schedule notification
    await NotificationService.scheduleAlarm(state.remaining);

    state = state.copyWith(status: TimerStatus.running);
    _startTicker();
  }

  void stop() {
    _ticker?.cancel();
    _ticker = null;
    audioService.stopBoiling();
    audioService.stopAlarm();
    WakelockPlus.disable();
    NotificationService.cancelAlarm();
    state = state.copyWith(
      status: TimerStatus.idle,
      remaining: state.totalDuration,
      animationState: AnimationState.chilling,
    );
  }

  void pause() {
    if (state.status != TimerStatus.running) return;
    _ticker?.cancel();
    _ticker = null;
    audioService.stopBoiling();
    NotificationService.cancelAlarm();
    WakelockPlus.disable();
    state = state.copyWith(
      status: TimerStatus.paused,
      animationState: AnimationState.chilling,
    );
  }

  Future<void> resume() async {
    if (state.status != TimerStatus.paused) return;
    await WakelockPlus.enable();
    if (HiveService.soundEnabled) audioService.playBoiling();
    await NotificationService.scheduleAlarm(state.remaining);
    state = state.copyWith(status: TimerStatus.running);
    _startTicker();
  }

  void restart() {
    _ticker?.cancel();
    _ticker = null;
    audioService.stopBoiling();
    audioService.stopAlarm();
    WakelockPlus.disable();
    NotificationService.cancelAlarm();
    state = state.copyWith(
      status: TimerStatus.idle,
      remaining: state.totalDuration,
      animationState: AnimationState.chilling,
    );
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (state.status != TimerStatus.running) {
      _ticker?.cancel();
      return;
    }

    final newRemaining = state.remaining - const Duration(seconds: 1);

    if (newRemaining <= Duration.zero) {
      _onComplete();
      return;
    }

    final animState = _computeAnimationState(
      state.totalDuration,
      newRemaining,
    );

    state = state.copyWith(
      remaining: newRemaining,
      animationState: animState,
    );
  }

  AnimationState _computeAnimationState(Duration total, Duration remaining) {
    final progress =
        (total.inSeconds - remaining.inSeconds) / total.inSeconds;

    if (progress < 0.25) return AnimationState.chilling;
    if (progress < 0.50) return AnimationState.warming;
    if (progress < 0.90) return AnimationState.boiling;
    return AnimationState.panic;
  }

  void _onComplete() {
    _ticker?.cancel();
    _ticker = null;
    audioService.stopBoiling();
    WakelockPlus.disable();

    // Heavy vibration
    if (HiveService.hapticsEnabled) {
      Vibration.vibrate(pattern: [0, 500, 200, 500, 200, 500]);
    }

    // Alarm sound
    if (HiveService.soundEnabled) {
      audioService.playAlarm();
    }

    state = state.copyWith(
      status: TimerStatus.complete,
      remaining: Duration.zero,
      animationState: AnimationState.celebrate,
    );
  }

  AudioService get audioService => AudioService.instance;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

// Providers
final timerProvider =
    StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier(ref);
});

final progressProvider = Provider<double>((ref) {
  return ref.watch(timerProvider).progressFraction;
});

final animationStateProvider = Provider<AnimationState>((ref) {
  return ref.watch(timerProvider).animationState;
});
