import 'package:mynotes/domain/entities/alarm.dart'
    show Alarm, AlarmRecurrence, AlarmStatus;

class RemindersMapper {
  /// Convert Alarm to database map
  static Map<String, dynamic> toMap(Alarm alarm) {
    return {
      'id': alarm.id,
      'title': 'Alarm', // Default title since Alarm entity doesn't have one
      'message': alarm.message,
      'scheduledTime': alarm.scheduledTime.toIso8601String(),
      'recurrence': alarm.recurrence.toString().split('.').last,
      'snoozeCount': alarm.snoozeCount,
      'isActive': alarm.isActive ? 1 : 0,
      'isCompleted': (alarm.status == AlarmStatus.completed) ? 1 : 0,
      'isDeleted': 0,
      'vibrate': alarm.vibrate ? 1 : 0,
      'soundPath': alarm.soundPath,
      'label': alarm.status.toString().split('.').last,
      'linkedNoteId': alarm.linkedNoteId,
      'status': alarm.status.toString().split('.').last,
      'linkedTodoId': alarm.linkedTodoId,
      'completedAt': alarm.completedAt?.toIso8601String(),
      'lastTriggered': alarm.lastTriggered?.toIso8601String(),
      'snoozedUntil': alarm.snoozedUntil?.toIso8601String(),
      'weekDays': alarm.weekDays?.join(','),
      'isEnabled': alarm.isEnabled ? 1 : 0,
      'createdAt': alarm.createdAt.toIso8601String(),
      'updatedAt': alarm.updatedAt.toIso8601String(),
      // Keep legacy fields for backward compatibility with old database schema
      'hasVibration': alarm.vibrate ? 1 : 0,
      'hasSound': alarm.soundPath != null ? 1 : 0,
    };
  }

  /// Convert database map to Alarm
  static Alarm fromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id'],
      message: map['message'] ?? 'Alarm',
      scheduledTime: DateTime.parse(map['scheduledTime']),
      isActive: (map['isActive'] ?? 1) == 1,
      recurrence: _parseRecurrence(map['recurrence']),
      status: _parseStatus(map['status'] ?? map['label']),
      linkedNoteId: map['linkedNoteId'],
      linkedTodoId: map['linkedTodoId'],
      soundPath: map['soundPath'],
      vibrate: (map['vibrate'] ?? map['hasVibration'] ?? 1) == 1,
      isEnabled: (map['isEnabled'] ?? map['isActive'] ?? 1) == 1,
      snoozeCount: map['snoozeCount'] ?? 0,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      lastTriggered: map['lastTriggered'] != null
          ? DateTime.parse(map['lastTriggered'])
          : null,
      snoozedUntil: map['snoozedUntil'] != null
          ? DateTime.parse(map['snoozedUntil'])
          : null,
      weekDays: _parseWeekDays(map['weekDays']),
    );
  }

  static AlarmRecurrence _parseRecurrence(String? value) {
    switch (value) {
      case 'daily':
        return AlarmRecurrence.daily;
      case 'weekly':
        return AlarmRecurrence.weekly;
      case 'monthly':
        return AlarmRecurrence.monthly;
      case 'yearly':
        return AlarmRecurrence.yearly;
      case 'custom':
        return AlarmRecurrence.custom;
      default:
        return AlarmRecurrence.none;
    }
  }

  static AlarmStatus _parseStatus(String? value) {
    switch (value) {
      case 'triggered':
        return AlarmStatus.triggered;
      case 'completed':
        return AlarmStatus.completed;
      default:
        return AlarmStatus.scheduled;
    }
  }

  /// Parse comma-separated weekDays string back to list
  static List<int>? _parseWeekDays(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return value.split(',').map((e) => int.parse(e.trim())).toList();
    } catch (e) {
      return null;
    }
  }
}
