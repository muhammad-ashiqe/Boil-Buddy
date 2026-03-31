import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';

import '../../../core/theme/app_theme.dart';

class RewardModal extends ConsumerStatefulWidget {
  const RewardModal({super.key});

  @override
  ConsumerState<RewardModal> createState() => _RewardModalState();
}

class _RewardModalState extends ConsumerState<RewardModal> {
  bool _revealed = false;
  String? _fact;
  bool _loading = false;
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    HapticFeedback.lightImpact();
    _confetti = ConfettiController(duration: const Duration(seconds: 4));
    _loadFact();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _loadFact() async {
    final jsonStr = await rootBundle.loadString('assets/data/egg_facts.json');
    final List<dynamic> facts = json.decode(jsonStr) as List;
    final idx = DateTime.now().millisecondsSinceEpoch % facts.length;
    setState(() {
      _fact = facts[idx] as String;
      _revealed = true;
    });
    _confetti.play();
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Confetti
        ConfettiWidget(
          confettiController: _confetti,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [
            AppTheme.warmYellow,
            AppTheme.kitchenBlue,
            AppTheme.successGreen,
            Colors.pink,
            Colors.orange,
          ],
          numberOfParticles: 40,
        ),
        // Sheet content
        Container(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          decoration: const BoxDecoration(
            color: AppTheme.softWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppTheme.softGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Egg icon
              const Text('🎉', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 12),
              Text(
                'Egg Rescued!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textDark,
                    ),
              ),
              const SizedBox(height: 16),
              if (_revealed) ...[
                _FactCard(fact: _fact ?? ''),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      SystemSound.play(SystemSoundType.click);
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Awesome! 🥚'),
                  ),
                ),
              ] else
                 const CircularProgressIndicator(),
            ],
          ),
        ),
      ],
    );
  }
}

class _FactCard extends StatelessWidget {
  final String fact;
  const _FactCard({required this.fact});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E7), Color(0xFFFFF3C4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.warmYellow.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.warmYellow.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🥚', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fact,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
