import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../providers/timer_provider.dart';

class EggDialogueWidget extends ConsumerStatefulWidget {
  const EggDialogueWidget({super.key});

  @override
  ConsumerState<EggDialogueWidget> createState() => _EggDialogueWidgetState();
}

class _EggDialogueWidgetState extends ConsumerState<EggDialogueWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathe;
  Timer? _quoteTimer;
  String _currentQuote = '';
  bool _isVisible = false;
  final Random _rng = Random();

  static const _idleQuotes = [
    'Ready to boil!',
    'Let\'s get started.',
    'Waiting...'
  ];
  static const _runningQuotes = [
    'Getting warmer...',
    'Bubble bubble...',
    'It\'s getting hot!',
    'Cooking!'
  ];
  static const _pausedQuotes = [
    'Taking a break?',
    'Don\'t let me get cold!'
  ];
  static const _completeQuotes = [
    'I\'m ready!',
    'Rescue me!',
    'Perfectly cooked!'
  ];

  @override
  void initState() {
    super.initState();
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scheduleNextQuote(isFirst: true);
  }

  void _scheduleNextQuote({bool isFirst = false, bool forceHideAfter = false}) {
    _quoteTimer?.cancel();

    if (forceHideAfter) {
      // It was just shown forcefully, hide it after 4 seconds
      _quoteTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _isVisible = false);
        _scheduleNextQuote(); // Reschedule normally
      });
      return;
    }

    if (_isVisible) {
      // Hide after 4 seconds
      _quoteTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _isVisible = false);
        _scheduleNextQuote();
      });
    } else {
      // Show after 6-10 seconds (or 3 seconds if first time)
      final waitSecs = isFirst ? 3 : 6 + _rng.nextInt(5);
      _quoteTimer = Timer(Duration(seconds: waitSecs), () {
        _pickQuote(null);
        if (mounted) {
          setState(() => _isVisible = true);
          SystemSound.play(SystemSoundType.click);
          HapticFeedback.selectionClick();
        }
        _scheduleNextQuote();
      });
    }
  }

  void _pickQuote(TimerStatus? statusOverride) {
    if (!mounted) return;
    final status = statusOverride ?? ref.read(timerProvider).status;
    List<String> pool;
    switch (status) {
      case TimerStatus.idle:
        pool = _idleQuotes;
        break;
      case TimerStatus.running:
        pool = _runningQuotes;
        break;
      case TimerStatus.paused:
        pool = _pausedQuotes;
        break;
      case TimerStatus.complete:
        pool = _completeQuotes;
        break;
    }
    _currentQuote = pool[_rng.nextInt(pool.length)];
  }

  @override
  void dispose() {
    _quoteTimer?.cancel();
    _breathe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(timerProvider.select((t) => t.status), (prev, next) {
      if (prev != next) {
        setState(() {
          _isVisible = true;
          _pickQuote(next);
        });
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.selectionClick();
        _scheduleNextQuote(forceHideAfter: true);
      }
    });

    if (!_isVisible) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _breathe,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -(_breathe.value * 4)),
          child: child,
        );
      },
      child: TweenAnimationBuilder<double>(
        key: ValueKey(_currentQuote), // Retrigger animation on new quote
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            alignment: Alignment.bottomLeft,
            child: child,
          );
        },
        child: CustomPaint(
          painter: _SpeechBubblePainter(),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 22),
            child: Text(
              _currentQuote,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Color(0xFF4A4A4A),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeechBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final path = Path();
    const r = 16.0;
    const tailW = 14.0;
    const tailH = 12.0;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height - tailH);
    path.addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(r)));

    // Tail pointing down-left
    path.moveTo(r + 10, rect.bottom);
    path.lineTo(r + 10, size.height);
    path.lineTo(r + tailW + 10, rect.bottom);
    path.close();

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
