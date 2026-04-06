import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

import '../../../core/models/egg_config.dart';
import '../../../services/audio_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/timer_provider.dart';

class EggSelectorWidget extends ConsumerWidget {
  const EggSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(eggSettingsProvider);
    final status = ref.watch(timerProvider).status;
    final isLocked = status != TimerStatus.idle;
    final hasCustomTime = config.customTime != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ── Size ────────────────────────────────────────────────
              Expanded(
                child: _DropdownSelector<EggSize>(
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
              ),
              // ── Temp ────────────────────────────────────────────────
              Expanded(
                child: _DropdownSelector<EggTemp>(
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
              ),
              // ── Style ───────────────────────────────────────────────
              Expanded(
                child: _DropdownSelector<EggStyle>(
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
              ),
              // ── Custom Timer ────────────────────────────────────────
              Expanded(
                child: _CustomTimerSelector(
                locked: isLocked,
                customTime: config.customTime,
                onTimeSelected: (val) {
                  AudioService.instance.playClick();
                  Vibration.vibrate(duration: 18, amplitude: 40);
                  ref.read(eggSettingsProvider.notifier).setCustomTime(val);
                },
              ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Tap the items to adjust according to your settings',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
    final cs = Theme.of(context).colorScheme;

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
                color: cs.surface,
                shape: BoxShape.circle,
                border: Border.all(color: cs.outline.withOpacity(0.4), width: 2),
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
                      key: ValueKey<T>(value),
                      color: isActive ? cs.primary : Colors.grey,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isActive ? curLabel : 'Auto',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isActive ? cs.onSurface : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: cs.onSurface.withOpacity(0.7),
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
    final cs = Theme.of(context).colorScheme;
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
                color: isActive ? cs.primary : cs.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? cs.primary : cs.outline.withOpacity(0.4),
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
                    color: isActive ? Colors.white : cs.primary,
                    size: 24,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isActive ? displayTime : 'Auto',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isActive ? Colors.white : cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Custom',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: cs.onSurface.withOpacity(0.7),
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
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      backgroundColor: cs.surface,
      elevation: 24,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.av_timer_rounded, size: 40, color: cs.primary),
            ),
            const SizedBox(height: 24),
            
            // Titles
            Text(
              'Custom Timer',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: cs.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Swipe to set or tap to type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 32),
            
            // Unified Input Area
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: cs.outline.withOpacity(0.04),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: cs.outline.withOpacity(0.1), width: 1.5),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Center selection highlight
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  
                  // Scroll Wheels and Labels
                  Positioned.fill(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 160,
                          child: _ScrollableWheelInput(
                            controller: _minutesController,
                            cs: cs,
                            maxVal: 59,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'min',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Text(
                            ':',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: cs.primary.withOpacity(0.4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        SizedBox(
                          width: 80,
                          height: 160,
                          child: _ScrollableWheelInput(
                            controller: _secondsController,
                            cs: cs,
                            maxVal: 59,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'sec',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Top/Bottom Fading Gradients
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            cs.surface,
                            cs.surface.withOpacity(0.0),
                            cs.surface.withOpacity(0.0),
                            cs.surface,
                          ],
                          stops: const [0.0, 0.25, 0.75, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 36),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Cancel', style: TextStyle(color: cs.onSurface.withOpacity(0.5), fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 8,
                      shadowColor: cs.primary.withOpacity(0.4),
                    ),
                    child: const Text('Confirm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _ScrollableWheelInput extends StatefulWidget {
  final TextEditingController controller;
  final ColorScheme cs;
  final int maxVal;

  const _ScrollableWheelInput({
    required this.controller,
    required this.cs,
    required this.maxVal,
  });

  @override
  State<_ScrollableWheelInput> createState() => _ScrollableWheelInputState();
}

class _ScrollableWheelInputState extends State<_ScrollableWheelInput> {
  late FixedExtentScrollController _scrollController;
  final FocusNode _focusNode = FocusNode();
  bool _isEditing = false;
  late final List<Widget> _wheelChildren;

  @override
  void initState() {
    super.initState();
    int initialVal = int.tryParse(widget.controller.text) ?? 0;
    _scrollController = FixedExtentScrollController(initialItem: initialVal);
    
    _wheelChildren = List.generate(widget.maxVal + 1, (index) {
      return Center(
        child: Text(
          index.toString().padLeft(2, '0'),
          style: TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w900,
            color: widget.cs.onSurface,
            letterSpacing: -1.0,
          ),
        ),
      );
    });

    _focusNode.addListener(() {
      if (!mounted) return;
      setState(() {
        _isEditing = _focusNode.hasFocus;
      });
      if (!_focusNode.hasFocus) {
        int val = int.tryParse(widget.controller.text) ?? 0;
        if (val < 0) val = 0;
        if (val > widget.maxVal) val = widget.maxVal;
        widget.controller.text = val.toString().padLeft(2, '0');
        if (_scrollController.hasClients) {
          _scrollController.jumpToItem(val);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Wheel
        Opacity(
          opacity: _isEditing ? 0.0 : 1.0,
          child: IgnorePointer(
            ignoring: _isEditing,
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(_focusNode);
              },
              child: ListWheelScrollView.useDelegate(
                controller: _scrollController,
                itemExtent: 56,
                physics: const FixedExtentScrollPhysics(),
                perspective: 0.005,
                useMagnifier: true,
                magnification: 1.15,
                overAndUnderCenterOpacity: 0.3,
                onSelectedItemChanged: (index) {
                  if (_isEditing) return;
                  final val = index % (widget.maxVal + 1);
                  widget.controller.text = val.toString().padLeft(2, '0');
                },
                childDelegate: ListWheelChildLoopingListDelegate(
                  children: _wheelChildren,
                ),
              ),
            ),
          ),
        ),
        // Typing Field
        IgnorePointer(
          ignoring: !_isEditing,
          child: Opacity(
            opacity: _isEditing ? 1.0 : 0.0,
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                color: widget.cs.onSurface,
                letterSpacing: -1.0,
              ),
              cursorColor: widget.cs.primary,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
              ),
              showCursor: true,
            ),
          ),
        ),
      ],
    );
  }
}

