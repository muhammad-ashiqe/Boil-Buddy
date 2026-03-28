import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_strings.dart';
import '../providers/timer_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/egg_animation.dart';
import '../widgets/egg_selector.dart';
import '../widgets/timer_display.dart';
import '../widgets/start_stop_button.dart';
import '../../reward/screens/reward_modal.dart';
import '../../settings/screens/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(timerProvider);
    final isComplete = timer.isComplete;
    final isRunning = timer.isRunning;
    final progress = ref.watch(progressProvider);

    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────
            _TopBar(
              onSettings: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const SettingsScreen()),
              ),
            ),
            // ── Egg & Timer ──────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 1),
                    // Progress ring + egg animation
                    Expanded(
                      flex: 8,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: _EggStage(progress: progress),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Countdown display
                    const TimerDisplay(),
                    const SizedBox(height: 16),
                    // Egg selectors (hidden while running)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 400),
                      opacity: isRunning ? 0.4 : 1.0,
                      child: const EggSelectorWidget(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // ── Bottom actions ───────────────────────
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: StartStopButton(
                onRescue: isComplete
                    ? () {
                        _showRewardModal(context);
                        ref.read(timerProvider.notifier).restart();
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRewardModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RewardModal(),
    );
  }
}

// ── Top bar ──────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback onSettings;

  const _TopBar({required this.onSettings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _TopBarButton(
            icon: Icons.settings_outlined,
            onTap: onSettings,
            tooltip: AppStrings.settings,
          ),
          // App title
          Column(
            children: [
              Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.deepBlue,
                      fontSize: 20,
                    ),
              ),
              Text(
                AppStrings.tagline,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
              ),
            ],
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _TopBarButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            SystemSound.play(SystemSoundType.click);
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 24, color: AppTheme.deepBlue),
          ),
        ),
      ),
    );
  }
}

// ── Egg stage with radial progress ───────────────────────

class _EggStage extends StatelessWidget {
  final double progress;
  const _EggStage({required this.progress});

  @override
  Widget build(BuildContext context) {
    return const EggAnimationWidget();
  }
}
