import 'package:flutter/material.dart';

/// Refined, Apple-inspired Liquid Glass UI theme for Repeat Speaker.
/// Features a luminous, soft light palette, translucent frosted glass cards,
/// subtle highlights, gentle diffused shadows, and high-contrast typography.
class LiquidGlassTheme {
  // Brand Accents (Vibrant yet Refined)
  static const Color primary = Color(0xFF4F46E5); // Electric Indigo
  static const Color primaryLight = Color(0xFF6366F1); // Indigo
  static const Color secondary = Color(0xFF0284C7); // Sky Cyan
  static const Color emerald = Color(0xFF10B981); // Emerald Green
  static const Color amber = Color(0xFFF59E0B); // Amber
  static const Color rose = Color(0xFFF43F5E); // Soft Rose

  // Light Mode (Luminous Pearlescent Glass)
  static const Color lightBackground = Color(0xFFF6F8FC);
  static const Color lightBackgroundSubtle = Color(0xFFEDF2F7);
  static const Color lightSurface = Color(
    0xF5FFFFFF,
  ); // 96% White Frosted Glass
  static const Color lightSurfaceSubtle = Color(
    0x99F1F5F9,
  ); // 60% Frosted Slate
  static const Color lightBorder = Color(0x33CBD5E1); // 20% Subtle Slate
  static const Color lightBorderHighlight = Color(
    0x80FFFFFF,
  ); // Specular Highlight

  // Dark Mode (Frosted Midnight Obsidian)
  static const Color darkBackground = Color(0xFF0C1019);
  static const Color darkBackgroundSubtle = Color(0xFF121826);
  static const Color darkSurface = Color(0xB31E2738); // 70% Frosted Slate Glass
  static const Color darkSurfaceSubtle = Color(0x66182030); // 40% Frosted Slate
  static const Color darkBorder = Color(0x26FFFFFF); // 15% Crisp Highlight
  static const Color darkBorderHighlight = Color(0x40FFFFFF);

  // Text Colors
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate 900
  static const Color lightTextSecondary = Color(0xFF475569); // Slate 600
  static const Color lightTextTertiary = Color(0xFF94A3B8); // Slate 400

  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color darkTextTertiary = Color(0xFF64748B); // Slate 500

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient playGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pauseGradient = LinearGradient(
    colors: [Color(0xFFE11D48), Color(0xFFF43F5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightBackdropGradient = LinearGradient(
    colors: [Color(0xFFF8FAFC), Color(0xFFEEF3F8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkBackdropGradient = LinearGradient(
    colors: [Color(0xFF0B0F19), Color(0xFF111827)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Surface Card Decoration (Liquid Glass with Soft Diffused Shadow)
  static BoxDecoration cardDecoration({
    required bool isDark,
    double borderRadius = 20,
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
          color: isDark ? const Color(0x30000000) : const Color(0x0C0F172A),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: isDark ? const Color(0x15000000) : const Color(0x040F172A),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  // Active Word Highlight Decoration
  static BoxDecoration wordHighlightDecoration({required bool isDark}) {
    return BoxDecoration(
      color: primary,
      borderRadius: BorderRadius.circular(6),
      boxShadow: const [
        BoxShadow(
          color: Color(0x334F46E5),
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  // Material Themes
  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryLight,
        secondary: secondary,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        error: rose,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: darkTextPrimary),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: primaryLight,
        inactiveTrackColor: Color(0x26FFFFFF),
        thumbColor: primaryLight,
        overlayColor: Color(0x296366F1),
        trackHeight: 3.5,
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
        onSurface: lightTextPrimary,
        error: rose,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: lightTextPrimary),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: Color(0x1F000000),
        thumbColor: primary,
        overlayColor: Color(0x296366F1),
        trackHeight: 3.5,
      ),
    );
  }
}
