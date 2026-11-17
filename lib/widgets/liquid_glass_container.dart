import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/liquid_glass_theme.dart';

/// A reusable Apple iOS-inspired Liquid Glass surface with frosted blur,
/// translucent gradient shine, subtle border, and soft elevation.
class LiquidGlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final Color? fillColor;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blur = 16,
    this.padding,
    this.margin,
    this.borderColor,
    this.fillColor,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: LiquidGlassTheme.glassDecoration(
        isDark: isDark,
        borderRadius: borderRadius,
        borderColor: borderColor,
        fillColor: fillColor,
      ),
      child: child,
    );

    // Apply frosted blur effect
    Widget blurred = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: content,
      ),
    );

    if (margin != null) {
      blurred = Padding(padding: margin!, child: blurred);
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: blurred,
      );
    }

    return blurred;
  }
}

/// Ambient background layer with soft floating colored light orbs that shine
/// through the liquid glass cards, giving genuine optical depth.
class LiquidGlassBackground extends StatelessWidget {
  final Widget child;

  const LiquidGlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Solid background base
        Container(
          color: isDark
              ? LiquidGlassTheme.darkBackground
              : LiquidGlassTheme.lightBackground,
        ),

        // Glowing Ambient Light Orb 1 (Top Right - Indigo / Cyan)
        Positioned(
          top: -size.height * 0.1,
          right: -size.width * 0.2,
          child: Container(
            width: size.width * 0.9,
            height: size.width * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [LiquidGlassTheme.darkGlowOrb1, Colors.transparent]
                    : [LiquidGlassTheme.lightGlowOrb1, Colors.transparent],
              ),
            ),
          ),
        ),

        // Glowing Ambient Light Orb 2 (Middle Left - Electric Cyan / Purple)
        Positioned(
          top: size.height * 0.35,
          left: -size.width * 0.3,
          child: Container(
            width: size.width * 0.85,
            height: size.width * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [LiquidGlassTheme.darkGlowOrb2, Colors.transparent]
                    : [LiquidGlassTheme.lightGlowOrb2, Colors.transparent],
              ),
            ),
          ),
        ),

        // Glowing Ambient Light Orb 3 (Bottom Center - Radiant Purple)
        Positioned(
          bottom: -size.height * 0.1,
          right: size.width * 0.1,
          child: Container(
            width: size.width * 0.8,
            height: size.width * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [LiquidGlassTheme.darkGlowOrb3, Colors.transparent]
                    : [const Color(0x1F818CF8), Colors.transparent],
              ),
            ),
          ),
        ),

        // Forefront Child
        child,
      ],
    );
  }
}
