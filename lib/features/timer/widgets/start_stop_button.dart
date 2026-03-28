import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/timer_provider.dart';

/// Adapts the bottom action area based on timer state:
///
///  idle     → [START BOILING 🥚]
///  running  → [⏸ PAUSE]  [✕ CANCEL]
///  paused   → [▶ RESUME]  [✕ CANCEL]
///  complete → [🥚 RESCUE EGG!]  [↺ BOIL AGAIN]
class StartStopButton extends ConsumerWidget {
  final VoidCallback? onRescue;

  const StartStopButton({super.key, this.onRescue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(timerProvider);
    final notifier = ref.read(timerProvider.notifier);

    switch (timer.status) {
      // ── IDLE ────────────────────────────────────────────────────────────
      case TimerStatus.idle:
        return _BigButton(
          label: 'START BOILING! 🥚',
          icon: Icons.play_arrow_rounded,
          colors: [AppTheme.brightRed, AppTheme.darkMaroon],
          shadowColor: AppTheme.darkMaroon,
          onTap: () {
            SystemSound.play(SystemSoundType.click);
            HapticFeedback.lightImpact();
            notifier.start();
          },
        );

      // ── RUNNING ─────────────────────────────────────────────────────────
      case TimerStatus.running:
        return Row(
          children: [
            Expanded(
              flex: 3,
              child: _BigButton(
                label: 'PAUSE',
                icon: Icons.pause_rounded,
                colors: [const Color(0xFFF57C00), const Color(0xFFE65100)],
                shadowColor: const Color(0xFFF57C00),
                onTap: () {
                  SystemSound.play(SystemSoundType.click);
                  HapticFeedback.lightImpact();
                  notifier.pause();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _OutlineButton(
                label: 'CANCEL',
                icon: Icons.close_rounded,
                onTap: () {
                  SystemSound.play(SystemSoundType.click);
                  HapticFeedback.lightImpact();
                  notifier.stop();
                },
              ),
            ),
          ],
        );

      // ── PAUSED ──────────────────────────────────────────────────────────
      case TimerStatus.paused:
        return Row(
          children: [
            Expanded(
              flex: 3,
              child: _BigButton(
                label: 'RESUME',
                icon: Icons.play_arrow_rounded,
                colors: [AppTheme.brightRed, AppTheme.darkMaroon],
                shadowColor: AppTheme.darkMaroon,
                onTap: () {
                  SystemSound.play(SystemSoundType.click);
                  HapticFeedback.lightImpact();
                  notifier.resume();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _OutlineButton(
                label: 'CANCEL',
                icon: Icons.close_rounded,
                onTap: () {
                  SystemSound.play(SystemSoundType.click);
                  HapticFeedback.lightImpact();
                  notifier.stop();
                },
              ),
            ),
          ],
        );

      // ── COMPLETE ────────────────────────────────────────────────────────
      case TimerStatus.complete:
        return _CompletionButtons(
          onRescue: () {
            if (onRescue != null) {
              SystemSound.play(SystemSoundType.click);
              HapticFeedback.lightImpact();
              onRescue!();
            }
          },
          onBoilAgain: () {
            SystemSound.play(SystemSoundType.click);
            HapticFeedback.lightImpact();
            notifier.restart();
          },
        );
    }
  }
}

// ── Big primary button ───────────────────────────────────────────────────────

class _BigButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<Color> colors;
  final Color shadowColor;
  final VoidCallback onTap;

  const _BigButton({
    required this.label,
    required this.icon,
    required this.colors,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  State<_BigButton> createState() => _BigButtonState();
}

class _BigButtonState extends State<_BigButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _press, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        widget.onTap();
      },
      onTapCancel: () => _press.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor.withOpacity(0.45),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 26),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Outline (secondary) button ───────────────────────────────────────────────

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.softGrey, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.textMedium, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textMedium,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Completion: Rescue + Boil Again ─────────────────────────────────────────

class _CompletionButtons extends StatefulWidget {
  final VoidCallback? onRescue;
  final VoidCallback onBoilAgain;

  const _CompletionButtons({this.onRescue, required this.onBoilAgain});

  @override
  State<_CompletionButtons> createState() => _CompletionButtonsState();
}

class _CompletionButtonsState extends State<_CompletionButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.04)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Rescue egg (pulsing green)
        Expanded(
          flex: 3,
          child: ScaleTransition(
            scale: _scale,
            child: GestureDetector(
              onTap: widget.onRescue,
              child: Container(
                height: 62,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.successGreen.withOpacity(0.50),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🥚', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 8),
                    Text(
                      'RESCUE EGG!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Boil Again
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: widget.onBoilAgain,
            child: Container(
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.softGrey, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.replay_rounded,
                      color: AppTheme.deepRed, size: 22),
                  const SizedBox(height: 2),
                  Text(
                    'Boil Again',
                    style: TextStyle(
                      color: AppTheme.deepRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
