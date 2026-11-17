import 'package:shared_preferences/shared_preferences.dart';

/// Manages persistent local data for Repeat Speaker.
/// Automatically retains input text, selected voice model, playback speed,
/// pause duration, and theme settings across app restarts and lifecycle events.
class StorageService {
  static const String _keyText = 'repeat_speaker_text';
  static const String _keySpeed = 'repeat_speaker_speed';
  static const String _keyPause = 'repeat_speaker_pause';
  static const String _keyVoiceId = 'repeat_speaker_voice_id';
  static const String _keyThemeMode = 'repeat_speaker_theme_mode';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Text Persistence
  static String getText({required String defaultText}) {
    return _prefs?.getString(_keyText) ?? defaultText;
  }

  static Future<void> saveText(String text) async {
    await _prefs?.setString(_keyText, text);
  }

  // Speed Persistence
  static double getSpeed({double defaultSpeed = 1.0}) {
    return _prefs?.getDouble(_keySpeed) ?? defaultSpeed;
  }

  static Future<void> saveSpeed(double speed) async {
    await _prefs?.setDouble(_keySpeed, speed);
  }

  // Pause Duration Persistence
  static double getPauseDuration({double defaultPause = 1.0}) {
    return _prefs?.getDouble(_keyPause) ?? defaultPause;
  }

  static Future<void> savePauseDuration(double pause) async {
    await _prefs?.setDouble(_keyPause, pause);
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
