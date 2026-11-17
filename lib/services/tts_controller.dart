import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/voice_model.dart';
import 'storage_service.dart';

enum PlaybackState { idle, playing, paused, pausingBetweenLoops }

/// Upgraded TTS Controller managing speech synthesis, endless loop sequencing,
/// 5 curated voice models, real-time word-by-word highlighting synchronization,
/// and automatic persistent settings.
class TtsController extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  PlaybackState _playbackState = PlaybackState.idle;
  bool _isRestartRequested = false;
  int _repeatCount = 0;
  double _speed = 1.0;
  double _pauseDuration = 1.0;
  String? _errorMessage;
  bool _isInitialized = false;
  int _loopSessionId = 0;
  String _activeSpeakingText = '';

  // Curated Voices (5 High-Quality Models)
  late List<CuratedVoice> _curatedVoices;
  late CuratedVoice _selectedCuratedVoice;
  List<Map<String, String>> _rawDeviceVoices = [];

  // Synchronized Word Highlighting
  int? _highlightStart;
  int? _highlightEnd;
  String? _currentWord;

  // Getters
  PlaybackState get playbackState => _playbackState;
  bool get isPlaying =>
      _playbackState == PlaybackState.playing ||
      _playbackState == PlaybackState.pausingBetweenLoops;
  bool get isPaused => _playbackState == PlaybackState.paused;
  bool get isIdle => _playbackState == PlaybackState.idle;
  bool get isWaitingBetweenLoops =>
      _playbackState == PlaybackState.pausingBetweenLoops;

  int get repeatCount => _repeatCount;
  double get speed => _speed;
  double get pauseDuration => _pauseDuration;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  String get activeSpeakingText => _activeSpeakingText;

  List<CuratedVoice> get curatedVoices => _curatedVoices;
  CuratedVoice get selectedCuratedVoice => _selectedCuratedVoice;

  int? get highlightStart => _highlightStart;
  int? get highlightEnd => _highlightEnd;
  String? get currentWord => _currentWord;

  /// Initializes TTS engine, restores persistent settings, and binds curated voice models.
  Future<void> initialize() async {
    // 1. Initialize persistent storage
    await StorageService.init();
    _speed = StorageService.getSpeed(defaultSpeed: 1.0);
    _pauseDuration = StorageService.getPauseDuration(defaultPause: 1.0);

    // 2. Initialize curated voices list
    _curatedVoices = CuratedVoice.getCuratedList();
    _selectedCuratedVoice = _curatedVoices.first;

    try {
      await _tts.awaitSpeakCompletion(true);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _applySpeechRate();

      // Configure Real-Time Word Highlighting Progress Handler
      _tts.setProgressHandler((String text, int start, int end, String word) {
        _highlightStart = start;
        _highlightEnd = end;
        _currentWord = word;
        notifyListeners();
      });

      _tts.setErrorHandler((dynamic msg) {
        _errorMessage = "TTS engine error: $msg";
        notifyListeners();
      });

      // Load installed device voices and bind to curated models
      await _loadAndBindVoices();

      // Restore saved voice model preference
      final savedVoiceId = StorageService.getVoiceId();
      if (savedVoiceId != null) {
        final match = _curatedVoices.firstWhere(
          (v) => v.id == savedVoiceId,
          orElse: () => _curatedVoices.first,
        );
        await selectCuratedVoice(match, autoSave: false);
      } else {
        await _applyVoiceToEngine(_selectedCuratedVoice);
      }

      _isInitialized = true;
    } catch (e) {
      _errorMessage =
          "Could not initialize TTS engine ($e). Make sure 'Speech Services by Google' is enabled.";
    }
    notifyListeners();
  }

  /// Maps 0.5x–2.0x UI speed to Android flutter_tts rate (0.5 engine rate = 1.0x normal speech).
  double _mapSpeedToEngineRate(double speed) {
    return (speed * 0.5).clamp(0.1, 1.0);
  }

  Future<void> _applySpeechRate() async {
    final engineRate = _mapSpeedToEngineRate(_speed);
    await _tts.setSpeechRate(engineRate);
  }

  /// Discovers available device voices and binds them to the 5 curated voice models.
  Future<void> _loadAndBindVoices() async {
    try {
      final dynamic rawVoices = await _tts.getVoices;
      if (rawVoices is List) {
        final List<Map<String, String>> parsed = [];
        for (final item in rawVoices) {
          if (item is Map) {
            final name = item['name']?.toString() ?? '';
            final locale = item['locale']?.toString() ?? '';
            final lower = locale.toLowerCase();
            if (lower.startsWith('en') ||
                lower.contains('en-') ||
                lower.contains('en_')) {
              parsed.add({'name': name, 'locale': locale});
            }
          }
        }
        _rawDeviceVoices = parsed;
        CuratedVoice.bindNativeVoices(_curatedVoices, _rawDeviceVoices);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to enumerate voices: $e");
      }
    }
  }

  /// Sets the active Curated Voice model and applies it to the native engine.
  Future<void> selectCuratedVoice(
    CuratedVoice voice, {
    bool autoSave = true,
    String? activeText,
  }) async {
    _selectedCuratedVoice = voice;
    if (autoSave) {
      await StorageService.saveVoiceId(voice.id);
    }
    await _applyVoiceToEngine(voice);

    if (isPlaying && activeText != null && activeText.trim().isNotEmpty) {
      _isRestartRequested = true;
      try {
        await _tts.stop();
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> _applyVoiceToEngine(CuratedVoice voice) async {
    try {
      await _tts.setLanguage(voice.locale);
      if (voice.matchedNativeName != null &&
          voice.matchedNativeName!.isNotEmpty) {
        await _tts.setVoice({
          "name": voice.matchedNativeName!,
          "locale": voice.locale,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error applying voice: $e");
      }
    }
  }

  /// Speaks a quick 1-sentence sample preview for the voice selector sheet.
  Future<void> previewVoice(CuratedVoice voice) async {
    final wasPlaying = isPlaying;
    if (wasPlaying) {
      await pauseLoop();
    }
    try {
      await _applyVoiceToEngine(voice);
      await _tts.speak(voice.samplePreview);
    } catch (_) {}
  }

  /// Updates speech speed (0.5x to 2.0x) with immediate persistence and live rate update.
  Future<void> setSpeed(
    double newSpeed, {
    String? activeText,
    bool applyImmediately = true,
  }) async {
    _speed = double.parse(newSpeed.toStringAsFixed(1));
    await StorageService.saveSpeed(_speed);
    await _applySpeechRate();
    notifyListeners();

    if (isPlaying &&
        applyImmediately &&
        activeText != null &&
        activeText.trim().isNotEmpty) {
      _isRestartRequested = true;
      try {
        await _tts.stop();
      } catch (_) {}
    }
  }

  /// Sets pause duration between loop repeats (0 to 5 seconds) with immediate persistence.
  void setPauseDuration(double duration) {
    _pauseDuration = double.parse(duration.toStringAsFixed(1));
    StorageService.savePauseDuration(_pauseDuration);
    notifyListeners();
  }

  /// Starts or resumes the endless repeat loop for the given text.
  Future<void> startLoop({required String text}) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) {
      _errorMessage = "Please enter some text before starting.";
      notifyListeners();
      return;
    }

    _activeSpeakingText = cleanText;
    _errorMessage = null;
    _playbackState = PlaybackState.playing;
    _isRestartRequested = false;

    // If starting fresh (from idle), reset repeat counter
    if (_repeatCount == 0 || _playbackState == PlaybackState.idle) {
      _repeatCount = 0;
    }

    final int sessionId = ++_loopSessionId;
    notifyListeners();

    try {
      await WakelockPlus.enable();
    } catch (_) {}

    while (isPlaying && sessionId == _loopSessionId) {
      if (!_isRestartRequested) {
        _repeatCount++;
      }
      _isRestartRequested = false;
      _playbackState = PlaybackState.playing;
      _clearHighlight();
      notifyListeners();

      try {
        await _tts.speak(cleanText);
      } catch (e) {
        _errorMessage = "Playback error: $e";
        break;
      }

      // Check if paused or stopped while speaking
      if (!isPlaying || sessionId != _loopSessionId) {
        break;
      }

      if (_isRestartRequested) {
        continue;
      }

      // Configurable pause between repeats (0s - 5s)
      if (_pauseDuration > 0) {
        _playbackState = PlaybackState.pausingBetweenLoops;
        _clearHighlight();
        notifyListeners();

        final int totalMs = (_pauseDuration * 1000).toInt();
        const int stepMs = 50;
        final int steps = (totalMs / stepMs).ceil();

        for (int i = 0; i < steps; i++) {
          if (!isPlaying ||
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

    // Clean up if loop naturally exited
    if (sessionId == _loopSessionId && _playbackState != PlaybackState.paused) {
      _playbackState = PlaybackState.idle;
      _clearHighlight();
      try {
        await WakelockPlus.disable();
      } catch (_) {}
      notifyListeners();
    }
  }

  /// Pauses playback and holds state.
  Future<void> pauseLoop() async {
    _playbackState = PlaybackState.paused;
    _loopSessionId++; // Invalidate active speech run
    try {
      await _tts.stop();
    } catch (_) {}
    try {
      await WakelockPlus.disable();
    } catch (_) {}
    notifyListeners();
  }

  /// Resumes playback from paused state.
  Future<void> resumeLoop() async {
    if (_activeSpeakingText.isNotEmpty) {
      await startLoop(text: _activeSpeakingText);
    }
  }

  /// Completely stops playback, cancels loop, and resets word highlighting.
  Future<void> stopLoop() async {
    _playbackState = PlaybackState.idle;
    _isRestartRequested = false;
    _clearHighlight();
    _loopSessionId++; // Invalidate active loop

    try {
      await _tts.stop();
    } catch (_) {}

    try {
      await WakelockPlus.disable();
    } catch (_) {}

    notifyListeners();
  }

  void _clearHighlight() {
    _highlightStart = null;
    _highlightEnd = null;
    _currentWord = null;
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
    _playbackState = PlaybackState.idle;
    _loopSessionId++;
    _tts.stop();
    try {
      WakelockPlus.disable();
    } catch (_) {}
    super.dispose();
  }
}
