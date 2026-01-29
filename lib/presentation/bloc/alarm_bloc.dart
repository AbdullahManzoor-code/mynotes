import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/note_repository.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/exceptions/app_exceptions.dart';
import 'alarm_event.dart';
import 'alarm_state.dart';

/// Alarm/Reminder BLoC with comprehensive error handling
/// Manages alarm creation, updates, deletion with validation and recovery
class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  final NoteRepository _noteRepository;
  final NotificationService _notificationService;

  AlarmBloc({
    required NoteRepository noteRepository,
    required NotificationService notificationService,
  }) : _noteRepository = noteRepository,
       _notificationService = notificationService,
       super(const AlarmInitial()) {
    on<AddAlarmEvent>(_onAddAlarm);
    on<UpdateAlarmEvent>(_onUpdateAlarm);
    on<DeleteAlarmEvent>(_onDeleteAlarm);
  }

  /// Validate alarm input
  void _validateAlarmInput(dynamic alarm) {
    if (alarm == null) {
      throw ReminderException(
        message: 'Alarm cannot be null',
        code: 'NULL_ALARM',
      );
    }

    if (alarm.message?.isEmpty ?? true) {
      throw ReminderException(
        message: 'Reminder message cannot be empty',
        code: 'EMPTY_MESSAGE',
      );
    }

    if (alarm.scheduledTime == null) {
      throw InvalidReminderDateException(message: 'Scheduled time is required');
    }

    final now = DateTime.now();
    if (alarm.scheduledTime!.isBefore(now)) {
      throw InvalidReminderDateException(
        message: 'Cannot schedule reminder for past time',
      );
    }
  }

  Future<void> _onAddAlarm(
    AddAlarmEvent event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      emit(const AlarmLoading());

      // Validate alarm input
      _validateAlarmInput(event.alarm);
      debugPrint('[AlarmBloc] Adding alarm: ${event.alarm.id}');

      // Get linked note if exists
      dynamic linkedNote;
      if (event.alarm.linkedNoteId != null) {
        try {
          linkedNote = await _noteRepository.getNoteById(
            event.alarm.linkedNoteId!,
          );
        } catch (e) {
          debugPrint('[AlarmBloc] Warning: Could not load linked note: $e');
          // Continue - linked note is optional
        }
      }

      try {
        // Schedule notification
        await _notificationService.schedule(
          id: event.alarm.id.hashCode,
          title: linkedNote?.title?.isNotEmpty == true
              ? linkedNote!.title
              : 'Reminder',
          body: event.alarm.message,
          scheduledTime: event.alarm.scheduledTime,
          repeatType: event.alarm.recurrence,
        );
        debugPrint('[AlarmBloc] Notification scheduled successfully');
      } on AppException catch (e) {
        throw ReminderSchedulingException(
          message: 'Failed to schedule notification: ${e.message}',
          originalError: e,
          stackTrace: e.stackTrace,
        );
      }

      // Add to note if linked
      if (linkedNote != null) {
        try {
          final updatedNote = linkedNote.addAlarm(event.alarm);
          await _noteRepository.updateNote(updatedNote);
          debugPrint('[AlarmBloc] Alarm added to note');
        } on AppException catch (e) {
          throw ReminderException(
            message: 'Failed to save alarm to database: ${e.message}',
            originalError: e,
            stackTrace: e.stackTrace,
          );
        }
      }

      emit(AlarmSuccess('Reminder set successfully', result: event.alarm));
    } on InvalidReminderDateException catch (e) {
      debugPrint('[AlarmBloc] Validation error: ${e.message}');
      emit(AlarmValidationError(e.message, field: 'alarm_input'));
    } on ReminderException catch (e) {
      debugPrint('[AlarmBloc] Alarm error: ${e.message}');
      emit(AlarmError(e.message, code: e.code, exception: e));
    } catch (e, stackTrace) {
      debugPrint('[AlarmBloc] Unexpected error: $e\n$stackTrace');
      emit(
        AlarmError(
          'Failed to set reminder: ${e.toString()}',
          code: 'UNEXPECTED_ERROR',
        ),
      );
    }
  }

  Future<void> _onUpdateAlarm(
    UpdateAlarmEvent event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      emit(const AlarmLoading());

      // Validate alarm input
      _validateAlarmInput(event.alarm);
      debugPrint('[AlarmBloc] Updating alarm: ${event.alarm.id}');

      // Get linked note if exists
      dynamic linkedNote;
      if (event.alarm.linkedNoteId != null) {
        try {
          linkedNote = await _noteRepository.getNoteById(
            event.alarm.linkedNoteId!,
          );
        } catch (e) {
          debugPrint('[AlarmBloc] Warning: Could not load linked note: $e');
        }
      }

      try {
        // Re-schedule notification with new details
        await _notificationService.cancel(event.alarm.id.hashCode);
        await _notificationService.schedule(
          id: event.alarm.id.hashCode,
          title: linkedNote?.title?.isNotEmpty == true
              ? linkedNote!.title
              : 'Reminder',
          body: event.alarm.message,
          scheduledTime: event.alarm.scheduledTime,
          repeatType: event.alarm.recurrence,
        );
        debugPrint('[AlarmBloc] Notification rescheduled successfully');
      } on AppException catch (e) {
        throw ReminderSchedulingException(
          message: 'Failed to reschedule notification: ${e.message}',
          originalError: e,
          stackTrace: e.stackTrace,
        );
      }

      // Update note if linked
      if (linkedNote != null) {
        try {
          var currentAlarms = linkedNote.alarms ?? [];
          // Replace existing alarm with same ID
          final filteredAlarms = currentAlarms
              .where((a) => a.id != event.alarm.id)
              .toList();
          filteredAlarms.add(event.alarm);

          final updatedNote = linkedNote.copyWith(alarms: filteredAlarms);
          await _noteRepository.updateNote(updatedNote);
          debugPrint('[AlarmBloc] Alarm updated in note');
        } on AppException catch (e) {
          throw ReminderException(
            message: 'Failed to update alarm in database: ${e.message}',
            originalError: e,
            stackTrace: e.stackTrace,
          );
        }
      }

      emit(AlarmSuccess('Reminder updated successfully', result: event.alarm));
    } on InvalidReminderDateException catch (e) {
      debugPrint('[AlarmBloc] Validation error: ${e.message}');
      emit(AlarmValidationError(e.message, field: 'alarm_input'));
    } on ReminderException catch (e) {
      debugPrint('[AlarmBloc] Alarm error: ${e.message}');
      emit(AlarmError(e.message, code: e.code, exception: e));
    } catch (e, stackTrace) {
      debugPrint('[AlarmBloc] Unexpected error: $e\n$stackTrace');
      emit(
        AlarmError(
          'Failed to update reminder: ${e.toString()}',
          code: 'UNEXPECTED_ERROR',
        ),
      );
    }
  }

  Future<void> _onDeleteAlarm(
    DeleteAlarmEvent event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      emit(const AlarmLoading());
      debugPrint('[AlarmBloc] Deleting alarm: ${event.alarmId}');

      try {
        // Cancel notification
        await _notificationService.cancel(event.alarmId.hashCode);
        debugPrint('[AlarmBloc] Notification cancelled');
      } on AppException catch (e) {
        debugPrint('[AlarmBloc] Warning: Failed to cancel notification: $e');
        // Continue - still need to remove from database
      }

      // Remove from note
      try {
        final note = await _noteRepository.getNoteById(event.noteId);
        if (note != null) {
          final updatedNote = note.removeAlarm(event.alarmId);
          await _noteRepository.updateNote(updatedNote);
          debugPrint('[AlarmBloc] Alarm removed from note');
        }
      } on AppException catch (e) {
        throw ReminderException(
          message: 'Failed to remove alarm from database: ${e.message}',
          originalError: e,
          stackTrace: e.stackTrace,
        );
      }

      emit(AlarmSuccess('Reminder deleted', result: event.alarmId));
    } on ReminderException catch (e) {
      debugPrint('[AlarmBloc] Alarm error: ${e.message}');
      emit(AlarmError(e.message, code: e.code, exception: e));
    } catch (e, stackTrace) {
      debugPrint('[AlarmBloc] Unexpected error: $e\n$stackTrace');
      emit(
        AlarmError(
          'Failed to delete reminder: ${e.toString()}',
          code: 'UNEXPECTED_ERROR',
        ),
      );
    }
  }
}
