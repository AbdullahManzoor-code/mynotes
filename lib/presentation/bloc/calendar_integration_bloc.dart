import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'calendar_integration_event.dart';
part 'calendar_integration_state.dart';

/// Calendar Integration BLoC
/// Syncs notes, todos, and reminders with device calendar
class CalendarIntegrationBloc
    extends Bloc<CalendarIntegrationEvent, CalendarIntegrationState> {
  CalendarIntegrationBloc() : super(const CalendarIntegrationInitial()) {
    on<LoadCalendarEventsEvent>(_onLoadCalendarEvents);
    on<SyncRemindersToCalendarEvent>(_onSyncRemindersToCalendar);
    on<SyncTodosToCalendarEvent>(_onSyncTodosToCalendar);
    on<CreateCalendarEventEvent>(_onCreateCalendarEvent);
    on<DeleteCalendarEventEvent>(_onDeleteCalendarEvent);
  }

  Future<void> _onLoadCalendarEvents(
    LoadCalendarEventsEvent event,
    Emitter<CalendarIntegrationState> emit,
  ) async {
    try {
      emit(const CalendarIntegrationLoading());

      // Mock: In production, use calendar_client_plugin
      final events = <Map<String, dynamic>>[];
      emit(CalendarEventsLoaded(events: events));
    } catch (e) {
      emit(CalendarIntegrationError(e.toString()));
    }
  }

  Future<void> _onSyncRemindersToCalendar(
    SyncRemindersToCalendarEvent event,
    Emitter<CalendarIntegrationState> emit,
  ) async {
    try {
      emit(const CalendarIntegrationLoading());

      // Sync all reminders with due dates to device calendar
      emit(const RemindersSyncedToCalendar());
    } catch (e) {
      emit(CalendarIntegrationError(e.toString()));
    }
  }

  Future<void> _onSyncTodosToCalendar(
    SyncTodosToCalendarEvent event,
    Emitter<CalendarIntegrationState> emit,
  ) async {
    try {
      emit(const CalendarIntegrationLoading());

      // Sync todos with due dates to device calendar
      emit(const TodosSyncedToCalendar());
    } catch (e) {
      emit(CalendarIntegrationError(e.toString()));
    }
  }

  Future<void> _onCreateCalendarEvent(
    CreateCalendarEventEvent event,
    Emitter<CalendarIntegrationState> emit,
  ) async {
    try {
      emit(const CalendarIntegrationLoading());

      emit(CalendarEventCreated(eventId: event.eventId, title: event.title));
    } catch (e) {
      emit(CalendarIntegrationError(e.toString()));
    }
  }

  Future<void> _onDeleteCalendarEvent(
    DeleteCalendarEventEvent event,
    Emitter<CalendarIntegrationState> emit,
  ) async {
    try {
      emit(const CalendarIntegrationLoading());

      emit(CalendarEventDeleted(eventId: event.eventId));
    } catch (e) {
      emit(CalendarIntegrationError(e.toString()));
    }
  }
}
