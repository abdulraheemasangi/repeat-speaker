import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Premium, Lucide-style vector icon set for Repeat Speaker.
/// Handcrafted with crisp 2.0 stroke width, rounded caps, and pixel-perfect scaling.
/// Eliminates all emoji dependencies for a professional, top-tier aesthetic.
class AppIcon extends StatelessWidget {
  final Widget Function(BuildContext context, Color color, double strokeWidth)
  builder;
  final double size;
  final Color? color;
  final double strokeWidth;

  const AppIcon._({
    super.key,
    required this.builder,
    this.size = 20,
    this.color,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? IconTheme.of(context).color ?? const Color(0xFF6366F1);
    return SizedBox(
      width: size,
      height: size,
      child: builder(context, effectiveColor, strokeWidth),
    );
  }

  /// Lucide Infinity (Figure-8 loop)
  factory AppIcon.infinity({
    Key? key,
    double size = 20,
    Color? color,
    double strokeWidth = 2.0,
  }) {
    return AppIcon._(
      key: key,
      size: size,
      color: color,
      strokeWidth: strokeWidth,
      builder: (_, c, sw) => CustomPaint(painter: _InfinityPainter(c, sw)),
    );
  }

  /// Lucide Repeat (Dual clockwise loop arrows)
  factory AppIcon.repeat({
    Key? key,
    double size = 20,
    Color? color,
    double strokeWidth = 2.0,
  }) {
    return AppIcon._(
      key: key,
      size: size,
      color: color,
      strokeWidth: strokeWidth,
      builder: (_, c, sw) => CustomPaint(painter: _RepeatPainter(c, sw)),
    );
  }

  /// Lucide Plus (+)
  factory AppIcon.plus({
    Key? key,
    double size = 20,
    Color? color,
    double strokeWidth = 2.0,
  }) {
    return AppIcon._(
      key: key,
      size: size,
      color: color,
      strokeWidth: strokeWidth,
      builder: (_, c, sw) => CustomPaint(painter: _PlusPainter(c, sw)),
    );
  }

  /// Lucide Minus (−)
  factory AppIcon.minus({
    Key? key,
    double size = 20,
    Color? color,
    double strokeWidth = 2.0,
  }) {
    return AppIcon._(
      key: key,
      size: size,
      color: color,
      strokeWidth: strokeWidth,
      builder: (_, c, sw) => CustomPaint(painter: _MinusPainter(c, sw)),
    );
  }

  /// Lucide Play (Filled / Outlined Playhead)
  factory AppIcon.play({
    Key? key,
    double size = 20,
    Color? color,
    double strokeWidth = 2.0,
    bool filled = true,
  }) {
    return AppIcon._(
      key: key,
      size: size,
      color: color,
      strokeWidth: strokeWidth,
      builder: (_, c, sw) => CustomPaint(painter: _PlayPainter(c, sw, filled)),
    );
  }

  /// Lucide Pause (Dual vertical pill bars)
  factory AppIcon.pause({
    Key? key,
    double size = 20,
    Color? color,
    double strokeWidth = 2.0,
  }) {
    return AppIcon._(
      key: key,
      size: size,
      color: color,
      strokeWidth: strokeWidth,
      builder: (_, c, sw) => CustomPaint(painter: _PausePainter(c, sw)),
    );
  }

  /// Lucide Mic (Studio Voice Model)
  factory AppIcon.mic({
    Key? key,
    double size = 20,
    Color? color,
    double strokeWidth = 2.0,
  }) {
    return AppIcon._(
      key: key,
      size: size,
      color: color,
      strokeWidth: strokeWidth,
      builder: (_, c, sw) => CustomPaint(painter: _MicPainter(c, sw)),
    );
  }

  /// Lucide Volume / Sound wave
  factory AppIcon.volume({
    Key? key,
    double size = 20,
    Color? color,
    double strokeWidth = 2.0,
  }) {
    return AppIcon._(
      key: key,
      size: size,
      color: color,
      strokeWidth: strokeWidth,
      builder: (_, c, sw) => CustomPaint(painter: _VolumePainter(c, sw)),
    );
  }

  /// Lucide Gauge / Speedometer
  factory AppIcon.speed({
    Key? key,
    double size = 20,
    Color? color,
    double strokeWidth = 2.0,
  }) {
    return AppIcon._(
      key: key,
      size: size,
      color: color,
      strokeWidth: strokeWidth,
      builder: (_, c, sw) => CustomPaint(painter: _SpeedPainter(c, sw)),
    );
  }

  /// Lucide Timer / Stopwatch
  factory AppIcon.timer({
    Key? key,
    double size = 20,
    Color? color,
    double strokeWidth = 2.0,
  }) {
    return AppIcon._(
      key: key,
      size: size,
      color: color,
      strokeWidth: strokeWidth,
      builder: (_, c, sw) => CustomPaint(painter: _TimerPainter(c, sw)),
    );
  }

  /// Lucide Clipboard Paste
  factory AppIcon.paste({
    Key? key,
    double size = 20,
    Color? color,
    double strokeWidth = 2.0,
  }) {
    return AppIcon._(
      key: key,
      size: size,
      color: color,
      strokeWidth: strokeWidth,
      builder: (_, c, sw) => CustomPaint(painter: _PastePainter(c, sw)),
    );
  }

  /// Lucide Clear / Trash
  factory AppIcon.clear({
    Key? key,
    double size = 20,
    Color? color,
    double strokeWidth = 2.0,
  }) {
    return AppIcon._(
      key: key,
      size: size,
      color: color,
      strokeWidth: strokeWidth,
      builder: (_, c, sw) => CustomPaint(painter: _ClearPainter(c, sw)),
    );
  }

  /// Lucide Edit / Pen
  factory AppIcon.edit({
    Key? key,
    double size = 20,
    Color? color,
    double strokeWidth = 2.0,
  }) {
    return AppIcon._(
      key: key,
      size: size,
      color: color,
      strokeWidth: strokeWidth,
      builder: (_, c, sw) => CustomPaint(painter: _EditPainter(c, sw)),
    );
  }

  /// Lucide Check
  factory AppIcon.check({
    Key? key,
    double size = 20,
    Color? color,
    double strokeWidth = 2.0,
  }) {
    return AppIcon._(
      key: key,
      size: size,
      color: color,
      strokeWidth: strokeWidth,
      builder: (_, c, sw) => CustomPaint(painter: _CheckPainter(c, sw)),
    );
  }

  /// Lucide Sun
  factory AppIcon.sun({
    Key? key,
    double size = 20,
    Color? color,
    double strokeWidth = 2.0,
  }) {
    return AppIcon._(
      key: key,
      size: size,
      color: color,
      strokeWidth: strokeWidth,
      builder: (_, c, sw) => CustomPaint(painter: _SunPainter(c, sw)),
    );
  }

  /// Lucide Moon
  factory AppIcon.moon({
    Key? key,
    double size = 20,
    Color? color,
    double strokeWidth = 2.0,
  }) {
    return AppIcon._(
      key: key,
      size: size,
      color: color,
      strokeWidth: strokeWidth,
      builder: (_, c, sw) => CustomPaint(painter: _MoonPainter(c, sw)),
    );
  }

  /// Lucide Info
  factory AppIcon.info({
    Key? key,
    double size = 20,
    Color? color,
    double strokeWidth = 2.0,
  }) {
    return AppIcon._(
      key: key,
      size: size,
      color: color,
      strokeWidth: strokeWidth,
      builder: (_, c, sw) => CustomPaint(painter: _InfoPainter(c, sw)),
    );
  }

  /// Lucide Chevron Right
  factory AppIcon.chevronRight({
    Key? key,
    double size = 20,
    Color? color,
    double strokeWidth = 2.0,
  }) {
    return AppIcon._(
      key: key,
      size: size,
      color: color,
      strokeWidth: strokeWidth,
      builder: (_, c, sw) => CustomPaint(painter: _ChevronRightPainter(c, sw)),
    );
  }

  /// Lucide Sparkles
  factory AppIcon.sparkles({
    Key? key,
    double size = 20,
    Color? color,
    double strokeWidth = 2.0,
  }) {
    return AppIcon._(
      key: key,
      size: size,
      color: color,
      strokeWidth: strokeWidth,
      builder: (_, c, sw) => CustomPaint(painter: _SparklesPainter(c, sw)),
    );
  }
}

// ==========================================
// CUSTOM VECTOR PAINTERS (VIEWPORT 24x24)
// ==========================================

Paint _strokePaint(Color color, double strokeWidth) {
  return Paint()
    ..color = color
    ..strokeWidth = strokeWidth
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..isAntiAlias = true;
}

Paint _fillPaint(Color color) {
  return Paint()
    ..color = color
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;
}

/// Symmetrical Infinity Path
class _InfinityPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _InfinityPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = _strokePaint(color, strokeWidth);

    final path = Path();
    // Beautiful mathematical Bernoullian / Lucide infinity curve
    path.moveTo(12, 12);
    path.cubicTo(9.5, 8.5, 6.5, 7.5, 4.5, 9.5);
    path.cubicTo(2.5, 11.5, 2.5, 12.5, 4.5, 14.5);
    path.cubicTo(6.5, 16.5, 9.5, 15.5, 12, 12);
    path.cubicTo(14.5, 8.5, 17.5, 7.5, 19.5, 9.5);
    path.cubicTo(21.5, 11.5, 21.5, 12.5, 19.5, 14.5);
    path.cubicTo(17.5, 16.5, 14.5, 15.5, 12, 12);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _InfinityPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Lucide Repeat Arrows
class _RepeatPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _RepeatPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = _strokePaint(color, strokeWidth);

    // Top loop & arrow
    final topPath = Path()
      ..moveTo(17, 2)
      ..lineTo(21, 6)
      ..lineTo(17, 10);
    canvas.drawPath(topPath, paint);

    final topArc = Path()
      ..moveTo(21, 6)
      ..lineTo(9, 6)
      ..arcToPoint(const Offset(5, 10), radius: const Radius.circular(4));
    canvas.drawPath(topArc, paint);

    // Bottom loop & arrow
    final bottomPath = Path()
      ..moveTo(7, 22)
      ..lineTo(3, 18)
      ..lineTo(7, 14);
    canvas.drawPath(bottomPath, paint);

    final bottomArc = Path()
      ..moveTo(3, 18)
      ..lineTo(15, 18)
      ..arcToPoint(const Offset(19, 14), radius: const Radius.circular(4));
    canvas.drawPath(bottomArc, paint);
  }

  @override
  bool shouldRepaint(covariant _RepeatPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Lucide Plus
class _PlusPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _PlusPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = _strokePaint(color, strokeWidth);

    canvas.drawLine(const Offset(12, 5), const Offset(12, 19), paint);
    canvas.drawLine(const Offset(5, 12), const Offset(19, 12), paint);
  }

  @override
  bool shouldRepaint(covariant _PlusPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Lucide Minus
class _MinusPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _MinusPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = _strokePaint(color, strokeWidth);

    canvas.drawLine(const Offset(5, 12), const Offset(19, 12), paint);
  }

  @override
  bool shouldRepaint(covariant _MinusPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Playhead
class _PlayPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final bool filled;
  _PlayPainter(this.color, this.strokeWidth, this.filled);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);

    final path = Path()
      ..moveTo(6, 4.5)
      ..lineTo(19, 12)
      ..lineTo(6, 19.5)
      ..close();

    if (filled) {
      canvas.drawPath(path, _fillPaint(color));
    } else {
      canvas.drawPath(path, _strokePaint(color, strokeWidth));
    }
  }

  @override
  bool shouldRepaint(covariant _PlayPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Lucide Pause
class _PausePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _PausePainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = _strokePaint(color, strokeWidth);

    canvas.drawLine(const Offset(8, 5), const Offset(8, 19), paint);
    canvas.drawLine(const Offset(16, 5), const Offset(16, 19), paint);
  }

  @override
  bool shouldRepaint(covariant _PausePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Lucide Mic
class _MicPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _MicPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = _strokePaint(color, strokeWidth);

    // Mic capsule
    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(8, 3, 8, 12),
      const Radius.circular(4),
    );
    canvas.drawRRect(rrect, paint);

    // Cradle arc
    final arcPath = Path()
      ..moveTo(4, 11)
      ..arcToPoint(const Offset(20, 11), radius: const Radius.circular(8));
    canvas.drawPath(arcPath, paint);

    // Stem and base
    canvas.drawLine(const Offset(12, 19), const Offset(12, 22), paint);
    canvas.drawLine(const Offset(8, 22), const Offset(16, 22), paint);
  }

  @override
  bool shouldRepaint(covariant _MicPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Lucide Volume
class _VolumePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _VolumePainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = _strokePaint(color, strokeWidth);

    final speaker = Path()
      ..moveTo(4, 9)
      ..lineTo(8, 9)
      ..lineTo(13, 5)
      ..lineTo(13, 19)
      ..lineTo(8, 15)
      ..lineTo(4, 15)
      ..close();
    canvas.drawPath(speaker, paint);

    // Wave 1
    final wave1 = Path()
      ..moveTo(16.5, 8.5)
      ..arcToPoint(const Offset(16.5, 15.5), radius: const Radius.circular(5));
    canvas.drawPath(wave1, paint);

    // Wave 2
    final wave2 = Path()
      ..moveTo(19.5, 6)
      ..arcToPoint(const Offset(19.5, 18), radius: const Radius.circular(8));
    canvas.drawPath(wave2, paint);
  }

  @override
  bool shouldRepaint(covariant _VolumePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Lucide Speed / Gauge
class _SpeedPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _SpeedPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = _strokePaint(color, strokeWidth);

    // Gauge semi-circle
    final gauge = Path()
      ..moveTo(4, 18)
      ..arcToPoint(const Offset(20, 18), radius: const Radius.circular(9.5));
    canvas.drawPath(gauge, paint);

    // Gauge needle
    canvas.drawLine(const Offset(12, 15), const Offset(15, 10), paint);
    canvas.drawCircle(const Offset(12, 15), 1.5, _fillPaint(color));
  }

  @override
  bool shouldRepaint(covariant _SpeedPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Lucide Timer
class _TimerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _TimerPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = _strokePaint(color, strokeWidth);

    // Watch circle
    canvas.drawCircle(const Offset(12, 13), 8, paint);

    // Top button
    canvas.drawLine(const Offset(12, 2), const Offset(12, 5), paint);
    canvas.drawLine(const Offset(9, 2), const Offset(15, 2), paint);

    // Hand
    canvas.drawLine(const Offset(12, 13), const Offset(12, 9), paint);
  }

  @override
  bool shouldRepaint(covariant _TimerPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Lucide Paste
class _PastePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _PastePainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = _strokePaint(color, strokeWidth);

    // Top clip
    final clip = Path()
      ..moveTo(9, 3)
      ..lineTo(15, 3)
      ..lineTo(15, 5)
      ..lineTo(9, 5)
      ..close();
    canvas.drawPath(clip, paint);

    // Board
    final board = Path()
      ..moveTo(9, 4)
      ..lineTo(6, 4)
      ..arcToPoint(const Offset(4, 6), radius: const Radius.circular(2))
      ..lineTo(4, 20)
      ..arcToPoint(const Offset(6, 22), radius: const Radius.circular(2))
      ..lineTo(18, 22)
      ..arcToPoint(const Offset(20, 20), radius: const Radius.circular(2))
      ..lineTo(20, 6)
      ..arcToPoint(const Offset(18, 4), radius: const Radius.circular(2))
      ..lineTo(15, 4);
    canvas.drawPath(board, paint);
  }

  @override
  bool shouldRepaint(covariant _PastePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Lucide Clear
class _ClearPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _ClearPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = _strokePaint(color, strokeWidth);

    canvas.drawLine(const Offset(18, 6), const Offset(6, 18), paint);
    canvas.drawLine(const Offset(6, 6), const Offset(18, 18), paint);
  }

  @override
  bool shouldRepaint(covariant _ClearPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Lucide Edit
class _EditPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _EditPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = _strokePaint(color, strokeWidth);

    final path = Path()
      ..moveTo(17, 3)
      ..lineTo(21, 7)
      ..lineTo(8, 20)
      ..lineTo(3, 21)
      ..lineTo(4, 16)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _EditPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Lucide Check
class _CheckPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _CheckPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = _strokePaint(color, strokeWidth);

    final path = Path()
      ..moveTo(4, 12)
      ..lineTo(9, 17)
      ..lineTo(20, 6);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Lucide Sun
class _SunPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _SunPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = _strokePaint(color, strokeWidth);

    canvas.drawCircle(const Offset(12, 12), 4, paint);

    // 8 rays
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final start = Offset(
        12 + 6.5 * math.cos(angle),
        12 + 6.5 * math.sin(angle),
      );
      final end = Offset(
        12 + 9.5 * math.cos(angle),
        12 + 9.5 * math.sin(angle),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SunPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Lucide Moon
class _MoonPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _MoonPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = _strokePaint(color, strokeWidth);

    final path = Path()
      ..moveTo(21, 12.79)
      ..cubicTo(20.35, 17.41, 16.41, 21, 11.5, 21)
      ..cubicTo(6.25, 21, 2, 16.75, 2, 11.5)
      ..cubicTo(2, 6.59, 5.59, 2.65, 10.21, 2)
      ..cubicTo(8.83, 3.86, 8, 6.2, 8, 8.75)
      ..cubicTo(8, 13.85, 12.15, 18, 17.25, 18)
      ..cubicTo(19.8, 18, 20.14, 17.17, 21, 12.79)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MoonPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Lucide Info
class _InfoPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _InfoPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = _strokePaint(color, strokeWidth);

    canvas.drawCircle(const Offset(12, 12), 9, paint);
    canvas.drawLine(const Offset(12, 11), const Offset(12, 16), paint);
    canvas.drawCircle(const Offset(12, 8), 1.0, _fillPaint(color));
  }

  @override
  bool shouldRepaint(covariant _InfoPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Lucide Chevron Right
class _ChevronRightPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _ChevronRightPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = _strokePaint(color, strokeWidth);

    final path = Path()
      ..moveTo(9, 18)
      ..lineTo(15, 12)
      ..lineTo(9, 6);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChevronRightPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Lucide Sparkles
class _SparklesPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _SparklesPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = _strokePaint(color, strokeWidth);

    // Primary 4-point star
    final star = Path()
      ..moveTo(12, 2)
      ..cubicTo(12, 7, 13, 8, 18, 9)
      ..cubicTo(13, 10, 12, 11, 12, 16)
      ..cubicTo(12, 11, 11, 10, 6, 9)
      ..cubicTo(11, 8, 12, 7, 12, 2)
      ..close();
    canvas.drawPath(star, paint);

    // Secondary small star
    final smallStar = Path()
      ..moveTo(19, 16)
      ..cubicTo(19, 18, 19.5, 18.5, 21.5, 19)
      ..cubicTo(19.5, 19.5, 19, 20, 19, 22)
      ..cubicTo(19, 20, 18.5, 19.5, 16.5, 19)
      ..cubicTo(18.5, 18.5, 19, 18, 19, 16)
      ..close();
    canvas.drawPath(smallStar, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklesPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
