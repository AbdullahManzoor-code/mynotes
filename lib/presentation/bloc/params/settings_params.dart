import 'package:equatable/equatable.dart';

/// Complete Param Model for Settings Operations
/// 📦 Container for all settings-related data
class SettingsParams extends Equatable {
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String notificationFrequency; // immediate, hourly, daily
  final bool darkModeEnabled;
  final String fontSizePreference; // small, medium, large
  final bool autoSaveEnabled;
  final int autoSaveIntervalSeconds;
  final bool cloudSyncEnabled;
  final String language;
  final bool passwordProtected;
  final List<String> backupLocations;
  final bool analyticsEnabled;

  final bool ledEnabled;
  final bool quietHoursEnabled;
  final String quietHoursStart;
  final String quietHoursEnd;
  final bool biometricEnabled;
  final bool biometricAvailable;
  final bool useCustomColors;
  final String storageUsed;
  final int mediaCount;
  final int noteCount;
  final String fontFamily;
  final double fontScale;

  const SettingsParams({
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.notificationFrequency = 'immediate',
    this.darkModeEnabled = false,
    this.fontSizePreference = 'medium',
    this.autoSaveEnabled = true,
    this.autoSaveIntervalSeconds = 30,
    this.cloudSyncEnabled = false,
    this.language = 'en',
    this.passwordProtected = false,
    this.backupLocations = const [],
    this.analyticsEnabled = true,
    this.ledEnabled = true,
    this.quietHoursEnabled = false,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '08:00',
    this.biometricEnabled = false,
    this.biometricAvailable = false,
    this.useCustomColors = false,
    this.storageUsed = '0 MB',
    this.mediaCount = 0,
    this.noteCount = 0,
    this.fontFamily = 'System Default',
    this.fontScale = 1.0,
  });

  SettingsParams copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? notificationFrequency,
    bool? darkModeEnabled,
    String? fontSizePreference,
    bool? autoSaveEnabled,
    int? autoSaveIntervalSeconds,
    bool? cloudSyncEnabled,
    String? language,
    bool? passwordProtected,
    List<String>? backupLocations,
    bool? analyticsEnabled,
    bool? ledEnabled,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool? biometricEnabled,
    bool? biometricAvailable,
    bool? useCustomColors,
    String? storageUsed,
    int? mediaCount,
    int? noteCount,
    String? fontFamily,
    double? fontScale,
  }) {
    return SettingsParams(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      notificationFrequency:
          notificationFrequency ?? this.notificationFrequency,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      fontSizePreference: fontSizePreference ?? this.fontSizePreference,
      autoSaveEnabled: autoSaveEnabled ?? this.autoSaveEnabled,
      autoSaveIntervalSeconds:
          autoSaveIntervalSeconds ?? this.autoSaveIntervalSeconds,
      cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
      language: language ?? this.language,
      passwordProtected: passwordProtected ?? this.passwordProtected,
      backupLocations: backupLocations ?? this.backupLocations,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      ledEnabled: ledEnabled ?? this.ledEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
      useCustomColors: useCustomColors ?? this.useCustomColors,
      storageUsed: storageUsed ?? this.storageUsed,
      mediaCount: mediaCount ?? this.mediaCount,
      noteCount: noteCount ?? this.noteCount,
      fontFamily: fontFamily ?? this.fontFamily,
      fontScale: fontScale ?? this.fontScale,
    );
  }

  SettingsParams toggleNotifications() =>
      copyWith(notificationsEnabled: !notificationsEnabled);
  SettingsParams toggleSound() => copyWith(soundEnabled: !soundEnabled);
  SettingsParams toggleVibration() =>
      copyWith(vibrationEnabled: !vibrationEnabled);
  SettingsParams toggleDarkMode() =>
      copyWith(darkModeEnabled: !darkModeEnabled);
  SettingsParams toggleAutoSave() =>
      copyWith(autoSaveEnabled: !autoSaveEnabled);
  SettingsParams toggleCloudSync() =>
      copyWith(cloudSyncEnabled: !cloudSyncEnabled);
  SettingsParams togglePasswordProtection() =>
      copyWith(passwordProtected: !passwordProtected);
  SettingsParams toggleAnalytics() =>
      copyWith(analyticsEnabled: !analyticsEnabled);

  @override
  List<Object?> get props => [
    notificationsEnabled,
    soundEnabled,
    vibrationEnabled,
    notificationFrequency,
    darkModeEnabled,
    fontSizePreference,
    autoSaveEnabled,
    autoSaveIntervalSeconds,
    cloudSyncEnabled,
    language,
    passwordProtected,
    backupLocations,
    analyticsEnabled,
    ledEnabled,
    quietHoursEnabled,
    quietHoursStart,
    quietHoursEnd,
    biometricEnabled,
    biometricAvailable,
    useCustomColors,
    storageUsed,
    mediaCount,
    noteCount,
    fontFamily,
    fontScale,
  ];
}
