import 'package:flutter/material.dart';

import 'app_icons.dart';

/// Clean, horizontal Repeat Limit selector with crisp SVG icons and zero emojis.
/// Restores the fast, single-tap chip layout with lighter glass styling.
class RepeatLimitControl extends StatelessWidget {
  final int currentLimit;
  final ValueChanged<int> onChanged;
  final bool isDark;

  const RepeatLimitControl({
    super.key,
    required this.currentLimit,
    required this.onChanged,
    required this.isDark,
  });

  static const List<int> _limits = [0, 1, 3, 5, 10, 20, 50];

  @override
  Widget build(BuildContext context) {
    final isContinuous = currentLimit == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Header with Title & Active Mode Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                AppIcon.repeat(
                  size: 16,
                  color: const Color(0xFF10B981),
                  strokeWidth: 2.2,
                ),
                const SizedBox(width: 8),
                Text(
                  "Repeat Limit",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: -0.2,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            // Light Mode Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981)
                    .withValues(alpha: isDark ? 0.20 : 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF10B981)
                      .withValues(alpha: isDark ? 0.35 : 0.20),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isContinuous) ...[
                    AppIcon.infinity(
                      size: 13,
                      color: const Color(0xFF10B981),
                      strokeWidth: 2.2,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      "Continuous",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ] else ...[
                    Text(
                      "${currentLimit}× repetitions",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // 2. Horizontal Chip Row (Clean SVG, Zero Emojis, Lighter Styling)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _limits.map((limit) {
              final isSelected = currentLimit == limit;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InkWell(
                  onTap: () => onChanged(limit),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF6366F1)
                                .withValues(alpha: isDark ? 0.30 : 0.14)
                          : (isDark
                                ? const Color(0x14FFFFFF)
                                : const Color(0x99FFFFFF)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF6366F1)
                            : (isDark
                                  ? const Color(0x1FFFFFFF)
                                  : const Color(0x40CBD5E1)),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0x266366F1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (limit == 0) ...[
                          AppIcon.infinity(
                            size: 13,
                            color: isSelected
                                ? const Color(0xFF4F46E5)
                                : (isDark
                                      ? const Color(0xCCFFFFFF)
                                      : const Color(0xFF475569)),
                            strokeWidth: 2.2,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Continuous",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF4F46E5)
                                  : (isDark
                                        ? const Color(0xCCFFFFFF)
                                        : const Color(0xFF475569)),
                            ),
                          ),
                        ] else ...[
                          Text(
                            "${limit}×",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF4F46E5)
                                  : (isDark
                                        ? const Color(0xCCFFFFFF)
                                        : const Color(0xFF475569)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
