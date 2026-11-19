import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Clean, minimal, and mathematically balanced circular repeat-loop logo.
/// Features two symmetrical circular arrows with tight, elegant spacing,
/// consistent curvature, and perfect legibility at all icon sizes.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showGlow;
  final bool animate;

  const AppLogo({
    super.key,
    this.size = 36,
    this.showGlow = false,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1), // Royal Indigo
            Color(0xFF4F46E5), // Deep Indigo
          ],
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                  blurRadius: size * 0.3,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.62, size * 0.62),
          painter: _CircularRepeatLoopPainter(),
        ),
      ),
    );
  }
}

class _CircularRepeatLoopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.40;
    final strokeWidth = size.width * 0.125;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Symmetrical tight arc sweep: ~140 degrees (2.44 radians), gap is small and balanced (~40 deg)
    const sweepAngle = 2.45; // ~140 degrees
    const topStartAngle = -math.pi * 0.90; // ~ -162 deg (starts top-left)
    const bottomStartAngle = math.pi * 0.10; // ~ 18 deg (starts bottom-right)

    // 1. Top Circular Arc (Clockwise from top-left to top-right)
    canvas.drawArc(rect, topStartAngle, sweepAngle, false, strokePaint);

    // Arrowhead 1 (at end of top arc: topStartAngle + sweepAngle)
    final endAngle1 = topStartAngle + sweepAngle;
    final tipX1 = center.dx + radius * math.cos(endAngle1);
    final tipY1 = center.dy + radius * math.sin(endAngle1);
    _drawArrowhead(
      canvas,
      tipX1,
      tipY1,
      endAngle1 + math.pi / 2,
      strokeWidth * 1.5,
      arrowPaint,
    );

    // 2. Bottom Circular Arc (Clockwise from bottom-right to bottom-left)
    canvas.drawArc(rect, bottomStartAngle, sweepAngle, false, strokePaint);

    // Arrowhead 2 (at end of bottom arc: bottomStartAngle + sweepAngle)
    final endAngle2 = bottomStartAngle + sweepAngle;
    final tipX2 = center.dx + radius * math.cos(endAngle2);
    final tipY2 = center.dy + radius * math.sin(endAngle2);
    _drawArrowhead(
      canvas,
      tipX2,
      tipY2,
      endAngle2 + math.pi / 2,
      strokeWidth * 1.5,
      arrowPaint,
    );
  }

  void _drawArrowhead(
    Canvas canvas,
    double x,
    double y,
    double angle,
    double size,
    Paint paint,
  ) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);

    final path = Path()
      ..moveTo(0, size * 0.70) // Tip
      ..lineTo(-size * 0.60, -size * 0.50)
      ..lineTo(size * 0.60, -size * 0.50)
      ..close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
