part of 'backup_bloc.dart';

abstract class BackupEvent {
  const BackupEvent();
}

class CreateBackupEvent extends BackupEvent {
  const CreateBackupEvent();
}

class RestoreBackupEvent extends BackupEvent {
  final String backupFilePath;

  const RestoreBackupEvent(this.backupFilePath);
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
}
