import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repeat_speaker/main.dart';
import 'package:repeat_speaker/services/tts_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Repeat Speaker Liquid Glass UI smoke test', (
    WidgetTester tester,
  ) async {
    final ttsController = TtsController();
    await tester.pumpWidget(RepeatSpeakerApp(ttsController: ttsController));
    await tester.pumpAndSettle();

    // Verify AppBar title & branding
    expect(find.text('Repeat Speaker'), findsOneWidget);
    expect(find.text('LIQUID GLASS AUDIO'), findsOneWidget);

    // Verify media controls presence (Play icon, Stop icon, Reset icon)
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

    // Verify presence of playback speed tuning
    expect(find.textContaining('Playback Speed'), findsOneWidget);

    // Verify presence of voice models trigger
    expect(find.byIcon(Icons.record_voice_over_rounded), findsOneWidget);
  });
}
