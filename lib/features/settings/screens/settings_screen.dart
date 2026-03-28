import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
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
    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.softWhite,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionHeader(context, 'Preferences'),
          _SettingsCard(
            children: [
              _toggle(
                label: '🔊 Sound',
                value: _sound,
                onChanged: (v) {
                  SystemSound.play(SystemSoundType.click);
                  HapticFeedback.lightImpact();
                  setState(() => _sound = v);
                  HiveService.setSoundEnabled(v);
                },
              ),
              _divider(),
              _toggle(
                label: '📳 Haptics',
                value: _haptics,
                onChanged: (v) {
                  SystemSound.play(SystemSoundType.click);
                  HapticFeedback.lightImpact();
                  setState(() => _haptics = v);
                  HiveService.setHapticsEnabled(v);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _sectionHeader(context, 'About'),
          _SettingsCard(
            children: [
              GestureDetector(
                onTap: _onVersionTap,
                child: _infoTile(
                  label: 'Version',
                  subtitle: '1.1.0 (Build 1)${kDebugMode ? ' [DEBUG]' : ''}',
                ),
              ),
              _divider(),
              _infoTile(label: 'App', subtitle: 'Boil Buddy: Perfect Egg Timer'),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.textMedium,
              letterSpacing: 1.5,
              fontSize: 11,
            ),
      ),
    );
  }

  Widget _toggle({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.kitchenBlue,
    );
  }

  ListTile _infoTile({required String label, required String subtitle}) {
    return ListTile(
      title:
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, indent: 16, endIndent: 16);
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
