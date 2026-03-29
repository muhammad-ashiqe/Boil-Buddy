import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

import '../../../core/models/egg_config.dart';
import '../../../services/audio_service.dart';
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
    final hasCustomTime = config.customTime != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
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
                isActive: !hasCustomTime,
                onSelected: (val) {
                  AudioService.instance.playClick();
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
                isActive: !hasCustomTime,
                onSelected: (val) {
                  AudioService.instance.playClick();
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
                isActive: !hasCustomTime,
                onSelected: (val) {
                  AudioService.instance.playClick();
                  Vibration.vibrate(duration: 18, amplitude: 40);
                  ref.read(eggSettingsProvider.notifier).setStyle(val);
                },
              ),
              // ── Custom Timer ────────────────────────────────────────
              _CustomTimerSelector(
                locked: isLocked,
                customTime: config.customTime,
                onTimeSelected: (val) {
                  AudioService.instance.playClick();
                  Vibration.vibrate(duration: 18, amplitude: 40);
                  ref.read(eggSettingsProvider.notifier).setCustomTime(val);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Tap the items to adjust according to your settings',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMedium,
            ),
            textAlign: TextAlign.center,
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
  final bool isActive;
  final ValueChanged<T> onSelected;

  const _DropdownSelector({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.itemLabels,
    required this.locked,
    required this.isActive,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final curIndex = items.indexOf(value);
    final curLabel = itemLabels[curIndex];

    return GestureDetector(
      onTap: locked
          ? null
          : () {
              final nextIndex = (curIndex + 1) % items.length;
              onSelected(items[nextIndex]);
            },
      child: Opacity(
        opacity: locked ? 0.3 : (isActive ? 1.0 : 0.6),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
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
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      icon,
                      key: ValueKey<T>(value), // Forces animation switch
                      color: isActive ? AppTheme.deepRed : Colors.grey,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isActive ? curLabel : 'Auto',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isActive ? AppTheme.textDark : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
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

class _CustomTimerSelector extends StatelessWidget {
  final bool locked;
  final Duration? customTime;
  final ValueChanged<Duration> onTimeSelected;

  const _CustomTimerSelector({
    required this.locked,
    required this.customTime,
    required this.onTimeSelected,
  });

  void _showTimerPicker(BuildContext context) {
    if (locked) return;

    final initialDuration = customTime ?? const Duration(minutes: 5);

    showDialog(
      context: context,
      builder: (context) => _CustomTimerDialog(
        initialDuration: initialDuration,
        onSelected: onTimeSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = customTime != null;
    String displayTime = 'Timer';
    if (isActive) {
      final m = customTime!.inMinutes.toString().padLeft(2, '0');
      final s = (customTime!.inSeconds % 60).toString().padLeft(2, '0');
      displayTime = '$m:$s';
    }

    return GestureDetector(
      onTap: locked ? null : () => _showTimerPicker(context),
      child: Opacity(
        opacity: locked ? 0.3 : 1.0,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.deepRed : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? AppTheme.deepRed : AppTheme.softGrey,
                  width: 2,
                ),
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
                  Icon(
                    Icons.timer,
                    color: isActive ? Colors.white : AppTheme.deepRed,
                    size: 24,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isActive ? displayTime : 'Auto',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isActive ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Custom',
              style: TextStyle(
                fontSize: 13,
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

class _CustomTimerDialog extends StatefulWidget {
  final Duration initialDuration;
  final ValueChanged<Duration> onSelected;

  const _CustomTimerDialog({
    required this.initialDuration,
    required this.onSelected,
  });

  @override
  State<_CustomTimerDialog> createState() => _CustomTimerDialogState();
}

class _CustomTimerDialogState extends State<_CustomTimerDialog> {
  late TextEditingController _minutesController;
  late TextEditingController _secondsController;

  @override
  void initState() {
    super.initState();
    _minutesController = TextEditingController(
      text: widget.initialDuration.inMinutes.toString(),
    );
    _secondsController = TextEditingController(
      text: (widget.initialDuration.inSeconds % 60).toString().padLeft(2, '0'),
    );
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _submit() {
    final m = int.tryParse(_minutesController.text) ?? 5;
    final s = int.tryParse(_secondsController.text) ?? 0;
    widget.onSelected(Duration(minutes: m, seconds: s));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer_outlined, size: 48, color: AppTheme.deepRed),
            const SizedBox(height: 16),
            const Text(
              'Set Custom Timer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeField(
                  controller: _minutesController,
                  label: 'Min',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    ':',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textMedium),
                  ),
                ),
                _buildTimeField(
                  controller: _secondsController,
                  label: 'Sec',
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.deepRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text('Confirm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField({required TextEditingController controller, required String label}) {
    return Column(
      children: [
        SizedBox(
          width: 70,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              filled: true,
              fillColor: AppTheme.softGrey.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMedium),
        ),
      ],
    );
  }
}
