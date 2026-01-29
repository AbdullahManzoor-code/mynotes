import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting app settings
class SettingsService {
  static const String _themeKey = 'app_theme';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _alarmSoundKey = 'alarm_sound';
  static const String _vibrateKey = 'vibrate_enabled';
  static const String _vibrationEnabledKey = 'vibration_enabled';
  static const String _ledEnabledKey = 'led_enabled';
  static const String _quietHoursEnabledKey = 'quiet_hours_enabled';
  static const String _quietHoursStartKey = 'quiet_hours_start';
  static const String _quietHoursEndKey = 'quiet_hours_end';

  static Future<void> setTheme(int themeIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, themeIndex);
  }

  static Future<int> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_themeKey) ?? 0;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  static Future<void> setAlarmSound(String sound) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_alarmSoundKey, sound);
  }

  static Future<String> getAlarmSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_alarmSoundKey) ?? 'Default';
  }

  static Future<void> setVibrateEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrateKey, enabled);
  }

  static Future<bool> getVibrateEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vibrateKey) ?? true;
  }

  // Vibration settings (instance methods)
  Future<void> setVibrationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationEnabledKey, enabled);
  }

  Future<bool> getVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vibrationEnabledKey) ?? true;
  }

  // LED settings
  Future<void> setLedEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ledEnabledKey, enabled);
  }

  Future<bool> getLedEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_ledEnabledKey) ?? true;
  }

  // Quiet hours settings
  Future<void> setQuietHoursEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_quietHoursEnabledKey, enabled);
  }

  Future<bool> getQuietHoursEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_quietHoursEnabledKey) ?? false;
  }

  Future<void> setQuietHoursStart(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_quietHoursStartKey, time);
  }

  Future<String?> getQuietHoursStart() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_quietHoursStartKey);
  }

  Future<void> setQuietHoursEnd(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_quietHoursEndKey, time);
  }

  Future<String?> getQuietHoursEnd() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_quietHoursEndKey);
  }
}
