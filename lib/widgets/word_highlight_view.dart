import 'package:flutter/material.dart';

/// Real-time synchronized word-by-word highlighting reader for Repeat Speaker.
/// Highlights the exact word currently being spoken with an Apple iOS-inspired
/// Liquid Glass glowing pill while speech progresses.
class WordHighlightView extends StatefulWidget {
  final String text;
  final int? highlightStart;
  final int? highlightEnd;
  final bool isDark;
  final VoidCallback? onDoubleTapEdit;

  const WordHighlightView({
    super.key,
    required this.text,
    required this.highlightStart,
    required this.highlightEnd,
    required this.isDark,
    this.onDoubleTapEdit,
  });

  @override
  State<WordHighlightView> createState() => _WordHighlightViewState();
}

class _WordHighlightViewState extends State<WordHighlightView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant WordHighlightView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Smoothly auto-scroll when reading longer text
    if (widget.highlightStart != null &&
        widget.highlightStart != oldWidget.highlightStart &&
        widget.text.isNotEmpty &&
        _scrollController.hasClients) {
      final double progress = (widget.highlightStart! / widget.text.length)
          .clamp(0.0, 1.0);
      final double maxScroll = _scrollController.position.maxScrollExtent;
      if (maxScroll > 0) {
        final targetOffset = (progress * maxScroll) - 60.0;
        _scrollController.animateTo(
          targetOffset.clamp(0.0, maxScroll),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.text;
    final start = widget.highlightStart;
    final end = widget.highlightEnd;

    final defaultTextColor = widget.isDark
        ? const Color(0xFFF1F5F9)
        : const Color(0xFF0F172A);

    final baseStyle = TextStyle(
      fontSize: 18,
      height: 1.6,
      letterSpacing: 0.2,
      color: defaultTextColor,
    );

    List<InlineSpan> spans = [];

    final bool hasValidHighlight =
        start != null &&
        end != null &&
        start >= 0 &&
        end <= text.length &&
        start < end;

    if (!hasValidHighlight) {
      spans.add(TextSpan(text: text, style: baseStyle));
    } else {
      // 1. Text before highlighted word
      if (start > 0) {
        spans.add(
          TextSpan(
            text: text.substring(0, start),
            style: baseStyle.copyWith(
              color: defaultTextColor.withValues(alpha: 0.65),
            ),
          ),
        );
      }

      // 2. Active highlighted word (Pill style)
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5),
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x334F46E5),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              text.substring(start, end),
              style: const TextStyle(
                fontSize: 18,
                height: 1.25,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      );

      // 3. Text after highlighted word
      if (end < text.length) {
        spans.add(TextSpan(text: text.substring(end), style: baseStyle));
      }
    }

    return GestureDetector(
      onDoubleTap: widget.onDoubleTapEdit,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: RichText(text: TextSpan(children: spans)),
        ),
      ),
    );
  }
}
