import 'package:device_calendar/device_calendar.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/todo_item.dart';

/// Service for interacting with the system calendar using device_calendar package
class CalendarService {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  /// Request permissions to access the calendar
  Future<bool> requestPermissions() async {
    final permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
      final request = await _deviceCalendarPlugin.requestPermissions();
      return request.isSuccess && request.data!;
    }
    return permissionsGranted.isSuccess && permissionsGranted.data!;
  }

  /// Get list of available calendars on the device
  Future<List<Calendar>> getCalendars() async {
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    if (calendarsResult.isSuccess && calendarsResult.data != null) {
      return calendarsResult.data!;
    }
    return [];
  }

  /// Add a note as a calendar event
  Future<bool> addNoteToCalendar(Note note, String calendarId) async {
    try {
      if (!await requestPermissions()) return false;

      final event = Event(
        calendarId,
        title: note.title.isEmpty ? 'Note' : note.title,
        description: note.content,
        start: TZDateTime.from(note.createdAt, local),
        end: TZDateTime.from(
          note.createdAt.add(const Duration(hours: 1)),
          local,
        ),
      );

      final result = await _deviceCalendarPlugin.createOrUpdateEvent(event);
      return result?.isSuccess ?? false;
    } catch (e) {
      print('Error adding note to calendar: $e');
      return false;
    }
  }

  /// Add a todo as a calendar event
  Future<bool> addTodoToCalendar(TodoItem todo, String calendarId) async {
    try {
      if (!await requestPermissions()) return false;

      final event = Event(
        calendarId,
        title: 'Task: ${todo.text}',
        description: 'Todo Item from MyNotes',
        start: TZDateTime.from(DateTime.now(), local),
        end: TZDateTime.from(
          DateTime.now().add(const Duration(minutes: 30)),
          local,
        ),
      );

      final result = await _deviceCalendarPlugin.createOrUpdateEvent(event);
      return result?.isSuccess ?? false;
    } catch (e) {
      print('Error adding todo to calendar: $e');
      return false;
    }
  }
}
