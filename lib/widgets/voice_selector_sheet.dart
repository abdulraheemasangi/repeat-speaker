import 'package:flutter/material.dart';

import '../models/voice_model.dart';
import '../services/tts_controller.dart';
import '../theme/liquid_glass_theme.dart';
import 'app_icons.dart';
import 'country_badge.dart';

/// Refined, Apple-inspired bottom sheet for selecting among the 5 curated voice models.
/// Completely free of emojis, featuring crisp vector country badges and 0ms reactive updates.
class VoiceSelectorSheet extends StatelessWidget {
  final TtsController ttsController;

  const VoiceSelectorSheet({super.key, required this.ttsController});

  static void show(BuildContext context, TtsController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => VoiceSelectorSheet(ttsController: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final curatedList = ttsController.curatedVoices;

    return ListenableBuilder(
      listenable: ttsController,
      builder: (context, _) {
        final selected = ttsController.selectedCuratedVoice;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141A26) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDark ? const Color(0x26FFFFFF) : const Color(0x40CBD5E1),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 24,
                offset: Offset(0, -6),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0x33FFFFFF)
                        : const Color(0x33000000),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Sheet Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1)
                              .withValues(alpha: isDark ? 0.20 : 0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: AppIcon.mic(
                          size: 18,
                          color: const Color(0xFF6366F1),
                          strokeWidth: 2.2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Voice Models",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            "5 Studio & Natural Engines",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? const Color(0x80FFFFFF)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Done",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Curated Voices List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: curatedList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final voice = curatedList[index];
                  final isSelected = voice.id == selected.id;

                  return InkWell(
                    onTap: () {
                      // Immediate 0ms visual selection update
                      ttsController.selectCuratedVoice(voice);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6366F1)
                                  .withValues(alpha: isDark ? 0.20 : 0.08)
                            : (isDark
                                  ? const Color(0x0DFFFFFF)
                                  : const Color(0x66F8FAFC)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF6366F1)
                              : (isDark
                                    ? const Color(0x1AFFFFFF)
                                    : const Color(0xFFE2E8F0)),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0x266366F1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          // Vector Country Badge (Replaces Emoji)
                          CountryBadge(
                            countryCode: voice.countryCode,
                            isDark: isDark,
                            size: 26,
                          ),

                          const SizedBox(width: 12),

                          // Voice Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      voice.title,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 1.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6366F1)
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AppIcon.sparkles(
                                            size: 9,
                                            color: const Color(0xFF6366F1),
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            voice.qualityBadge,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF6366F1),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  voice.subtitle,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? const Color(0x80FFFFFF)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Preview Audio Sample Button
                          Tooltip(
                            message: "Preview Voice",
                            child: InkWell(
                              onTap: () => ttsController.previewVoice(voice),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF6366F1)
                                      .withValues(alpha: isDark ? 0.18 : 0.08),
                                ),
                                child: AppIcon.volume(
                                  size: 16,
                                  color: const Color(0xFF6366F1),
                                  strokeWidth: 2.2,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Selection Radio / Checkmark
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? const Color(0xFF6366F1)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF6366F1)
                                    : (isDark
                                          ? const Color(0x4DFFFFFF)
                                          : const Color(0x40CBD5E1)),
                                width: 1.5,
                              ),
                            ),
                            child: isSelected
                                ? Center(
                                    child: AppIcon.check(
                                      size: 12,
                                      color: Colors.white,
                                      strokeWidth: 2.8,
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
