import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/timer_provider.dart';

class TimerDisplay extends ConsumerWidget {
  const TimerDisplay({super.key});

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color _progressColor(double p) {
    if (p < 0.25) return AppTheme.brightRed;
    if (p < 0.5) return AppTheme.deepRed;
    if (p < 0.9) return AppTheme.accentOrange;
    return AppTheme.darkMaroon;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(timerProvider);
    final displayTime = timer.remaining;
    final isComplete = timer.isComplete;
    final progress = ref.watch(progressProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Small Radial timer
        SizedBox(
          width: 130,
          height: 130,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: AppTheme.softGrey,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _progressColor(progress),
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isComplete
                    ? _completionBadge(context)
                    : Text(
                        _format(displayTime),
                        key: ValueKey(_format(displayTime)),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: _timerColor(timer.animationState),
                              letterSpacing: 2,
                            ),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Status label
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Text(
            _statusLabel(timer),
            key: ValueKey(timer.status),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMedium,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
          ),
        ),
      ],
    );
  }

  Color _timerColor(AnimationState state) {
    switch (state) {
      case AnimationState.chilling:
        return AppTheme.deepRed;
      case AnimationState.warming:
        return const Color(0xFFA00000);
      case AnimationState.boiling:
        return AppTheme.accentOrange;
      case AnimationState.panic:
        return const Color(0xFF4A0000);
      case AnimationState.celebrate:
        return AppTheme.successGreen;
    }
  }

  String _statusLabel(TimerState timer) {
    switch (timer.status) {
      case TimerStatus.idle:
        return 'READY TO BOIL';
      case TimerStatus.running:
        return _runningLabel(timer.animationState);
      case TimerStatus.paused:
        return 'PAUSED';
      case TimerStatus.complete:
        return '🎉 DONE!';
    }
  }

  String _runningLabel(AnimationState state) {
    switch (state) {
      case AnimationState.chilling:
        return 'HEATING UP...';
      case AnimationState.warming:
        return 'WARMING...';
      case AnimationState.boiling:
        return 'BOILING! 💦';
      case AnimationState.panic:
        return 'ALMOST DONE! ⚡';
      case AnimationState.celebrate:
        return '🎉 DONE!';
    }
  }

  Widget _completionBadge(BuildContext context) {
    return Container(
      key: const ValueKey('done'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.successGreen,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppTheme.successGreen.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        '00:00',
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 2,
            ),
      ),
    );
  }
}
