import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

import '../providers/timer_provider.dart';
import '../providers/settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/audio_service.dart';
import 'reactive_egg.dart';
import 'egg_dialogue.dart';

class EggAnimationWidget extends ConsumerStatefulWidget {
  const EggAnimationWidget({super.key});

  @override
  ConsumerState<EggAnimationWidget> createState() => _EggAnimationWidgetState();
}

class _EggAnimationWidgetState extends ConsumerState<EggAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _bubbleController;
  late Animation<double> _bubbleAnim;

  @override
  void initState() {
    super.initState();

    _bubbleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
    _bubbleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_bubbleController);
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animState = ref.watch(animationStateProvider);
    final progress = ref.watch(progressProvider);

    final bubbleMs = (900 - (progress * 600)).clamp(300, 900).toInt();
    if (_bubbleController.duration?.inMilliseconds != bubbleMs) {
      _bubbleController.duration = Duration(milliseconds: bubbleMs);
      if (_bubbleController.isAnimating) _bubbleController.repeat();
    }

    return AnimatedBuilder(
      animation: _bubbleAnim,
      builder: (context, _) {
        final double h = 340;
        final double potTop = h * 0.40;
        final double potBottom = h * 0.90;
        final double potH = potBottom - potTop;
        final double waterRatio = 0.72 + progress * 0.15; // Increased base level
        final double waterY = potBottom - (potH * waterRatio);

        return SizedBox(
          width: 300,
          height: 340,
          child: Stack(
            children: [
              // 1. Back Pot & Water
              Positioned.fill(
                child: CustomPaint(
                  painter: _PotBackPainter(
                    animState: animState,
                    progress: progress,
                  ),
                ),
              ),
              
              // 2. The Reactive Egg
              Positioned(
                left: 0,
                right: 0,
                bottom: 340 - waterY - 30, // Keep it floating higher, showing face
                child: Center(
                  child: ReactiveEgg(
                    boilingIntensity: progress,
                    isPaused: animState == AnimationState.paused,
                  ),
                ),
              ),

              // 3. Front Pot, Water Surface, Bubbles, Steam
              Positioned.fill(
                child: CustomPaint(
                  painter: _PotFrontPainter(
                    animState: animState,
                    progress: progress,
                    bubbleT: _bubbleAnim.value,
                    isPaused: animState == AnimationState.paused,
                  ),
                ),
              ),
              
              // 4. Egg Dialogue
              const Positioned(
                top: 40,
                right: 20,
                child: EggDialogueWidget(),
              ),
              
              // 5. Egg Count Badge
              const Positioned(
                bottom: 20,
                right: 15,
                child: EggCountBadge(),
              ),
            ],
          ),
        );
      },
    );
  }
}

Color _getWaterColor(AnimationState animState) {
  switch (animState) {
    case AnimationState.chilling: return const Color(0xFF81D4FA);
    case AnimationState.warming: return const Color(0xFF4FC3F7);
    case AnimationState.boiling:
    case AnimationState.panic: return const Color(0xFF29B6F6);
    case AnimationState.celebrate: return const Color(0xFF29B6F6);
    case AnimationState.paused: return const Color(0xFF81D4FA);
  }
}

double _bowlWidthAt(double y, double top, double bottom, double topW, double bottomW) {
  if (y <= top) return topW;
  if (y >= bottom) return bottomW;
  final t = (y - top) / (bottom - top);
  return bottomW + (topW - bottomW) * sqrt(1.0 - t * t);
}

Path _getBowlSilhouette(double cx, double top, double bottom, double topW, double bottomW, {bool close = true}) {
  final path = Path();
  path.moveTo(cx - topW / 2, top);
  
  final int steps = 30;
  for (int i = 1; i <= steps; i++) {
    final t = i / steps;
    final y = top + (bottom - top) * t;
    final tSq = t * t;
    final w = bottomW + (topW - bottomW) * sqrt(1.0 - tSq.clamp(0.0, 1.0));
    path.lineTo(cx - w / 2, y);
  }
  
  // Front bottom arc
  final bottomRect = Rect.fromCenter(center: Offset(cx, bottom), width: bottomW, height: bottomW * 0.25);
  path.arcTo(bottomRect, pi, -pi, false);
  
  for (int i = steps - 1; i >= 0; i--) {
    final t = i / steps;
    final y = top + (bottom - top) * t;
    final tSq = t * t;
    final w = bottomW + (topW - bottomW) * sqrt(1.0 - tSq.clamp(0.0, 1.0));
    path.lineTo(cx + w / 2, y);
  }
  if (close) path.close();
  return path;
}

Path _getWaterBodyPath(double cx, double waterY, double potBottom, double potTop, double potW, double bottomW, {required bool isFront}) {
  final path = Path();
  final waterW = _bowlWidthAt(waterY, potTop, potBottom, potW, bottomW);
  final int steps = 20;

  path.moveTo(cx - waterW / 2, waterY);
  // Left wall
  for (int i = 1; i <= steps; i++) {
    final t = i / steps;
    final y = waterY + (potBottom - waterY) * t;
    final w = _bowlWidthAt(y, potTop, potBottom, potW, bottomW);
    path.lineTo(cx - w / 2, y);
  }
  // Bottom arc
  final bottomRect = Rect.fromCenter(center: Offset(cx, potBottom), width: bottomW, height: bottomW * 0.25);
  path.arcTo(bottomRect, pi, -pi, false);
  // Right wall
  for (int i = steps - 1; i >= 0; i--) {
    final t = i / steps;
    final y = waterY + (potBottom - waterY) * t;
    final w = _bowlWidthAt(y, potTop, potBottom, potW, bottomW);
    path.lineTo(cx + w / 2, y);
  }
  // Connect right to left via the elliptical surface
  final Rect surfaceRect = Rect.fromCenter(center: Offset(cx, waterY), width: waterW, height: waterW * 0.25);
  path.arcTo(surfaceRect, 0, isFront ? pi : -pi, false);
  return path;
}

// ═══════════════════════════════════════════════════════════════════════════
// POT BACK PAINTER
// ═══════════════════════════════════════════════════════════════════════════
class _PotBackPainter extends CustomPainter {
  final AnimationState animState;
  final double progress;

  _PotBackPainter({
    required this.animState,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final potTop = h * 0.40;
    final potBottom = h * 0.90;
    final potH = potBottom - potTop;
    final potW = w * 0.90;
    final bottomW = potW * 0.55;

    final potMouthRect = Rect.fromCenter(
        center: Offset(cx, potTop), width: potW, height: potW * 0.25);

    final waterRatio = 0.72 + progress * 0.15;
    final waterY = potBottom - (potH * waterRatio);

    // Back rim stroke (glass bowl opening back)
    canvas.drawArc(
        potMouthRect, pi, pi, false, Paint()..color = const Color(0xFF91CDE4).withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 3);
        
    // Base rim stroke (back of base)
    final bottomRect = Rect.fromCenter(center: Offset(cx, potBottom), width: bottomW, height: bottomW * 0.25);
    canvas.drawArc(
        bottomRect, pi, pi, false, Paint()..color = const Color(0xFF91CDE4).withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 2);

    final waterW = _bowlWidthAt(waterY, potTop, potBottom, potW, bottomW);
    final waterEllipseRect = Rect.fromCenter(
        center: Offset(cx, waterY), width: waterW, height: waterW * 0.25);

    // Draw Back Water Volume
    final backWaterPath = _getWaterBodyPath(cx, waterY, potBottom, potTop, potW, bottomW, isFront: false);
    canvas.drawPath(
      backWaterPath,
      Paint()..color = _getWaterColor(animState).withOpacity(0.55),
    );
    
    // Draw the full surface base ellipse (lighter)
    canvas.drawOval(
      waterEllipseRect,
      Paint()..color = _getWaterColor(animState).withOpacity(0.3),
    );
  }

  @override
  bool shouldRepaint(_PotBackPainter o) =>
      o.animState != animState || o.progress != progress;
}

// ═══════════════════════════════════════════════════════════════════════════
// POT FRONT PAINTER
// ═══════════════════════════════════════════════════════════════════════════
class _PotFrontPainter extends CustomPainter {
  final AnimationState animState;
  final double progress;
  final double bubbleT;
  final bool isPaused;

  _PotFrontPainter({
    required this.animState,
    required this.progress,
    required this.bubbleT,
    this.isPaused = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final potTop = h * 0.40;
    final potBottom = h * 0.90;
    final potH = potBottom - potTop;
    final potW = w * 0.90; 
    final bottomW = potW * 0.55;

    final waterRatio = 0.72 + progress * 0.15;
    final waterY = potBottom - (potH * waterRatio);
    final potMouthRect = Rect.fromCenter(center: Offset(cx, potTop), width: potW, height: potW * 0.25);

    // 1. Water Front Volume
    final frontWaterPath = _getWaterBodyPath(cx, waterY, potBottom, potTop, potW, bottomW, isFront: true);
    canvas.drawPath(frontWaterPath, Paint()..color = _getWaterColor(animState).withOpacity(0.5));

    // Bubbles
    if (!isPaused) {
      _drawBubbles(canvas, cx, waterY, potBottom, potW, bottomW, potTop, potBottom);
    }

    // 2. Bowl Glass Front
    final bowlShape = _getBowlSilhouette(cx, potTop, potBottom, potW, bottomW, close: true);
    final bowlStroke = _getBowlSilhouette(cx, potTop, potBottom, potW, bottomW, close: false);
    
    // Glass body tint
    canvas.drawPath(bowlShape, Paint()..color = const Color(0xFFAFE1FA).withOpacity(0.15));

    // Reflections
    canvas.save();
    canvas.clipPath(bowlShape);
    
    // Thick white streaks simulating light reflecting off the rounded glass
    final streakPaint = Paint()..color = Colors.white.withOpacity(0.35)..style = PaintingStyle.stroke..strokeWidth = 15..strokeCap = StrokeCap.round..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    
    final streakPath = Path();
    for(int i = 2; i < 25; i++) {
        final t = i / 30;
        final y = potTop + potH * t;
        final bw = _bowlWidthAt(y, potTop, potBottom, potW, bottomW);
        if (i == 2) {
            streakPath.moveTo(cx - bw/2 + 35, y);
        } else {
            streakPath.lineTo(cx - bw/2 + 35, y);
        }
    }
    canvas.drawPath(streakPath, streakPaint);

    final streakPaintThin = Paint()..color = Colors.white.withOpacity(0.2)..style = PaintingStyle.stroke..strokeWidth = 6..strokeCap = StrokeCap.round;
    final streakPathThin = Path();
    for(int i = 5; i < 20; i++) {
        final t = i / 30;
        final y = potTop + potH * t;
        final bw = _bowlWidthAt(y, potTop, potBottom, potW, bottomW);
        if (i == 5) {
            streakPathThin.moveTo(cx + bw/2 - 25, y);
        } else {
            streakPathThin.lineTo(cx + bw/2 - 25, y);
        }
    }
    canvas.drawPath(streakPathThin, streakPaintThin);

    canvas.restore();

    // 3. Pot outlines
    canvas.drawPath(
      bowlStroke,
      Paint()
        ..color = const Color(0xFF91CDE4).withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );

    // Front mouth rim
    canvas.drawArc(
      potMouthRect,
      0,
      pi,
      false,
      Paint()
        ..color = const Color(0xFFCDEEFE).withOpacity(0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );
    canvas.drawArc(
      potMouthRect,
      0,
      pi,
      false,
      Paint()
        ..color = Colors.white.withOpacity(0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    
    // Front base rim
    final bottomRect = Rect.fromCenter(center: Offset(cx, potBottom), width: bottomW, height: bottomW * 0.25);
    canvas.drawArc(
      bottomRect,
      0,
      pi,
      false,
      Paint()
        ..color = const Color(0xFF91CDE4).withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  void _drawBubbles(Canvas canvas, double cx, double topY, double b, double topW, double bottomW, double potTop, double potBottom) {
    if (progress <= 0) return;
    final rng = Random(42);
    final count = (progress * 25).ceil();
    
    for (int i = 0; i < count; i++) {
      final delay = rng.nextDouble();
      final t = ((bubbleT + delay) % 1.0);
      
      final by = b - 15 - t * (b - topY - 15);
      final maxWidth = _bowlWidthAt(by, potTop, potBottom, topW, bottomW);
      final rx = (rng.nextDouble() * 2 - 1);
      final bx = cx + rx * (maxWidth / 2 - 15);
      
      final br = 4.0 + rng.nextDouble() * 8.0;
      final op = (0.8 * (1 - t)).clamp(0.0, 1.0);
      
      canvas.drawCircle(Offset(bx, by), br, Paint()..color = const Color(0xFF81D4FA).withOpacity(op * 0.7));
      canvas.drawCircle(Offset(bx, by), br, Paint()..color = Colors.white.withOpacity(op)..style = PaintingStyle.stroke..strokeWidth = 2.0);
      canvas.drawCircle(Offset(bx - br * 0.3, by - br * 0.3), br * 0.2, Paint()..color = Colors.white.withOpacity(op));

      if (animState == AnimationState.boiling || animState == AnimationState.panic) {
         if (i % 3 == 0) {
           final steamY = topY - (t * 60) - 10;
           final steamX = bx + sin(t * pi * 4) * 15;
           final steamOp = (1 - t) * 0.5;
           
           final steamPath = Path()
             ..moveTo(steamX, steamY)
             ..quadraticBezierTo(steamX - 15, steamY - 15, steamX + 5, steamY - 25)
             ..quadraticBezierTo(steamX + 15, steamY - 35, steamX, steamY - 50);
             
           canvas.drawPath(steamPath, Paint()..color = Colors.white.withOpacity(steamOp.clamp(0.0, 1.0))..style = PaintingStyle.stroke..strokeWidth = 6..strokeCap = StrokeCap.round..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
         }
      }
    }
  }

  @override
  bool shouldRepaint(_PotFrontPainter o) =>
      o.animState != animState ||
      o.progress != progress ||
      o.bubbleT != bubbleT;
}

class EggCountBadge extends ConsumerWidget {
  const EggCountBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eggConfig = ref.watch(eggSettingsProvider);
    final count = eggConfig.eggCount;
    final isLocked = ref.watch(timerProvider).status == TimerStatus.running ||
        ref.watch(timerProvider).status == TimerStatus.paused;
    final cs = Theme.of(context).colorScheme;

    if (count > 1) {
      return GestureDetector(
        onTap: isLocked ? null : () {
          AudioService.instance.playClick();
          _showCountAdjuster(context, ref, count);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count Eggs',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              if (!isLocked) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    AudioService.instance.playClick();
                    ref.read(eggSettingsProvider.notifier).setEggCount(1);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    } else {
      // count == 1
      return GestureDetector(
        onTap: isLocked ? null : () {
          AudioService.instance.playClick();
          _showCountAdjuster(context, ref, count);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: cs.outline.withOpacity(0.4), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 22, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                'Egg',
                style: TextStyle(
                  color: cs.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showCountAdjuster(
      BuildContext context, WidgetRef ref, int initialCount) {
    int tempCount = initialCount;
    showDialog(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              backgroundColor: cs.surface,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.egg_alt_outlined,
                        size: 48, color: cs.primary),
                    const SizedBox(height: 16),
                    Text(
                      'How many eggs?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: tempCount > 1
                              ? () {
                                  AudioService.instance.playClick();
                                  setState(() => tempCount--);
                                }
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          color: cs.primary,
                          iconSize: 32,
                        ),
                        const SizedBox(width: 24),
                        Text(
                          '$tempCount',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          onPressed: tempCount < 12
                              ? () {
                                  AudioService.instance.playClick();
                                  setState(() => tempCount++);
                                }
                              : null,
                          icon: const Icon(Icons.add_circle_outline),
                          color: cs.primary,
                          iconSize: 32,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel',
                                style: TextStyle(
                                    color: cs.onSurface.withOpacity(0.5),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              AudioService.instance.playClick();
                              ref
                                  .read(eggSettingsProvider.notifier)
                                  .setEggCount(tempCount);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                            ),
                            child: const Text('Confirm',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

