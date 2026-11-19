import 'package:flutter/material.dart';

import 'app_icons.dart';
import 'app_logo.dart';

/// Refined Apple-inspired "About Repeat Speaker" Dialog with Liquid Glass aesthetic.
class AppAboutDialog extends StatelessWidget {
  const AppAboutDialog({super.key});

  static void show(BuildContext context) {
    showDialog(context: context, builder: (ctx) => const AppAboutDialog());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF141A26) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? const Color(0x26FFFFFF) : const Color(0x33CBD5E1),
          width: 1,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
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
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),

            const SizedBox(height: 5),

            // Version Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5)
                    .withValues(alpha: isDark ? 0.25 : 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF4F46E5)
                      .withValues(alpha: isDark ? 0.35 : 0.25),
                  width: 1,
                ),
              ),
              child: const Text(
                "Version 1.5.0 (Build 6)",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4F46E5),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Description
            Text(
              "A premium, distraction-free speech repetition studio engineered for memorization, pronunciation mastery, and speech prep.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDark
                    ? const Color(0xB3FFFFFF)
                    : const Color(0xFF475569),
              ),
            ),

            const SizedBox(height: 16),

            _buildFeatureRow(
              AppIcon.repeat(size: 16, color: const Color(0xFF4F46E5)),
              "Liquid Glass Stepper with Custom Repeat Limits",
              isDark,
            ),
            _buildFeatureRow(
              AppIcon.edit(size: 16, color: const Color(0xFF4F46E5)),
              "Dynamic Text Synchronization & Word Highlighting",
              isDark,
            ),
            _buildFeatureRow(
              AppIcon.mic(size: 16, color: const Color(0xFF4F46E5)),
              "5 Studio Voice Models with 0ms Instant Switching",
              isDark,
            ),
            _buildFeatureRow(
              AppIcon.check(size: 16, color: const Color(0xFF4F46E5)),
              "Pure Vector Icons with Zero Emoji Dependencies",
              isDark,
            ),

            const SizedBox(height: 22),

            // Close Button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(Widget icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? const Color(0xCCFFFFFF)
                    : const Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
