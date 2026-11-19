import 'package:flutter/material.dart';

import '../theme/liquid_glass_theme.dart';

/// High-performance, minimal surface container.
/// Eliminates heavy GPU blur operations for silky-smooth 60-120fps performance on Android.
class LiquidGlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
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
    this.borderRadius = 18,
    this.padding,
    this.margin,
    this.borderColor,
    this.fillColor,
    this.onTap,
    this.width,
    this.height,
    // Keep backward-compatible signature
    double blur = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: LiquidGlassTheme.cardDecoration(
        isDark: isDark,
        borderRadius: borderRadius,
        borderColor: borderColor,
        fillColor: fillColor,
      ),
      child: child,
    );

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }

    return content;
  }
}

/// Apple-inspired Liquid Glass background layer with soft luminous gradient.
class LiquidGlassBackground extends StatelessWidget {
  final Widget child;

  const LiquidGlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? LiquidGlassTheme.darkBackdropGradient
            : LiquidGlassTheme.lightBackdropGradient,
      ),
      child: child,
    );
  }
}
