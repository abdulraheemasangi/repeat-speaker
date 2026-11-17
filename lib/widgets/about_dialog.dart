import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_logo.dart';

/// Premium Apple iOS Liquid Glass "About Repeat Speaker" Dialog
class AppAboutDialog extends StatelessWidget {
  const AppAboutDialog({super.key});

  static void show(BuildContext context) {
    showDialog(context: context, builder: (ctx) => const AppAboutDialog());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xE6121724) : const Color(0xF2FFFFFF),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark ? const Color(0x33FFFFFF) : const Color(0x80CBD5E1),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? const Color(0x66000000)
                    : const Color(0x1F0F172A),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              const AppLogo(size: 64),

              const SizedBox(height: 16),

              // Title
              Text(
                "Repeat Speaker",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 4),

              // Version Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF00F2FE)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Version 1.1.0 (Build 2) • Liquid Glass",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                "A premium text-to-speech loop playback tool designed for language mastery, memory retention, pronunciation practice, and continuous listening.",
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

              // Feature Highlights
              _buildFeatureRow(
                Icons.all_inclusive_rounded,
                "Endless Loop with Zero Audio Overlap",
                isDark,
              ),
              _buildFeatureRow(
                Icons.spellcheck_rounded,
                "Real-Time Word-by-Word Highlighting",
                isDark,
              ),
              _buildFeatureRow(
                Icons.record_voice_over_rounded,
                "5 Curated Studio & Neural Voices",
                isDark,
              ),
              _buildFeatureRow(
                Icons.save_rounded,
                "Automatic Local Data Persistence",
                isDark,
              ),
              _buildFeatureRow(
                Icons.screen_lock_portrait_rounded,
                "Active Screen Wakelock Support",
                isDark,
              ),

              const SizedBox(height: 20),

              // Close Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Close",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF00F2FE)),
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
