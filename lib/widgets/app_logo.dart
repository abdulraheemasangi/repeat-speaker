import 'package:flutter/material.dart';

/// Clean, minimal, professional brand logo for Repeat Speaker.
/// Replaces the over-edited complex emblem with a modern, elegant icon.
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
            Color(0xFF6366F1), // Clean Indigo
            Color(0xFF4F46E5), // Deep Indigo
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.repeat_rounded,
          color: Colors.white,
          size: size * 0.60,
        ),
      ),
    );
  }
}
