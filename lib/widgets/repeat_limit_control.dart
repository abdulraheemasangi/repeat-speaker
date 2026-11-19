import 'package:flutter/material.dart';

import 'app_icons.dart';

/// Premium, Apple-inspired Repeat Limit Control with Liquid Glass styling.
/// Features elegant stepper (+ / −) controls, an animated count display,
/// a seamless continuous-loop option, and quick preset pills without any emojis.
class RepeatLimitControl extends StatefulWidget {
  final int currentLimit;
  final ValueChanged<int> onChanged;
  final bool isDark;

  const RepeatLimitControl({
    super.key,
    required this.currentLimit,
    required this.onChanged,
    required this.isDark,
  });

  @override
  State<RepeatLimitControl> createState() => _RepeatLimitControlState();
}

class _RepeatLimitControlState extends State<RepeatLimitControl> {
  // Preset repetition limits
  static const List<int> _presets = [0, 1, 3, 5, 10, 25];

  void _increment() {
    if (widget.currentLimit == 0) {
      widget.onChanged(1);
    } else if (widget.currentLimit < 99) {
      widget.onChanged(widget.currentLimit + 1);
    }
  }

  void _decrement() {
    if (widget.currentLimit > 1) {
      widget.onChanged(widget.currentLimit - 1);
    } else if (widget.currentLimit == 1) {
      // Step down to Continuous (0)
      widget.onChanged(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final isContinuous = widget.currentLimit == 0;

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
            // Glass Mode Badge
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981)
                    .withValues(alpha: isDark ? 0.20 : 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF10B981)
                      .withValues(alpha: isDark ? 0.35 : 0.25),
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
                      "${widget.currentLimit}× Target",
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

        const SizedBox(height: 12),

        // 2. Center Stepper Container (Liquid Glass)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0x1AFFFFFF) : const Color(0x66F1F5F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0x1FFFFFFF) : const Color(0x40CBD5E1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Decrement Button
              _StepperButton(
                icon: AppIcon.minus(
                  size: 18,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  strokeWidth: 2.4,
                ),
                onTap: _decrement,
                isDark: isDark,
                tooltip: "Decrease repeats",
              ),

              // Animated Center Display
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: isContinuous
                      ? KeyedSubtree(
                          key: const ValueKey('continuous_mode'),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppIcon.infinity(
                                size: 28,
                                color: const Color(0xFF10B981),
                                strokeWidth: 2.2,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Continuous Playback",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0x99FFFFFF)
                                      : const Color(0x990F172A),
                                ),
                              ),
                            ],
                          ),
                        )
                      : KeyedSubtree(
                          key: ValueKey('limit_${widget.currentLimit}'),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${widget.currentLimit}",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                widget.currentLimit == 1
                                    ? "repetition"
                                    : "repetitions",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0x99FFFFFF)
                                      : const Color(0x990F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),

              // Increment Button
              _StepperButton(
                icon: AppIcon.plus(
                  size: 18,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  strokeWidth: 2.4,
                ),
                onTap: _increment,
                isDark: isDark,
                tooltip: "Increase repeats",
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 3. Quick Preset Pills (No Emojis)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _presets.map((preset) {
              final isSelected = widget.currentLimit == preset;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _PresetPill(
                  preset: preset,
                  isSelected: isSelected,
                  isDark: isDark,
                  onTap: () => widget.onChanged(preset),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Circular Glass Stepper Button with tactile press animation
class _StepperButton extends StatefulWidget {
  final Widget icon;
  final VoidCallback onTap;
  final bool isDark;
  final String tooltip;

  const _StepperButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    required this.tooltip,
  });

  @override
  State<_StepperButton> createState() => _StepperButtonState();
}

class _StepperButtonState extends State<_StepperButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.90 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isDark ? const Color(0x33FFFFFF) : Colors.white,
              border: Border.all(
                color: widget.isDark
                    ? const Color(0x26FFFFFF)
                    : const Color(0xFFCBD5E1),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isDark
                      ? const Color(0x20000000)
                      : const Color(0x0F0F172A),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: widget.icon,
          ),
        ),
      ),
    );
  }
}

/// Quick preset chip pill
class _PresetPill extends StatelessWidget {
  final int preset;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _PresetPill({
    required this.preset,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6366F1)
              : (isDark ? const Color(0x14FFFFFF) : const Color(0x80FFFFFF)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6366F1)
                : (isDark ? const Color(0x1AFFFFFF) : const Color(0xFFE2E8F0)),
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0x406366F1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (preset == 0) ...[
              AppIcon.infinity(
                size: 12,
                color: isSelected
                    ? Colors.white
                    : (isDark
                          ? const Color(0xCCFFFFFF)
                          : const Color(0xFF475569)),
                strokeWidth: 2.2,
              ),
              const SizedBox(width: 4),
              Text(
                "Continuous",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                            ? const Color(0xCCFFFFFF)
                            : const Color(0xFF475569)),
                ),
              ),
            ] else ...[
              Text(
                "${preset}×",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                            ? const Color(0xCCFFFFFF)
                            : const Color(0xFF475569)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
