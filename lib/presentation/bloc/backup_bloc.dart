import 'package:flutter_bloc/flutter_bloc.dart';

part 'backup_event.dart';
part 'backup_state.dart';

class BackupBloc extends Bloc<BackupEvent, BackupState> {
  String? _lastBackupDate;

  BackupBloc() : super(BackupInitial()) {
    on<CreateBackupEvent>(_onCreateBackup);
    on<RestoreBackupEvent>(_onRestoreBackup);
    on<ClearCacheEvent>(_onClearCache);
    on<CalculateCacheSizeEvent>(_onCalculateCacheSize);
    on<UpdateBackupProgressEvent>(_onUpdateBackupProgress);
  }

  Future<void> _onCreateBackup(
    CreateBackupEvent event,
    Emitter<BackupState> emit,
  ) async {
    emit(BackupInProgress(0.0));

    try {
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(Duration(milliseconds: 100));
        emit(BackupInProgress(i / 100));
      }

      _lastBackupDate = DateTime.now().toIso8601String();
      emit(
        BackupCompleted(
          backupFile: 'backup_${DateTime.now().millisecondsSinceEpoch}.zip',
          lastBackupDate: _lastBackupDate!,
        ),
      );
    } catch (e) {
      emit(BackupError('Backup failed: $e'));
    }
  }

  Future<void> _onRestoreBackup(
    RestoreBackupEvent event,
    Emitter<BackupState> emit,
  ) async {
    emit(BackupInProgress(0.0));

    try {
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(Duration(milliseconds: 100));
        emit(BackupInProgress(i / 100));
      }

      emit(
        RestoreCompleted(
          message: 'Data restored successfully from ${event.backupFilePath}',
        ),
      );
    } catch (e) {
      emit(BackupError('Restore failed: $e'));
    }
  }

  Future<void> _onClearCache(
    ClearCacheEvent event,
    Emitter<BackupState> emit,
  ) async {
    try {
      emit(CacheClearInProgress());
      await Future.delayed(Duration(milliseconds: 500));
      emit(CacheCleared());
    } catch (e) {
      emit(BackupError('Cache clear failed: $e'));
    }
  }

  Future<void> _onCalculateCacheSize(
    CalculateCacheSizeEvent event,
    Emitter<BackupState> emit,
  ) async {
    try {
      // Simulate cache size calculation
      await Future.delayed(Duration(milliseconds: 300));
      emit(CacheSizeCalculated(sizeInBytes: 5242880)); // 5 MB
    } catch (e) {
      emit(BackupError('Failed to calculate cache size: $e'));
    }
  }

  Future<void> _onUpdateBackupProgress(
    UpdateBackupProgressEvent event,
    Emitter<BackupState> emit,
  ) async {
    emit(BackupInProgress(event.progress));
  }
}
