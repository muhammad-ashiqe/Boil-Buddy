import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

import '../../../core/models/egg_config.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../providers/timer_provider.dart';

class EggSelectorWidget extends ConsumerWidget {
  const EggSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(eggSettingsProvider);
    final status = ref.watch(timerProvider).status;
    final isLocked =
        status == TimerStatus.running || status == TimerStatus.paused;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // ── Size ────────────────────────────────────────────────
          _DropdownSelector<EggSize>(
            label: 'Size',
            icon: Icons.egg_alt_outlined,
            value: config.size,
            items: EggSize.values,
            itemLabels: const ['Small', 'Medium', 'Large'],
            locked: isLocked,
            onSelected: (val) {
              SystemSound.play(SystemSoundType.click);
              Vibration.vibrate(duration: 18, amplitude: 40);
              ref.read(eggSettingsProvider.notifier).setSize(val);
            },
          ),
          // ── Temp ────────────────────────────────────────────────
          _DropdownSelector<EggTemp>(
            label: 'Temp',
            icon: Icons.thermostat,
            value: config.temp,
            items: EggTemp.values,
            itemLabels: const ['Fridge', 'Room'],
            locked: isLocked,
            onSelected: (val) {
              SystemSound.play(SystemSoundType.click);
              Vibration.vibrate(duration: 18, amplitude: 40);
              ref.read(eggSettingsProvider.notifier).setTemp(val);
            },
          ),
          // ── Style ───────────────────────────────────────────────
          _DropdownSelector<EggStyle>(
            label: 'Style',
            icon: Icons.water_drop_outlined,
            value: config.style,
            items: EggStyle.values,
            itemLabels: const ['Soft', 'Medium', 'Hard'],
            locked: isLocked,
            onSelected: (val) {
              SystemSound.play(SystemSoundType.click);
              Vibration.vibrate(duration: 18, amplitude: 40);
              ref.read(eggSettingsProvider.notifier).setStyle(val);
            },
          ),
        ],
      ),
    );
  }
}

class _DropdownSelector<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T value;
  final List<T> items;
  final List<String> itemLabels;
  final bool locked;
  final ValueChanged<T> onSelected;

  const _DropdownSelector({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.itemLabels,
    required this.locked,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final curIndex = items.indexOf(value);
    final curLabel = itemLabels[curIndex];

    return GestureDetector(
      onTap: locked ? null : () {
        final nextIndex = (curIndex + 1) % items.length;
        onSelected(items[nextIndex]);
      },
      child: Opacity(
        opacity: locked ? 0.5 : 1.0,
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.softGrey, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   AnimatedSwitcher(
                     duration: const Duration(milliseconds: 200),
                     transitionBuilder: (Widget child, Animation<double> animation) {
                       return ScaleTransition(scale: animation, child: child);
                     },
                     child: Icon(
                       icon, 
                       key: ValueKey<T>(value), // Forces animation switch on value change
                       color: AppTheme.deepRed, 
                       size: 28
                     ),
                   ),
                  const SizedBox(height: 2),
                  Text(
                    curLabel,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
