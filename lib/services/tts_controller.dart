import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/voice_model.dart';
import 'storage_service.dart';

enum PlaybackState { idle, playing, paused, pausingBetweenLoops }

/// Upgraded, high-performance TTS Controller for Repeat Speaker.
/// Features immediate 0ms voice switching, real-time dynamic text synchronization,
/// exact post-utterance loop counting, configurable loop limit enforcement,
/// and buttery-smooth 60-120fps progress tracking.
class TtsController extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  PlaybackState _playbackState = PlaybackState.idle;
  bool _isRestartRequested = false;
  int _repeatCount = 0;
  int _targetLoopLimit = 0; // 0 = Endless loop, > 0 = auto-stop after N repeats
  double _speed = 1.0;
  double _pauseDuration = 1.0;
  String? _errorMessage;
  bool _isInitialized = false;
  int _loopSessionId = 0;

  // Real-time Text Synchronization
  String _currentText = '';
  String Function()? _textSupplier;

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
  int get targetLoopLimit => _targetLoopLimit;
  double get speed => _speed;
  double get pauseDuration => _pauseDuration;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  String get currentText => _currentText;

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
    _targetLoopLimit = StorageService.getLoopLimit(defaultLimit: 0);

    // 2. Initialize curated voices list
    _curatedVoices = CuratedVoice.getCuratedList();
    _selectedCuratedVoice = _curatedVoices.first;

    try {
      await _tts.awaitSpeakCompletion(true);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _applySpeechRate();

      // Configure Real-Time Word Highlighting (debounced & deduplicated)
      _tts.setProgressHandler((String text, int start, int end, String word) {
        if (_highlightStart != start || _highlightEnd != end) {
          _highlightStart = start;
          _highlightEnd = end;
          _currentWord = word;
          notifyListeners();
        }
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
        _selectedCuratedVoice = match;
      }
      await _applyVoiceToEngine(_selectedCuratedVoice);

      _isInitialized = true;
    } catch (e) {
      _errorMessage =
          "Could not initialize TTS engine ($e). Make sure 'Speech Services by Google' is enabled.";
    }
    notifyListeners();
  }

  /// Dynamic text synchronization: updates text immediately so next speech
  /// always speaks the latest user-provided text.
  void updateText(String newText) {
    _currentText = newText.trim();
  }

  /// Sets loop repetition limit (0 = Endless, 1, 3, 5, 10, etc.)
  void setTargetLoopLimit(int limit) {
    if (_targetLoopLimit != limit) {
      _targetLoopLimit = limit;
      StorageService.saveLoopLimit(limit);
      notifyListeners();
    }
  }

  /// Maps 0.5x–2.0x UI speed to Android flutter_tts rate.
  double _mapSpeedToEngineRate(double speed) {
    return (speed * 0.5).clamp(0.1, 1.0);
  }

  Future<void> _applySpeechRate() async {
    final engineRate = _mapSpeedToEngineRate(_speed);
    await _tts.setSpeechRate(engineRate);
  }

  /// Discovers available device voices and binds them to curated models.
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

  /// Selects voice model with INSTANT (0ms) synchronous UI update.
  /// Asynchronously persists to storage and updates native engine in background.
  void selectCuratedVoice(
    CuratedVoice voice, {
    bool autoSave = true,
    String? activeText,
  }) {
    if (_selectedCuratedVoice.id == voice.id) return;

    // 1. Instant synchronous UI update
    _selectedCuratedVoice = voice;
    notifyListeners();

    // 2. Asynchronous disk persistence
    if (autoSave) {
      StorageService.saveVoiceId(voice.id);
    }

    // 3. Asynchronously configure native engine
    _applyVoiceToEngine(voice).then((_) {
      if (isPlaying) {
        _isRestartRequested = true;
        try {
          _tts.stop();
        } catch (_) {}
      }
    });
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

  /// Speaks a quick sample preview for the voice selector.
  /// Strictly halts any active repeat loop before speaking preview,
  /// preventing audio collision and loop runaway.
  Future<void> previewVoice(CuratedVoice voice) async {
    // 1. Invalidate any active background loop completely
    _playbackState = PlaybackState.paused;
    _loopSessionId++;
    _clearHighlight();
    notifyListeners();

    try {
      await _tts.stop();
    } catch (_) {}

    try {
      await _applyVoiceToEngine(voice);
      await _tts.speak(voice.samplePreview);
    } catch (_) {}
  }

  /// Updates speech speed with immediate persistence and live rate update.
  Future<void> setSpeed(
    double newSpeed, {
    String? activeText,
    bool applyImmediately = true,
  }) async {
    _speed = double.parse(newSpeed.toStringAsFixed(1));
    await StorageService.saveSpeed(_speed);
    await _applySpeechRate();
    notifyListeners();

    if (isPlaying && applyImmediately) {
      _isRestartRequested = true;
      try {
        await _tts.stop();
      } catch (_) {}
    }
  }

  /// Sets pause duration between loop repeats (0 to 5 seconds).
  void setPauseDuration(double duration) {
    _pauseDuration = double.parse(duration.toStringAsFixed(1));
    StorageService.savePauseDuration(_pauseDuration);
    notifyListeners();
  }

  /// Starts or resumes the repeat loop for the given text.
  /// Uses [textSupplier] to dynamically fetch latest text before each repetition,
  /// preventing stale or hardcoded text from being spoken.
  Future<void> startLoop({
    required String text,
    String Function()? textSupplier,
  }) async {
    _textSupplier = textSupplier;
    _currentText = text.trim();

    if (_currentText.isEmpty) {
      _errorMessage = "Please enter some text before starting.";
      notifyListeners();
      return;
    }

    _errorMessage = null;
    _playbackState = PlaybackState.playing;
    _isRestartRequested = false;

    // Fresh session token
    final int sessionId = ++_loopSessionId;
    notifyListeners();

    try {
      await WakelockPlus.enable();
    } catch (_) {}

    // Ensure active voice is applied before speaking
    await _applyVoiceToEngine(_selectedCuratedVoice);

    while (_playbackState == PlaybackState.playing &&
        sessionId == _loopSessionId) {
      // 1. Dynamically fetch latest text for this repetition
      final String phrase = _textSupplier != null
          ? _textSupplier!().trim()
          : _currentText.trim();

      if (phrase.isEmpty) {
        _errorMessage = "Text is empty.";
        break;
      }
      _currentText = phrase;

      _isRestartRequested = false;
      _playbackState = PlaybackState.playing;
      _clearHighlight();
      notifyListeners();

      // 2. Speak the phrase with timing safeguard
      final stopwatch = Stopwatch()..start();
      try {
        await _tts.speak(phrase);
      } catch (e) {
        _errorMessage = "Playback error: $e";
        break;
      }
      stopwatch.stop();

      // Check if paused or stopped while speaking
      if (_playbackState != PlaybackState.playing ||
          sessionId != _loopSessionId) {
        break;
      }

      // If speech was interrupted, aborted, or returned instantaneously (< 350ms)
      // (such as when switching voices or stopping engine), do NOT increment loop count!
      if (_isRestartRequested || stopwatch.elapsedMilliseconds < 350) {
        _isRestartRequested = false;
        continue;
      }

      // 3. INCREMENT LOOP COUNT ONLY AFTER GENUINE SUCCESSFUL COMPLETION
      _repeatCount++;
      notifyListeners();

      // 4. CHECK LOOP LIMIT (Stop automatically when target is reached)
      if (_targetLoopLimit > 0 && _repeatCount >= _targetLoopLimit) {
        _playbackState = PlaybackState.idle;
        _clearHighlight();
        try {
          await WakelockPlus.disable();
        } catch (_) {}
        notifyListeners();
        break; // Reached configured loop limit!
      }

      // 5. Configurable pause between repeats (0s - 5s)
      if (_pauseDuration > 0) {
        _playbackState = PlaybackState.pausingBetweenLoops;
        _clearHighlight();
        notifyListeners();

        final int totalMs = (_pauseDuration * 1000).toInt();
        const int stepMs = 50;
        final int steps = (totalMs / stepMs).ceil();

        for (int i = 0; i < steps; i++) {
          if (_playbackState != PlaybackState.pausingBetweenLoops ||
              sessionId != _loopSessionId ||
              _isRestartRequested) {
            break;
          }
          await Future.delayed(const Duration(milliseconds: stepMs));
        }

        if (_playbackState != PlaybackState.pausingBetweenLoops ||
            sessionId != _loopSessionId) {
          break;
        }

        if (_isRestartRequested) {
          continue;
        }

        _playbackState = PlaybackState.playing;
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

  /// Pauses playback and holds loop counter and state.
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

  /// Resumes playback from paused state using the latest text.
  Future<void> resumeLoop({String? latestText}) async {
    final textToUse = latestText?.trim().isNotEmpty == true
        ? latestText!.trim()
        : (_textSupplier != null
              ? _textSupplier!().trim()
              : _currentText.trim());

    if (textToUse.isNotEmpty) {
      await startLoop(text: textToUse, textSupplier: _textSupplier);
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

  /// Resets loop counter back to 0.
  void resetCounter() {
    _repeatCount = 0;
    notifyListeners();
  }

  /// Clears error message.
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
