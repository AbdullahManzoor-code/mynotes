part of 'backup_bloc.dart';

abstract class BackupState {
  const BackupState();
}

class BackupInitial extends BackupState {
  const BackupInitial();
}

class BackupInProgress extends BackupState {
  final double progress;

  const BackupInProgress(this.progress);
}

class BackupCompleted extends BackupState {
  final String backupFile;
  final String lastBackupDate;

  const BackupCompleted({
    required this.backupFile,
    required this.lastBackupDate,
  });
}

class RestoreCompleted extends BackupState {
  final String message;

  const RestoreCompleted({required this.message});
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
}

class BackupError extends BackupState {
  final String message;

  const BackupError(this.message);
}
