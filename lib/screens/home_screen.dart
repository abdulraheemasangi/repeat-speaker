import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/tts_controller.dart';
import '../widgets/voice_selector_dialog.dart';

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
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.ttsController.addListener(_onTtsStateChanged);

    // Default friendly sample text for instant user testing
    _textController.text = "Repeat this sentence to practice pronunciation, memorize key phrases, or study effectively.";
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
            backgroundColor: Theme.of(context).colorScheme.error,
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

  void _handleStart() {
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
    // Dismiss keyboard when starting playback
    FocusScope.of(context).unfocus();
    widget.ttsController.startLoop(text: text);
  }

  void _handleStop() {
    widget.ttsController.stopLoop();
  }

  void _handleClear() {
    if (_textController.text.isEmpty) return;

    if (widget.ttsController.isPlaying) {
      widget.ttsController.stopLoop();
    }

    final previousText = _textController.text;
    setState(() {
      _textController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Text cleared"),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () {
            setState(() {
              _textController.text = previousText;
            });
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
    showDialog(
      context: context,
      builder: (ctx) => VoiceSelectorDialog(
        voices: widget.ttsController.englishVoices,
        currentVoice: widget.ttsController.selectedVoice,
        onVoiceSelected: (voice) {
          widget.ttsController.selectVoice(
            voice,
            activeText: _textController.text,
          );
        },
      ),
    );
  }

  String _formatSpeedLabel(double speed) {
    if ((speed - 1.0).abs() < 0.05) return "1.0x (Normal)";
    if (speed <= 0.6) return "${speed.toStringAsFixed(1)}x (Very Slow)";
    if (speed < 1.0) return "${speed.toStringAsFixed(1)}x (Slow)";
    if (speed <= 1.4) return "${speed.toStringAsFixed(1)}x (Moderate)";
    if (speed <= 1.8) return "${speed.toStringAsFixed(1)}x (Fast)";
    return "${speed.toStringAsFixed(1)}x (Double Speed)";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPlaying = widget.ttsController.isPlaying;
    final isWaiting = widget.ttsController.isWaitingBetweenLoops;
    final repeatCount = widget.ttsController.repeatCount;
    final speed = widget.ttsController.speed;
    final pauseDuration = widget.ttsController.pauseDuration;
    final selectedVoice = widget.ttsController.selectedVoice;

    // Word and character count calculation
    final text = _textController.text;
    final charCount = text.length;
    final wordCount = text.trim().isEmpty
        ? 0
        : text.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.repeat_rounded,
                color: colorScheme.onPrimaryContainer,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "Repeat Speaker",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Choose English Voice",
            icon: const Icon(Icons.record_voice_over_outlined),
            onPressed: _showVoiceSelector,
          ),
          IconButton(
            tooltip: widget.isDarkMode
                ? "Switch to Light Mode"
                : "Switch to Dark Mode",
            icon: Icon(
              widget.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: widget.onToggleTheme,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Text Input Container Card
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isPlaying
                              ? colorScheme.primary
                              : colorScheme.outlineVariant.withOpacity(0.5),
                          width: isPlaying ? 2.0 : 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Action bar inside the text card
                            Row(
                              children: [
                                Text(
                                  "Text to Repeat",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const Spacer(),
                                // Paste button
                                TextButton.icon(
                                  onPressed: isPlaying ? null : _handlePaste,
                                  icon: const Icon(
                                    Icons.paste_rounded,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    "Paste",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                  ),
                                ),
                                // Clear button
                                TextButton.icon(
                                  onPressed: _textController.text.isEmpty
                                      ? null
                                      : _handleClear,
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    "Clear",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: colorScheme.error,
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 12),
                            // Multi-line Text Field
                            TextField(
                              controller: _textController,
                              focusNode: _focusNode,
                              maxLines: null,
                              minLines: 6,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.45,
                              ),
                              decoration: InputDecoration(
                                hintText: "Type or paste English text here...\nThe app will read it aloud in a continuous loop until you tap Stop.",
                                hintStyle: TextStyle(
                                  color: colorScheme.outline.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                            ),
                            // Word / Character Count Footer
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "$wordCount words • $charCount characters",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Playback Status & Repeat Counter Card
                    Card(
                      elevation: 0,
                      color: isPlaying
                          ? (isWaiting
                                ? Colors.amber.withOpacity(0.12)
                                : Colors.teal.withOpacity(0.12))
                          : colorScheme.surfaceContainerHighest.withOpacity(
                              0.4,
                            ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            // Status Indicator Icon / Pulse
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isPlaying
                                    ? (isWaiting ? Colors.amber : Colors.teal)
                                    : colorScheme.outline.withOpacity(0.2),
                              ),
                              child: Icon(
                                isPlaying
                                    ? (isWaiting
                                          ? Icons.hourglass_top_rounded
                                          : Icons.volume_up_rounded)
                                    : Icons.play_arrow_outlined,
                                size: 18,
                                color: isPlaying
                                    ? Colors.white
                                    : colorScheme.outline,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Counter and State Description
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isPlaying
                                        ? (isWaiting
                                              ? "Pausing between repeats..."
                                              : "Playing repeat loop")
                                        : "Ready to speak",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isPlaying
                                          ? (isWaiting
                                                ? Colors.amber[800]
                                                : Colors.teal[700])
                                          : colorScheme.outline,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    repeatCount == 0
                                        ? "Repeated: 0 times"
                                        : "Repeated: $repeatCount ${repeatCount == 1 ? 'time' : 'times'}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Reset counter button if not playing and count > 0
                            if (!isPlaying && repeatCount > 0)
                              IconButton(
                                tooltip: "Reset repeat counter",
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  size: 20,
                                ),
                                onPressed: widget.ttsController.resetCounter,
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Pause Duration Setting Card
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: colorScheme.outlineVariant.withOpacity(0.4),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      size: 18,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Pause Between Repeats",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
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
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    pauseDuration == 0.0
                                        ? "No pause (0s)"
                                        : "${pauseDuration.toStringAsFixed(1)}s",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8,
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
                    ),

                    // Voice Summary Pill / Button
                    if (selectedVoice != null) ...[
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: _showVoiceSelector,
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.mic_none_rounded,
                                size: 16,
                                color: colorScheme.outline,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Voice: ${selectedVoice['locale']} (${selectedVoice['name']?.split('.').last ?? 'Default'})",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.outline,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Fixed Thumb-Friendly Bottom Control Bar
            Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      widget.isDarkMode ? 0.3 : 0.08,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Speech Speed Controller Row & Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.speed_rounded,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Speed",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
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
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatSpeedLabel(speed),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                    ),
                    child: Slider(
                      value: speed,
                      min: 0.5,
                      max: 2.0,
                      divisions: 15, // 0.1 increments
                      label: "${speed.toStringAsFixed(1)}x",
                      onChanged: (val) {
                        // Applies immediately even during playback
                        widget.ttsController.setSpeed(
                          val,
                          activeText: _textController.text,
                          applyImmediately: true,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Large Dual Control Buttons (Thumb-friendly, 56dp height)
                  Row(
                    children: [
                      // START Button
                      Expanded(
                        flex: isPlaying ? 1 : 2,
                        child: SizedBox(
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: isPlaying ? null : _handleStart,
                            icon: const Icon(
                              Icons.play_arrow_rounded,
                              size: 26,
                            ),
                            label: const Text(
                              "START",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF10B981,
                              ), // Emerald green
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: widget.isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[300],
                              disabledForegroundColor: widget.isDarkMode
                                  ? Colors.grey[600]
                                  : Colors.grey[500],
                              elevation: isPlaying ? 0 : 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // STOP Button
                      Expanded(
                        flex: isPlaying ? 2 : 1,
                        child: SizedBox(
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: !isPlaying ? null : _handleStop,
                            icon: const Icon(Icons.stop_rounded, size: 26),
                            label: const Text(
                              "STOP",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFFEF4444,
                              ), // Crimson red
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: widget.isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[300],
                              disabledForegroundColor: widget.isDarkMode
                                  ? Colors.grey[600]
                                  : Colors.grey[500],
                              elevation: isPlaying ? 4 : 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
