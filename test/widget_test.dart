import 'package:flutter_test/flutter_test.dart';
import 'package:repeat_speaker/main.dart';
import 'package:repeat_speaker/services/tts_controller.dart';
import 'package:repeat_speaker/widgets/circular_media_controls.dart';
import 'package:repeat_speaker/widgets/repeat_limit_control.dart';
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

    // Verify AppBar title
    expect(find.text('Repeat Speaker'), findsOneWidget);

    // Verify presence of single Play/Pause media controls
    expect(find.byType(CircularMediaControls), findsOneWidget);

    // Verify presence of playback speed tuning
    expect(find.textContaining('Playback Speed'), findsOneWidget);

    // Verify presence of redesigned Repeat Limit control
    expect(find.byType(RepeatLimitControl), findsOneWidget);
    expect(find.textContaining('Repeat Limit'), findsOneWidget);

    // Verify presence of voice models trigger
    expect(find.byTooltip('Voice Models'), findsOneWidget);
  });
}
