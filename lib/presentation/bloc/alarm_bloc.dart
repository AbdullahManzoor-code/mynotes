import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/note_repository.dart';
import '../../core/notifications/notification_service.dart';
import 'alarm_event.dart';
import 'alarm_state.dart';

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

  Future<void> _onAddAlarm(
    AddAlarmEvent event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      emit(const AlarmLoading());

      final note = await _noteRepository.getNoteById(event.alarm.noteId);
      if (note == null) {
        emit(const AlarmError('Parent note not found'));
        return;
      }

      // 1. Schedule notification
      await _notificationService.schedule(
        id: event.alarm.id.hashCode,
        title: note.title.isEmpty ? 'Reminder' : note.title,
        body: event.alarm.message ?? 'Tap to view note',
        scheduledTime: event.alarm.alarmTime,
        repeatType: event.alarm.repeatType,
      );

      // 2. Add to note
      final updatedNote = note.addAlarm(event.alarm);
      await _noteRepository.updateNote(updatedNote);

      emit(const AlarmSuccess('Reminder set successfully'));
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(AlarmError(errorMsg));
    }
  }

  Future<void> _onUpdateAlarm(
    UpdateAlarmEvent event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      emit(const AlarmLoading());

      final note = await _noteRepository.getNoteById(event.alarm.noteId);
      if (note == null) {
        emit(const AlarmError('Parent note not found'));
        return;
      }

      // 1. Re-schedule notification (calculates hashCode from ID string)
      // Cancel old one first to be safe, though same ID overwrites usually
      await _notificationService.schedule(
        id: event.alarm.id.hashCode,
        title: note.title.isEmpty ? 'Reminder' : note.title,
        body: event.alarm.message ?? 'Tap to view note',
        scheduledTime: event.alarm.alarmTime,
        repeatType: event.alarm.repeatType,
      );

      // 2. Update note (remove old, add new is handled by logic or dedicated updateAlarm method in Note)
      // Note.addAlarm handles adding, but if ID exists we should replace it.
      // My Note.addAlarm logic was:
      // final updatedAlarms = List<Alarm>.from(alarms ?? []);
      // updatedAlarms.add(alarm); -- this appends.
      // I should have a updateAlarm or replace logic.

      // Let's implement replace logic here manually since Note is immutable
      var currentAlarms = note.alarms ?? [];
      // Remove existing with same ID
      final filteredAlarms = currentAlarms
          .where((a) => a.id != event.alarm.id)
          .toList();
      filteredAlarms.add(event.alarm);

      final updatedNote = note.copyWith(alarms: filteredAlarms);
      await _noteRepository.updateNote(updatedNote);

      emit(const AlarmSuccess('Reminder updated successfully'));
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(AlarmError(errorMsg));
    }
  }

  Future<void> _onDeleteAlarm(
    DeleteAlarmEvent event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      emit(const AlarmLoading());

      // 1. Cancel notification
      // Using hashCode of the ID string as the notification ID
      await _notificationService.cancel(event.alarmId.hashCode);

      // 2. Remove from note
      final note = await _noteRepository.getNoteById(event.noteId);
      if (note != null) {
        final updatedNote = note.removeAlarm(event.alarmId);
        await _noteRepository.updateNote(updatedNote);
      }

      emit(const AlarmSuccess('Reminder deleted'));
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(AlarmError(errorMsg));
    }
  }
}
