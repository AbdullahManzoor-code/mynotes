import 'package:equatable/equatable.dart';

/// Enhanced Alarm/Reminder entity (ALM-001, ALM-002, ALM-003, ALM-004)
/// Supports: Date/Time scheduling, recurring patterns, timezone awareness, note linking
class Alarm extends Equatable {
  final String id;
  final String message;
  final DateTime scheduledTime;
  final bool isActive;
  final AlarmRecurrence recurrence;
  final AlarmStatus status;
  final String? linkedNoteId;
  final String? soundPath;
  final bool vibrate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastTriggered;
  final DateTime? snoozedUntil;
  final List<int>? weekDays; // For weekly recurrence (1=Mon, 7=Sun)

  const Alarm({
    required this.id,
    required this.message,
    required this.scheduledTime,
    this.isActive = true,
    this.recurrence = AlarmRecurrence.none,
    this.status = AlarmStatus.scheduled,
    this.linkedNoteId,
    this.soundPath,
    this.vibrate = true,
    required this.createdAt,
    required this.updatedAt,
    this.lastTriggered,
    this.snoozedUntil,
    this.weekDays,
  });

  /// Check if alarm is overdue (ALM-004)
  bool get isOverdue {
    if (!isActive || status == AlarmStatus.completed) return false;
    final now = DateTime.now();
    if (snoozedUntil != null && snoozedUntil!.isAfter(now)) return false;
    return now.isAfter(scheduledTime);
  }

  /// Check if alarm is due within 1 hour (ALM-004)
  bool get isDueSoon {
    if (!isActive || status == AlarmStatus.completed) return false;
    final now = DateTime.now();
    final effectiveTime = snoozedUntil ?? scheduledTime;
    final oneHourFromNow = now.add(const Duration(hours: 1));
    return effectiveTime.isAfter(now) && effectiveTime.isBefore(oneHourFromNow);
  }

  /// Get visual indicator color (ALM-004)
  AlarmIndicator get indicator {
    if (!isActive || status == AlarmStatus.completed) {
      return AlarmIndicator.inactive;
    }
    if (isOverdue) return AlarmIndicator.overdue;
    if (isDueSoon) return AlarmIndicator.soon;
    return AlarmIndicator.future;
  }

  /// Get formatted time remaining
  String get timeRemaining {
    final now = DateTime.now();
    final effectiveTime = snoozedUntil ?? scheduledTime;
    final difference = effectiveTime.difference(now);

    if (difference.isNegative) {
      final absDiff = difference.abs();
      if (absDiff.inHours > 24) {
        return '${absDiff.inDays}d ago';
      } else if (absDiff.inMinutes > 60) {
        return '${absDiff.inHours}h ago';
      } else {
        return '${absDiff.inMinutes}m ago';
      }
    }

    if (difference.inDays > 0) {
      return 'in ${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours}h';
    } else {
      return 'in ${difference.inMinutes}m';
    }
  }

  /// Calculate next occurrence for recurring alarms (ALM-002)
  DateTime? getNextOccurrence() {
    if (recurrence == AlarmRecurrence.none) return null;

    final now = DateTime.now();
    DateTime next = scheduledTime;

    switch (recurrence) {
      case AlarmRecurrence.daily:
        while (next.isBefore(now)) {
          next = next.add(const Duration(days: 1));
        }
        break;

      case AlarmRecurrence.weekly:
        if (weekDays == null || weekDays!.isEmpty) {
          // Default to same weekday as scheduled time
          while (next.isBefore(now)) {
            next = next.add(const Duration(days: 7));
          }
        } else {
          // Find next occurrence based on selected weekdays
          for (int i = 0; i < 14; i++) {
            final testDate = now.add(Duration(days: i));
            if (weekDays!.contains(testDate.weekday) && testDate.isAfter(now)) {
              next = DateTime(
                testDate.year,
                testDate.month,
                testDate.day,
                scheduledTime.hour,
                scheduledTime.minute,
              );
              break;
            }
          }
        }
        break;

      case AlarmRecurrence.monthly:
        while (next.isBefore(now)) {
          final newMonth = next.month == 12 ? 1 : next.month + 1;
          final newYear = next.month == 12 ? next.year + 1 : next.year;
          next = DateTime(newYear, newMonth, next.day, next.hour, next.minute);
        }
        break;

      case AlarmRecurrence.yearly:
        while (next.isBefore(now)) {
          next = DateTime(
            next.year + 1,
            next.month,
            next.day,
            next.hour,
            next.minute,
          );
        }
        break;

      case AlarmRecurrence.none:
        return null;
    }

    return next;
  }

  /// Toggle active state
  Alarm toggleActive() =>
      copyWith(isActive: !isActive, updatedAt: DateTime.now());

  /// Mark as triggered (ALM-003)
  Alarm markTriggered() => copyWith(
    status: AlarmStatus.triggered,
    lastTriggered: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  /// Snooze alarm (ALM-005, NOT-002)
  Alarm snooze(Duration duration) => copyWith(
    status: AlarmStatus.snoozed,
    snoozedUntil: DateTime.now().add(duration),
    updatedAt: DateTime.now(),
  );

  /// Mark as completed
  Alarm markCompleted() => copyWith(
    status: AlarmStatus.completed,
    isActive: false,
    updatedAt: DateTime.now(),
  );

  /// Quick reschedule (ALM-005)
  Alarm reschedule(DateTime newTime) => copyWith(
    scheduledTime: newTime,
    status: AlarmStatus.scheduled,
    snoozedUntil: null,
    updatedAt: DateTime.now(),
  );

  Alarm copyWith({
    String? id,
    String? message,
    DateTime? scheduledTime,
    bool? isActive,
    AlarmRecurrence? recurrence,
    AlarmStatus? status,
    String? linkedNoteId,
    String? soundPath,
    bool? vibrate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastTriggered,
    DateTime? snoozedUntil,
    List<int>? weekDays,
  }) {
    return Alarm(
      id: id ?? this.id,
      message: message ?? this.message,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isActive: isActive ?? this.isActive,
      recurrence: recurrence ?? this.recurrence,
      status: status ?? this.status,
      linkedNoteId: linkedNoteId ?? this.linkedNoteId,
      soundPath: soundPath ?? this.soundPath,
      vibrate: vibrate ?? this.vibrate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastTriggered: lastTriggered ?? this.lastTriggered,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      weekDays: weekDays ?? this.weekDays,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'scheduledTime': scheduledTime.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'recurrence': recurrence.index,
      'status': status.index,
      'linkedNoteId': linkedNoteId,
      'soundPath': soundPath,
      'vibrate': vibrate ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastTriggered': lastTriggered?.toIso8601String(),
      'snoozedUntil': snoozedUntil?.toIso8601String(),
      'weekDays': weekDays?.join(','),
    };
  }

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'] as String,
      message: json['message'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      isActive: (json['isActive'] as int) == 1,
      recurrence: AlarmRecurrence.values[json['recurrence'] as int],
      status: AlarmStatus.values[json['status'] as int],
      linkedNoteId: json['linkedNoteId'] as String?,
      soundPath: json['soundPath'] as String?,
      vibrate: (json['vibrate'] as int) == 1,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastTriggered: json['lastTriggered'] != null
          ? DateTime.parse(json['lastTriggered'] as String)
          : null,
      snoozedUntil: json['snoozedUntil'] != null
          ? DateTime.parse(json['snoozedUntil'] as String)
          : null,
      weekDays:
          json['weekDays'] != null && (json['weekDays'] as String).isNotEmpty
          ? (json['weekDays'] as String)
                .split(',')
                .map((e) => int.parse(e))
                .toList()
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    message,
    scheduledTime,
    isActive,
    recurrence,
    status,
    linkedNoteId,
    soundPath,
    vibrate,
    createdAt,
    updatedAt,
    lastTriggered,
    snoozedUntil,
    weekDays,
  ];
}

/// Recurrence pattern (ALM-002)
enum AlarmRecurrence { none, daily, weekly, monthly, yearly }

extension AlarmRecurrenceExtension on AlarmRecurrence {
  String get displayName {
    switch (this) {
      case AlarmRecurrence.none:
        return 'One-time';
      case AlarmRecurrence.daily:
        return 'Daily';
      case AlarmRecurrence.weekly:
        return 'Weekly';
      case AlarmRecurrence.monthly:
        return 'Monthly';
      case AlarmRecurrence.yearly:
        return 'Yearly';
    }
  }

  String get icon {
    switch (this) {
      case AlarmRecurrence.none:
        return '⏰';
      case AlarmRecurrence.daily:
        return '📅';
      case AlarmRecurrence.weekly:
        return '🔄';
      case AlarmRecurrence.monthly:
        return '🗓️';
      case AlarmRecurrence.yearly:
        return '🎂';
    }
  }
}

/// Alarm status (ALM-003)
enum AlarmStatus { scheduled, triggered, snoozed, completed }

extension AlarmStatusExtension on AlarmStatus {
  String get displayName {
    switch (this) {
      case AlarmStatus.scheduled:
        return 'Scheduled';
      case AlarmStatus.triggered:
        return 'Triggered';
      case AlarmStatus.snoozed:
        return 'Snoozed';
      case AlarmStatus.completed:
        return 'Completed';
    }
  }
}

/// Visual indicators (ALM-004)
enum AlarmIndicator {
  overdue, // Red - past due time
  soon, // Yellow/Amber - due within 1 hour
  future, // Green - future alarm
  inactive, // Grey - disabled or completed
}
