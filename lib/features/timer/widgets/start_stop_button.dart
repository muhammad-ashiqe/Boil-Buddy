import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/audio_service.dart';
import '../providers/timer_provider.dart';

class StartStopButton extends ConsumerWidget {
  final VoidCallback? onRescue;

  const StartStopButton({super.key, this.onRescue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(timerProvider);
    final notifier = ref.read(timerProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    final primaryLight = Color.lerp(cs.primary, Colors.white, 0.25)!;

    switch (timer.status) {
      case TimerStatus.idle:
        return _BigButton(
          label: 'START BOILING! 🥚',
          icon: Icons.play_arrow_rounded,
          colors: [primaryLight, cs.primary],
          shadowColor: cs.primary,
          onTap: () {
            AudioService.instance.playClick();
            HapticFeedback.lightImpact();
            notifier.start();
          },
        );

      case TimerStatus.running:
        return Row(
          children: [
            Expanded(
              flex: 3,
              child: _BigButton(
                label: 'PAUSE',
                icon: Icons.pause_rounded,
                colors: [primaryLight, cs.primary],
                shadowColor: cs.primary,
                onTap: () {
                  AudioService.instance.playClick();
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
                  AudioService.instance.playClick();
                  HapticFeedback.lightImpact();
                  notifier.stop();
                },
              ),
            ),
          ],
        );

      case TimerStatus.paused:
        return Row(
          children: [
            Expanded(
              flex: 3,
              child: _BigButton(
                label: 'RESUME',
                icon: Icons.play_arrow_rounded,
                colors: [primaryLight, cs.primary],
                shadowColor: cs.primary,
                onTap: () {
                  AudioService.instance.playClick();
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
                  AudioService.instance.playClick();
                  HapticFeedback.lightImpact();
                  notifier.stop();
                },
              ),
            ),
          ],
        );

      case TimerStatus.complete:
        return _CompletionButtons(
          onRescue: () {
            if (onRescue != null) {
              AudioService.instance.playClick();
              HapticFeedback.lightImpact();
              onRescue!();
            }
          },
          onBoilAgain: () {
            AudioService.instance.playClick();
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
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outline.withOpacity(0.4), width: 1.5),
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
            Icon(icon, color: cs.onSurface.withOpacity(0.6), size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: cs.onSurface.withOpacity(0.6),
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
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        // Rescue egg — theme primary with success tint
        Expanded(
          flex: 3,
          child: ScaleTransition(
            scale: _scale,
            child: GestureDetector(
              onTap: widget.onRescue,
              child: Container(
                height: 62,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(cs.primary, Colors.white, 0.2)!,
                      cs.primary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.45),
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
        // Boil Again — theme-aware
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: widget.onBoilAgain,
            child: Container(
              height: 62,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: cs.outline.withOpacity(0.4), width: 1.5),
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
                  Icon(Icons.replay_rounded, color: cs.primary, size: 22),
                  const SizedBox(height: 2),
                  Text(
                    'Boil Again',
                    style: TextStyle(
                      color: cs.primary,
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
