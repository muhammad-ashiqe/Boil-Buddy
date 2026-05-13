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
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      fontSize: isActive ? 9.5 : 10,
                      fontWeight: FontWeight.w800,
                      color: isActive ? Colors.white : cs.onSurface,
                      letterSpacing: isActive ? -0.2 : 0,
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
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth.clamp(280.0, 420.0);
    final isCompact = screenWidth < 360;
    final outerPadding = isCompact ? 18.0 : 24.0;
    final wheelAreaHeight = isCompact ? 136.0 : 148.0;
    final highlightHeight = isCompact ? 48.0 : 52.0;
    final digitFontSize = isCompact ? 34.0 : 38.0;
    final colonFontSize = isCompact ? 24.0 : 28.0;
    final itemExtent = isCompact ? 48.0 : 52.0;
    final iconSize = isCompact ? 34.0 : 38.0;
    final titleSize = isCompact ? 21.0 : 24.0;
    final subtitleSize = isCompact ? 12.5 : 14.0;
    final buttonVerticalPadding = isCompact ? 14.0 : 16.0;
    final dialogRadius = isCompact ? 26.0 : 30.0;
    final inputRadius = isCompact ? 20.0 : 24.0;
    final highlightInset = isCompact ? 12.0 : 16.0;
    final wheelGap = isCompact ? 8.0 : 12.0;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dialogRadius),
      ),
      backgroundColor: cs.surface,
      elevation: 24,
      shadowColor: Colors.black26,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth),
        child: Padding(
          padding: EdgeInsets.all(outerPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isCompact ? 12 : 14),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.av_timer_rounded,
                  size: iconSize,
                  color: cs.primary,
                ),
              ),
              SizedBox(height: isCompact ? 18 : 22),
              Text(
                'Custom Timer',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Swipe to set or tap to type',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: subtitleSize,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withOpacity(0.5),
                ),
              ),
              SizedBox(height: isCompact ? 24 : 28),
              Container(
                height: wheelAreaHeight,
                decoration: BoxDecoration(
                  color: cs.outline.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(inputRadius),
                  border: Border.all(
                    color: cs.outline.withOpacity(0.1),
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: highlightInset),
                      child: Container(
                        height: highlightHeight,
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: wheelAreaHeight,
                                    child: _ScrollableWheelInput(
                                      controller: _minutesController,
                                      cs: cs,
                                      maxVal: 59,
                                      fontSize: digitFontSize,
                                      itemExtent: itemExtent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: wheelGap),
                          Text(
                            ':',
                            style: TextStyle(
                              fontSize: colonFontSize,
                              fontWeight: FontWeight.w900,
                              color: cs.primary.withOpacity(0.4),
                              height: 1,
                            ),
                          ),
                          SizedBox(width: wheelGap),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: wheelAreaHeight,
                                    child: _ScrollableWheelInput(
                                      controller: _secondsController,
                                      cs: cs,
                                      maxVal: 59,
                                      fontSize: digitFontSize,
                                      itemExtent: itemExtent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(inputRadius),
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
              SizedBox(height: isCompact ? 24 : 30),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: buttonVerticalPadding,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(0.5),
                          fontSize: isCompact ? 15 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isCompact ? 12 : 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: buttonVerticalPadding,
                        ),
                        elevation: 8,
                        shadowColor: cs.primary.withOpacity(0.4),
                      ),
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: isCompact ? 16 : 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScrollableWheelInput extends StatefulWidget {
  final TextEditingController controller;
  final ColorScheme cs;
  final int maxVal;
  final double fontSize;
  final double itemExtent;

  const _ScrollableWheelInput({
    required this.controller,
    required this.cs,
    required this.maxVal,
    required this.fontSize,
    required this.itemExtent,
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
            fontSize: widget.fontSize,
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
                itemExtent: widget.itemExtent,
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
                fontSize: widget.fontSize,
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
              maxLength: 2,
              buildCounter: (
                BuildContext context, {
                required int currentLength,
                required bool isFocused,
                required int? maxLength,
              }) {
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }
}

