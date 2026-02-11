part of 'backup_bloc.dart';

abstract class BackupEvent extends Equatable {
  const BackupEvent();

  @override
  List<Object?> get props => [];
}

class CreateBackupEvent extends BackupEvent {
  final BackupParams params;

  const CreateBackupEvent(this.params);

  factory CreateBackupEvent.withDefaults() {
    return CreateBackupEvent(const BackupParams());
  }

  @override
  List<Object?> get props => [params];
}

class RestoreBackupEvent extends BackupEvent {
  final BackupParams params;
  final String backupFilePath;

  const RestoreBackupEvent({
    required this.params,
    required this.backupFilePath,
  });

  @override
  List<Object?> get props => [params, backupFilePath];
}

class UpdateBackupSettingsEvent extends BackupEvent {
  final BackupParams params;

  const UpdateBackupSettingsEvent(this.params);

  factory UpdateBackupSettingsEvent.toggleEncryption(BackupParams params) {
    return UpdateBackupSettingsEvent(params.toggleEncryption());
  }

  factory UpdateBackupSettingsEvent.toggleAutoRestore(BackupParams params) {
    return UpdateBackupSettingsEvent(params.toggleAutoRestore());
  }

  @override
  List<Object?> get props => [params];
}

class ClearCacheEvent extends BackupEvent {
  const ClearCacheEvent();
}

class CalculateCacheSizeEvent extends BackupEvent {
  const CalculateCacheSizeEvent();
}

class UpdateBackupProgressEvent extends BackupEvent {
  final double progress;

  const UpdateBackupProgressEvent(this.progress);

  @override
  List<Object?> get props => [progress];
}

class LoadBackupStatsEvent extends BackupEvent {
  const LoadBackupStatsEvent();
}

class LoadBackupSettingsEvent extends BackupEvent {
  const LoadBackupSettingsEvent();
}
