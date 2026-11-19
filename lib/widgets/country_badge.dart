import 'package:flutter/material.dart';

/// Clean, professional country code badge that replaces emoji flags.
/// Delivers a modern, Apple-style minimalist aesthetic with crisp typography.
class CountryBadge extends StatelessWidget {
  final String countryCode;
  final bool isDark;
  final double size;

  const CountryBadge({
    super.key,
    required this.countryCode,
    required this.isDark,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final code = countryCode.toUpperCase();
    final Color accentColor = switch (code) {
      'US' => const Color(0xFF6366F1), // Indigo
      'GB' => const Color(0xFF0EA5E9), // Sky
      'AU' => const Color(0xFF10B981), // Emerald
      _ => const Color(0xFF8B5CF6), // Purple
    };

    return Container(
      width: size * 1.35,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1.0,
        ),
      ),
      child: Text(
        code,
        style: TextStyle(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: accentColor,
        ),
      ),
    );
  }
}
