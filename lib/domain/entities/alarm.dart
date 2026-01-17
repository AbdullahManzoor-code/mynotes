import 'package:equatable/equatable.dart';

/// Alarm entity for note reminders
class Alarm extends Equatable {
  final String id;
  final String noteId;
  final DateTime alarmTime;
  final bool isActive;
  final AlarmRepeatType repeatType;
  final String? message;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Alarm({
    required this.id,
    required this.noteId,
    required this.alarmTime,
    this.isActive = true,
    this.repeatType = AlarmRepeatType.none,
    this.message,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create a copy with updated fields
  Alarm copyWith({
    String? id,
    String? noteId,
    DateTime? alarmTime,
    bool? isActive,
    AlarmRepeatType? repeatType,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Alarm(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      alarmTime: alarmTime ?? this.alarmTime,
      isActive: isActive ?? this.isActive,
      repeatType: repeatType ?? this.repeatType,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Toggle active status
  Alarm toggleActive() {
    return copyWith(isActive: !isActive, updatedAt: DateTime.now());
  }

  /// Check if alarm is expired (past time and not repeating)
  bool get isExpired {
    return alarmTime.isBefore(DateTime.now()) &&
        repeatType == AlarmRepeatType.none;
  }

  /// Check if alarm should trigger soon (within 1 hour)
  bool get isSoon {
    if (!isActive || isExpired) return false;
    final now = DateTime.now();
    final difference = alarmTime.difference(now);
    return difference.inHours < 1 && difference.inMinutes > 0;
  }

  /// Get next alarm time based on repeat type
  DateTime? getNextAlarmTime() {
    if (!isActive || repeatType == AlarmRepeatType.none) {
      return null;
    }

    final now = DateTime.now();
    if (alarmTime.isAfter(now)) {
      return alarmTime;
    }

    switch (repeatType) {
      case AlarmRepeatType.daily:
        return alarmTime.add(const Duration(days: 1));
      case AlarmRepeatType.weekly:
        return alarmTime.add(const Duration(days: 7));
      case AlarmRepeatType.monthly:
        return DateTime(
          alarmTime.year,
          alarmTime.month + 1,
          alarmTime.day,
          alarmTime.hour,
          alarmTime.minute,
        );
      case AlarmRepeatType.none:
        return null;
    }
  }

  @override
  List<Object?> get props => [
    id,
    noteId,
    alarmTime,
    isActive,
    repeatType,
    message,
    createdAt,
    updatedAt,
  ];
}

/// Enum for alarm repeat types
enum AlarmRepeatType {
  none,
  daily,
  weekly,
  monthly;

  /// Get display name
  String get displayName {
    switch (this) {
      case AlarmRepeatType.none:
        return 'Once';
      case AlarmRepeatType.daily:
        return 'Daily';
      case AlarmRepeatType.weekly:
        return 'Weekly';
      case AlarmRepeatType.monthly:
        return 'Monthly';
    }
  }

  /// Get icon
  String get icon {
    switch (this) {
      case AlarmRepeatType.none:
        return '⏰';
      case AlarmRepeatType.daily:
        return '📅';
      case AlarmRepeatType.weekly:
        return '🔄';
      case AlarmRepeatType.monthly:
        return '🗓️';
    }
  }
}
