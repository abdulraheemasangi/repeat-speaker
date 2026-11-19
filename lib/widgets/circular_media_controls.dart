import 'package:flutter/material.dart';

import '../services/tts_controller.dart';
import '../theme/liquid_glass_theme.dart';

/// Single circular Play/Pause media control for Repeat Speaker.
/// Clean, thumb-friendly, lightweight with SVG Material rounded icons.
class CircularMediaControls extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isPlaying =
        playbackState == PlaybackState.playing ||
        playbackState == PlaybackState.pausingBetweenLoops;
    final isPaused = playbackState == PlaybackState.paused;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status header
        _buildStatusHeader(isPlaying, isPaused),

        const SizedBox(height: 12),

        // Single Central Play / Pause Button with clean SVG Material Icon
        SizedBox(
          width: 72,
          height: 72,
          child: ElevatedButton(
            onPressed: () {
              if (isPlaying) {
                onPause();
              } else {
                onPlay();
              }
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              backgroundColor: isPlaying
                  ? const Color(0xFFF43F5E) // Clean Light Rose for Pause
                  : const Color(0xFF6366F1), // Clean Electric Indigo for Play
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),

        // Reset Counter action
        if (!isPlaying && repeatCount > 0) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onResetCounter,
            child: Text(
              "Reset Counter",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? const Color(0x99FFFFFF)
                    : const Color(0x99000000),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ] else if (isPaused) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onStop,
            child: const Text(
              "Stop",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFFF43F5E),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusHeader(bool isPlaying, bool isPaused) {
    String status;
    Color dotColor;

    if (isPlaying) {
      if (playbackState == PlaybackState.pausingBetweenLoops) {
        status = targetLoopLimit > 0
            ? "Pausing before loop #${repeatCount + 1} of $targetLoopLimit"
            : "Pausing before loop #${repeatCount + 1}";
        dotColor = LiquidGlassTheme.amber;
      } else {
        status = targetLoopLimit > 0
            ? "Playing loop #${repeatCount + 1} of $targetLoopLimit"
            : "Playing loop #${repeatCount + 1}";
        dotColor = LiquidGlassTheme.emerald;
      }
    } else if (isPaused) {
      status = targetLoopLimit > 0
          ? "Paused at loop #${repeatCount + 1} of $targetLoopLimit"
          : "Paused at loop #${repeatCount + 1}";
      dotColor = LiquidGlassTheme.rose;
    } else {
      if (repeatCount == 0) {
        status = targetLoopLimit > 0
            ? "Ready • Limit: ${targetLoopLimit}x"
            : "Ready to repeat";
      } else {
        status = targetLoopLimit > 0 && repeatCount >= targetLoopLimit
            ? "Target reached • Repeated $repeatCount times"
            : "Finished • Repeated $repeatCount times";
      }
      dotColor = LiquidGlassTheme.primary;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
        ),
        const SizedBox(width: 8),
        Text(
          status,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
