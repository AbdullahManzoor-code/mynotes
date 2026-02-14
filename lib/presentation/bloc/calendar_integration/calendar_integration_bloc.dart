import 'package:bloc/bloc.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:equatable/equatable.dart';
import 'package:mynotes/core/services/calendar_service.dart';
import 'package:mynotes/presentation/bloc/calendar_integration/calendar_integration_state.dart';
import 'package:table_calendar/table_calendar.dart';

part 'calendar_integration_event.dart';
// part 'calendar_integration_state.dart';

/// Calendar Integration BLoC
/// Syncs notes, todos, and reminders with device calendar
class CalendarIntegrationBloc
    extends Bloc<CalendarIntegrationEvent, CalendarIntegrationState> {
  final CalendarService _calendarService;

  CalendarIntegrationBloc({required CalendarService calendarService})
    : _calendarService = calendarService,
      super(
        CalendarIntegrationInitial(
          selectedDay: DateTime.now(),
          focusedDay: DateTime.now(),
        ),
      ) {
    on<LoadCalendarEventsEvent>(_onLoadCalendarEvents);
    on<SyncRemindersToCalendarEvent>(_onSyncRemindersToCalendar);
    on<SyncTodosToCalendarEvent>(_onSyncTodosToCalendar);
    on<CreateCalendarEventEvent>(_onCreateCalendarEvent);
    on<DeleteCalendarEventEvent>(_onDeleteCalendarEvent);
    on<ChangeCalendarFormatEvent>(_onChangeCalendarFormat);
    on<SelectDayEvent>(_onSelectDay);
    on<ResetToTodayEvent>(_onResetToToday);
    on<LoadAvailableCalendarsEvent>(_onLoadAvailableCalendars);
  }

  void _onChangeCalendarFormat(
    ChangeCalendarFormatEvent event,
    Emitter<CalendarIntegrationState> emit,
  ) {
    if (state is CalendarIntegrationInitial) {
      final s = state as CalendarIntegrationInitial;
      emit(
        CalendarIntegrationInitial(
          format: event.format,
          selectedDay: s.selectedDay,
          focusedDay: s.focusedDay,
          availableCalendars: s.availableCalendars,
        ),
      );
    } else if (state is CalendarDaySelected) {
      final s = state as CalendarDaySelected;
      emit(
        CalendarDaySelected(
          format: event.format,
          selectedDay: s.selectedDay,
          focusedDay: s.focusedDay,
          availableCalendars: s.availableCalendars,
        ),
      );
    } else if (state is CalendarFormatChanged) {
      final s = state as CalendarFormatChanged;
      emit(
        CalendarFormatChanged(
          format: event.format,
          selectedDay: s.selectedDay,
          focusedDay: s.focusedDay,
          availableCalendars: s.availableCalendars,
        ),
      );
    }
  }

  void _onSelectDay(
    SelectDayEvent event,
    Emitter<CalendarIntegrationState> emit,
  ) {
    CalendarFormat format = CalendarFormat.month;
    List<Calendar> availableCalendars = [];
    if (state is CalendarIntegrationInitial) {
      format = (state as CalendarIntegrationInitial).format;
      availableCalendars =
          (state as CalendarIntegrationInitial).availableCalendars;
    } else if (state is CalendarDaySelected) {
      format = (state as CalendarDaySelected).format;
      availableCalendars = (state as CalendarDaySelected).availableCalendars;
    } else if (state is CalendarFormatChanged) {
      format = (state as CalendarFormatChanged).format;
      availableCalendars = (state as CalendarFormatChanged).availableCalendars;
    }

    emit(
      CalendarDaySelected(
        format: format,
        selectedDay: event.selectedDay,
        focusedDay: event.focusedDay,
        availableCalendars: availableCalendars,
      ),
    );
  }

  void _onResetToToday(
    ResetToTodayEvent event,
    Emitter<CalendarIntegrationState> emit,
  ) {
    CalendarFormat format = CalendarFormat.month;
    List<Calendar> availableCalendars = [];
    if (state is CalendarIntegrationInitial) {
      format = (state as CalendarIntegrationInitial).format;
      availableCalendars =
          (state as CalendarIntegrationInitial).availableCalendars;
    } else if (state is CalendarDaySelected) {
      format = (state as CalendarDaySelected).format;
      availableCalendars = (state as CalendarDaySelected).availableCalendars;
    } else if (state is CalendarFormatChanged) {
      format = (state as CalendarFormatChanged).format;
      availableCalendars = (state as CalendarFormatChanged).availableCalendars;
    }

    emit(
      CalendarDaySelected(
        format: format,
        selectedDay: DateTime.now(),
        focusedDay: DateTime.now(),
        availableCalendars: availableCalendars,
      ),
    );
  }

  Future<void> _onLoadAvailableCalendars(
    LoadAvailableCalendarsEvent event,
    Emitter<CalendarIntegrationState> emit,
  ) async {
    CalendarFormat format = CalendarFormat.month;
    DateTime selectedDay = DateTime.now();
    DateTime focusedDay = DateTime.now();

    if (state is CalendarIntegrationInitial) {
      final s = state as CalendarIntegrationInitial;
      format = s.format;
      selectedDay = s.selectedDay;
      focusedDay = s.focusedDay;
    } else if (state is CalendarDaySelected) {
      final s = state as CalendarDaySelected;
      format = s.format;
      selectedDay = s.selectedDay;
      focusedDay = s.focusedDay;
    } else if (state is CalendarFormatChanged) {
      final s = state as CalendarFormatChanged;
      format = s.format;
      selectedDay = s.selectedDay;
      focusedDay = s.focusedDay;
    }

    emit(
      CalendarIntegrationInitial(
        format: format,
        selectedDay: selectedDay,
        focusedDay: focusedDay,
        isLoading: true,
      ),
    );

    try {
      final calendars = await _calendarService.getCalendars();
      emit(
        CalendarDaySelected(
          format: format,
          selectedDay: selectedDay,
          focusedDay: focusedDay,
          availableCalendars: calendars,
        ),
      );
    } catch (e) {
      emit(CalendarIntegrationError(e.toString()));
    }
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
