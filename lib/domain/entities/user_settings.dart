/// User settings entity for storing app preferences
class UserSettings {
  final String id;
  final String theme;
  final String fontFamily;
  final double fontSize;
  final bool biometricEnabled;
  final bool pinRequired;
  final int autoLockMinutes;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String? quietHoursStart;
  final String? quietHoursEnd;
  final String voiceLanguage;
  final bool voiceCommandsEnabled;
  final bool audioFeedbackEnabled;
  final double voiceConfidenceThreshold;
  final int defaultNoteColor;
  final String defaultTodoCategory;
  final int defaultTodoPriority;
  final bool autoBackupEnabled;
  final bool cloudSyncEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserSettings({
    required this.id,
    this.theme = 'system',
    this.fontFamily = 'roboto',
    this.fontSize = 1.0,
    this.biometricEnabled = false,
    this.pinRequired = false,
    this.autoLockMinutes = 5,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.quietHoursStart,
    this.quietHoursEnd,
    this.voiceLanguage = 'en-US',
    this.voiceCommandsEnabled = true,
    this.audioFeedbackEnabled = true,
    this.voiceConfidenceThreshold = 0.8,
    this.defaultNoteColor = 0,
    this.defaultTodoCategory = 'Personal',
    this.defaultTodoPriority = 2,
    this.autoBackupEnabled = false,
    this.cloudSyncEnabled = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON map (from database)
  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      id: map['id'] as String,
      theme: map['theme'] as String? ?? 'system',
      fontFamily: map['fontFamily'] as String? ?? 'roboto',
      fontSize: (map['fontSize'] as num?)?.toDouble() ?? 1.0,
      biometricEnabled: (map['biometricEnabled'] as int?) == 1,
      pinRequired: (map['pinRequired'] as int?) == 1,
      autoLockMinutes: map['autoLockMinutes'] as int? ?? 5,
      notificationsEnabled: (map['notificationsEnabled'] as int?) != 0,
      soundEnabled: (map['soundEnabled'] as int?) != 0,
      vibrationEnabled: (map['vibrationEnabled'] as int?) != 0,
      quietHoursStart: map['quietHoursStart'] as String?,
      quietHoursEnd: map['quietHoursEnd'] as String?,
      voiceLanguage: map['voiceLanguage'] as String? ?? 'en-US',
      voiceCommandsEnabled: (map['voiceCommandsEnabled'] as int?) != 0,
      audioFeedbackEnabled: (map['audioFeedbackEnabled'] as int?) != 0,
      voiceConfidenceThreshold:
          (map['voiceConfidenceThreshold'] as num?)?.toDouble() ?? 0.8,
      defaultNoteColor: map['defaultNoteColor'] as int? ?? 0,
      defaultTodoCategory: map['defaultTodoCategory'] as String? ?? 'Personal',
      defaultTodoPriority: map['defaultTodoPriority'] as int? ?? 2,
      autoBackupEnabled: (map['autoBackupEnabled'] as int?) == 1,
      cloudSyncEnabled: (map['cloudSyncEnabled'] as int?) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// Convert to JSON map (for database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'theme': theme,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'biometricEnabled': biometricEnabled ? 1 : 0,
      'pinRequired': pinRequired ? 1 : 0,
      'autoLockMinutes': autoLockMinutes,
      'notificationsEnabled': notificationsEnabled ? 1 : 0,
      'soundEnabled': soundEnabled ? 1 : 0,
      'vibrationEnabled': vibrationEnabled ? 1 : 0,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'voiceLanguage': voiceLanguage,
      'voiceCommandsEnabled': voiceCommandsEnabled ? 1 : 0,
      'audioFeedbackEnabled': audioFeedbackEnabled ? 1 : 0,
      'voiceConfidenceThreshold': voiceConfidenceThreshold,
      'defaultNoteColor': defaultNoteColor,
      'defaultTodoCategory': defaultTodoCategory,
      'defaultTodoPriority': defaultTodoPriority,
      'autoBackupEnabled': autoBackupEnabled ? 1 : 0,
      'cloudSyncEnabled': cloudSyncEnabled ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Copy with modifications
  UserSettings copyWith({
    String? id,
    String? theme,
    String? fontFamily,
    double? fontSize,
    bool? biometricEnabled,
    bool? pinRequired,
    int? autoLockMinutes,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    String? voiceLanguage,
    bool? voiceCommandsEnabled,
    bool? audioFeedbackEnabled,
    double? voiceConfidenceThreshold,
    int? defaultNoteColor,
    String? defaultTodoCategory,
    int? defaultTodoPriority,
    bool? autoBackupEnabled,
    bool? cloudSyncEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      theme: theme ?? this.theme,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      pinRequired: pinRequired ?? this.pinRequired,
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      voiceLanguage: voiceLanguage ?? this.voiceLanguage,
      voiceCommandsEnabled: voiceCommandsEnabled ?? this.voiceCommandsEnabled,
      audioFeedbackEnabled: audioFeedbackEnabled ?? this.audioFeedbackEnabled,
      voiceConfidenceThreshold:
          voiceConfidenceThreshold ?? this.voiceConfidenceThreshold,
      defaultNoteColor: defaultNoteColor ?? this.defaultNoteColor,
      defaultTodoCategory: defaultTodoCategory ?? this.defaultTodoCategory,
      defaultTodoPriority: defaultTodoPriority ?? this.defaultTodoPriority,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
