import 'dart:math';
import 'package:flutter/material.dart';

enum EggEmotion { chilled, relaxed, panicked, ascended }

class ReactiveEgg extends StatefulWidget {
  final double boilingIntensity;

  const ReactiveEgg({
    super.key,
    required this.boilingIntensity,
  });

  @override
  State<ReactiveEgg> createState() => _ReactiveEggState();
}

class _ReactiveEggState extends State<ReactiveEgg>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnim;

  late AnimationController _shiverController;
  late Animation<double> _shiverAnim;

  late AnimationController _bobController;
  late Animation<double> _bobAnim;

  late AnimationController _ascendController;
  late Animation<double> _ascendAnim;
  late Animation<double> _wingsAnim;

  late AnimationController _blinkController;
  late Animation<double> _blinkAnim;

  late AnimationController _jumpController;
  late Animation<double> _jumpAnim;

  late AnimationController _stateTransitionController;
  late Animation<double> _stateTransitionAnim;

  EggEmotion _currentEmotion = EggEmotion.relaxed;
  EggEmotion _previousEmotion = EggEmotion.relaxed;

  bool _isSurprised = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _updateEmotion(widget.boilingIntensity);
    _scheduleBlink();
  }

  void _initAnimations() {
    // Breathing (Scale Y)
    _breathingController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _breathingAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut));

    // Shiver (Rotation)
    _shiverController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 50));
    _shiverAnim = Tween<double>(begin: -0.05, end: 0.05).animate(
        CurvedAnimation(parent: _shiverController, curve: Curves.linear));

    // Bobbing (Translate Y)
    _bobController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _bobAnim = Tween<double>(begin: -10.0, end: 10.0).animate(
        CurvedAnimation(parent: _bobController, curve: Curves.easeInOut));

    // Ascend (Translate Y & Wings)
    _ascendController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
    _ascendAnim = Tween<double>(begin: 0.0, end: -50.0).animate(
        CurvedAnimation(parent: _ascendController, curve: Curves.easeOut));
    _wingsAnim = Tween<double>(begin: -0.2, end: 0.2).animate(
        CurvedAnimation(parent: _ascendController, curve: Curves.linear));

    // Blink (Open/Closed Eye T)
    _blinkController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _blinkAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_blinkController);

    // Jump / Surprised (Translate Y)
    _jumpController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _jumpAnim = Tween<double>(begin: 0.0, end: -40.0).animate(
        CurvedAnimation(parent: _jumpController, curve: Curves.easeOutBack));

    // State Transition (Morphing T)
    _stateTransitionController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _stateTransitionAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _stateTransitionController, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant ReactiveEgg oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.boilingIntensity != widget.boilingIntensity) {
      _updateEmotion(widget.boilingIntensity);
    }
  }

  void _updateEmotion(double intensity) {
    var nextEmotion = _getEmotionFromIntensity(intensity);
    if (nextEmotion != _currentEmotion) {
      _previousEmotion = _currentEmotion;
      _currentEmotion = nextEmotion;
      _transitionTo(nextEmotion);
    }
  }

  EggEmotion _getEmotionFromIntensity(double intensity) {
    if (intensity >= 1.0) return EggEmotion.ascended;
    if (intensity >= 0.7) return EggEmotion.panicked;
    return EggEmotion.relaxed;
  }

  void _transitionTo(EggEmotion next) {
    _stateTransitionController.forward(from: 0.0);

    // Stop all conditional anims
    _shiverController.stop();
    _bobController.stop();
    _breathingController.stop();
    _ascendController.stop();

    if (next == EggEmotion.chilled) {
      _shiverController.repeat(reverse: true);
    } else if (next == EggEmotion.relaxed) {
      _breathingController.repeat(reverse: true);
    } else if (next == EggEmotion.panicked) {
      _bobController.repeat(reverse: true);
    } else if (next == EggEmotion.ascended) {
      _ascendController.repeat(reverse: true);
    }
  }

  Future<void> _scheduleBlink() async {
    while (mounted) {
      final wait = 2000 + Random().nextInt(4000);
      await Future.delayed(Duration(milliseconds: wait));
      if (!mounted) break;
      if (_currentEmotion == EggEmotion.ascended ||
          _currentEmotion == EggEmotion.chilled ||
          _isSurprised) {
        continue;
      }
      await _blinkController.forward();
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) break;
      await _blinkController.reverse();
    }
  }

  void _handleTap() async {
    if (_isSurprised || _currentEmotion == EggEmotion.ascended) return;

    setState(() {
      _isSurprised = true;
    });

    _jumpController.forward();
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      _jumpController.reverse();
      setState(() {
        _isSurprised = false;
      });
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _shiverController.dispose();
    _bobController.dispose();
    _ascendController.dispose();
    _blinkController.dispose();
    _jumpController.dispose();
    _stateTransitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _breathingAnim,
          _shiverAnim,
          _bobAnim,
          _ascendAnim,
          _wingsAnim,
          _blinkAnim,
          _jumpAnim,
          _stateTransitionAnim,
        ]),
        builder: (context, _) {
          double scaleY = 1.0;
          double rotZ = 0.0;
          double translateY = _jumpAnim.value;

          if (_currentEmotion == EggEmotion.chilled) {
            rotZ = _shiverAnim.value;
          } else if (_currentEmotion == EggEmotion.relaxed) {
            scaleY = _breathingAnim.value;
          } else if (_currentEmotion == EggEmotion.panicked) {
            translateY += _bobAnim.value;
          } else if (_currentEmotion == EggEmotion.ascended) {
            translateY += _ascendAnim.value;
          }

          return Transform(
            alignment: Alignment.bottomCenter,
            transform: Matrix4.identity()
              ..translate(0.0, translateY)
              ..rotateZ(rotZ)
              ..scale(1.0, scaleY),
            child: CustomPaint(
              size: const Size(120, 160),
              painter: _EggPainter(
                currentEmotion: _currentEmotion,
                previousEmotion: _previousEmotion,
                transitionT: _stateTransitionAnim.value,
                blinkT: _blinkAnim.value,
                wingsT: _wingsAnim.value,
                isSurprised: _isSurprised,
                intensity: widget.boilingIntensity,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EggPainter extends CustomPainter {
  final EggEmotion currentEmotion;
  final EggEmotion previousEmotion;
  final double transitionT;
  final double blinkT;
  final double wingsT;
  final bool isSurprised;
  final double intensity; // To drive sweat drops

  _EggPainter({
    required this.currentEmotion,
    required this.previousEmotion,
    required this.transitionT,
    required this.blinkT,
    required this.wingsT,
    required this.isSurprised,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final c = Offset(w / 2, h / 2);
    final eggRect = Rect.fromCenter(center: c, width: w, height: h);

    _drawShadow(canvas, eggRect);

    if (currentEmotion == EggEmotion.ascended ||
        (previousEmotion == EggEmotion.ascended && transitionT < 1.0)) {
      _drawHaloAndWings(canvas, c, w, h);
    }

    _drawBody(canvas, eggRect);
    _drawFace(canvas, c, w, h);

    if (currentEmotion == EggEmotion.panicked) {
      _drawSweat(canvas, c, w, h);
    }
  }

  Color _lerpColor(Color a, Color b, double t) {
    return Color.lerp(a, b, t) ?? b;
  }

  Color _getEmotionBaseColor(EggEmotion emotion) {
    switch (emotion) {
      case EggEmotion.chilled:
        return const Color(0xFFB3E5FC); // Light Blueish
      case EggEmotion.relaxed:
        return const Color(0xFFFFB347); // Warm Yellow/Orange
      case EggEmotion.panicked:
        return const Color(0xFFFF8A65); // Reddish
      case EggEmotion.ascended:
        return const Color(0xFFFFD54F); // Golden
    }
  }

  Color _getEmotionDarkColor(EggEmotion emotion) {
    switch (emotion) {
      case EggEmotion.chilled:
        return const Color(0xFF0288D1);
      case EggEmotion.relaxed:
        return const Color(0xFFFF8C00);
      case EggEmotion.panicked:
        return const Color(0xFFD84315);
      case EggEmotion.ascended:
        return const Color(0xFFFF8F00);
    }
  }

  void _drawShadow(Canvas canvas, Rect eggRect) {
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(eggRect.center.dx, eggRect.bottom),
          width: eggRect.width * 0.8,
          height: 20),
      Paint()
        ..color = Colors.black.withOpacity(0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
  }

  void _drawBody(Canvas canvas, Rect eggRect) {
    final baseColor = _lerpColor(_getEmotionBaseColor(previousEmotion),
        _getEmotionBaseColor(currentEmotion), transitionT);
    final darkColor = _lerpColor(_getEmotionDarkColor(previousEmotion),
        _getEmotionDarkColor(currentEmotion), transitionT);

    canvas.drawOval(
      eggRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          radius: 0.9,
          colors: [Colors.white.withOpacity(0.9), baseColor, darkColor],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(eggRect),
    );

    canvas.drawOval(
      eggRect.deflate(2),
      Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawFace(Canvas canvas, Offset c, double w, double h) {
    final faceY = c.dy - 10;
    final leftEyeC = Offset(c.dx - 18, faceY);
    final rightEyeC = Offset(c.dx + 18, faceY);
    final mouthC = Offset(c.dx, faceY + 25);

    if (isSurprised) {
      _drawSurprisedFace(canvas, leftEyeC, rightEyeC, mouthC);
      return;
    }

    _drawInterpolatedFace(canvas, leftEyeC, rightEyeC, mouthC);
  }

  void _drawSurprisedFace(
      Canvas canvas, Offset leftEye, Offset rightEye, Offset mouth) {
    // Wide open eyes
    final eyeP = Paint()..color = const Color(0xFF1E1E1E);
    canvas.drawCircle(leftEye, 8, eyeP);
    canvas.drawCircle(rightEye, 8, eyeP);

    // Small O mouth
    canvas.drawCircle(Offset(mouth.dx, mouth.dy + 5), 6, eyeP);
  }

  void _drawInterpolatedFace(
      Canvas canvas, Offset leftEyeC, Offset rightEyeC, Offset mouthC) {
    // Determine target eye and mouth shapes based on current emotion
    // To keep it simple, we draw explicit shapes for each target and blend them
    // For pure vector morphing, we use standard Paths or primitives based on states.

    if (currentEmotion == EggEmotion.chilled ||
        (previousEmotion == EggEmotion.chilled && transitionT < 0.5)) {
      _drawChilledFace(canvas, leftEyeC, rightEyeC, mouthC);
    } else if (currentEmotion == EggEmotion.panicked ||
        (previousEmotion == EggEmotion.panicked && transitionT < 0.5)) {
      _drawPanickedFace(canvas, leftEyeC, rightEyeC, mouthC);
    } else if (currentEmotion == EggEmotion.ascended ||
        (previousEmotion == EggEmotion.ascended && transitionT < 0.5)) {
      _drawAscendedFace(canvas, leftEyeC, rightEyeC, mouthC);
    } else {
      _drawRelaxedFace(canvas, leftEyeC, rightEyeC, mouthC);
    }
  }

  void _drawChilledFace(
      Canvas canvas, Offset leftEye, Offset rightEye, Offset mouth) {
    final eyeP = Paint()
      ..color = const Color(0xFF1E1E1E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // "><" Eyes
    canvas.drawLine(
        Offset(leftEye.dx - 6, leftEye.dy - 4), Offset(leftEye.dx + 4, leftEye.dy + 2), eyeP);
    canvas.drawLine(
        Offset(leftEye.dx - 6, leftEye.dy + 6), Offset(leftEye.dx + 4, leftEye.dy), eyeP);
        
    canvas.drawLine(Offset(rightEye.dx + 6, rightEye.dy - 4),
        Offset(rightEye.dx - 4, rightEye.dy + 2), eyeP);
    canvas.drawLine(Offset(rightEye.dx + 6, rightEye.dy + 6),
        Offset(rightEye.dx - 4, rightEye.dy), eyeP);

    // Wavy mouth
    final mouthP = Path()
      ..moveTo(mouth.dx - 8, mouth.dy)
      ..quadraticBezierTo(mouth.dx - 4, mouth.dy - 3, mouth.dx, mouth.dy)
      ..quadraticBezierTo(mouth.dx + 4, mouth.dy + 3, mouth.dx + 8, mouth.dy);
    canvas.drawPath(mouthP, eyeP);
  }

  void _drawRelaxedFace(
      Canvas canvas, Offset leftEye, Offset rightEye, Offset mouth) {
    final eyeP = Paint()
      ..color = const Color(0xFF1E1E1E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    if (blinkT > 0.5) {
      canvas.drawLine(Offset(leftEye.dx - 6, leftEye.dy),
          Offset(leftEye.dx + 6, leftEye.dy), eyeP);
      canvas.drawLine(Offset(rightEye.dx - 6, rightEye.dy),
          Offset(rightEye.dx + 6, rightEye.dy), eyeP);
    } else {
      // U shaped eyes
      canvas.drawArc(
          Rect.fromCenter(center: leftEye, width: 12, height: 12),
          0,
          pi,
          false,
          eyeP);
      canvas.drawArc(
          Rect.fromCenter(center: rightEye, width: 12, height: 12),
          0,
          pi,
          false,
          eyeP);
    }

    // Smile
    canvas.drawArc(
        Rect.fromCenter(center: Offset(mouth.dx, mouth.dy - 5), width: 16, height: 16),
        0,
        pi,
        false,
        eyeP);
  }

  void _drawPanickedFace(
      Canvas canvas, Offset leftEye, Offset rightEye, Offset mouth) {
    // Wide circles
    final eyeP = Paint()..color = const Color(0xFF1E1E1E);
    canvas.drawOval(
        Rect.fromCenter(center: leftEye, width: 12, height: 16), eyeP);
    canvas.drawOval(
        Rect.fromCenter(center: rightEye, width: 12, height: 16), eyeP);

    // Big O
    canvas.drawOval(
        Rect.fromCenter(center: Offset(mouth.dx, mouth.dy + 5), width: 14, height: 20),
        eyeP);
    
    // Inner dark red mouth
    canvas.drawOval(
        Rect.fromCenter(center: Offset(mouth.dx, mouth.dy + 5), width: 8, height: 12),
        Paint()..color = const Color(0xFF8E0000));
  }

  void _drawAscendedFace(
      Canvas canvas, Offset leftEye, Offset rightEye, Offset mouth) {
    final eyeP = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // "^ ^" Eyes
    final dl = Path()
      ..moveTo(leftEye.dx - 6, leftEye.dy + 4)
      ..quadraticBezierTo(
          leftEye.dx, leftEye.dy - 4, leftEye.dx + 6, leftEye.dy + 4);
    final dr = Path()
      ..moveTo(rightEye.dx - 6, rightEye.dy + 4)
      ..quadraticBezierTo(
          rightEye.dx, rightEye.dy - 4, rightEye.dx + 6, rightEye.dy + 4);

    canvas.drawPath(dl, eyeP);
    canvas.drawPath(dr, eyeP);

    // Peaceful small smile
    canvas.drawArc(
        Rect.fromCenter(center: Offset(mouth.dx, mouth.dy), width: 10, height: 8),
        0.2,
        pi - 0.4,
        false,
        eyeP);
  }

  void _drawSweat(Canvas canvas, Offset c, double w, double h) {
    // Just a static representation driven by intensity.
    // In actual implementation, we'd use external animation value, but here it's fine.
    final sweat1 = Offset(c.dx + w * 0.35, c.dy - h * 0.2);
    final sweat2 = Offset(c.dx - w * 0.3, c.dy - h * 0.1);

    final dropP = Paint()..color = Colors.lightBlueAccent.withOpacity(0.8);

    Path makeDrop(Offset p) {
      return Path()
        ..moveTo(p.dx, p.dy - 6)
        ..quadraticBezierTo(p.dx + 4, p.dy, p.dx + 4, p.dy + 4)
        ..arcToPoint(Offset(p.dx - 4, p.dy + 4),
            radius: const Radius.circular(4))
        ..quadraticBezierTo(p.dx - 4, p.dy, p.dx, p.dy - 6);
    }

    canvas.drawPath(makeDrop(sweat1), dropP);
    canvas.drawPath(makeDrop(sweat2), dropP);
  }

  void _drawHaloAndWings(Canvas canvas, Offset c, double w, double h) {
    // Halo
    canvas.drawOval(
      Rect.fromCenter(center: Offset(c.dx, c.dy - h * 0.55), width: w * 0.7, height: 16),
      Paint()
        ..color = const Color(0xFFFFD54F).withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Wings
    final wingP = Paint()..color = Colors.white.withOpacity(0.9);
    
    // Left Wing
    canvas.save();
    canvas.translate(c.dx - w * 0.45, c.dy);
    canvas.rotate(wingsT);
    final leftWing = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-30, -20, -40, 0)
      ..quadraticBezierTo(-20, 20, 0, 10);
    canvas.drawPath(leftWing, wingP);
    canvas.restore();

    // Right Wing
    canvas.save();
    canvas.translate(c.dx + w * 0.45, c.dy);
    canvas.rotate(-wingsT);
    final rightWing = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(30, -20, 40, 0)
      ..quadraticBezierTo(20, 20, 0, 10);
    canvas.drawPath(rightWing, wingP);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_EggPainter oldDelegate) {
    return true; // We animate continuously
  }
}
