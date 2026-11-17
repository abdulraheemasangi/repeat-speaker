import 'package:flutter/material.dart';

import '../services/tts_controller.dart';
import '../theme/liquid_glass_theme.dart';

/// Minimal, single Play/Pause media control for Repeat Speaker.
/// Provides a single, thumb-friendly circular button without laggy animation loops.
class CircularMediaControls extends StatelessWidget {
  final PlaybackState playbackState;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onStop;
  final VoidCallback onResetCounter;
  final int repeatCount;
  final bool isDark;

  const CircularMediaControls({
    super.key,
    required this.playbackState,
    required this.onPlay,
    required this.onPause,
    required this.onStop,
    required this.onResetCounter,
    required this.repeatCount,
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
        // Minimal Loop Counter Status Label
        _buildStatusHeader(isPlaying, isPaused),

        const SizedBox(height: 12),

        // ONLY A SINGLE PLAY / PAUSE BUTTON (As requested)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Single Play / Pause Button
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
                      ? const Color(0xFFEF4444) // Clean Red for Pause
                      : const Color(0xFF6366F1), // Clean Indigo for Play
                  foregroundColor: Colors.white,
                  elevation: 2,
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 38,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        // Subtle Stop / Reset text action if repeat count > 0 or paused
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
        ],
      ],
    );
  }

  Widget _buildStatusHeader(bool isPlaying, bool isPaused) {
    String status;
    Color dotColor;

    if (isPlaying) {
      if (playbackState == PlaybackState.pausingBetweenLoops) {
        status = "Pausing before loop #${repeatCount + 1}";
        dotColor = LiquidGlassTheme.amber;
      } else {
        status = "Playing loop #$repeatCount";
        dotColor = LiquidGlassTheme.emerald;
      }
    } else if (isPaused) {
      status = "Paused at loop #$repeatCount";
      dotColor = LiquidGlassTheme.secondary;
    } else {
      status = repeatCount == 0
          ? "Ready to repeat"
          : "Finished • Repeated $repeatCount times";
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
