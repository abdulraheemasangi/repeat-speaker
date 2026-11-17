import 'dart:ui';

import 'package:flutter/material.dart';

/// Premium Apple iOS-inspired Liquid Glass Design System
class LiquidGlassTheme {
  // Brand Gradients
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00F2FE), // Electric Cyan
      Color(0xFF4FACFE), // Sky Blue
      Color(0xFF6366F1), // Royal Indigo
      Color(0xFFA855F7), // Radiant Purple
    ],
  );

  static const LinearGradient accentPlayGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981), // Emerald Teal
      Color(0xFF06B6D4), // Cyan
    ],
  );

  static const LinearGradient accentPauseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF59E0B), // Warm Amber
      Color(0xFFEF4444), // Coral Red
    ],
  );

  static const LinearGradient glassHighlightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x33FFFFFF), Color(0x05FFFFFF)],
  );

  // Background Colors
  static const Color darkBackground = Color(0xFF0A0D14);
  static const Color darkSurface = Color(0xFF121724);
  static const Color darkGlassFill = Color(0x1AFFFFFF); // 10% white
  static const Color darkGlassBorder = Color(0x33FFFFFF); // 20% white
  static const Color darkGlowOrb1 = Color(0x3D6366F1); // 24% Indigo
  static const Color darkGlowOrb2 = Color(0x3D00F2FE); // 24% Cyan
  static const Color darkGlowOrb3 = Color(0x2EA855F7); // 18% Purple

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFF1F5F9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightGlassFill = Color(0xD9FFFFFF); // 85% white
  static const Color lightGlassBorder = Color(0x66CBD5E1); // slate border
  static const Color lightGlowOrb1 = Color(0x266366F1);
  static const Color lightGlowOrb2 = Color(0x2638BDF8);

  // Glass Box Decorations
  static BoxDecoration glassDecoration({
    required bool isDark,
    double borderRadius = 20,
    Color? borderColor,
    Color? fillColor,
    bool hasShadow = true,
  }) {
    return BoxDecoration(
      color:
          fillColor ??
          (isDark ? const Color(0x18FFFFFF) : const Color(0xB3FFFFFF)),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color:
            borderColor ??
            (isDark ? const Color(0x33FFFFFF) : const Color(0x80CBD5E1)),
        width: 1.2,
      ),
      boxShadow: hasShadow
          ? [
              BoxShadow(
                color: isDark
                    ? const Color(0x40000000)
                    : const Color(0x140F172A),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              if (isDark)
                const BoxShadow(
                  color: Color(0x0DFFFFFF),
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
            ]
          : null,
    );
  }

  // Active Word Highlight Decoration (Liquid Glass Pill)
  static BoxDecoration wordHighlightDecoration({required bool isDark}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFF6366F1), // Indigo
          Color(0xFF8B5CF6), // Violet
        ],
      ),
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [
        BoxShadow(
          color: Color(0x666366F1),
          blurRadius: 12,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  // Material ThemeData Builders
  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6366F1),
        secondary: Color(0xFF00F2FE),
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
        activeTrackColor: Color(0xFF6366F1),
        inactiveTrackColor: Color(0x33FFFFFF),
        thumbColor: Color(0xFF00F2FE),
        overlayColor: Color(0x2900F2FE),
        trackHeight: 4,
      ),
    );
  }

  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF6366F1),
        secondary: Color(0xFF0284C7),
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
        activeTrackColor: Color(0xFF6366F1),
        inactiveTrackColor: Color(0x26000000),
        thumbColor: Color(0xFF6366F1),
        overlayColor: Color(0x296366F1),
        trackHeight: 4,
      ),
    );
  }
}
