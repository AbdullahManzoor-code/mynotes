import 'dart:ui';

import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

/// Enhanced service for speech-to-text functionality with advanced features
class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;
  bool _isPaused = false;
  String _currentLocale = 'en_US';
  double _minConfidence = 0.5;
  int _customTimeout = 30;
  bool _permissionGranted = false;
  double _currentSoundLevel = 0.0;

  /// Get listening status
  bool get isListening => _isListening;

  /// Get availability status
  bool get isAvailable => _isAvailable;

  /// Get paused status
  bool get isPaused => _isPaused;

  /// Get current sound level (0.0 to 1.0)
  double get soundLevel => _currentSoundLevel;

  /// Get current locale
  String get currentLocale => _currentLocale;

  /// Set minimum confidence threshold (0.0 to 1.0)
  void setMinConfidence(double confidence) {
    _minConfidence = confidence.clamp(0.0, 1.0);
  }

  /// Set custom timeout in seconds
  void setCustomTimeout(int seconds) {
    _customTimeout = seconds.clamp(5, 120);
  }

  /// Set preferred language locale
  void setLocale(String locale) {
    _currentLocale = locale;
  }

  /// Initialize speech recognition with caching
  Future<bool> initialize() async {
    try {
      // Check cached permission status
      if (_permissionGranted) {
        if (!_isAvailable) {
          _isAvailable = await _speech.initialize(
            onError: (error) => _handleError(error.errorMsg),
            onStatus: (status) => _handleStatus(status),
          );
        }
        return _isAvailable;
      }

      // Request microphone permission
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        return false;
      }

      _permissionGranted = true;

      _isAvailable = await _speech.initialize(
        onError: (error) => _handleError(error.errorMsg),
        onStatus: (status) => _handleStatus(status),
      );

      return _isAvailable;
    } catch (e) {
      print('Error initializing speech: $e');
      return false;
    }
  }

  /// Handle error messages
  void _handleError(String error) {
    print('Speech error: $error');
    // Could emit to a stream for UI consumption
  }

  /// Handle status changes
  void _handleStatus(String status) {
    print('Speech status: $status');
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
      _isPaused = false;
    }
  }

  /// Start listening for speech with advanced options
  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onPartialResult,
    VoidCallback? onDone,
    Function(double)? onSoundLevel,
  }) async {
    if (!_isAvailable) {
      final initialized = await initialize();
      if (!initialized) return;
    }

    if (_isListening) return;

    _isListening = true;
    _isPaused = false;

    await _speech.listen(
      onResult: (result) {
        // Apply confidence filtering
        if (result.confidence < _minConfidence) {
          return;
        }

        // Apply smart formatting
        String text = result.recognizedWords;
        text = _applySmartFormatting(text);

        if (result.finalResult) {
          onResult(text);
          if (onDone != null) onDone();
          _isListening = false;
        } else if (onPartialResult != null) {
          onPartialResult(text);
        }
      },
      onSoundLevelChange: (level) {
        _currentSoundLevel = level;
        if (onSoundLevel != null) onSoundLevel(level);
      },
      localeId: _currentLocale,
      listenFor: Duration(seconds: _customTimeout),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
      listenMode: ListenMode.dictation,
    );
  }

  /// Apply smart text formatting
  String _applySmartFormatting(String text) {
    if (text.isEmpty) return text;

    // Auto-capitalize first letter
    text = text[0].toUpperCase() + text.substring(1);

    // Auto-punctuation
    text = text.replaceAllMapped(
      RegExp(r'\b(period|dot)\b', caseSensitive: false),
      (match) => '.',
    );
    text = text.replaceAllMapped(
      RegExp(r'\b(comma)\b', caseSensitive: false),
      (match) => ',',
    );
    text = text.replaceAllMapped(
      RegExp(r'\b(question mark)\b', caseSensitive: false),
      (match) => '?',
    );
    text = text.replaceAllMapped(
      RegExp(r'\b(exclamation mark|exclamation point)\b', caseSensitive: false),
      (match) => '!',
    );

    // New line commands
    text = text.replaceAllMapped(
      RegExp(r'\b(new line|next line)\b', caseSensitive: false),
      (match) => '\n',
    );
    text = text.replaceAllMapped(
      RegExp(r'\b(new paragraph)\b', caseSensitive: false),
      (match) => '\n\n',
    );

    return text;
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      _isPaused = false;
    }
  }

  /// Pause listening (if supported by platform)
  Future<void> pauseListening() async {
    if (_isListening && !_isPaused) {
      await _speech.stop();
      _isPaused = true;
    }
  }

  /// Resume listening after pause
  Future<void> resumeListening({
    required Function(String) onResult,
    Function(String)? onPartialResult,
    VoidCallback? onDone,
  }) async {
    if (_isPaused) {
      _isPaused = false;
      await startListening(
        onResult: onResult,
        onPartialResult: onPartialResult,
        onDone: onDone,
      );
    }
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    if (_isListening) {
      await _speech.cancel();
      _isListening = false;
    }
  }

  /// Get available locales
  Future<List<LocaleName>> getLocales() async {
    if (!_isAvailable) {
      await initialize();
    }
    return await _speech.locales();
  }

  /// Dispose resources
  void dispose() {
    _speech.stop();
  }
}
