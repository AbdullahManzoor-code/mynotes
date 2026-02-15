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
      'hasVibration': alarm.vibrate ? 1 : 0,
      'hasSound': alarm.soundPath != null ? 1 : 0,
      'label': alarm.status.toString().split('.').last,
      'linkedNoteId': alarm.linkedNoteId,
      'createdAt': alarm.createdAt.toIso8601String(),
      'updatedAt': alarm.updatedAt.toIso8601String(),
    };
  }

  /// Convert database map to Alarm
  static Alarm fromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id'],
      message: map['message'] ?? 'Alarm',
      scheduledTime: DateTime.parse(map['scheduledTime']),
      isActive: map['isActive'] == 1,
      recurrence: _parseRecurrence(map['recurrence']),
      status: _parseStatus(map['label']),
      linkedNoteId: map['linkedNoteId'],
      snoozeCount: map['snoozeCount'] ?? 0,
      vibrate: map['hasVibration'] == 1,
      soundPath: (map['hasSound'] == 1) ? 'default' : null,
      isEnabled: map['isActive'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
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
      default:
        return AlarmRecurrence.none;
    }
  }

  static AlarmStatus _parseStatus(String? value) {
    switch (value) {
      case 'triggered':
        return AlarmStatus.triggered;
      case 'snoozed':
        return AlarmStatus.snoozed;
      case 'completed':
        return AlarmStatus.completed;
      default:
        return AlarmStatus.scheduled;
    }
  }
}
