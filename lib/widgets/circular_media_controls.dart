import 'package:flutter/material.dart';

import '../services/tts_controller.dart';
import '../theme/liquid_glass_theme.dart';

/// Premium circular media-player controls for Repeat Speaker.
/// Features an iOS-inspired floating circular Play/Pause button with
/// ambient glow, micro-animations, and secondary Stop & Reset controls.
class CircularMediaControls extends StatefulWidget {
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
  State<CircularMediaControls> createState() => _CircularMediaControlsState();
}

class _CircularMediaControlsState extends State<CircularMediaControls>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.playbackState;
    final isPlaying =
        state == PlaybackState.playing ||
        state == PlaybackState.pausingBetweenLoops;
    final isPaused = state == PlaybackState.paused;
    final isIdle = state == PlaybackState.idle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Live Playback Status & Counter Pill
        _buildStatusHeader(state, isPlaying, isPaused, isIdle),

        const SizedBox(height: 14),

        // Media Controls Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Reset Counter Button
            _buildGlassIconButton(
              icon: Icons.refresh_rounded,
              tooltip: "Reset Counter",
              onTap: widget.repeatCount > 0 ? widget.onResetCounter : null,
              isEnabled: widget.repeatCount > 0,
            ),

            const SizedBox(width: 24),

            // 2. Large Hero Circular Play / Pause Button
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
                scale: _isPressed
                    ? 0.92
                    : (isPlaying ? _pulseAnimation.value : 1.0),
                duration: const Duration(milliseconds: 120),
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isPlaying
                        ? LiquidGlassTheme.accentPauseGradient
                        : LiquidGlassTheme.accentPlayGradient,
                    boxShadow: [
                      BoxShadow(
                        color: isPlaying
                            ? const Color(0xFFEF4444).withValues(alpha: 0.45)
                            : const Color(0xFF10B981).withValues(alpha: 0.45),
                        blurRadius: 28,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                      const BoxShadow(
                        color: Color(0x66FFFFFF),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 24),

            // 3. Stop Button
            _buildGlassIconButton(
              icon: Icons.stop_rounded,
              tooltip: "Stop Loop",
              onTap: !isIdle ? widget.onStop : null,
              isEnabled: !isIdle,
              accentColor: const Color(0xFFEF4444),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusHeader(
    PlaybackState state,
    bool isPlaying,
    bool isPaused,
    bool isIdle,
  ) {
    Color indicatorColor;
    String statusText;

    switch (state) {
      case PlaybackState.playing:
        indicatorColor = const Color(0xFF10B981); // Emerald
        statusText = "Playing loop #${widget.repeatCount}";
        break;
      case PlaybackState.pausingBetweenLoops:
        indicatorColor = const Color(0xFFF59E0B); // Amber
        statusText = "Pausing before loop #${widget.repeatCount + 1}";
        break;
      case PlaybackState.paused:
        indicatorColor = const Color(0xFF00F2FE); // Cyan
        statusText = "Paused at loop #${widget.repeatCount}";
        break;
      case PlaybackState.idle:
      default:
        indicatorColor = const Color(0xFF6366F1); // Indigo
        statusText = widget.repeatCount == 0
            ? "Ready to repeat"
            : "Finished • Repeated ${widget.repeatCount} times";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: widget.isDark
            ? const Color(0x1AFFFFFF)
            : const Color(0x0F0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isDark
              ? const Color(0x26FFFFFF)
              : const Color(0x1F0F172A),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: indicatorColor,
              boxShadow: [
                BoxShadow(
                  color: indicatorColor.withValues(alpha: 0.6),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onTap,
    required bool isEnabled,
    Color? accentColor,
  }) {
    final color = isEnabled
        ? (accentColor ??
              (widget.isDark ? Colors.white : const Color(0xFF0F172A)))
        : (widget.isDark ? const Color(0x4DFFFFFF) : const Color(0x33000000));

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isDark
                ? const Color(0x1AFFFFFF)
                : const Color(0x80FFFFFF),
            border: Border.all(
              color: widget.isDark
                  ? const Color(0x33FFFFFF)
                  : const Color(0x66CBD5E1),
              width: 1.2,
            ),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: widget.isDark
                          ? const Color(0x40000000)
                          : const Color(0x140F172A),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(child: Icon(icon, color: color, size: 24)),
        ),
      ),
    );
  }
}
