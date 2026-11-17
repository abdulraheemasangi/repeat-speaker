import 'package:flutter/material.dart';

/// Minimal, high-performance UI theme for Repeat Speaker.
/// Removes heavy GPU blurs, ambient radial orbs, and excessive glows
/// to deliver butter-smooth 60-120fps responsiveness on Android.
class LiquidGlassTheme {
  // Brand Accents (Minimal & Refined)
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color secondary = Color(0xFF0EA5E9); // Sky
  static const Color emerald = Color(0xFF10B981); // Emerald
  static const Color amber = Color(0xFFF59E0B); // Amber

  // Dark Mode (Minimal Obsidian)
  static const Color darkBackground = Color(0xFF0F131C);
  static const Color darkSurface = Color(0xFF181D2A);
  static const Color darkSurfaceSubtle = Color(0xFF131722);
  static const Color darkBorder = Color(0x1FFFFFFF); // 12% white crisp border

  // Light Mode (Minimal Clean Slate)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSubtle = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Surface Card Decoration (Lightweight, Zero GPU Blur Cost)
  static BoxDecoration cardDecoration({
    required bool isDark,
    double borderRadius = 18,
    Color? borderColor,
    Color? fillColor,
  }) {
    return BoxDecoration(
      color: fillColor ?? (isDark ? darkSurface : lightSurface),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? (isDark ? darkBorder : lightBorder),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark ? const Color(0x26000000) : const Color(0x080F172A),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Active Word Highlight Decoration (Minimal & Clear)
  static BoxDecoration wordHighlightDecoration({required bool isDark}) {
    return BoxDecoration(
      color: const Color(0xFF6366F1),
      borderRadius: BorderRadius.circular(6),
    );
  }

  // Material Themes
  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: darkSurface,
        onSurface: Colors.white,
        error: Color(0xFFEF4444),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: Color(0x26FFFFFF),
        thumbColor: primary,
        overlayColor: Color(0x296366F1),
        trackHeight: 3,
      ),
    );
  }

  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: lightSurface,
        onSurface: Color(0xFF0F172A),
        error: Color(0xFFDC2626),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFF0F172A)),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: Color(0x1F000000),
        thumbColor: primary,
        overlayColor: Color(0x296366F1),
        trackHeight: 3,
      ),
    );
  }
}
