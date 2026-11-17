import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/liquid_glass_theme.dart';

/// Professional, custom vector-drawn branding logo for Repeat Speaker.
/// Depicts a continuous infinity loop intertwined with acoustic sound waves
/// and subtle glass light reflection.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showGlow;
  final bool animate;

  const AppLogo({
    super.key,
    this.size = 38,
    this.showGlow = true,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget logo = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.45),
                  blurRadius: size * 0.4,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: const Color(0xFF00F2FE).withValues(alpha: 0.35),
                  blurRadius: size * 0.25,
                  offset: const Offset(-2, -2),
                ),
              ]
            : null,
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _RepeatSpeakerLogoPainter(),
      ),
    );

    return logo;
  }
}

class _RepeatSpeakerLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Frosted Glass Disc Background
    final discPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF2A2E4D), Color(0xFF141726)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, discPaint);

    // Rim Highlight
    final rimPaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFF00F2FE),
          Color(0xFF6366F1),
          Color(0xFFA855F7),
          Color(0xFF00F2FE),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.055;
    canvas.drawCircle(center, radius - rimPaint.strokeWidth / 2, rimPaint);

    // 2. Continuous Infinity / Repeat Loop Symbol
    final scale = size.width / 100.0;
    final loopPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00F2FE), Color(0xFF6366F1), Color(0xFFEC4899)],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.7))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 6.5 * scale;

    final path = Path();
    // Mathematical Lemniscate / Infinity curve
    final a = 24.0 * scale;
    for (double t = 0; t <= 2 * math.pi; t += 0.05) {
      final denom = 1 + math.sin(t) * math.sin(t);
      final x = center.dx + (a * math.cos(t)) / denom;
      final y = center.dy + (a * math.sin(t) * math.cos(t)) / denom;
      if (t == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, loopPaint);

    // 3. Central Sound Emission Dots
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 2.5 * scale, dotPaint);

    // Left and Right Audio Waves
    final wavePaint = Paint()
      ..color = const Color(0xFF00F2FE).withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0 * scale;

    // Right acoustic arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 14 * scale),
      -math.pi / 4,
      math.pi / 2,
      false,
      wavePaint,
    );

    // Left acoustic arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 14 * scale),
      3 * math.pi / 4,
      math.pi / 2,
      false,
      wavePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
