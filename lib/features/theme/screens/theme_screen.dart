import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_color_scheme.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../services/audio_service.dart';

class ThemeScreen extends ConsumerStatefulWidget {
  const ThemeScreen({super.key});

  @override
  ConsumerState<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends ConsumerState<ThemeScreen> {
  late AppColorScheme _pendingScheme;
  bool _isCustom = false;

  Color _customPrimary = const Color(0xFF8B0000);
  Color _customBackground = const Color(0xFFFAEBD7);
  Color _customAccent = const Color(0xFFCC3300);

  @override
  void initState() {
    super.initState();
    _pendingScheme = ref.read(themeProvider);
    if (_pendingScheme.id == 'custom') {
      _isCustom = true;
      _customPrimary = _pendingScheme.primary;
      _customBackground = _pendingScheme.background;
      _customAccent = _pendingScheme.accent;
    }
  }

  Future<void> _applyTheme() async {
    if (_isCustom) {
      await ref.read(themeProvider.notifier).setCustomTheme(
            primary: _customPrimary,
            background: _customBackground,
            accent: _customAccent,
          );
    } else {
      await ref.read(themeProvider.notifier).setTheme(_pendingScheme);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeScheme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: activeScheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_rounded,
                        color: activeScheme.textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose Your Theme',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: activeScheme.textDark,
                        ),
                      ),
                      Text(
                        'Tap to select your live theme',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: activeScheme.textMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Preset Grid + Custom ──────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Preset Themes', activeScheme),
                    const SizedBox(height: 12),

                    // 3-column grid of presets
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: AppColorScheme.presets.length,
                      itemBuilder: (_, i) {
                        final preset = AppColorScheme.presets[i];
                        final isSelected =
                            !_isCustom && _pendingScheme.id == preset.id;
                        return _PresetCard(
                          scheme: preset,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _pendingScheme = preset;
                              _isCustom = false;
                            });
                            _applyTheme();
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── Custom Theme ───────────────────────────────
                    _sectionLabel('Custom Theme', activeScheme),
                    const SizedBox(height: 12),

                    _CustomThemeCard(
                      isSelected: _isCustom,
                      primary: _customPrimary,
                      background: _customBackground,
                      accent: _customAccent,
                      activeScheme: activeScheme,
                      onTap: () {
                        setState(() => _isCustom = true);
                        _applyTheme();
                      },
                      onPickPrimary: () => _showColorPicker(
                        context: context,
                        title: 'Pick Primary Color',
                        selected: _customPrimary,
                        onPicked: (c) {
                            setState(() {
                                _customPrimary = c;
                                _isCustom = true;
                            });
                            _applyTheme();
                        },
                        activeScheme: activeScheme,
                      ),
                      onPickBackground: () => _showColorPicker(
                        context: context,
                        title: 'Pick Background Color',
                        selected: _customBackground,
                        onPicked: (c) {
                            setState(() {
                                _customBackground = c;
                                _isCustom = true;
                            });
                            _applyTheme();
                        },
                        activeScheme: activeScheme,
                      ),
                      onPickAccent: () => _showColorPicker(
                        context: context,
                        title: 'Pick Accent Color',
                        selected: _customAccent,
                        onPicked: (c) {
                            setState(() {
                                _customAccent = c;
                                _isCustom = true;
                            });
                            _applyTheme();
                        },
                        activeScheme: activeScheme,
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, AppColorScheme scheme) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: scheme.textDark,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  void _showColorPicker({
    required BuildContext context,
    required String title,
    required Color selected,
    required ValueChanged<Color> onPicked,
    required AppColorScheme activeScheme,
  }) {
    showDialog(
      context: context,
      builder: (_) => _ColorPickerDialog(
        title: title,
        selected: selected,
        onPicked: onPicked,
        activeScheme: activeScheme,
      ),
    );
  }
}

// ── Preset Card (matches the reference image style) ───────────────────────────

class _PresetCard extends StatelessWidget {
  final AppColorScheme scheme;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetCard({
    required this.scheme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? scheme.primary
                : scheme.softBorder.withOpacity(0.6),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? scheme.primary.withOpacity(0.2)
                  : Colors.black.withOpacity(0.04),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                scheme.name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: scheme.textDark,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Dot(scheme.primary),
                  const SizedBox(width: 3),
                  _Dot(scheme.accent),
                  const SizedBox(width: 3),
                  _Dot(scheme.surface, borderColor: scheme.softBorder),
                  const SizedBox(width: 3),
                  _Dot(scheme.textMedium),
                  const SizedBox(width: 3),
                  _Dot(scheme.background, borderColor: scheme.softBorder),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final Color? borderColor;

  const _Dot(this.color, {this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1)
            : null,
      ),
    );
  }
}

// ── Custom Theme Card ─────────────────────────────────────────────────────────

class _CustomThemeCard extends StatelessWidget {
  final bool isSelected;
  final Color primary;
  final Color background;
  final Color accent;
  final AppColorScheme activeScheme;
  final VoidCallback onTap;
  final VoidCallback onPickPrimary;
  final VoidCallback onPickBackground;
  final VoidCallback onPickAccent;

  const _CustomThemeCard({
    required this.isSelected,
    required this.primary,
    required this.background,
    required this.accent,
    required this.activeScheme,
    required this.onTap,
    required this.onPickPrimary,
    required this.onPickBackground,
    required this.onPickAccent,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isSelected ? const Color(0xFF22262E) : activeScheme.surface;
    final borderColor = isSelected ? primary : activeScheme.softBorder;
    final labelColor = isSelected ? Colors.white : activeScheme.textDark;
    final subColor = isSelected ? Colors.white60 : activeScheme.textMedium;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? primary.withOpacity(0.25)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 14 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  const Text('🎨', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Custom Theme',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: labelColor,
                          ),
                        ),
                        Text(
                          'Build your own palette',
                          style: TextStyle(
                            fontSize: 11,
                            color: subColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Color pickers row
              Row(
                children: [
                  Expanded(
                    child: _ColorPickerButton(
                      label: 'Primary',
                      color: primary,
                      labelColor: subColor,
                      onTap: onPickPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ColorPickerButton(
                      label: 'Background',
                      color: background,
                      labelColor: subColor,
                      onTap: onPickBackground,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ColorPickerButton(
                      label: 'Accent',
                      color: accent,
                      labelColor: subColor,
                      onTap: onPickAccent,
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

class _ColorPickerButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color labelColor;
  final VoidCallback onTap;

  const _ColorPickerButton({
    required this.label,
    required this.color,
    required this.labelColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.colorize_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Color Picker Dialog ───────────────────────────────────────────────────────

class _ColorPickerDialog extends StatefulWidget {
  final String title;
  final Color selected;
  final ValueChanged<Color> onPicked;
  final AppColorScheme activeScheme;

  const _ColorPickerDialog({
    required this.title,
    required this.selected,
    required this.onPicked,
    required this.activeScheme,
  });

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color _picked;

  @override
  void initState() {
    super.initState();
    _picked = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.activeScheme;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: s.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _picked,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: _picked.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: s.textDark,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Palette grid (40 colors — 8 columns)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: AppColorScheme.customPalette.length,
              itemBuilder: (_, i) {
                final c = AppColorScheme.customPalette[i];
                final isChosen = _picked.value == c.value;
                return GestureDetector(
                  onTap: () {
                    setState(() => _picked = c);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isChosen ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isChosen
                          ? [
                              BoxShadow(
                                color: c.withOpacity(0.6),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: isChosen
                        ? const Icon(Icons.check_rounded,
                            size: 14, color: Colors.white)
                        : null,
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Confirm button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onPicked(_picked);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _picked,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 4,
                  shadowColor: _picked.withOpacity(0.4),
                ),
                child: const Text(
                  'Use This Color',
                  style:
                      TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
