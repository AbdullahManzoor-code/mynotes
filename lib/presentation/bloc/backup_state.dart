part of 'backup_bloc.dart';

abstract class BackupState extends Equatable {
  const BackupState();

  @override
  List<Object?> get props => [];
}

class BackupInitial extends BackupState {
  const BackupInitial();
}

class BackupInProgress extends BackupState {
  final double progress;

  const BackupInProgress(this.progress);

  @override
  List<Object?> get props => [progress];
}

class BackupCompleted extends BackupState {
  final BackupParams params;
  final String backupFile;
  final DateTime lastBackupDate;

  BackupCompleted({
    required this.params,
    required this.backupFile,
    DateTime? lastBackupDate,
  }) : lastBackupDate = lastBackupDate ?? DateTime.now();

  @override
  List<Object?> get props => [params, backupFile, lastBackupDate];
}

class RestoreCompleted extends BackupState {
  final BackupParams params;
  final String message;

  const RestoreCompleted({required this.params, required this.message});

  @override
  List<Object?> get props => [params, message];
}

class BackupSettingsUpdated extends BackupState {
  final BackupParams params;

  const BackupSettingsUpdated(this.params);

  @override
  List<Object?> get props => [params];
}

class CacheClearInProgress extends BackupState {
  const CacheClearInProgress();
}

class CacheCleared extends BackupState {
  const CacheCleared();
}

class CacheSizeCalculated extends BackupState {
  final int sizeInBytes;

  const CacheSizeCalculated({required this.sizeInBytes});

  String get formattedSize {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    double size = sizeInBytes.toDouble();
    int suffixIndex = 0;

    while (size > 1024 && suffixIndex < suffixes.length - 1) {
      size /= 1024;
      suffixIndex++;
    }

    return '${size.toStringAsFixed(2)} ${suffixes[suffixIndex]}';
  }

  @override
  List<Object?> get props => [sizeInBytes];
}

class BackupError extends BackupState {
  final String message;

  const BackupError(this.message);

  @override
  List<Object?> get props => [message];
}

class BackupStatsLoaded extends BackupState {
  final double dbSize;
  final double mediaSize;
  final BackupParams params;

  const BackupStatsLoaded({
    required this.dbSize,
    required this.mediaSize,
    required this.params,
  });

  @override
  List<Object?> get props => [dbSize, mediaSize, params];
}
