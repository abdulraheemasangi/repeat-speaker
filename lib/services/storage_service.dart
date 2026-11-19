import 'package:shared_preferences/shared_preferences.dart';

/// Manages persistent local data for Repeat Speaker.
/// Retains user text, curated voice selection, speech speed, pause duration,
/// configured loop limit, and theme mode across app closures and restarts.
class StorageService {
  static const String _keyText = 'repeat_speaker_text';
  static const String _keySpeed = 'repeat_speaker_speed';
  static const String _keyPause = 'repeat_speaker_pause';
  static const String _keyVoiceId = 'repeat_speaker_voice_id';
  static const String _keyThemeMode = 'repeat_speaker_theme_mode';
  static const String _keyLoopLimit = 'repeat_speaker_loop_limit';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Text Persistence
  static bool hasSavedText() {
    return _prefs?.containsKey(_keyText) ?? false;
  }

  static String getText({required String defaultText}) {
    if (_prefs == null) return defaultText;
    if (_prefs!.containsKey(_keyText)) {
      return _prefs!.getString(_keyText) ?? '';
    }
    return defaultText;
  }

  static Future<void> saveText(String text) async {
    await _prefs?.setString(_keyText, text);
  }

  // Speed Persistence (0.5x - 2.0x)
  static double getSpeed({double defaultSpeed = 1.0}) {
    return _prefs?.getDouble(_keySpeed) ?? defaultSpeed;
  }

  static Future<void> saveSpeed(double speed) async {
    await _prefs?.setDouble(_keySpeed, speed);
  }

  // Pause Duration Persistence (0.0s - 5.0s)
  static double getPauseDuration({double defaultPause = 1.0}) {
    return _prefs?.getDouble(_keyPause) ?? defaultPause;
  }

  static Future<void> savePauseDuration(double pause) async {
    await _prefs?.setDouble(_keyPause, pause);
  }

  // Configured Loop Target / Limit (0 = Endless, 1, 3, 5, 10, etc.)
  static int getLoopLimit({int defaultLimit = 0}) {
    return _prefs?.getInt(_keyLoopLimit) ?? defaultLimit;
  }

  static Future<void> saveLoopLimit(int limit) async {
    await _prefs?.setInt(_keyLoopLimit, limit);
  }

  // Voice Model Persistence
  static String? getVoiceId() {
    return _prefs?.getString(_keyVoiceId);
  }

  static Future<void> saveVoiceId(String voiceId) async {
    await _prefs?.setString(_keyVoiceId, voiceId);
  }

  // Theme Persistence ('dark' or 'light')
  static String getThemeMode({String defaultMode = 'dark'}) {
    return _prefs?.getString(_keyThemeMode) ?? defaultMode;
  }

  static Future<void> saveThemeMode(String mode) async {
    await _prefs?.setString(_keyThemeMode, mode);
  }
}
