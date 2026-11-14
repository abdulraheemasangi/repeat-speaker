import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Manages Text-To-Speech lifecycle, looping playback, speed mapping,
/// pause delays, wakelock, and voice selection.
class TtsController extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  bool _isPlaying = false;
  bool _isWaitingBetweenLoops = false;
  bool _isRestartRequested = false;
  int _repeatCount = 0;
  double _speed = 1.0; // UI speed: 0.5x to 2.0x
  double _pauseDuration = 1.0; // Seconds: 0.0 to 5.0
  List<Map<String, String>> _englishVoices = [];
  Map<String, String>? _selectedVoice;
  String? _errorMessage;
  bool _isInitialized = false;
  int _loopSessionId = 0;

  // Getters
  bool get isPlaying => _isPlaying;
  bool get isWaitingBetweenLoops => _isWaitingBetweenLoops;
  int get repeatCount => _repeatCount;
  double get speed => _speed;
  double get pauseDuration => _pauseDuration;
  List<Map<String, String>> get englishVoices => _englishVoices;
  Map<String, String>? get selectedVoice => _selectedVoice;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;

  /// Initializes TTS engine with default configurations.
  Future<void> initialize() async {
    try {
      await _tts.awaitSpeakCompletion(true);
      await _tts.setLanguage("en-US");
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _applySpeechRate();

      // Configure TTS handlers
      _tts.setErrorHandler((dynamic msg) {
        _errorMessage = "TTS engine error: $msg";
        notifyListeners();
      });

      // Load installed English voices
      await _loadVoices();

      // Verify language availability
      final dynamic isAvailable = await _tts.isLanguageAvailable("en-US");
      if (isAvailable == false) {
        _errorMessage = "English TTS voice is not available. Please install or enable 'Speech Services by Google' in your Android Settings.";
      }

      _isInitialized = true;
    } catch (e) {
      _errorMessage =
          "Could not initialize TTS engine ($e). Please make sure 'Speech Services by Google' is enabled on your device.";
    }
    notifyListeners();
  }

  /// Map UI speed (0.5x - 2.0x) to Android flutter_tts engine rate.
  /// On Android flutter_tts:
  /// - 0.5 engine rate produces 1.0x normal speech.
  /// - 0.25 engine rate produces 0.5x half speed.
  /// - 1.0 engine rate produces 2.0x double speed.
  double _mapSpeedToEngineRate(double speed) {
    return (speed * 0.5).clamp(0.1, 1.0);
  }

  Future<void> _applySpeechRate() async {
    final engineRate = _mapSpeedToEngineRate(_speed);
    await _tts.setSpeechRate(engineRate);
  }

  /// Discovers available English voices on the device, prioritizing Google high-quality en-US voices.
  Future<void> _loadVoices() async {
    try {
      final dynamic rawVoices = await _tts.getVoices;
      if (rawVoices is List) {
        final List<Map<String, String>> parsed = [];
        for (final item in rawVoices) {
          if (item is Map) {
            final name = item['name']?.toString() ?? '';
            final locale = item['locale']?.toString() ?? '';
            final lowerLocale = locale.toLowerCase();
            // Filter only English voices
            if (lowerLocale.startsWith('en') ||
                lowerLocale.contains('en-') ||
                lowerLocale.contains('en_')) {
              parsed.add({'name': name, 'locale': locale});
            }
          }
        }

        _englishVoices = parsed;

        if (_englishVoices.isNotEmpty) {
          // Preference order:
          // 1. Google TTS en-US natural/high-quality/network voice
          // 2. Any en-US voice
          // 3. First available English voice
          Map<String, String>? best;

          for (final voice in _englishVoices) {
            final loc = voice['locale']?.toLowerCase() ?? '';
            final name = voice['name']?.toLowerCase() ?? '';
            final isEnUs = loc.contains('en-us') || loc.contains('en_us');
            final isGoogleOrNatural =
                name.contains('google') ||
                name.contains('natural') ||
                name.contains('network') ||
                name.contains('premium');

            if (isEnUs && isGoogleOrNatural) {
              best = voice;
              break;
            }
          }

          best ??= _englishVoices.firstWhere((v) {
            final loc = v['locale']?.toLowerCase() ?? '';
            return loc.contains('en-us') || loc.contains('en_us');
          }, orElse: () => _englishVoices.first);

          await selectVoice(best);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to enumerate voices: $e");
      }
    }
  }

  /// Sets selected voice
  Future<void> selectVoice(
    Map<String, String> voice, {
    String? activeText,
  }) async {
    _selectedVoice = voice;
    try {
      await _tts.setVoice({"name": voice['name']!, "locale": voice['locale']!});
      if (_isPlaying && activeText != null && activeText.trim().isNotEmpty) {
        _isRestartRequested = true;
        await _tts.stop();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error setting voice: $e");
      }
    }
    notifyListeners();
  }

  /// Updates speech speed (0.5x to 2.0x).
  /// If [applyImmediately] is true and currently speaking, the current sentence
  /// will be restarted immediately at the new speed.
  Future<void> setSpeed(
    double newSpeed, {
    String? activeText,
    bool applyImmediately = true,
  }) async {
    _speed = double.parse(newSpeed.toStringAsFixed(1));
    await _applySpeechRate();
    notifyListeners();

    if (_isPlaying &&
        applyImmediately &&
        activeText != null &&
        activeText.trim().isNotEmpty) {
      _isRestartRequested = true;
      try {
        await _tts.stop();
      } catch (_) {}
    }
  }

  /// Sets pause duration between loop repeats (0 to 5 seconds).
  void setPauseDuration(double duration) {
    _pauseDuration = double.parse(duration.toStringAsFixed(1));
    notifyListeners();
  }

  /// Starts the endless repeat loop for the given text.
  Future<void> startLoop({required String text}) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) {
      _errorMessage = "Please enter some text before starting.";
      notifyListeners();
      return;
    }

    _errorMessage = null;
    _isPlaying = true;
    _isWaitingBetweenLoops = false;
    _isRestartRequested = false;
    _repeatCount = 0;
    final int sessionId = ++_loopSessionId;
    notifyListeners();

    // Prevent phone screen from turning off while playing
    try {
      await WakelockPlus.enable();
    } catch (_) {}

    while (_isPlaying && sessionId == _loopSessionId) {
      if (!_isRestartRequested) {
        _repeatCount++;
      }
      _isRestartRequested = false;
      _isWaitingBetweenLoops = false;
      notifyListeners();

      try {
        await _tts.speak(cleanText);
      } catch (e) {
        _errorMessage = "Playback error: $e";
        break;
      }

      // Check if user stopped while speaking
      if (!_isPlaying || sessionId != _loopSessionId) {
        break;
      }

      // If speech was stopped to restart immediately at new speed or voice
      if (_isRestartRequested) {
        continue;
      }

      // Configurable pause between repeats (0s - 5s)
      if (_pauseDuration > 0) {
        _isWaitingBetweenLoops = true;
        notifyListeners();

        final int totalMs = (_pauseDuration * 1000).toInt();
        const int stepMs = 50;
        final int steps = (totalMs / stepMs).ceil();

        for (int i = 0; i < steps; i++) {
          if (!_isPlaying ||
              sessionId != _loopSessionId ||
              _isRestartRequested) {
            break;
          }
          await Future.delayed(const Duration(milliseconds: stepMs));
        }

        if (_isRestartRequested) {
          continue;
        }
      }
    }

    // Clean up when loop exits
    if (sessionId == _loopSessionId) {
      _isPlaying = false;
      _isWaitingBetweenLoops = false;
      _isRestartRequested = false;
      try {
        await WakelockPlus.disable();
      } catch (_) {}
      notifyListeners();
    }
  }

  /// Immediately stops playback, cancels the loop, and disables screen wakelock.
  Future<void> stopLoop() async {
    _isPlaying = false;
    _isWaitingBetweenLoops = false;
    _isRestartRequested = false;
    _loopSessionId++; // Invalidate active loop

    try {
      await _tts.stop();
    } catch (_) {}

    try {
      await WakelockPlus.disable();
    } catch (_) {}

    notifyListeners();
  }

  /// Resets loop counter
  void resetCounter() {
    _repeatCount = 0;
    notifyListeners();
  }

  /// Clears error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _isPlaying = false;
    _loopSessionId++;
    _tts.stop();
    try {
      WakelockPlus.disable();
    } catch (_) {}
    super.dispose();
  }
}
