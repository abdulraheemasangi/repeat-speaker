import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repeat_speaker/main.dart';
import 'package:repeat_speaker/services/tts_controller.dart';

void main() {
  testWidgets('App renders title, text input field, and controls', (
    WidgetTester tester,
  ) async {
    final ttsController = TtsController();
    await tester.pumpWidget(RepeatSpeakerApp(ttsController: ttsController));
    await tester.pumpAndSettle();

    // Verify AppBar title
    expect(find.text('Repeat Speaker'), findsOneWidget);

    // Verify presence of Start button and Stop button
    expect(find.text('START'), findsOneWidget);
    expect(find.text('STOP'), findsOneWidget);

    // Verify presence of clear button
    expect(find.text('Clear'), findsOneWidget);

    // Verify presence of speed label
    expect(find.textContaining('Speed'), findsWidgets);

    // Verify initial loop counter text
    expect(find.text('Repeated: 0 times'), findsOneWidget);
  });
}
