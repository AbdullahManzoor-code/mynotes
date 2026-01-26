import 'package:flutter/services.dart';

/// Service for audio and haptic feedback
class AudioFeedbackService {
  bool _hapticsEnabled = true;
  bool _soundEnabled = true;

  /// Enable or disable haptic feedback
  void setHapticsEnabled(bool enabled) {
    _hapticsEnabled = enabled;
  }

  /// Enable or disable sound feedback
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Get haptics status
  bool get isHapticsEnabled => _hapticsEnabled;

  /// Get sound status
  bool get isSoundEnabled => _soundEnabled;

  /// Light haptic feedback (for button presses)
  Future<void> lightHaptic() async {
    if (_hapticsEnabled) {
      await HapticFeedback.lightImpact();
    }
  }

  /// Medium haptic feedback (for selections)
  Future<void> mediumHaptic() async {
    if (_hapticsEnabled) {
      await HapticFeedback.mediumImpact();
    }
  }

  /// Heavy haptic feedback (for important actions)
  Future<void> heavyHaptic() async {
    if (_hapticsEnabled) {
      await HapticFeedback.heavyImpact();
    }
  }

  /// Selection haptic (for scrolling through items)
  Future<void> selectionHaptic() async {
    if (_hapticsEnabled) {
      await HapticFeedback.selectionClick();
    }
  }

  /// Vibrate for errors
  Future<void> errorHaptic() async {
    if (_hapticsEnabled) {
      await HapticFeedback.vibrate();
    }
  }

  /// Success pattern (double tap)
  Future<void> successHaptic() async {
    if (_hapticsEnabled) {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    }
  }

  /// Recording started feedback
  Future<void> recordingStarted() async {
    await heavyHaptic();
    // Could play a beep sound here if sound is enabled
  }

  /// Recording stopped feedback
  Future<void> recordingStopped() async {
    await mediumHaptic();
    // Could play a beep sound here if sound is enabled
  }

  /// Command recognized feedback
  Future<void> commandRecognized() async {
    await successHaptic();
  }

  /// Error occurred feedback
  Future<void> errorOccurred() async {
    await errorHaptic();
  }
}
