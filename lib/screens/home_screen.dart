import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/storage_service.dart';
import '../services/tts_controller.dart';
import '../widgets/about_dialog.dart';
import '../widgets/app_logo.dart';
import '../widgets/circular_media_controls.dart';
import '../widgets/liquid_glass_container.dart';
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
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(error)),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
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
      widget.ttsController.resumeLoop();
    } else {
      widget.ttsController.startLoop(text: text);
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Text cleared"),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: "UNDO",
          textColor: const Color(0xFF00F2FE),
          onPressed: () {
            setState(() {
              _textController.text = previousText;
            });
            StorageService.saveText(previousText);
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pasted from clipboard"),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _showVoiceSelector() {
    VoiceSelectorSheet.show(context, widget.ttsController);
  }

  void _showAboutDialog() {
    AppAboutDialog.show(context);
  }

  String _formatSpeedLabel(double speed) {
    if ((speed - 1.0).abs() < 0.05) return "1.0x (Normal)";
    if (speed <= 0.6) return "${speed.toStringAsFixed(1)}x (Slow)";
    if (speed < 1.0) return "${speed.toStringAsFixed(1)}x (Calm)";
    if (speed <= 1.4) return "${speed.toStringAsFixed(1)}x (Brisk)";
    if (speed <= 1.8) return "${speed.toStringAsFixed(1)}x (Fast)";
    return "${speed.toStringAsFixed(1)}x (Double)";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final isPlaying = widget.ttsController.isPlaying;
    final isPaused = widget.ttsController.isPaused;
    final isIdle = widget.ttsController.isIdle;
    final speed = widget.ttsController.speed;
    final pauseDuration = widget.ttsController.pauseDuration;
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
            const AppLogo(size: 32),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Repeat Speaker",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 0.3,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  "LIQUID GLASS AUDIO",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: const Color(0xFF00F2FE).withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Voice Selector Action
          IconButton(
            tooltip: "Voice Models",
            icon: const Icon(Icons.record_voice_over_rounded, size: 22),
            onPressed: _showVoiceSelector,
          ),
          // Theme Toggle Action
          IconButton(
            tooltip: isDark ? "Switch to Light Mode" : "Switch to Dark Mode",
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 22,
            ),
            onPressed: widget.onToggleTheme,
          ),
          // About Dialog Action
          IconButton(
            tooltip: "About",
            icon: const Icon(Icons.info_outline_rounded, size: 22),
            onPressed: _showAboutDialog,
          ),
          const SizedBox(width: 4),
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
                                    Icon(
                                      showHighlightReader
                                          ? Icons.spatial_audio_rounded
                                          : Icons.edit_note_rounded,
                                      size: 18,
                                      color: const Color(0xFF6366F1),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      showHighlightReader
                                          ? "Synchronized Playback"
                                          : "Text to Repeat",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                if (showHighlightReader)
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() => _forceEditMode = true);
                                    },
                                    icon: const Icon(
                                      Icons.edit_rounded,
                                      size: 14,
                                    ),
                                    label: const Text(
                                      "Edit",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF00F2FE),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  )
                                else ...[
                                  TextButton.icon(
                                    onPressed: isPlaying ? null : _handlePaste,
                                    icon: const Icon(
                                      Icons.paste_rounded,
                                      size: 14,
                                    ),
                                    label: const Text(
                                      "Paste",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF6366F1),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: _textController.text.isEmpty
                                        ? null
                                        : _handleClear,
                                    icon: const Icon(
                                      Icons.clear_rounded,
                                      size: 14,
                                    ),
                                    label: const Text(
                                      "Clear",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFFEF4444),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            const Divider(height: 16, color: Color(0x26FFFFFF)),

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
                                              : const Color(0x66000000),
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
                                      color: isDark
                                          ? const Color(0x66FFFFFF)
                                          : const Color(0x66000000),
                                    ),
                                  )
                                else
                                  const SizedBox.shrink(),
                                Text(
                                  "$wordCount words • $charCount characters",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? const Color(0x80FFFFFF)
                                        : const Color(0x80000000),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 2. Active Voice Model Quick Pill
                      LiquidGlassContainer(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        onTap: _showVoiceSelector,
                        child: Row(
                          children: [
                            Text(
                              selectedVoice.flag,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 10),
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
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00F2FE)
                                              .withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          selectedVoice.qualityBadge,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF00B4D8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    selectedVoice.subtitle,
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
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: isDark
                                  ? const Color(0x66FFFFFF)
                                  : const Color(0x66000000),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 3. Playback Tuning Card (Speed & Pause Sliders)
                      LiquidGlassContainer(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Speed Slider Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.speed_rounded,
                                      size: 16,
                                      color: Color(0xFF6366F1),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Playback Speed",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
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
                                    color: const Color(0xFF6366F1)
                                        .withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _formatSpeedLabel(speed),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6366F1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 7,
                                ),
                              ),
                              child: Slider(
                                value: speed,
                                min: 0.5,
                                max: 2.0,
                                divisions: 15,
                                label: "${speed.toStringAsFixed(1)}x",
                                onChanged: (val) {
                                  widget.ttsController.setSpeed(
                                    val,
                                    activeText: _textController.text,
                                    applyImmediately: true,
                                  );
                                },
                              ),
                            ),

                            const Divider(height: 8, color: Color(0x1AFFFFFF)),

                            // Pause Slider Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.timer_outlined,
                                      size: 16,
                                      color: Color(0xFF00F2FE),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Pause Between Repeats",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
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
                                    color: const Color(0xFF00F2FE)
                                        .withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    pauseDuration == 0.0
                                        ? "No pause (0s)"
                                        : "${pauseDuration.toStringAsFixed(1)}s",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00B4D8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFF00F2FE),
                                thumbColor: const Color(0xFF00F2FE),
                                trackHeight: 3,
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
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: CircularMediaControls(
                    playbackState: widget.ttsController.playbackState,
                    repeatCount: widget.ttsController.repeatCount,
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
