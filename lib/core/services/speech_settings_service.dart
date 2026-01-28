import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing speech recognition settings and preferences
class SpeechSettingsService {
  static const String _confidenceKey = 'speech_confidence';
  static const String _timeoutKey = 'speech_timeout';
  static const String _autoPunctuationKey = 'speech_auto_punctuation';
  static const String _autoCapitalizeKey = 'speech_auto_capitalize';
  static const String _commandsEnabledKey = 'speech_commands_enabled';
  static const String _hapticsEnabledKey = 'speech_haptics_enabled';
  static const String _soundFeedbackKey = 'speech_sound_feedback';
  static const String _batteryOptimizationKey = 'speech_battery_optimization';

  // Default values
  static const double _defaultConfidence = 0.5;
  static const int _defaultTimeout = 30;
  static const bool _defaultAutoPunctuation = true;
  static const bool _defaultAutoCapitalize = true;
  static const bool _defaultCommandsEnabled = true;
  static const bool _defaultHapticsEnabled = true;
  static const bool _defaultSoundFeedback = false;
  static const bool _defaultBatteryOptimization = false;

  /// Get minimum confidence threshold
  Future<double> getMinConfidence() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_confidenceKey) ?? _defaultConfidence;
  }

  /// Set minimum confidence threshold
  Future<void> setMinConfidence(double confidence) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_confidenceKey, confidence.clamp(0.0, 1.0));
  }

  /// Get custom timeout in seconds
  Future<int> getTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_timeoutKey) ?? _defaultTimeout;
  }

  /// Set custom timeout in seconds
  Future<void> setTimeout(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timeoutKey, seconds.clamp(5, 120));
  }

  /// Get auto-punctuation setting
  Future<bool> getAutoPunctuation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoPunctuationKey) ?? _defaultAutoPunctuation;
  }

  /// Set auto-punctuation setting
  Future<void> setAutoPunctuation(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoPunctuationKey, enabled);
  }

  /// Get auto-capitalize setting
  Future<bool> getAutoCapitalize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoCapitalizeKey) ?? _defaultAutoCapitalize;
  }

  /// Set auto-capitalize setting
  Future<void> setAutoCapitalize(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoCapitalizeKey, enabled);
  }

  /// Get voice commands enabled setting
  Future<bool> getCommandsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_commandsEnabledKey) ?? _defaultCommandsEnabled;
  }

  /// Set voice commands enabled setting
  Future<void> setCommandsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_commandsEnabledKey, enabled);
  }

  /// Get haptics enabled setting
  Future<bool> getHapticsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hapticsEnabledKey) ?? _defaultHapticsEnabled;
  }

  /// Set haptics enabled setting
  Future<void> setHapticsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticsEnabledKey, enabled);
  }

  /// Get sound feedback setting
  Future<bool> getSoundFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundFeedbackKey) ?? _defaultSoundFeedback;
  }

  /// Set sound feedback setting
  Future<void> setSoundFeedback(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundFeedbackKey, enabled);
  }

  /// Get battery optimization setting
  Future<bool> getBatteryOptimization() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_batteryOptimizationKey) ??
        _defaultBatteryOptimization;
  }

  /// Set battery optimization setting
  Future<void> setBatteryOptimization(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_batteryOptimizationKey, enabled);
  }

  /// Get all settings as a map
  Future<Map<String, dynamic>> getAllSettings() async {
    return {
      'minConfidence': await getMinConfidence(),
      'timeout': await getTimeout(),
      'autoPunctuation': await getAutoPunctuation(),
      'autoCapitalize': await getAutoCapitalize(),
      'commandsEnabled': await getCommandsEnabled(),
      'hapticsEnabled': await getHapticsEnabled(),
      'soundFeedback': await getSoundFeedback(),
      'batteryOptimization': await getBatteryOptimization(),
    };
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_confidenceKey, _defaultConfidence);
    await prefs.setInt(_timeoutKey, _defaultTimeout);
    await prefs.setBool(_autoPunctuationKey, _defaultAutoPunctuation);
    await prefs.setBool(_autoCapitalizeKey, _defaultAutoCapitalize);
    await prefs.setBool(_commandsEnabledKey, _defaultCommandsEnabled);
    await prefs.setBool(_hapticsEnabledKey, _defaultHapticsEnabled);
    await prefs.setBool(_soundFeedbackKey, _defaultSoundFeedback);
    await prefs.setBool(_batteryOptimizationKey, _defaultBatteryOptimization);
  }
}

