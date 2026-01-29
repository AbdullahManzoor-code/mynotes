part of 'calendar_integration_bloc.dart';

abstract class CalendarIntegrationState extends Equatable {
  const CalendarIntegrationState();

  @override
  List<Object?> get props => [];
}

class CalendarIntegrationInitial extends CalendarIntegrationState {
  const CalendarIntegrationInitial();
}

class CalendarIntegrationLoading extends CalendarIntegrationState {
  const CalendarIntegrationLoading();
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
