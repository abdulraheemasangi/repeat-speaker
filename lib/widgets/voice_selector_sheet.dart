import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/voice_model.dart';
import '../services/tts_controller.dart';
import '../theme/liquid_glass_theme.dart';

/// Apple iOS-inspired Liquid Glass Bottom Sheet for selecting among
/// the 5 curated high-quality voice models.
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
    final selected = ttsController.selectedCuratedVoice;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xE6121724) : const Color(0xF2FFFFFF),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDark ? const Color(0x33FFFFFF) : const Color(0x80CBD5E1),
              width: 1.2,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // iOS Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0x4DFFFFFF)
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Voice Models",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "5 Curated Natural & Studio Grade Voices",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0x99FFFFFF)
                              : const Color(0x99000000),
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

              const SizedBox(height: 16),

              // Curated Voices List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: curatedList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final voice = curatedList[index];
                  final isSelected = voice.id == selected.id;

                  return GestureDetector(
                    onTap: () {
                      ttsController.selectCuratedVoice(voice);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6366F1)
                                  .withValues(alpha: isDark ? 0.22 : 0.12)
                            : (isDark
                                  ? const Color(0x14FFFFFF)
                                  : const Color(0x66F1F5F9)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF6366F1)
                              : (isDark
                                    ? const Color(0x26FFFFFF)
                                    : const Color(0x40CBD5E1)),
                          width: isSelected ? 1.8 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF6366F1)
                                      .withValues(alpha: 0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          // Flag & Gender Badge
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? const Color(0x26FFFFFF)
                                  : const Color(0x1A0F172A),
                            ),
                            child: Center(
                              child: Text(
                                voice.flag,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
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
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00F2FE)
                                            .withValues(
                                              alpha: isDark ? 0.2 : 0.15,
                                            ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        voice.qualityBadge,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF00B4D8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  voice.subtitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? const Color(0x99FFFFFF)
                                        : const Color(0x99000000),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Preview Audio Test Button
                          IconButton(
                            tooltip: "Listen to sample",
                            icon: const Icon(Icons.volume_up_rounded, size: 22),
                            color: const Color(0xFF6366F1),
                            onPressed: () {
                              ttsController.previewVoice(voice);
                            },
                          ),

                          // Selection Checkmark
                          Container(
                            width: 24,
                            height: 24,
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
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
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
        ),
      ),
    );
  }
}
