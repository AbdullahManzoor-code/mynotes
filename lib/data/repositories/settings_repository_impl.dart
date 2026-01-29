import 'package:uuid/uuid.dart';
import '../../domain/entities/user_settings.dart';
import '../datasources/local_database.dart';

/// Repository for user settings persistence
class SettingsRepositoryImpl {
  final NotesDatabase _database;
  late UserSettings _cachedSettings;
  bool _settingsLoaded = false;

  SettingsRepositoryImpl(this._database);

  /// Get or initialize user settings
  Future<UserSettings> getSettings() async {
    if (_settingsLoaded) {
      return _cachedSettings;
    }

    final db = await _database.database;
    final maps = await db.query(NotesDatabase.userSettingsTable);

    if (maps.isEmpty) {
      // Create default settings
      final defaultSettings = UserSettings(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await db.insert(
        NotesDatabase.userSettingsTable,
        defaultSettings.toMap(),
      );

      _cachedSettings = defaultSettings;
      _settingsLoaded = true;
      return _cachedSettings;
    }

    _cachedSettings = UserSettings.fromMap(maps.first);
    _settingsLoaded = true;
    return _cachedSettings;
  }

  /// Update user settings
  Future<void> updateSettings(UserSettings settings) async {
    final db = await _database.database;

    await db.update(
      NotesDatabase.userSettingsTable,
      {
        ...settings.toMap(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [settings.id],
    );

    _cachedSettings = settings;
  }

  /// Update theme
  Future<void> updateTheme(String theme) async {
    final settings = await getSettings();
    final updated = settings.copyWith(theme: theme);
    await updateSettings(updated);
  }

  /// Update font family
  Future<void> updateFontFamily(String fontFamily) async {
    final settings = await getSettings();
    final updated = settings.copyWith(fontFamily: fontFamily);
    await updateSettings(updated);
  }

  /// Update font size
  Future<void> updateFontSize(double fontSize) async {
    final settings = await getSettings();
    final updated = settings.copyWith(fontSize: fontSize);
    await updateSettings(updated);
  }

  /// Toggle biometric
  Future<void> setBiometricEnabled(bool enabled) async {
    final settings = await getSettings();
    final updated = settings.copyWith(biometricEnabled: enabled);
    await updateSettings(updated);
  }

  /// Update PIN requirement
  Future<void> setPinRequired(bool required) async {
    final settings = await getSettings();
    final updated = settings.copyWith(pinRequired: required);
    await updateSettings(updated);
  }

  /// Update auto-lock minutes
  Future<void> setAutoLockMinutes(int minutes) async {
    final settings = await getSettings();
    final updated = settings.copyWith(autoLockMinutes: minutes);
    await updateSettings(updated);
  }

  /// Toggle notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    final settings = await getSettings();
    final updated = settings.copyWith(notificationsEnabled: enabled);
    await updateSettings(updated);
  }

  /// Toggle sound
  Future<void> setSoundEnabled(bool enabled) async {
    final settings = await getSettings();
    final updated = settings.copyWith(soundEnabled: enabled);
    await updateSettings(updated);
  }

  /// Toggle vibration
  Future<void> setVibrationEnabled(bool enabled) async {
    final settings = await getSettings();
    final updated = settings.copyWith(vibrationEnabled: enabled);
    await updateSettings(updated);
  }

  /// Set quiet hours
  Future<void> setQuietHours(String? startTime, String? endTime) async {
    final settings = await getSettings();
    final updated = settings.copyWith(
      quietHoursStart: startTime,
      quietHoursEnd: endTime,
    );
    await updateSettings(updated);
  }

  /// Update voice language
  Future<void> setVoiceLanguage(String language) async {
    final settings = await getSettings();
    final updated = settings.copyWith(voiceLanguage: language);
    await updateSettings(updated);
  }

  /// Toggle voice commands
  Future<void> setVoiceCommandsEnabled(bool enabled) async {
    final settings = await getSettings();
    final updated = settings.copyWith(voiceCommandsEnabled: enabled);
    await updateSettings(updated);
  }

  /// Toggle audio feedback
  Future<void> setAudioFeedbackEnabled(bool enabled) async {
    final settings = await getSettings();
    final updated = settings.copyWith(audioFeedbackEnabled: enabled);
    await updateSettings(updated);
  }

  /// Set voice confidence threshold
  Future<void> setVoiceConfidenceThreshold(double threshold) async {
    final settings = await getSettings();
    final updated = settings.copyWith(
      voiceConfidenceThreshold: threshold.clamp(0.6, 0.9),
    );
    await updateSettings(updated);
  }

  /// Set default note color
  Future<void> setDefaultNoteColor(int color) async {
    final settings = await getSettings();
    final updated = settings.copyWith(defaultNoteColor: color);
    await updateSettings(updated);
  }

  /// Set default todo category
  Future<void> setDefaultTodoCategory(String category) async {
    final settings = await getSettings();
    final updated = settings.copyWith(defaultTodoCategory: category);
    await updateSettings(updated);
  }

  /// Set default todo priority
  Future<void> setDefaultTodoPriority(int priority) async {
    final settings = await getSettings();
    final updated = settings.copyWith(defaultTodoPriority: priority);
    await updateSettings(updated);
  }

  /// Toggle auto-backup
  Future<void> setAutoBackupEnabled(bool enabled) async {
    final settings = await getSettings();
    final updated = settings.copyWith(autoBackupEnabled: enabled);
    await updateSettings(updated);
  }

  /// Toggle cloud sync
  Future<void> setCloudSyncEnabled(bool enabled) async {
    final settings = await getSettings();
    final updated = settings.copyWith(cloudSyncEnabled: enabled);
    await updateSettings(updated);
  }

  /// Check if quiet hours active now
  Future<bool> isQuietHourActive() async {
    final settings = await getSettings();

    if (settings.quietHoursStart == null || settings.quietHoursEnd == null) {
      return false;
    }

    final now = DateTime.now();
    final startTime = _parseTime(settings.quietHoursStart!);
    final endTime = _parseTime(settings.quietHoursEnd!);

    // Handle case where quiet hours cross midnight
    if (startTime.isBefore(endTime)) {
      return now.isAfter(startTime) && now.isBefore(endTime);
    } else {
      // Spans midnight
      return now.isAfter(startTime) || now.isBefore(endTime);
    }
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    final settings = await getSettings();
    final defaultSettings = UserSettings(
      id: settings.id,
      createdAt: settings.createdAt,
      updatedAt: DateTime.now(),
    );

    await updateSettings(defaultSettings);
  }

  /// Helper to parse time string (HH:mm format)
  DateTime _parseTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// Clear cached settings (forces reload on next access)
  void clearCache() {
    _settingsLoaded = false;
  }
}
