import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repeat_speaker/main.dart';
import 'package:repeat_speaker/services/tts_controller.dart';
import 'package:repeat_speaker/widgets/circular_media_controls.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Repeat Speaker Material Vector UI smoke test', (
    WidgetTester tester,
  ) async {
    final ttsController = TtsController();
    await tester.pumpWidget(RepeatSpeakerApp(ttsController: ttsController));
    await tester.pumpAndSettle();

    // Verify AppBar title
    expect(find.text('Repeat Speaker'), findsOneWidget);

    // Verify presence of single Play/Pause media controls with rounded vector icon
    expect(find.byType(CircularMediaControls), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

    // Verify presence of playback speed tuning
    expect(find.textContaining('Playback Speed'), findsOneWidget);

    // Verify presence of Repeat Limit chips and Endless icon
    expect(find.textContaining('Repeat Limit'), findsOneWidget);
    expect(find.text('Endless'), findsOneWidget);
    expect(find.byIcon(Icons.all_inclusive_rounded), findsOneWidget);

    // Verify presence of voice models trigger
    expect(find.byTooltip('Voice Models'), findsOneWidget);
    expect(find.byIcon(Icons.record_voice_over_rounded), findsOneWidget);
  });
}
