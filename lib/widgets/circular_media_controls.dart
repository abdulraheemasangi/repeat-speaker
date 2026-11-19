import 'package:flutter/material.dart';

import '../services/tts_controller.dart';
import '../theme/liquid_glass_theme.dart';
import 'app_icons.dart';

/// Premium, single Play/Pause media control with Apple-inspired Liquid Glass styling.
/// Features a tactile central circular button with gradient fill, specular highlights,
/// smooth press feedback, and clean vector status indicators without emojis.
class CircularMediaControls extends StatefulWidget {
  final PlaybackState playbackState;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onStop;
  final VoidCallback onResetCounter;
  final int repeatCount;
  final int targetLoopLimit;
  final bool isDark;

  const CircularMediaControls({
    super.key,
    required this.playbackState,
    required this.onPlay,
    required this.onPause,
    required this.onStop,
    required this.onResetCounter,
    required this.repeatCount,
    this.targetLoopLimit = 0,
    required this.isDark,
  });

  @override
  State<CircularMediaControls> createState() => _CircularMediaControlsState();
}

class _CircularMediaControlsState extends State<CircularMediaControls> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isPlaying =
        widget.playbackState == PlaybackState.playing ||
        widget.playbackState == PlaybackState.pausingBetweenLoops;
    final isPaused = widget.playbackState == PlaybackState.paused;
    final isDark = widget.isDark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Refined Status Badge Header
        _buildStatusHeader(isPlaying, isPaused, isDark),

        const SizedBox(height: 14),

        // 2. Central Play / Pause Button with Liquid Glass Halo
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              onTap: () {
                if (isPlaying) {
                  widget.onPause();
                } else {
                  widget.onPlay();
                }
              },
              child: AnimatedScale(
                scale: _isPressed ? 0.92 : 1.0,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOutCubic,
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isPlaying
                        ? LiquidGlassTheme.pauseGradient
                        : LiquidGlassTheme.playGradient,
                    border: Border.all(
                      color: const Color(0x66FFFFFF),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isPlaying
                            ? const Color(0x59F43F5E)
                            : const Color(0x594F46E5),
                        blurRadius: 18,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: isDark
                            ? const Color(0x40000000)
                            : const Color(0x1A0F172A),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isPlaying
                        ? AppIcon.pause(
                            size: 30,
                            color: Colors.white,
                            strokeWidth: 3.2,
                          )
                        : Padding(
                            padding: const EdgeInsets.only(left: 3.0),
                            child: AppIcon.play(
                              size: 34,
                              color: Colors.white,
                              filled: true,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // 3. Reset Counter / Stop Actions (Glass Pill)
        if (!isPlaying && widget.repeatCount > 0) ...[
          const SizedBox(height: 12),
          InkWell(
            onTap: widget.onResetCounter,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0x14FFFFFF)
                    : const Color(0x66F1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0x1FFFFFFF)
                      : const Color(0x40CBD5E1),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcon.repeat(
                    size: 13,
                    color: isDark
                        ? const Color(0xB3FFFFFF)
                        : const Color(0xFF64748B),
                    strokeWidth: 2.0,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Reset Counter",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xCCFFFFFF)
                          : const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else if (isPaused) ...[
          const SizedBox(height: 12),
          InkWell(
            onTap: widget.onStop,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF43F5E)
                    .withValues(alpha: isDark ? 0.20 : 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF43F5E)
                      .withValues(alpha: isDark ? 0.35 : 0.25),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcon.clear(
                    size: 12,
                    color: const Color(0xFFF43F5E),
                    strokeWidth: 2.2,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "Stop Playback",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF43F5E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusHeader(bool isPlaying, bool isPaused, bool isDark) {
    String status;
    Color dotColor;
    Widget? statusIcon;

    if (isPlaying) {
      if (widget.playbackState == PlaybackState.pausingBetweenLoops) {
        status = widget.targetLoopLimit > 0
            ? "Pausing before loop #${widget.repeatCount + 1} of ${widget.targetLoopLimit}"
            : "Pausing before loop #${widget.repeatCount + 1}";
        dotColor = LiquidGlassTheme.amber;
        statusIcon = AppIcon.timer(size: 13, color: dotColor, strokeWidth: 2.0);
      } else {
        status = widget.targetLoopLimit > 0
            ? "Playing loop #${widget.repeatCount + 1} of ${widget.targetLoopLimit}"
            : "Playing loop #${widget.repeatCount + 1}";
        dotColor = LiquidGlassTheme.emerald;
        statusIcon = AppIcon.volume(
          size: 13,
          color: dotColor,
          strokeWidth: 2.0,
        );
      }
    } else if (isPaused) {
      status = widget.targetLoopLimit > 0
          ? "Paused at loop #${widget.repeatCount + 1} of ${widget.targetLoopLimit}"
          : "Paused at loop #${widget.repeatCount + 1}";
      dotColor = LiquidGlassTheme.rose;
      statusIcon = AppIcon.pause(size: 12, color: dotColor, strokeWidth: 2.2);
    } else {
      if (widget.repeatCount == 0) {
        status = widget.targetLoopLimit > 0
            ? "Ready • Limit: ${widget.targetLoopLimit}×"
            : "Ready to repeat";
      } else {
        status =
            widget.targetLoopLimit > 0 &&
                widget.repeatCount >= widget.targetLoopLimit
            ? "Target reached • Repeated ${widget.repeatCount} times"
            : "Finished • Repeated ${widget.repeatCount} times";
      }
      dotColor = LiquidGlassTheme.primary;
      statusIcon = widget.repeatCount > 0
          ? AppIcon.check(size: 13, color: dotColor, strokeWidth: 2.2)
          : AppIcon.repeat(size: 13, color: dotColor, strokeWidth: 2.0);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: dotColor.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: dotColor.withValues(alpha: isDark ? 0.30 : 0.20),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (statusIcon != null) ...[
            statusIcon,
            const SizedBox(width: 6),
          ] else ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
              ),
            ),
            const SizedBox(width: 7),
          ],
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
