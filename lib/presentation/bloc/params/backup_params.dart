import 'package:equatable/equatable.dart';

/// Complete Param Model for Backup Operations
/// 📦 Container for all backup-related data
class BackupParams extends Equatable {
  final String backupLocation;
  final String backupFrequency; // manual, daily, weekly, monthly
  final bool includeAttachments;
  final bool includeMedia;
  final bool encryptionEnabled;
  final String? encryptionPassword;
  final bool autoRestoreLatest;
  final DateTime? lastBackupTime;
  final int? backupSizeBytes;
  final List<String> excludedTags;
  final String exportFormat; // ZIP, Markdown, JSON, PDF

  const BackupParams({
    this.backupLocation = 'local',
    this.backupFrequency = 'weekly',
    this.includeAttachments = true,
    this.includeMedia = true,
    this.encryptionEnabled = false,
    this.encryptionPassword,
    this.autoRestoreLatest = false,
    this.lastBackupTime,
    this.backupSizeBytes,
    this.excludedTags = const [],
    this.exportFormat = 'ZIP',
  });

  BackupParams copyWith({
    String? backupLocation,
    String? backupFrequency,
    bool? includeAttachments,
    bool? includeMedia,
    bool? encryptionEnabled,
    String? encryptionPassword,
    bool? autoRestoreLatest,
    DateTime? lastBackupTime,
    int? backupSizeBytes,
    List<String>? excludedTags,
    String? exportFormat,
  }) {
    return BackupParams(
      backupLocation: backupLocation ?? this.backupLocation,
      backupFrequency: backupFrequency ?? this.backupFrequency,
      includeAttachments: includeAttachments ?? this.includeAttachments,
      includeMedia: includeMedia ?? this.includeMedia,
      encryptionEnabled: encryptionEnabled ?? this.encryptionEnabled,
      encryptionPassword: encryptionPassword ?? this.encryptionPassword,
      autoRestoreLatest: autoRestoreLatest ?? this.autoRestoreLatest,
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
      backupSizeBytes: backupSizeBytes ?? this.backupSizeBytes,
      excludedTags: excludedTags ?? this.excludedTags,
      exportFormat: exportFormat ?? this.exportFormat,
    );
  }

  BackupParams toggleAttachments() =>
      copyWith(includeAttachments: !includeAttachments);
  BackupParams toggleMedia() => copyWith(includeMedia: !includeMedia);
  BackupParams toggleEncryption() =>
      copyWith(encryptionEnabled: !encryptionEnabled);
  BackupParams toggleAutoRestore() =>
      copyWith(autoRestoreLatest: !autoRestoreLatest);

  @override
  List<Object?> get props => [
    backupLocation,
    backupFrequency,
    includeAttachments,
    includeMedia,
    encryptionEnabled,
    encryptionPassword,
    autoRestoreLatest,
    lastBackupTime,
    backupSizeBytes,
    excludedTags,
  ];
}
