import 'package:flutter/material.dart';

import '../models/voice_model.dart';
import '../services/tts_controller.dart';

/// Clean, minimal bottom sheet for selecting among the 5 curated voice models.
/// Uses ListenableBuilder to guarantee instant (0ms) visual selection updates.
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
            color: isDark ? const Color(0xFF181D2A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark ? const Color(0x1FFFFFFF) : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0x33FFFFFF)
                        : const Color(0x33000000),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Sheet Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Voice Models",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "5 Curated Studio & Natural Voices",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0x80FFFFFF)
                              : const Color(0x80000000),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6366F1),
                    ),
                    child: const Text(
                      "Done",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

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
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6366F1)
                                  .withValues(alpha: isDark ? 0.18 : 0.08)
                            : (isDark
                                  ? const Color(0x0AFFFFFF)
                                  : const Color(0xFFF8FAFC)),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF6366F1)
                              : (isDark
                                    ? const Color(0x14FFFFFF)
                                    : const Color(0xFFE2E8F0)),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Flag
                          Text(
                            voice.flag,
                            style: const TextStyle(fontSize: 22),
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
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6366F1)
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        voice.qualityBadge,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF6366F1),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  voice.subtitle,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? const Color(0x80FFFFFF)
                                        : const Color(0x80000000),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Preview Audio Sample
                          IconButton(
                            tooltip: "Listen to sample",
                            icon: const Icon(Icons.volume_up_rounded, size: 20),
                            color: const Color(0xFF6366F1),
                            onPressed: () {
                              ttsController.previewVoice(voice);
                            },
                          ),

                          // Selection Checkmark
                          Container(
                            width: 20,
                            height: 20,
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
                                          : const Color(0x4D000000)),
                                width: 1.5,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
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
