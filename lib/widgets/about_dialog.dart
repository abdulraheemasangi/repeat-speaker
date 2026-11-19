import 'package:flutter/material.dart';

import 'app_logo.dart';

/// Clean, minimal "About Repeat Speaker" Dialog
class AppAboutDialog extends StatelessWidget {
  const AppAboutDialog({super.key});

  static void show(BuildContext context) {
    showDialog(context: context, builder: (ctx) => const AppAboutDialog());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF181D2A) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: isDark ? const Color(0x1FFFFFFF) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo
            const AppLogo(size: 56),

            const SizedBox(height: 14),

            // Title
            Text(
              "Repeat Speaker",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),

            const SizedBox(height: 4),

            // Version Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Version 1.3.0 (Build 4)",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Description
            Text(
              "A clean, minimal text-to-speech loop playback app for memorization, speech prep, and pronunciation practice.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDark
                    ? const Color(0xB3FFFFFF)
                    : const Color(0xB30F172A),
              ),
            ),

            const SizedBox(height: 16),

            _buildFeatureRow(
              Icons.repeat_rounded,
              "Loop Playback with Target Limits (1x, 3x, 5x, Endless)",
              isDark,
            ),
            _buildFeatureRow(
              Icons.spellcheck_rounded,
              "Real-time Word Highlighting & Dynamic Text Sync",
              isDark,
            ),
            _buildFeatureRow(
              Icons.record_voice_over_rounded,
              "5 Curated Voices with Instant 0ms Switching",
              isDark,
            ),
            _buildFeatureRow(
              Icons.save_rounded,
              "Automatic Persistence for Text, Voice & Settings",
              isDark,
            ),

            const SizedBox(height: 20),

            // Close Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Close",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6366F1)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? const Color(0xCCFFFFFF)
                    : const Color(0xCC0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
