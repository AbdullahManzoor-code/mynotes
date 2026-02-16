// lib/presentation/bloc/alarm_bloc.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/core/services/app_logger.dart' show AppLogger;
import 'package:mynotes/presentation/bloc/params/alarm_params.dart';
import 'package:mynotes/domain/entities/alarm.dart'
    show Alarm, AlarmRecurrence, AlarmStatus, AlarmIndicator, AlarmStats;
import 'package:uuid/uuid.dart';
import 'dart:async';

import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/notifications/notification_service.dart'
    as notification_service;
import '../../../domain/repositories/alarm_repository.dart';
import '../../../domain/repositories/note_repository.dart';
import 'alarm_event.dart';
import 'alarm_state.dart';

/// Alarm/Reminder BLoC with comprehensive error handling
/// Manages alarm creation, updates, deletion with validation and recovery
class AlarmsBloc extends Bloc<AlarmEvent, AlarmState> {
  final AlarmRepository _alarmRepository;
  final NoteRepository _noteRepository;
  final notification_service.NotificationService _notificationService;
  final Uuid _uuid = const Uuid();

  // Cache for loaded alarms
  final List<AlarmParams> _cachedAlarms = [];
  Timer? _refreshTimer;

  AlarmsBloc({
    required AlarmRepository alarmRepository,
    required NoteRepository noteRepository,
    required notification_service.NotificationService notificationService,
  }) : _alarmRepository = alarmRepository,
       _noteRepository = noteRepository,
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
    on<ClearCompletedAlarmsEvent>(_onClearCompletedAlarms);
    on<RescheduleAlarmEvent>(_onRescheduleAlarm);
    on<FilterAlarms>(_onFilterAlarms);
    on<UpdateAlarmDraftEvent>(_onUpdateAlarmDraft);
    on<UpdateAlarmUiConfigEvent>(_onUpdateAlarmUiConfig);
    on<StartPeriodicRefreshEvent>(_onStartPeriodicRefresh);
    on<StopPeriodicRefreshEvent>(_onStopPeriodicRefresh);
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }

  void _onStartPeriodicRefresh(
    StartPeriodicRefreshEvent event,
    Emitter<AlarmState> emit,
  ) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      add(const RefreshAlarmsEvent());
    });
  }

  void _onStopPeriodicRefresh(
    StopPeriodicRefreshEvent event,
    Emitter<AlarmState> emit,
  ) {
    _refreshTimer?.cancel();
  }

  void _onUpdateAlarmUiConfig(
    UpdateAlarmUiConfigEvent event,
    Emitter<AlarmState> emit,
  ) {
    if (state is AlarmLoaded) {
      final current = state as AlarmLoaded;
      emit(
        current.copyWith(
          searchQuery: event.searchQuery,
          showFab: event.showFab,
        ),
      );
    }
  }

  /// 📝 Handle draft updates
  void _onUpdateAlarmDraft(
    UpdateAlarmDraftEvent event,
    Emitter<AlarmState> emit,
  ) {
    if (state is AlarmLoaded) {
      final current = state as AlarmLoaded;
      emit(
        current.copyWith(draftParams: event.params, clearDraft: event.clear),
      );
    }
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
      AppLogger.i('Loading alarms...');

      // Load alarms from repository
      final alarmEntities = await _alarmRepository.getAlarms();

      // Convert to AlarmParams for consistency
      final alarms = alarmEntities
          .map((a) => AlarmParams.fromAlarm(a))
          .toList();

      // Update cache
      _cachedAlarms.clear();
      _cachedAlarms.addAll(alarms);

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

      AppLogger.i('Loaded ${resultAlarms.length} alarms');

      emit(
        AlarmLoaded(
          alarms: resultAlarms,
          activeAlarms: resultAlarms.where((a) => a.isEnabled).toList(),
          upcomingAlarms: resultAlarms
              .where((a) => a.isEnabled && !a.isPast)
              .toList(),
          filteredAlarms: _applyCurrentFilter(resultAlarms, 'all'),
          stats: _calculateStats(resultAlarms),
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.e('Load error: $e', e, stackTrace);
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
      AppLogger.i('Adding alarm: ${event.params.title}');

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
          AppLogger.i('Found linked note: ${linkedNote?.title}');
        } catch (e) {
          AppLogger.w('Warning: Could not load linked note: $e');
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
        AppLogger.i('Notification scheduled successfully');
      } catch (e, stackTrace) {
        throw ReminderSchedulingException(
          message: 'Failed to schedule notification: $e',
          originalError: e,
          stackTrace: stackTrace,
        );
      }

      // Save alarm to repository
      try {
        final alarmEntity = _toAlarmEntity(alarmToSave);
        await _alarmRepository.createAlarm(alarmEntity);
        AppLogger.i('Alarm saved to database');
      } catch (e, stackTrace) {
        // Rollback: Cancel the scheduled notification
        await _notificationService.cancel(alarmId.hashCode);
        throw ReminderException(
          message: 'Failed to save alarm to database: $e',
          originalError: e,
          stackTrace: stackTrace,
        );
      }

      // Update cache
      _cachedAlarms.add(alarmToSave);

      AppLogger.i('Alarm created successfully: $alarmId');
      emit(
        AlarmSuccess(
          'Alarm set for ${alarmToSave.getTimeString()}',
          result: alarmToSave,
        ),
      );
    } on ValidationException catch (e) {
      AppLogger.w('Validation error: ${e.message}');
      emit(
        AlarmValidationError(
          e.message,
          field: e.field,
          invalidValue: e.invalidValue,
        ),
      );
    } on InvalidReminderDateException catch (e) {
      AppLogger.w('Date validation error: ${e.message}');
      emit(AlarmValidationError(e.message, field: 'alarmTime'));
    } on ReminderSchedulingException catch (e) {
      AppLogger.e('Scheduling error: ${e.message}', e, e.stackTrace);
      emit(AlarmError(e.message, code: e.code, exception: e));
    } on ReminderException catch (e) {
      AppLogger.e('Reminder error: ${e.message}', e, e.stackTrace);
      emit(AlarmError(e.message, code: e.code, exception: e));
    } catch (e, stackTrace) {
      AppLogger.e('Unexpected error: $e', e, stackTrace);
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
      AppLogger.i('Updating alarm: ${event.params.alarmId}');

      final alarmToUpdate = event.params.copyWith(updatedAt: DateTime.now());

      // Get linked note if exists
      dynamic linkedNote;
      if (alarmToUpdate.noteId != null) {
        try {
          linkedNote = await _noteRepository.getNoteById(alarmToUpdate.noteId!);
        } catch (e) {
          AppLogger.w('Warning: Could not load linked note: $e');
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
        AppLogger.i('Notification rescheduled successfully');
      } catch (e, stackTrace) {
        throw ReminderSchedulingException(
          message: 'Failed to reschedule notification: $e',
          originalError: e,
          stackTrace: stackTrace,
        );
      }

      // Update alarm in repository
      try {
        final alarmEntity = _toAlarmEntity(alarmToUpdate);
        await _alarmRepository.updateAlarm(alarmEntity);
        AppLogger.i('Alarm updated in database');
      } catch (e, stackTrace) {
        // Rollback notification if database fails
        if (alarmToUpdate.alarmId != null) {
          await _notificationService.cancel(alarmToUpdate.alarmId!.hashCode);
        }
        throw ReminderException(
          message: 'Failed to update alarm in database: $e',
          originalError: e,
          stackTrace: stackTrace,
        );
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

      AppLogger.i('Alarm updated successfully');
      emit(AlarmSuccess('Alarm updated successfully', result: alarmToUpdate));
    } on ValidationException catch (e) {
      AppLogger.w('Validation error: ${e.message}');
      emit(
        AlarmValidationError(
          e.message,
          field: e.field,
          invalidValue: e.invalidValue,
        ),
      );
    } on InvalidReminderDateException catch (e) {
      AppLogger.w('Date validation error: ${e.message}');
      emit(AlarmValidationError(e.message, field: 'alarmTime'));
    } on ReminderSchedulingException catch (e) {
      AppLogger.e('Scheduling error: ${e.message}', e, e.stackTrace);
      emit(AlarmError(e.message, code: e.code, exception: e));
    } on ReminderException catch (e) {
      AppLogger.e('Reminder error: ${e.message}', e, e.stackTrace);
      emit(AlarmError(e.message, code: e.code, exception: e));
    } catch (e, stackTrace) {
      AppLogger.e('Unexpected error: $e', e, stackTrace);
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
      AppLogger.i('Deleting alarm: ${event.alarmId}');

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
        AppLogger.i('Notification cancelled');
      } catch (e) {
        AppLogger.w('Warning: Failed to cancel notification: $e');
        // Continue - notification might not exist
      }

      // Delete from repository
      try {
        await _alarmRepository.deleteAlarm(event.alarmId);
        AppLogger.i('Alarm deleted from database');
      } catch (e, stackTrace) {
        throw ReminderException(
          message: 'Failed to delete alarm from database: $e',
          originalError: e,
          stackTrace: stackTrace,
        );
      }

      // Update cache
      _cachedAlarms.removeWhere((a) => a.alarmId == event.alarmId);

      AppLogger.i('Alarm deleted successfully');
      emit(
        AlarmDeleted(
          alarmId: event.alarmId,
          deletedAlarm: alarmToDelete, // For undo
        ),
      );
    } on ReminderNotFoundException catch (e) {
      AppLogger.w('Alarm not found: ${e.reminderId}');
      emit(AlarmError(e.message, code: e.code, exception: e));
    } on ReminderException catch (e) {
      AppLogger.e('Delete error: ${e.message}', e, e.stackTrace);
      emit(AlarmError(e.message, code: e.code, exception: e));
    } catch (e, stackTrace) {
      AppLogger.e('Unexpected error: $e', e, stackTrace);
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
      AppLogger.i(
        'Snoozing alarm: ${event.alarmId} for ${event.snoozeMinutes} minutes',
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

      final snoozedAlarm = alarm.copyWith(
        snoozedUntil: snoozeUntil,
        updatedAt: DateTime.now(),
      );

      // Update in repository
      final alarmEntity = _toAlarmEntity(snoozedAlarm);
      await _alarmRepository.updateAlarm(alarmEntity);

      // Update cache
      final index = _cachedAlarms.indexWhere((a) => a.alarmId == event.alarmId);
      if (index >= 0) {
        _cachedAlarms[index] = snoozedAlarm;
      }

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

      AppLogger.i('Alarm snoozed until $snoozeUntil');
      emit(
        AlarmSnoozed(
          alarm: alarm,
          snoozeUntil: snoozeUntil,
          snoozeMinutes: event.snoozeMinutes,
        ),
      );
    } on ReminderNotFoundException catch (e) {
      AppLogger.w('Alarm not found for snooze: ${e.reminderId}');
      emit(AlarmError(e.message, code: e.code, exception: e));
    } catch (e, stackTrace) {
      AppLogger.e('Snooze error: $e', e, stackTrace);
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
      AppLogger.i('Completing alarm: ${event.alarmId}');

      // Find alarm
      AlarmParams? alarm;
      try {
        alarm = _cachedAlarms.firstWhere((a) => a.alarmId == event.alarmId);
      } catch (_) {
        throw ReminderNotFoundException(reminderId: event.alarmId);
      }

      // Cancel notification
      await _notificationService.cancel(event.alarmId.hashCode);

      // Mark completed in repository
      await _alarmRepository.markCompleted(event.alarmId);

      // Reload from repository to get updated alarm
      final updatedAlarmEntity = await _alarmRepository.getAlarmById(
        event.alarmId,
      );
      if (updatedAlarmEntity != null) {
        final updatedAlarm = AlarmParams.fromAlarm(updatedAlarmEntity);

        // Update cache
        final index = _cachedAlarms.indexWhere(
          (a) => a.alarmId == event.alarmId,
        );
        if (index >= 0) {
          _cachedAlarms[index] = updatedAlarm;
        }
      }

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
        AppLogger.i('Recurring alarm rescheduled for $nextOccurrence');
      }

      emit(AlarmSuccess('Alarm completed', result: alarm));
    } on ReminderNotFoundException catch (e) {
      AppLogger.w('Alarm not found for complete: ${e.reminderId}');
      emit(AlarmError(e.message, code: e.code, exception: e));
    } catch (e, stackTrace) {
      AppLogger.e('Complete error: $e', e, stackTrace);
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
      AppLogger.i('Toggling alarm status: ${event.alarmId}');

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
      AppLogger.w('Alarm not found for toggle: ${e.reminderId}');
      emit(AlarmError(e.message, code: e.code, exception: e));
    } catch (e) {
      AppLogger.e('Toggle error: $e', e, null);
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
      AppLogger.i('Deleting alarms for note: ${event.noteId}');

      final alarmsToDelete = _cachedAlarms
          .where((a) => a.noteId == event.noteId)
          .toList();

      for (final alarm in alarmsToDelete) {
        if (alarm.alarmId != null) {
          await _notificationService.cancel(alarm.alarmId.hashCode);
        }
      }

      _cachedAlarms.removeWhere((a) => a.noteId == event.noteId);

      AppLogger.i('Deleted ${alarmsToDelete.length} alarms');
      emit(
        AlarmSuccess(
          'Deleted ${alarmsToDelete.length} alarms',
          result: alarmsToDelete,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.e('Delete for note error: $e', e, stackTrace);
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

  /// 🧹 Clear completed alarms
  Future<void> _onClearCompletedAlarms(
    ClearCompletedAlarmsEvent event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      emit(const AlarmLoading(message: 'Clearing completed reminders...'));

      // Find completed alarms
      final completedAlarms = _cachedAlarms
          .where(
            (a) => a.status == AlarmStatus.completed || a.completedAt != null,
          )
          .toList();

      if (completedAlarms.isEmpty) {
        emit(
          AlarmLoaded(
            alarms: List.from(_cachedAlarms),
            filteredAlarms: _applyCurrentFilter(
              _cachedAlarms,
              (state is AlarmLoaded)
                  ? (state as AlarmLoaded).currentFilter
                  : 'all',
            ),
            stats: _calculateStats(_cachedAlarms),
          ),
        );
        return;
      }

      // Delete each completed alarm
      for (final alarm in completedAlarms) {
        if (alarm.alarmId != null) {
          await _alarmRepository.deleteAlarm(alarm.alarmId!);
          _cachedAlarms.removeWhere((a) => a.alarmId == alarm.alarmId);
        }
      }

      emit(
        AlarmLoaded(
          alarms: List.from(_cachedAlarms),
          filteredAlarms: _applyCurrentFilter(
            _cachedAlarms,
            (state is AlarmLoaded)
                ? (state as AlarmLoaded).currentFilter
                : 'all',
          ),
          stats: _calculateStats(_cachedAlarms),
        ),
      );
    } catch (e) {
      emit(
        AlarmError(
          'Failed to clear completed reminders: ${e.toString()}',
          code: 'CLEAR_COMPLETED_ERROR',
        ),
      );
    }
  }

  /// 📅 Reschedule alarm
  Future<void> _onRescheduleAlarm(
    RescheduleAlarmEvent event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      emit(const AlarmLoading(message: 'Rescheduling reminder...'));

      final alarm = getAlarmById(event.alarmId);
      if (alarm == null) {
        throw ValidationException(
          message: 'Alarm not found',
          field: 'alarmId',
          invalidValue: event.alarmId,
        );
      }

      final updatedAlarm = alarm.copyWith(
        alarmTime: event.newTime,
        status: AlarmStatus.scheduled,
        updatedAt: DateTime.now(),
      );

      // Convert to Alarm entity and update in repository
      final alarmEntity = _toAlarmEntity(updatedAlarm);
      await _alarmRepository.updateAlarm(alarmEntity);

      // Update cache
      final index = _cachedAlarms.indexWhere((a) => a.alarmId == event.alarmId);
      if (index != -1) {
        _cachedAlarms[index] = updatedAlarm;
      }

      emit(
        AlarmLoaded(
          alarms: List.from(_cachedAlarms),
          filteredAlarms: _applyCurrentFilter(
            _cachedAlarms,
            (state is AlarmLoaded)
                ? (state as AlarmLoaded).currentFilter
                : 'all',
          ),
          stats: _calculateStats(_cachedAlarms),
        ),
      );
    } catch (e) {
      emit(
        AlarmError(
          'Failed to reschedule reminder: ${e.toString()}',
          code: 'RESCHEDULE_ERROR',
        ),
      );
    }
  }

  /// 🔍 Filter alarms
  void _onFilterAlarms(FilterAlarms event, Emitter<AlarmState> emit) {
    if (state is AlarmLoaded) {
      final s = state as AlarmLoaded;
      emit(
        s.copyWith(
          currentFilter: event.filter,
          filteredAlarms: _applyCurrentFilter(_cachedAlarms, event.filter),
          stats: _calculateStats(_cachedAlarms),
        ),
      );
    }
  }

  List<AlarmParams> _applyCurrentFilter(
    List<AlarmParams> alarms,
    String filter,
  ) {
    final now = DateTime.now();
    switch (filter.toLowerCase()) {
      case 'today':
        return alarms.where((a) => a.isToday).toList();
      case 'upcoming':
        return alarms
            .where((a) => a.isEnabled && a.alarmTime.isAfter(now))
            .toList();
      case 'overdue':
        return alarms.where((a) => a.isOverdue).toList();
      case 'snoozed':
        return alarms
            .where(
              (a) => a.snoozedUntil != null && a.snoozedUntil!.isAfter(now),
            )
            .toList();
      case 'completed':
        return alarms
            .where(
              (a) => a.status == AlarmStatus.completed || a.completedAt != null,
            )
            .toList();
      case 'all':
      default:
        return List.from(alarms);
    }
  }

  AlarmStats _calculateStats(List<AlarmParams> alarms) {
    final now = DateTime.now();
    return AlarmStats(
      total: alarms.length,
      active: alarms
          .where((a) => a.isEnabled && a.status != AlarmStatus.completed)
          .length,
      overdue: alarms.where((a) => a.isOverdue).length,
      today: alarms.where((a) => a.isToday).length,
      upcoming: alarms
          .where((a) => a.isEnabled && a.alarmTime.isAfter(now))
          .length,
      snoozed: alarms
          .where((a) => a.snoozedUntil != null && a.snoozedUntil!.isAfter(now))
          .length,
      completed: alarms
          .where(
            (a) => a.status == AlarmStatus.completed || a.completedAt != null,
          )
          .length,
    );
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

  // ═══════════════════════════════════════════════════════════════════════════
  // CONVERSION HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Convert AlarmParams to Alarm entity for repository operations
  Alarm _toAlarmEntity(AlarmParams params) {
    // Determine recurrence based on repeat days
    AlarmRecurrence recurrence;
    if (params.repeatDays.isEmpty) {
      recurrence = AlarmRecurrence.none;
    } else if (params.repeatDays.length == 7) {
      recurrence = AlarmRecurrence.daily;
    } else if (params.repeatDays.length == 1) {
      // Single day selected = custom
      recurrence = AlarmRecurrence.custom;
    } else if (params.repeatDays.length > 1 && params.repeatDays.length < 7) {
      // Multiple specific days selected = custom
      recurrence = AlarmRecurrence.custom;
    } else {
      recurrence = AlarmRecurrence.weekly;
    }

    return Alarm(
      id: params.alarmId ?? _uuid.v4(),
      message: params.title,
      scheduledTime: params.alarmTime,
      isActive: params.isEnabled,
      recurrence: recurrence,
      status: params.status,
      linkedNoteId: params.noteId,
      linkedTodoId: null, // AlarmParams doesn't have linkedTodoId
      soundPath: params.sound,
      vibrate: params.vibrate,
      isEnabled: params.isEnabled,
      snoozeCount: 0, // AlarmParams doesn't track snooze count separately
      completedAt: params.completedAt,
      createdAt: params.createdAt ?? DateTime.now(),
      updatedAt: params.updatedAt ?? DateTime.now(),
      lastTriggered: null, // AlarmParams doesn't have lastTriggered
      snoozedUntil: params.snoozedUntil,
      weekDays: params.repeatDays.isNotEmpty ? params.repeatDays : null,
    );
  }

  /// Format custom selected days as readable string (e.g., "Mon, Wed, Fri")
  String _formatCustomDays(List<int> repeatDays) {
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    if (repeatDays.isEmpty) return 'No days selected';
    if (repeatDays.length == 7) return 'Every day';

    final sortedDays = repeatDays.toList()..sort();
    return sortedDays.map((day) => dayNames[day % 7]).join(', ');
  }

  /// Get description for alarm recurrence with custom days
  String getRecurrenceDescription(AlarmParams alarm) {
    switch (alarm.isRecurring ? true : false) {
      case false:
        return 'One-time alarm';
      case true:
        if (alarm.repeatDays.isEmpty) {
          return 'No repeat';
        } else if (alarm.repeatDays.length == 7) {
          return 'Daily';
        } else if (alarm.repeatDays.length < 7) {
          return 'Custom - ${_formatCustomDays(alarm.repeatDays)}';
        } else {
          return 'Weekly';
        }
    }
  }
}
