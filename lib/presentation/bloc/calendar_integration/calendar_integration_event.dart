part of 'calendar_integration_bloc.dart';

abstract class CalendarIntegrationEvent extends Equatable {
  const CalendarIntegrationEvent();

  @override
  List<Object?> get props => [];
}

class ChangeCalendarFormatEvent extends CalendarIntegrationEvent {
  final CalendarFormat format;

  const ChangeCalendarFormatEvent(this.format);

  @override
  List<Object?> get props => [format];
}

class SelectDayEvent extends CalendarIntegrationEvent {
  final DateTime selectedDay;
  final DateTime focusedDay;

  const SelectDayEvent(this.selectedDay, this.focusedDay);

  @override
  List<Object?> get props => [selectedDay, focusedDay];
}

class ResetToTodayEvent extends CalendarIntegrationEvent {
  const ResetToTodayEvent();
}

class LoadAvailableCalendarsEvent extends CalendarIntegrationEvent {
  const LoadAvailableCalendarsEvent();
}

class LoadCalendarEventsEvent extends CalendarIntegrationEvent {
  final DateTime? dateRange;

  const LoadCalendarEventsEvent({this.dateRange});

  @override
  List<Object?> get props => [dateRange];
}

class SyncRemindersToCalendarEvent extends CalendarIntegrationEvent {
  const SyncRemindersToCalendarEvent();
}

class SyncTodosToCalendarEvent extends CalendarIntegrationEvent {
  const SyncTodosToCalendarEvent();
}

class CreateCalendarEventEvent extends CalendarIntegrationEvent {
  final String eventId;
  final String title;
  final DateTime startDate;
  final DateTime? endDate;

  const CreateCalendarEventEvent({
    required this.eventId,
    required this.title,
    required this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [eventId, title, startDate, endDate];
}

class DeleteCalendarEventEvent extends CalendarIntegrationEvent {
  final String eventId;

  const DeleteCalendarEventEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}
