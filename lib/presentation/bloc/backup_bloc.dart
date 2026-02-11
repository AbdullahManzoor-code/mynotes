import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/services/backup_service.dart';
import 'params/backup_params.dart';

part 'backup_event.dart';
part 'backup_state.dart';

class BackupBloc extends Bloc<BackupEvent, BackupState> {
  BackupBloc() : super(const BackupInitial()) {
    on<CreateBackupEvent>(_onCreateBackup);
    on<RestoreBackupEvent>(_onRestoreBackup);
    on<UpdateBackupSettingsEvent>(_onUpdateBackupSettings);
    on<ClearCacheEvent>(_onClearCache);
    on<CalculateCacheSizeEvent>(_onCalculateCacheSize);
    on<UpdateBackupProgressEvent>(_onUpdateBackupProgress);
    on<LoadBackupStatsEvent>(_onLoadBackupStats);
    on<LoadBackupSettingsEvent>(_onLoadBackupSettings);
  }

  Future<void> _onLoadBackupStats(
    LoadBackupStatsEvent event,
    Emitter<BackupState> emit,
  ) async {
    try {
      final stats = await BackupService.getBackupStats();
      emit(
        BackupStatsLoaded(
          dbSize: stats['db'] ?? 0,
          mediaSize: stats['media'] ?? 0,
          params: const BackupParams(), // Load settings properly in real app
        ),
      );
    } catch (e) {
      emit(BackupError('Failed to load stats: $e'));
    }
  }

  Future<void> _onLoadBackupSettings(
    LoadBackupSettingsEvent event,
    Emitter<BackupState> emit,
  ) async {
    // Mock settings load
    emit(
      const BackupStatsLoaded(dbSize: 0, mediaSize: 0, params: BackupParams()),
    );
  }

  Future<void> _onCreateBackup(
    CreateBackupEvent event,
    Emitter<BackupState> emit,
  ) async {
    emit(const BackupInProgress(0.0));

    try {
      final params = event.params;
      String? backupPath;

      if (params.exportFormat == 'ZIP') {
        final type = params.includeMedia
            ? BackupType.full
            : BackupType.dataOnly;
        backupPath = await BackupService.createBackup(type);
      } else {
        // Mock implementation for other formats
        for (int i = 0; i <= 100; i += 20) {
          await Future.delayed(const Duration(milliseconds: 200));
          emit(BackupInProgress(i / 100));
        }
        backupPath = 'mock_path_for_${params.exportFormat}';
      }

      if (backupPath != null) {
        emit(BackupCompleted(params: params, backupFile: backupPath));
      } else {
        emit(const BackupError('Failed to create backup'));
      }
    } catch (e) {
      emit(BackupError('Backup failed: $e'));
    }
  }

  Future<void> _onRestoreBackup(
    RestoreBackupEvent event,
    Emitter<BackupState> emit,
  ) async {
    emit(const BackupInProgress(0.0));

    try {
      final success = await BackupService.importBackup(
        event.backupFilePath,
        merge: true,
      );

      if (success) {
        emit(
          RestoreCompleted(
            params: event.params,
            message: 'Data restored successfully from ${event.backupFilePath}',
          ),
        );
      } else {
        emit(const BackupError('Restore failed'));
      }
    } catch (e) {
      emit(BackupError('Restore failed: $e'));
    }
  }

  Future<void> _onUpdateBackupSettings(
    UpdateBackupSettingsEvent event,
    Emitter<BackupState> emit,
  ) async {
    try {
      emit(BackupSettingsUpdated(event.params));
    } catch (e) {
      emit(BackupError('Failed to update settings: $e'));
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
