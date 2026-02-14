import 'package:device_calendar/device_calendar.dart';
import 'package:equatable/equatable.dart';
import 'package:table_calendar/table_calendar.dart';

abstract class CalendarIntegrationState extends Equatable {
  const CalendarIntegrationState();

  @override
  List<Object?> get props => [];
}

class CalendarIntegrationInitial extends CalendarIntegrationState {
  final CalendarFormat format;
  final DateTime selectedDay;
  final DateTime focusedDay;
  final List<Calendar> availableCalendars;
  final bool isLoading;

  const CalendarIntegrationInitial({
    this.format = CalendarFormat.month,
    required this.selectedDay,
    required this.focusedDay,
    this.availableCalendars = const [],
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [
    format,
    selectedDay,
    focusedDay,
    availableCalendars,
    isLoading,
  ];
}

class CalendarIntegrationLoading extends CalendarIntegrationState {
  const CalendarIntegrationLoading();
}

class CalendarFormatChanged extends CalendarIntegrationState {
  final CalendarFormat format;
  final DateTime selectedDay;
  final DateTime focusedDay;
  final List<Calendar> availableCalendars;

  const CalendarFormatChanged({
    required this.format,
    required this.selectedDay,
    required this.focusedDay,
    required this.availableCalendars,
  });

  @override
  List<Object?> get props => [
    format,
    selectedDay,
    focusedDay,
    availableCalendars,
  ];
}

class CalendarDaySelected extends CalendarIntegrationState {
  final CalendarFormat format;
  final DateTime selectedDay;
  final DateTime focusedDay;
  final List<Calendar> availableCalendars;

  const CalendarDaySelected({
    required this.format,
    required this.selectedDay,
    required this.focusedDay,
    required this.availableCalendars,
  });

  @override
  List<Object?> get props => [
    format,
    selectedDay,
    focusedDay,
    availableCalendars,
  ];
}

class CalendarsLoaded extends CalendarIntegrationState {
  final List<Calendar> calendars;
  final CalendarFormat format;
  final DateTime selectedDay;
  final DateTime focusedDay;

  const CalendarsLoaded({
    required this.calendars,
    required this.format,
    required this.selectedDay,
    required this.focusedDay,
  });

  @override
  List<Object?> get props => [calendars, format, selectedDay, focusedDay];
}

class CalendarEventsLoaded extends CalendarIntegrationState {
  final List<Map<String, dynamic>> events;

  const CalendarEventsLoaded({required this.events});

  @override
  List<Object?> get props => [events];
}

class RemindersSyncedToCalendar extends CalendarIntegrationState {
  const RemindersSyncedToCalendar();
}

class TodosSyncedToCalendar extends CalendarIntegrationState {
  const TodosSyncedToCalendar();
}

class CalendarEventCreated extends CalendarIntegrationState {
  final String eventId;
  final String title;

  const CalendarEventCreated({required this.eventId, required this.title});

  @override
  List<Object?> get props => [eventId, title];
}

class CalendarEventDeleted extends CalendarIntegrationState {
  final String eventId;

  const CalendarEventDeleted({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

class CalendarIntegrationError extends CalendarIntegrationState {
  final String message;

  const CalendarIntegrationError(this.message);

  @override
  List<Object?> get props => [message];
}
