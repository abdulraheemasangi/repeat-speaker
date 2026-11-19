import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/storage_service.dart';
import '../services/tts_controller.dart';
import '../widgets/about_dialog.dart';
import '../widgets/app_icons.dart';
import '../widgets/app_logo.dart';
import '../widgets/circular_media_controls.dart';
import '../widgets/country_badge.dart';
import '../widgets/liquid_glass_container.dart';
import '../widgets/repeat_limit_control.dart';
import '../widgets/voice_selector_sheet.dart';
import '../widgets/word_highlight_view.dart';

class HomeScreen extends StatefulWidget {
  final TtsController ttsController;
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.ttsController,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();
  bool _forceEditMode = false;

  @override
  void initState() {
    super.initState();
    widget.ttsController.addListener(_onTtsStateChanged);

    // Restore persistent text or provide elegant default sample
    final initialText = StorageService.getText(
      defaultText: "Repeat this sentence to master pronunciation, memorize key phrases, and build natural fluency.",
    );
    _textController = TextEditingController(text: initialText);
  }

  @override
  void dispose() {
    widget.ttsController.removeListener(_onTtsStateChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTtsStateChanged() {
    if (mounted) {
      final error = widget.ttsController.errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                AppIcon.info(size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(error)),
              ],
            ),
            backgroundColor: const Color(0xFFE11D48),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: "OK",
              textColor: Colors.white,
              onPressed: () => widget.ttsController.clearError(),
            ),
          ),
        );
        widget.ttsController.clearError();
      }
      setState(() {});
    }
  }

  void _handlePlay() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please type or paste some text first!"),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      _focusNode.requestFocus();
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _forceEditMode = false);

    if (widget.ttsController.isPaused) {
      widget.ttsController.resumeLoop(latestText: text);
    } else {
      widget.ttsController.startLoop(
        text: text,
        textSupplier: () => _textController.text.trim(),
      );
    }
  }

  void _handlePause() {
    widget.ttsController.pauseLoop();
  }

  void _handleStop() {
    widget.ttsController.stopLoop();
    setState(() => _forceEditMode = false);
  }

  void _handleClear() {
    if (_textController.text.isEmpty) return;

    if (widget.ttsController.isPlaying) {
      widget.ttsController.stopLoop();
    }

    final previousText = _textController.text;
    setState(() {
      _textController.clear();
      _forceEditMode = true;
    });
    StorageService.saveText('');
    widget.ttsController.updateText('');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Text cleared"),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: "UNDO",
          textColor: const Color(0xFF4F46E5),
          onPressed: () {
            setState(() {
              _textController.text = previousText;
            });
            StorageService.saveText(previousText);
            widget.ttsController.updateText(previousText);
          },
        ),
      ),
    );
  }

  Future<void> _handlePaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      setState(() {
        _textController.text = data.text!;
      });
      StorageService.saveText(_textController.text);
      widget.ttsController.updateText(_textController.text);
    }
  }

  void _showVoiceSelector() {
    VoiceSelectorSheet.show(context, widget.ttsController);
  }

  void _showAboutDialog() {
    AppAboutDialog.show(context);
  }

  String _formatSpeedLabel(double speed) {
    if ((speed - 1.0).abs() < 0.05) return "1.0× Normal";
    if (speed <= 0.6) return "${speed.toStringAsFixed(1)}× Slow";
    if (speed < 1.0) return "${speed.toStringAsFixed(1)}× Calm";
    if (speed <= 1.4) return "${speed.toStringAsFixed(1)}× Brisk";
    if (speed <= 1.8) return "${speed.toStringAsFixed(1)}× Fast";
    return "${speed.toStringAsFixed(1)}× Double";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final isPlaying = widget.ttsController.isPlaying;
    final isPaused = widget.ttsController.isPaused;
    final speed = widget.ttsController.speed;
    final pauseDuration = widget.ttsController.pauseDuration;
    final targetLoopLimit = widget.ttsController.targetLoopLimit;
    final selectedVoice = widget.ttsController.selectedCuratedVoice;

    final text = _textController.text;
    final charCount = text.length;
    final wordCount = text.trim().isEmpty
        ? 0
        : text.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;

    // Show WordHighlightView during playback unless user explicitly tapped edit
    final bool showHighlightReader = (isPlaying || isPaused) && !_forceEditMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            const AppLogo(size: 30),
            const SizedBox(width: 10),
            Text(
              "Repeat Speaker",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: -0.3,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        actions: [
          // Voice Selector Action
          _HeaderGlassButton(
            tooltip: "Voice Models",
            icon: AppIcon.mic(
              size: 18,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              strokeWidth: 2.2,
            ),
            onPressed: _showVoiceSelector,
            isDark: isDark,
          ),
          const SizedBox(width: 6),
          // Theme Toggle Action
          _HeaderGlassButton(
            tooltip: isDark ? "Switch to Light Mode" : "Switch to Dark Mode",
            icon: isDark
                ? AppIcon.sun(
                    size: 18,
                    color: const Color(0xFFFBBF24),
                    strokeWidth: 2.2,
                  )
                : AppIcon.moon(
                    size: 18,
                    color: const Color(0xFF4F46E5),
                    strokeWidth: 2.2,
                  ),
            onPressed: widget.onToggleTheme,
            isDark: isDark,
          ),
          const SizedBox(width: 6),
          // About Dialog Action
          _HeaderGlassButton(
            tooltip: "About",
            icon: AppIcon.info(
              size: 18,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              strokeWidth: 2.2,
            ),
            onPressed: _showAboutDialog,
            isDark: isDark,
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: LiquidGlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Scrollable Content Area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Text & Synchronized Word Highlighting Card
                      LiquidGlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Card Action Header
                            Row(
                              children: [
                                Row(
                                  children: [
                                    showHighlightReader
                                        ? AppIcon.volume(
                                            size: 16,
                                            color: const Color(0xFF4F46E5),
                                            strokeWidth: 2.2,
                                          )
                                        : AppIcon.edit(
                                            size: 16,
                                            color: const Color(0xFF4F46E5),
                                            strokeWidth: 2.2,
                                          ),
                                    const SizedBox(width: 8),
                                    Text(
                                      showHighlightReader
                                          ? "Synchronized Playback"
                                          : "Text to Repeat",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        letterSpacing: -0.2,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                if (showHighlightReader)
                                  _GlassActionButton(
                                    icon: AppIcon.edit(
                                      size: 13,
                                      color: const Color(0xFF0284C7),
                                      strokeWidth: 2.2,
                                    ),
                                    label: "Edit",
                                    accentColor: const Color(0xFF0284C7),
                                    isDark: isDark,
                                    onPressed: () {
                                      setState(() => _forceEditMode = true);
                                    },
                                  )
                                else ...[
                                  _GlassActionButton(
                                    icon: AppIcon.paste(
                                      size: 13,
                                      color: const Color(0xFF4F46E5),
                                      strokeWidth: 2.2,
                                    ),
                                    label: "Paste",
                                    accentColor: const Color(0xFF4F46E5),
                                    isDark: isDark,
                                    onPressed: isPlaying ? null : _handlePaste,
                                  ),
                                  const SizedBox(width: 6),
                                  _GlassActionButton(
                                    icon: AppIcon.clear(
                                      size: 13,
                                      color: const Color(0xFFE11D48),
                                      strokeWidth: 2.2,
                                    ),
                                    label: "Clear",
                                    accentColor: const Color(0xFFE11D48),
                                    isDark: isDark,
                                    onPressed: _textController.text.isEmpty
                                        ? null
                                        : _handleClear,
                                  ),
                                ],
                              ],
                            ),

                            const Divider(height: 16, color: Color(0x1F94A3B8)),

                            // Dynamic Text Content: Editor vs Synchronized Highlighter
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                minHeight: 140,
                                maxHeight: 220,
                              ),
                              child: showHighlightReader
                                  ? WordHighlightView(
                                      text: _textController.text,
                                      highlightStart:
                                          widget.ttsController.highlightStart,
                                      highlightEnd:
                                          widget.ttsController.highlightEnd,
                                      isDark: isDark,
                                      onDoubleTapEdit: () {
                                        setState(() => _forceEditMode = true);
                                      },
                                    )
                                  : TextField(
                                      controller: _textController,
                                      focusNode: _focusNode,
                                      maxLines: null,
                                      minLines: 5,
                                      keyboardType: TextInputType.multiline,
                                      textInputAction: TextInputAction.newline,
                                      onChanged: (val) {
                                        StorageService.saveText(val);
                                        widget.ttsController.updateText(val);
                                        setState(() {});
                                      },
                                      style: TextStyle(
                                        fontSize: 17,
                                        height: 1.5,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "Type or paste English text to repeat...\nWord-by-word synchronized highlighting will guide your listening during playback.",
                                        hintStyle: TextStyle(
                                          color: isDark
                                              ? const Color(0x66FFFFFF)
                                              : const Color(0x66475569),
                                          fontSize: 15,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                      ),
                                    ),
                            ),

                            // Character & Word Counter Footer
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (showHighlightReader)
                                  Text(
                                    "Double-tap to edit",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? const Color(0x66FFFFFF)
                                          : const Color(0xFF94A3B8),
                                    ),
                                  )
                                else
                                  const SizedBox.shrink(),
                                Text(
                                  "$wordCount words • $charCount characters",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0x80FFFFFF)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 2. Active Voice Model Quick Card
                      LiquidGlassContainer(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        onTap: _showVoiceSelector,
                        child: Row(
                          children: [
                            CountryBadge(
                              countryCode: selectedVoice.countryCode,
                              isDark: isDark,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        selectedVoice.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.2,
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
                                          color: const Color(0xFF4F46E5)
                                              .withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            AppIcon.sparkles(
                                              size: 9,
                                              color: const Color(0xFF4F46E5),
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              selectedVoice.qualityBadge,
                                              style: const TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF4F46E5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    selectedVoice.subtitle,
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
                            AppIcon.chevronRight(
                              size: 18,
                              color: isDark
                                  ? const Color(0x66FFFFFF)
                                  : const Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 3. Playback Tuning & Repeat Limit Card
                      LiquidGlassContainer(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Speed Slider Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    AppIcon.speed(
                                      size: 16,
                                      color: const Color(0xFF4F46E5),
                                      strokeWidth: 2.2,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Playback Speed",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        letterSpacing: -0.2,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4F46E5)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _formatSpeedLabel(speed),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF4F46E5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFF4F46E5),
                                thumbColor: const Color(0xFF4F46E5),
                                trackHeight: 3.5,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 7,
                                ),
                              ),
                              child: Slider(
                                value: speed,
                                min: 0.5,
                                max: 2.0,
                                divisions: 15,
                                label: "${speed.toStringAsFixed(1)}×",
                                onChanged: (val) {
                                  widget.ttsController.setSpeed(
                                    val,
                                    activeText: _textController.text,
                                    applyImmediately: true,
                                  );
                                },
                              ),
                            ),

                            const Divider(height: 12, color: Color(0x1F94A3B8)),

                            // 2. Pause Slider Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    AppIcon.timer(
                                      size: 16,
                                      color: const Color(0xFF0284C7),
                                      strokeWidth: 2.2,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Pause Between Repeats",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        letterSpacing: -0.2,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0284C7)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    pauseDuration == 0.0
                                        ? "No pause (0s)"
                                        : "${pauseDuration.toStringAsFixed(1)}s",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0284C7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFF0284C7),
                                thumbColor: const Color(0xFF0284C7),
                                trackHeight: 3.5,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 7,
                                ),
                              ),
                              child: Slider(
                                value: pauseDuration,
                                min: 0.0,
                                max: 5.0,
                                divisions: 10,
                                label: "${pauseDuration.toStringAsFixed(1)}s",
                                onChanged: (val) {
                                  widget.ttsController.setPauseDuration(val);
                                },
                              ),
                            ),

                            const Divider(height: 16, color: Color(0x1F94A3B8)),

                            // 3. Brand New Repeat Limit Control (Stepper + Animated Display + Continuous Mode)
                            RepeatLimitControl(
                              currentLimit: targetLoopLimit,
                              onChanged: (limit) {
                                widget.ttsController.setTargetLoopLimit(limit);
                              },
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Fixed Floating Bottom Circular Media Controls Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: LiquidGlassContainer(
                  borderRadius: 28,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: CircularMediaControls(
                    playbackState: widget.ttsController.playbackState,
                    repeatCount: widget.ttsController.repeatCount,
                    targetLoopLimit: widget.ttsController.targetLoopLimit,
                    isDark: isDark,
                    onPlay: _handlePlay,
                    onPause: _handlePause,
                    onStop: _handleStop,
                    onResetCounter: widget.ttsController.resetCounter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tactile Circular Glass Header Button
class _HeaderGlassButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final String tooltip;
  final bool isDark;

  const _HeaderGlassButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0x1AFFFFFF) : const Color(0x80FFFFFF),
            border: Border.all(
              color: isDark ? const Color(0x26FFFFFF) : const Color(0x40CBD5E1),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? const Color(0x20000000)
                    : const Color(0x0A0F172A),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: icon,
        ),
      ),
    );
  }
}

/// Refined Glass Action Button for Edit, Paste, Clear
class _GlassActionButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback? onPressed;
  final Color accentColor;
  final bool isDark;

  const _GlassActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.40,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: isDark ? 0.16 : 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: accentColor.withValues(alpha: isDark ? 0.30 : 0.20),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
