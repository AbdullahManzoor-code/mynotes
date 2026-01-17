import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting app settings
class SettingsService {
  static const String _themeKey = 'app_theme';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _alarmSoundKey = 'alarm_sound';
  static const String _vibrateKey = 'vibrate_enabled';

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
}
