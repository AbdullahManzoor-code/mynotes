import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'alarm.g.dart';

/// Enhanced Alarm/Reminder entity (ALM-001, ALM-002, ALM-003, ALM-004)
/// Supports: Date/Time scheduling, recurring patterns, timezone awareness, note linking
@JsonSerializable()
class Alarm extends Equatable {
  final String id;
  final String message;
  final DateTime scheduledTime;
  final bool isActive;
  final AlarmRecurrence recurrence;
  final AlarmStatus status;
  final String? linkedNoteId;
  final String? linkedTodoId; // NEW: Link to todo
  final String? soundPath;
  final bool vibrate;
  final bool isEnabled; // NEW: Enable/disable toggle
  final int snoozeCount; // NEW: Track snooze count
  final DateTime? completedAt; // NEW: Completion timestamp
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
    this.linkedTodoId,
    this.soundPath,
    this.vibrate = true,
    this.isEnabled = true,
    this.snoozeCount = 0,
    this.completedAt,
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

  /// Check if alarm is completed
  bool get isCompleted =>
      completedAt != null || status == AlarmStatus.completed;

  /// Check if alarm has linked item
  bool get hasLinkedItem => linkedNoteId != null || linkedTodoId != null;

  /// Check if alarm is snoozed
  bool get isSnoozed =>
      snoozedUntil != null && snoozedUntil!.isAfter(DateTime.now());

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
    completedAt: DateTime.now(),
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
    String? linkedTodoId,
    String? soundPath,
    bool? vibrate,
    bool? isEnabled,
    int? snoozeCount,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastTriggered,
    DateTime? snoozedUntil,
    List<int>? weekDays,
    bool clearLinkedNote = false,
    bool clearLinkedTodo = false,
    bool clearCompletedAt = false,
  }) {
    return Alarm(
      id: id ?? this.id,
      message: message ?? this.message,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isActive: isActive ?? this.isActive,
      recurrence: recurrence ?? this.recurrence,
      status: status ?? this.status,
      linkedNoteId: clearLinkedNote
          ? null
          : (linkedNoteId ?? this.linkedNoteId),
      linkedTodoId: clearLinkedTodo
          ? null
          : (linkedTodoId ?? this.linkedTodoId),
      soundPath: soundPath ?? this.soundPath,
      vibrate: vibrate ?? this.vibrate,
      isEnabled: isEnabled ?? this.isEnabled,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastTriggered: lastTriggered ?? this.lastTriggered,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      weekDays: weekDays ?? this.weekDays,
    );
  }

  factory Alarm.fromJson(Map<String, dynamic> json) => _$AlarmFromJson(json);

  Map<String, dynamic> toJson() => _$AlarmToJson(this);

  @override
  List<Object?> get props => [
    id,
    message,
    scheduledTime,
    isActive,
    recurrence,
    status,
    linkedNoteId,
    linkedTodoId,
    soundPath,
    vibrate,
    isEnabled,
    snoozeCount,
    completedAt,
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

/// Snooze presets for Alarms
enum SnoozePreset { tenMinutes, oneHour, oneDay, tomorrowMorning }

/// Alarm statistics for UI
class AlarmStats {
  final int total;
  final int active;
  final int overdue;
  final int today;
  final int upcoming;
  final int snoozed;
  final int completed;

  AlarmStats({
    required this.total,
    required this.active,
    required this.overdue,
    required this.today,
    required this.upcoming,
    required this.snoozed,
    required this.completed,
  });

  /// Create empty stats
  factory AlarmStats.empty() => AlarmStats(
    total: 0,
    active: 0,
    overdue: 0,
    today: 0,
    upcoming: 0,
    snoozed: 0,
    completed: 0,
  );
}

/// Helper methods for handling lists of alarms
extension AlarmListExtension on List<Alarm> {
  /// Sort alarms by scheduled time
  List<Alarm> sortByTime({bool ascending = true}) {
    final sorted = List<Alarm>.from(this);
    sorted.sort((a, b) {
      final aTime = a.snoozedUntil ?? a.scheduledTime;
      final bTime = b.snoozedUntil ?? b.scheduledTime;
      return ascending ? aTime.compareTo(bTime) : bTime.compareTo(aTime);
    });
    return sorted;
  }

  /// Get statistics for alarms
  AlarmStats get stats {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return AlarmStats(
      total: length,
      active: where((a) => a.isActive && !a.isCompleted).length,
      overdue: where((a) => a.isOverdue).length,
      today: where((a) {
        final time = a.snoozedUntil ?? a.scheduledTime;
        return time.isAfter(today) && time.isBefore(tomorrow);
      }).length,
      upcoming: where((a) {
        final time = a.snoozedUntil ?? a.scheduledTime;
        return time.isAfter(now) && !a.isCompleted;
      }).length,
      snoozed: where((a) => a.isSnoozed).length,
      completed: where((a) => a.isCompleted).length,
    );
  }
}
