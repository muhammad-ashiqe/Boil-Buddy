import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../services/audio_service.dart';
import '../../../services/hive_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _sound = true;
  bool _haptics = true;
  int _versionTapCount = 0;

  @override
  void initState() {
    super.initState();
    _sound = HiveService.soundEnabled;
    _haptics = HiveService.hapticsEnabled;
  }

  void _onVersionTap() {
    if (!kDebugMode) return;
    _versionTapCount++;
    if (_versionTapCount >= 7) {
      _versionTapCount = 0;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔧 Developer Mode Unlocked'),
          backgroundColor: Colors.deepPurple,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ref.watch(themeProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: cs.primary),
        titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionHeader(context, 'Preferences', scheme.textMedium),
          _SettingsCard(
            surfaceColor: Theme.of(context).cardColor,
            children: [
              _toggle(
                label: '🔊 Sound',
                value: _sound,
                activeColor: cs.primary,
                onChanged: (v) {
                  AudioService.instance.playClick();
                  HapticFeedback.lightImpact();
                  setState(() => _sound = v);
                  HiveService.setSoundEnabled(v);
                },
              ),
              _divider(scheme.softBorder),
              _toggle(
                label: '📳 Haptics',
                value: _haptics,
                activeColor: cs.primary,
                onChanged: (v) {
                  AudioService.instance.playClick();
                  HapticFeedback.lightImpact();
                  setState(() => _haptics = v);
                  HiveService.setHapticsEnabled(v);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _sectionHeader(context, 'About', scheme.textMedium),
          _SettingsCard(
            surfaceColor: Theme.of(context).cardColor,
            children: [
              GestureDetector(
                onTap: _onVersionTap,
                child: _infoTile(
                  label: 'Version',
                  subtitle: '1.1.0 (Build 1)${kDebugMode ? ' [DEBUG]' : ''}',
                  textColor: scheme.textDark,
                  subtitleColor: scheme.textMedium,
                ),
              ),
              _divider(scheme.softBorder),
              _infoTile(
                label: 'App',
                subtitle: 'Boil Buddy: Perfect Egg Timer',
                textColor: scheme.textDark,
                subtitleColor: scheme.textMedium,
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 1.5,
              fontSize: 11,
            ),
      ),
    );
  }

  Widget _toggle({
    required String label,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface)),
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
    );
  }

  Widget _infoTile({
    required String label,
    required String subtitle,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return ListTile(
      title: Text(label,
          style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
      subtitle: Text(subtitle, style: TextStyle(color: subtitleColor)),
    );
  }

  Widget _divider(Color color) =>
      Divider(height: 1, indent: 16, endIndent: 16, color: color);
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final Color surfaceColor;
  const _SettingsCard({required this.children, required this.surfaceColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: children),
      ),
    );
  }
}

