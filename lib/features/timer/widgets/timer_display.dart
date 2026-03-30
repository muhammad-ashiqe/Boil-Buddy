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

  /// Progress color: fades from primary → accent → success green
  Color _progressColor(double p, Color primary, Color accent) {
    if (p < 0.3) return primary;
    if (p < 0.6) return Color.lerp(primary, accent, (p - 0.3) / 0.3)!;
    if (p < 0.9) return Color.lerp(accent, AppTheme.successGreen, (p - 0.6) / 0.3)!;
    return AppTheme.successGreen;
  }

  Color _timerColor(AnimationState state, Color primary) {
    switch (state) {
      case AnimationState.chilling:
        return primary;
      case AnimationState.warming:
        return Color.lerp(primary, AppTheme.accentOrange, 0.4)!;
      case AnimationState.boiling:
        return AppTheme.accentOrange;
      case AnimationState.panic:
        return AppTheme.successGreen;
      case AnimationState.celebrate:
        return AppTheme.successGreen;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(timerProvider);
    final displayTime = timer.remaining;
    final isComplete = timer.isComplete;
    final progress = ref.watch(progressProvider);
    final cs = Theme.of(context).colorScheme;

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
                  backgroundColor: cs.outline.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _progressColor(progress, cs.primary, AppTheme.accentOrange),
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
                              color: _timerColor(timer.animationState, cs.primary),
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
                  color: cs.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
          ),
        ),
      ],
    );
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
      child: Text(
        '00:00',
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppTheme.successGreen,
              letterSpacing: 2,
            ),
      ),
    );
  }
}

