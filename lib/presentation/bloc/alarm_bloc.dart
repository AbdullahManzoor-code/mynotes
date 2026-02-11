// lib/presentation/bloc/alarm_bloc.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../core/exceptions/app_exceptions.dart';
import '../../core/notifications/notification_service.dart';
import '../../domain/repositories/note_repository.dart';
import 'alarm_event.dart';
import 'alarm_state.dart';
import 'params/alarm_params.dart';

/// Alarm/Reminder BLoC with comprehensive error handling
/// Manages alarm creation, updates, deletion with validation and recovery
class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  final NoteRepository _noteRepository;
  final NotificationService _notificationService;
  final Uuid _uuid = const Uuid();

  // Cache for loaded alarms
  List<AlarmParams> _cachedAlarms = [];

  AlarmBloc({
    required NoteRepository noteRepository,
    required NotificationService notificationService,
  }) : _noteRepository = noteRepository,
       _notificationService = notificationService,
       super(const AlarmInitial()) {
    // Register event handlers
    on<LoadAlarmsEvent>(_onLoadAlarms);
    on<AddAlarmEvent>(_onAddAlarm);
    on<UpdateAlarmEvent>(_onUpdateAlarm);
    on<DeleteAlarmEvent>(_onDeleteAlarm);
    on<SnoozeAlarmEvent>(_onSnoozeAlarm);
    on<CompleteAlarmEvent>(_onCompleteAlarm);
    on<ToggleAlarmEvent>(_onToggleAlarm);
    on<DeleteAlarmsForNoteEvent>(_onDeleteAlarmsForNote);
    on<RefreshAlarmsEvent>(_onRefreshAlarms);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VALIDATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Validate alarm parameters before save
  void _validateAlarmParams(AlarmParams params) {
    // Check for required fields
    if (params.title.trim().isEmpty) {
      throw ValidationException(
        message: 'Alarm title cannot be empty',
        field: 'title',
      );
    }

    // Check alarm time for one-time alarms
    if (params.isOneTime) {
      final now = DateTime.now();
      if (params.alarmTime.isBefore(now)) {
        throw InvalidReminderDateException(
          message: 'Cannot schedule alarm for past time',
          invalidDate: params.alarmTime,
        );
      }
    }

    // Validate repeat days
    for (final day in params.repeatDays) {
      if (day < 0 || day > 6) {
        throw ValidationException(
          message: 'Invalid repeat day: $day. Must be 0-6',
          field: 'repeatDays',
          invalidValue: day,
        );
      }
    }

    // Validate snooze interval
    if (params.snoozeIntervalMinutes < 1 || params.snoozeIntervalMinutes > 60) {
      throw ValidationException(
        message: 'Snooze interval must be between 1 and 60 minutes',
        field: 'snoozeIntervalMinutes',
        invalidValue: params.snoozeIntervalMinutes,
      );
    }
  }

  /// Validate alarm ID exists
  void _validateAlarmId(String? alarmId) {
    if (alarmId == null || alarmId.trim().isEmpty) {
      throw ValidationException(
        message: 'Alarm ID is required',
        field: 'alarmId',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EVENT HANDLERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// 📥 Load all alarms
  Future<void> _onLoadAlarms(
    LoadAlarmsEvent event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      emit(const AlarmLoading(message: 'Loading alarms...'));
      debugPrint('[AlarmBloc] Loading alarms...');

      // TODO: Replace with actual repository call
      // For now, use cached alarms
      final alarms = List<AlarmParams>.from(_cachedAlarms);

      // Filter by note if specified
      final filteredAlarms = event.noteId != null
          ? alarms.where((a) => a.noteId == event.noteId).toList()
          : alarms;

      // Filter disabled if requested
      final resultAlarms = event.includeDisabled
          ? filteredAlarms
          : filteredAlarms.where((a) => a.isEnabled).toList();

      // Sort by alarm time
      resultAlarms.sort((a, b) => a.alarmTime.compareTo(b.alarmTime));

      debugPrint('[AlarmBloc] Loaded ${resultAlarms.length} alarms');

      emit(
        AlarmsLoaded(
          alarms: resultAlarms,
          activeAlarms: resultAlarms.where((a) => a.isEnabled).toList(),
          upcomingAlarms: resultAlarms
              .where((a) => a.isEnabled && !a.isPast)
              .toList(),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('[AlarmBloc] Load error: $e\n$stackTrace');
      emit(
        AlarmError(
          'Failed to load alarms: ${e.toString()}',
          code: 'LOAD_ERROR',
        ),
      );
    }
  }

  /// ➕ Add new alarm
  Future<void> _onAddAlarm(
    AddAlarmEvent event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      emit(const AlarmLoading(message: 'Creating alarm...'));

      // Validate input
      _validateAlarmParams(event.params);
      debugPrint('[AlarmBloc] Adding alarm: ${event.params.title}');

      // Generate ID if not provided
      final alarmId = event.params.alarmId ?? _uuid.v4();
      final now = DateTime.now();

      final alarmToSave = event.params.copyWith(
        alarmId: alarmId,
        createdAt: event.params.createdAt ?? now,
        updatedAt: now,
      );

      // Get linked note if exists
      dynamic linkedNote;
      if (alarmToSave.noteId != null) {
        try {
          linkedNote = await _noteRepository.getNoteById(alarmToSave.noteId!);
          debugPrint('[AlarmBloc] Found linked note: ${linkedNote?.title}');
        } catch (e) {
          debugPrint('[AlarmBloc] Warning: Could not load linked note: $e');
          // Continue - linked note is optional
        }
      }

      // Schedule notification
      try {
        await _notificationService.schedule(
          id: alarmId.hashCode,
          title: linkedNote?.title?.isNotEmpty == true
              ? linkedNote.title
              : alarmToSave.title,
          body: alarmToSave.description,
          scheduledTime: alarmToSave.alarmTime,
          repeatDays: alarmToSave.repeatDays.isNotEmpty
              ? alarmToSave.repeatDays
              : null,
        );
        debugPrint('[AlarmBloc] Notification scheduled successfully');
      } catch (e, stackTrace) {
        throw ReminderSchedulingException(
          message: 'Failed to schedule notification: $e',
          originalError: e,
          stackTrace: stackTrace,
        );
      }

      // Update linked note if exists
      if (linkedNote != null) {
        try {
          // Assuming note has addAlarm method or we update alarms list
          final currentAlarms = linkedNote.alarms ?? [];
          final updatedAlarms = [...currentAlarms, alarmToSave];
          final updatedNote = linkedNote.copyWith(alarms: updatedAlarms);
          await _noteRepository.updateNote(updatedNote);
          debugPrint('[AlarmBloc] Alarm added to note');
        } catch (e, stackTrace) {
          // Rollback: Cancel the scheduled notification
          await _notificationService.cancel(alarmId.hashCode);
          throw ReminderException(
            message: 'Failed to save alarm to database: $e',
            originalError: e,
            stackTrace: stackTrace,
          );
        }
      }

      // Update cache
      _cachedAlarms.add(alarmToSave);

      debugPrint('[AlarmBloc] Alarm created successfully: $alarmId');
      emit(
        AlarmSuccess(
          'Alarm set for ${alarmToSave.getTimeString()}',
          result: alarmToSave,
        ),
      );
    } on ValidationException catch (e) {
      debugPrint('[AlarmBloc] Validation error: ${e.message}');
      emit(
        AlarmValidationError(
          e.message,
          field: e.field,
          invalidValue: e.invalidValue,
        ),
      );
    } on InvalidReminderDateException catch (e) {
      debugPrint('[AlarmBloc] Date validation error: ${e.message}');
      emit(AlarmValidationError(e.message, field: 'alarmTime'));
    } on ReminderSchedulingException catch (e) {
      debugPrint('[AlarmBloc] Scheduling error: ${e.message}');
      emit(AlarmError(e.message, code: e.code, exception: e));
    } on ReminderException catch (e) {
      debugPrint('[AlarmBloc] Reminder error: ${e.message}');
      emit(AlarmError(e.message, code: e.code, exception: e));
    } catch (e, stackTrace) {
      debugPrint('[AlarmBloc] Unexpected error: $e\n$stackTrace');
      emit(
        AlarmError(
          'Failed to create alarm: ${e.toString()}',
          code: 'UNEXPECTED_ERROR',
        ),
      );
    }
  }

  /// ✏️ Update existing alarm
  Future<void> _onUpdateAlarm(
    UpdateAlarmEvent event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      emit(const AlarmLoading(message: 'Updating alarm...'));

      // ✅ FIXED: Use event.params instead of event.alarm
      _validateAlarmId(event.params.alarmId);
      _validateAlarmParams(event.params);
      debugPrint('[AlarmBloc] Updating alarm: ${event.params.alarmId}');

      final alarmToUpdate = event.params.copyWith(updatedAt: DateTime.now());

      // Get linked note if exists
      dynamic linkedNote;
      if (alarmToUpdate.noteId != null) {
        try {
          linkedNote = await _noteRepository.getNoteById(alarmToUpdate.noteId!);
        } catch (e) {
          debugPrint('[AlarmBloc] Warning: Could not load linked note: $e');
        }
      }

      // Reschedule notification
      try {
        // Cancel existing - use null-safe access
        final existingAlarmId = alarmToUpdate.alarmId;
        if (existingAlarmId != null) {
          await _notificationService.cancel(existingAlarmId.hashCode);
        }

        // Schedule new if enabled
        if (alarmToUpdate.isEnabled && existingAlarmId != null) {
          await _notificationService.schedule(
            id: existingAlarmId.hashCode,
            title: linkedNote?.title?.isNotEmpty == true
                ? linkedNote.title
                : alarmToUpdate.title,
            body: alarmToUpdate.description,
            scheduledTime: alarmToUpdate.alarmTime,
            repeatDays: alarmToUpdate.repeatDays.isNotEmpty
                ? alarmToUpdate.repeatDays
                : null,
          );
        }
        debugPrint('[AlarmBloc] Notification rescheduled successfully');
      } catch (e, stackTrace) {
        throw ReminderSchedulingException(
          message: 'Failed to reschedule notification: $e',
          originalError: e,
          stackTrace: stackTrace,
        );
      }

      // Update linked note if exists
      if (linkedNote != null) {
        try {
          // Get current alarms, replace the updated one
          final currentAlarms = linkedNote.alarms ?? [];
          final filteredAlarms = currentAlarms
              .where((a) => a.id != alarmToUpdate.alarmId)
              .toList();
          filteredAlarms.add(alarmToUpdate);

          final updatedNote = linkedNote.copyWith(alarms: filteredAlarms);
          await _noteRepository.updateNote(updatedNote);
          debugPrint('[AlarmBloc] Alarm updated in note');
        } catch (e, stackTrace) {
          throw ReminderException(
            message: 'Failed to update alarm in database: $e',
            originalError: e,
            stackTrace: stackTrace,
          );
        }
      }

      // Update cache
      final index = _cachedAlarms.indexWhere(
        (a) => a.alarmId == alarmToUpdate.alarmId,
      );
      if (index >= 0) {
        _cachedAlarms[index] = alarmToUpdate;
      } else {
        // If not in cache, add it
        _cachedAlarms.add(alarmToUpdate);
      }

      debugPrint('[AlarmBloc] Alarm updated successfully');
      emit(AlarmSuccess('Alarm updated successfully', result: alarmToUpdate));
    } on ValidationException catch (e) {
      debugPrint('[AlarmBloc] Validation error: ${e.message}');
      emit(
        AlarmValidationError(
          e.message,
          field: e.field,
          invalidValue: e.invalidValue,
        ),
      );
    } on InvalidReminderDateException catch (e) {
      debugPrint('[AlarmBloc] Date validation error: ${e.message}');
      emit(AlarmValidationError(e.message, field: 'alarmTime'));
    } on ReminderSchedulingException catch (e) {
      debugPrint('[AlarmBloc] Scheduling error: ${e.message}');
      emit(AlarmError(e.message, code: e.code, exception: e));
    } on ReminderException catch (e) {
      debugPrint('[AlarmBloc] Reminder error: ${e.message}');
      emit(AlarmError(e.message, code: e.code, exception: e));
    } catch (e, stackTrace) {
      debugPrint('[AlarmBloc] Unexpected error: $e\n$stackTrace');
      emit(
        AlarmError(
          'Failed to update alarm: ${e.toString()}',
          code: 'UNEXPECTED_ERROR',
        ),
      );
    }
  }

  /// 🗑️ Delete alarm
  Future<void> _onDeleteAlarm(
    DeleteAlarmEvent event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      emit(const AlarmLoading(message: 'Deleting alarm...'));

      // ✅ FIXED: Use event.alarmId instead of event.params
      _validateAlarmId(event.alarmId);
      debugPrint('[AlarmBloc] Deleting alarm: ${event.alarmId}');

      // Find alarm in cache for undo support
      AlarmParams? alarmToDelete;
      try {
        alarmToDelete = _cachedAlarms.firstWhere(
          (a) => a.alarmId == event.alarmId,
        );
      } catch (_) {
        throw ReminderNotFoundException(reminderId: event.alarmId);
      }

      // Cancel notification
      try {
        await _notificationService.cancel(event.alarmId.hashCode);
        debugPrint('[AlarmBloc] Notification cancelled');
      } catch (e) {
        debugPrint('[AlarmBloc] Warning: Failed to cancel notification: $e');
        // Continue - notification might not exist
      }

      // Remove from linked note if exists
      // ✅ FIXED: Use event.noteId
      final noteId = event.noteId ?? alarmToDelete.noteId;
      if (noteId != null) {
        try {
          final linkedNote = await _noteRepository.getNoteById(noteId);
          if (linkedNote != null) {
            final currentAlarms = linkedNote.alarms ?? [];
            final filteredAlarms = currentAlarms
                .where((a) => a.id != event.alarmId)
                .toList();

            final updatedNote = linkedNote.copyWith(alarms: filteredAlarms);
            await _noteRepository.updateNote(updatedNote);
            debugPrint('[AlarmBloc] Alarm removed from note');
          }
        } catch (e, stackTrace) {
          throw ReminderException(
            message: 'Failed to remove alarm from database: $e',
            originalError: e,
            stackTrace: stackTrace,
          );
        }
      }

      // Update cache
      _cachedAlarms.removeWhere((a) => a.alarmId == event.alarmId);

      debugPrint('[AlarmBloc] Alarm deleted successfully');
      emit(
        AlarmDeleted(
          alarmId: event.alarmId,
          deletedAlarm: alarmToDelete, // For undo
        ),
      );
    } on ReminderNotFoundException catch (e) {
      debugPrint('[AlarmBloc] Alarm not found: ${e.reminderId}');
      emit(AlarmError(e.message, code: e.code, exception: e));
    } on ReminderException catch (e) {
      debugPrint('[AlarmBloc] Delete error: ${e.message}');
      emit(AlarmError(e.message, code: e.code, exception: e));
    } catch (e, stackTrace) {
      debugPrint('[AlarmBloc] Unexpected error: $e\n$stackTrace');
      emit(
        AlarmError(
          'Failed to delete alarm: ${e.toString()}',
          code: 'UNEXPECTED_ERROR',
        ),
      );
    }
  }

  /// ⏰ Snooze alarm
  Future<void> _onSnoozeAlarm(
    SnoozeAlarmEvent event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      emit(const AlarmLoading(message: 'Snoozing alarm...'));

      _validateAlarmId(event.alarmId);
      debugPrint(
        '[AlarmBloc] Snoozing alarm: ${event.alarmId} for ${event.snoozeMinutes} minutes',
      );

      // Find alarm in cache
      AlarmParams? alarm;
      try {
        alarm = _cachedAlarms.firstWhere((a) => a.alarmId == event.alarmId);
      } catch (_) {
        throw ReminderNotFoundException(reminderId: event.alarmId);
      }

      final snoozeUntil = DateTime.now().add(
        Duration(minutes: event.snoozeMinutes),
      );

      // Cancel current notification
      await _notificationService.cancel(event.alarmId.hashCode);

      // Schedule snoozed notification (one-time, no repeat)
      await _notificationService.schedule(
        id: event.alarmId.hashCode,
        title: '⏰ ${alarm.title} (Snoozed)',
        body: alarm.description,
        scheduledTime: snoozeUntil,
        repeatDays: null, // One-time for snooze
      );

      debugPrint('[AlarmBloc] Alarm snoozed until $snoozeUntil');
      emit(
        AlarmSnoozed(
          alarm: alarm,
          snoozeUntil: snoozeUntil,
          snoozeMinutes: event.snoozeMinutes,
        ),
      );
    } on ReminderNotFoundException catch (e) {
      emit(AlarmError(e.message, code: e.code, exception: e));
    } catch (e, stackTrace) {
      debugPrint('[AlarmBloc] Snooze error: $e\n$stackTrace');
      emit(
        AlarmError(
          'Failed to snooze alarm: ${e.toString()}',
          code: 'SNOOZE_ERROR',
        ),
      );
    }
  }

  /// ✅ Complete/dismiss alarm
  Future<void> _onCompleteAlarm(
    CompleteAlarmEvent event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      _validateAlarmId(event.alarmId);
      debugPrint('[AlarmBloc] Completing alarm: ${event.alarmId}');

      // Find alarm
      AlarmParams? alarm;
      try {
        alarm = _cachedAlarms.firstWhere((a) => a.alarmId == event.alarmId);
      } catch (_) {
        throw ReminderNotFoundException(reminderId: event.alarmId);
      }

      // Cancel notification
      await _notificationService.cancel(event.alarmId.hashCode);

      // For recurring alarms, reschedule for next occurrence
      if (alarm.isRecurring) {
        final nextOccurrence = alarm.getNextOccurrence();
        await _notificationService.schedule(
          id: event.alarmId.hashCode,
          title: alarm.title,
          body: alarm.description,
          scheduledTime: nextOccurrence,
          repeatDays: alarm.repeatDays.isNotEmpty ? alarm.repeatDays : null,
        );
        debugPrint(
          '[AlarmBloc] Recurring alarm rescheduled for $nextOccurrence',
        );
      } else {
        // Disable one-time alarm
        final updatedAlarm = alarm.copyWith(isEnabled: false);
        final index = _cachedAlarms.indexWhere(
          (a) => a.alarmId == event.alarmId,
        );
        if (index >= 0) {
          _cachedAlarms[index] = updatedAlarm;
        }
      }

      emit(AlarmSuccess('Alarm completed', result: alarm));
    } on ReminderNotFoundException catch (e) {
      emit(AlarmError(e.message, code: e.code, exception: e));
    } catch (e, stackTrace) {
      debugPrint('[AlarmBloc] Complete error: $e\n$stackTrace');
      emit(
        AlarmError(
          'Failed to complete alarm: ${e.toString()}',
          code: 'COMPLETE_ERROR',
        ),
      );
    }
  }

  /// 🔄 Toggle alarm enabled status
  Future<void> _onToggleAlarm(
    ToggleAlarmEvent event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      _validateAlarmId(event.alarmId);

      // Find alarm
      AlarmParams? alarm;
      try {
        alarm = _cachedAlarms.firstWhere((a) => a.alarmId == event.alarmId);
      } catch (_) {
        throw ReminderNotFoundException(reminderId: event.alarmId);
      }

      final newEnabled = event.isEnabled ?? !alarm.isEnabled;
      final updatedAlarm = alarm.copyWith(
        isEnabled: newEnabled,
        updatedAt: DateTime.now(),
      );

      // Dispatch update event
      add(UpdateAlarmEvent(updatedAlarm));
    } on ReminderNotFoundException catch (e) {
      emit(AlarmError(e.message, code: e.code, exception: e));
    } catch (e) {
      emit(
        AlarmError(
          'Failed to toggle alarm: ${e.toString()}',
          code: 'TOGGLE_ERROR',
        ),
      );
    }
  }

  /// 🗑️ Delete all alarms for a note
  Future<void> _onDeleteAlarmsForNote(
    DeleteAlarmsForNoteEvent event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      emit(const AlarmLoading(message: 'Deleting alarms...'));
      debugPrint('[AlarmBloc] Deleting alarms for note: ${event.noteId}');

      final alarmsToDelete = _cachedAlarms
          .where((a) => a.noteId == event.noteId)
          .toList();

      for (final alarm in alarmsToDelete) {
        if (alarm.alarmId != null) {
          await _notificationService.cancel(alarm.alarmId.hashCode);
        }
      }

      _cachedAlarms.removeWhere((a) => a.noteId == event.noteId);

      debugPrint('[AlarmBloc] Deleted ${alarmsToDelete.length} alarms');
      emit(
        AlarmSuccess(
          'Deleted ${alarmsToDelete.length} alarms',
          result: alarmsToDelete,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('[AlarmBloc] Delete error: $e\n$stackTrace');
      emit(
        AlarmError(
          'Failed to delete alarms: ${e.toString()}',
          code: 'DELETE_ERROR',
        ),
      );
    }
  }

  /// 🔄 Refresh alarms
  Future<void> _onRefreshAlarms(
    RefreshAlarmsEvent event,
    Emitter<AlarmState> emit,
  ) async {
    add(const LoadAlarmsEvent());
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLIC HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get alarm by ID from cache
  AlarmParams? getAlarmById(String alarmId) {
    try {
      return _cachedAlarms.firstWhere((a) => a.alarmId == alarmId);
    } catch (_) {
      return null;
    }
  }

  /// Get alarms for a note from cache
  List<AlarmParams> getAlarmsForNote(String noteId) {
    return _cachedAlarms.where((a) => a.noteId == noteId).toList();
  }

  /// Get upcoming alarms from cache
  List<AlarmParams> getUpcomingAlarms({int limit = 5}) {
    final now = DateTime.now();
    final upcoming =
        _cachedAlarms
            .where((a) => a.isEnabled && a.alarmTime.isAfter(now))
            .toList()
          ..sort((a, b) => a.alarmTime.compareTo(b.alarmTime));

    return upcoming.take(limit).toList();
  }

  /// Get all cached alarms (for testing/debugging)
  List<AlarmParams> get allCachedAlarms => List.unmodifiable(_cachedAlarms);

  /// Clear cache (for testing)
  @visibleForTesting
  void clearCache() {
    _cachedAlarms.clear();
  }
}
