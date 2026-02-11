import 'package:equatable/equatable.dart';

/// Complete Param Model for Calendar Integration Operations
/// 📦 Container for all calendar-related data
class CalendarEventParams extends Equatable {
  final String? eventId;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String? location;
  final bool isAllDay;
  final String? reminderTime;
  final bool isRecurring;
  final String? recurringPattern;
  final List<String> attendees;
  final String? noteId;

  const CalendarEventParams({
    this.eventId,
    this.title = '',
    this.description = '',
    required this.startDate,
    required this.endDate,
    this.location,
    this.isAllDay = false,
    this.reminderTime,
    this.isRecurring = false,
    this.recurringPattern,
    this.attendees = const [],
    this.noteId,
  });

  CalendarEventParams copyWith({
    String? eventId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    bool? isAllDay,
    String? reminderTime,
    bool? isRecurring,
    String? recurringPattern,
    List<String>? attendees,
    String? noteId,
  }) {
    return CalendarEventParams(
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      isAllDay: isAllDay ?? this.isAllDay,
      reminderTime: reminderTime ?? this.reminderTime,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      attendees: attendees ?? this.attendees,
      noteId: noteId ?? this.noteId,
    );
  }

  CalendarEventParams toggleAllDay() => copyWith(isAllDay: !isAllDay);
  CalendarEventParams makeRecurring(String pattern) =>
      copyWith(isRecurring: true, recurringPattern: pattern);
  CalendarEventParams makeOneTime() =>
      copyWith(isRecurring: false, recurringPattern: null);

  @override
  List<Object?> get props => [
    eventId,
    title,
    description,
    startDate,
    endDate,
    location,
    isAllDay,
    reminderTime,
    isRecurring,
    recurringPattern,
    attendees,
    noteId,
  ];
}
