// lib/presentation/bloc/params/alarm_params.dart

import 'package:equatable/equatable.dart';
import '../../../domain/entities/alarm.dart';

/// Complete Param Model for Alarm Operations
/// 📦 Container for all alarm-related data
/// Single object instead of multiple parameters
class AlarmParams extends Equatable {
  final String? alarmId;
  final DateTime alarmTime;
  final String title;
  final String description;
  final bool isEnabled;
  final List<int> repeatDays; // 0-6 for days of week (0 = Sunday)
  final String? sound;
  final bool vibrate;
  final String? noteId;
  final String? reminderId;
  final bool hasSnooze;
  final int snoozeIntervalMinutes;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? snoozedUntil;
  final DateTime? completedAt;
  final AlarmStatus status; // Add AlarmStatus

  const AlarmParams({
    this.alarmId,
    required this.alarmTime,
    this.title = 'Alarm',
    this.description = '',
    this.isEnabled = true,
    this.repeatDays = const [],
    this.sound,
    this.vibrate = true,
    this.noteId,
    this.reminderId,
    this.hasSnooze = true,
    this.snoozeIntervalMinutes = 5,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
    this.snoozedUntil,
    this.completedAt,
    this.status = AlarmStatus.scheduled,
  });

  /// ✨ Create a copy with modified fields
  AlarmParams copyWith({
    String? alarmId,
    DateTime? alarmTime,
    String? title,
    String? description,
    bool? isEnabled,
    List<int>? repeatDays,
    String? sound,
    bool? vibrate,
    String? noteId,
    String? reminderId,
    bool? hasSnooze,
    int? snoozeIntervalMinutes,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? snoozedUntil,
    DateTime? completedAt,
    AlarmStatus? status,
  }) {
    return AlarmParams(
      alarmId: alarmId ?? this.alarmId,
      alarmTime: alarmTime ?? this.alarmTime,
      title: title ?? this.title,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
      repeatDays: repeatDays ?? List<int>.from(this.repeatDays),
      sound: sound ?? this.sound,
      vibrate: vibrate ?? this.vibrate,
      noteId: noteId ?? this.noteId,
      reminderId: reminderId ?? this.reminderId,
      hasSnooze: hasSnooze ?? this.hasSnooze,
      snoozeIntervalMinutes:
          snoozeIntervalMinutes ?? this.snoozeIntervalMinutes,
      tags: tags ?? List<String>.from(this.tags),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
    );
  }

  /// 🔄 Toggle enabled status
  AlarmParams toggleEnabled() {
    return copyWith(isEnabled: !isEnabled, updatedAt: DateTime.now());
  }

  /// ⏰ Change alarm time
  AlarmParams withAlarmTime(DateTime newTime) {
    return copyWith(alarmTime: newTime, updatedAt: DateTime.now());
  }

  /// ➕ Add repeat day (0-6, where 0 = Sunday)
  AlarmParams withRepeatDay(int day) {
    if (day < 0 || day > 6) {
      throw ArgumentError('Day must be between 0 and 6');
    }
    if (repeatDays.contains(day)) return this;

    final days = List<int>.from(repeatDays)
      ..add(day)
      ..sort();
    return copyWith(repeatDays: days, updatedAt: DateTime.now());
  }

  /// ➖ Remove repeat day
  AlarmParams withoutRepeatDay(int day) {
    if (!repeatDays.contains(day)) return this;

    return copyWith(
      repeatDays: repeatDays.where((d) => d != day).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// 📝 Update description
  AlarmParams withDescription(String newDescription) {
    return copyWith(description: newDescription, updatedAt: DateTime.now());
  }

  /// 🏷️ Add tag
  AlarmParams withTag(String tag) {
    if (tags.contains(tag)) return this;

    return copyWith(tags: [...tags, tag], updatedAt: DateTime.now());
  }

  /// 🏷️ Remove tag
  AlarmParams withoutTag(String tag) {
    if (!tags.contains(tag)) return this;

    return copyWith(
      tags: tags.where((t) => t != tag).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// 🔗 Link to note
  AlarmParams withNoteId(String? id) {
    return copyWith(noteId: id, updatedAt: DateTime.now());
  }

  /// ✅ Check if recurring
  bool get isRecurring => repeatDays.isNotEmpty;

  /// ✅ Check if one-time alarm
  bool get isOneTime => repeatDays.isEmpty;

  /// ✅ Check if alarm is for today
  bool get isToday {
    final now = DateTime.now();
    return alarmTime.year == now.year &&
        alarmTime.month == now.month &&
        alarmTime.day == now.day;
  }

  /// ✅ Check if alarm is in the past
  bool get isPast => alarmTime.isBefore(DateTime.now());

  /// ✅ Check if alarm is valid (not in past for one-time alarms)
  bool get isValid {
    if (isRecurring) return true;
    return !isPast;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ALIAS GETTERS FOR COMPATIBILITY WITH ALARM ENTITY
  // ═══════════════════════════════════════════════════════════════════════════

  /// Alias for alarmId to match Alarm entity
  String? get id => alarmId;

  /// Alias for title to match Alarm entity
  String get message => title;

  /// Alias for alarmTime to match Alarm entity
  DateTime get scheduledTime => alarmTime;

  /// Alias for linkedNoteId
  String? get linkedNoteId => noteId;

  /// Check if alarm is overdue
  bool get isOverdue {
    if (!isEnabled || status == AlarmStatus.completed) return false;
    final now = DateTime.now();
    if (snoozedUntil != null && snoozedUntil!.isAfter(now)) return false;
    return now.isAfter(alarmTime);
  }

  /// Check if alarm is due within 1 hour
  bool get isDueSoon {
    if (!isEnabled || status == AlarmStatus.completed) return false;
    final now = DateTime.now();
    final effectiveTime = snoozedUntil ?? alarmTime;
    final oneHourFromNow = now.add(const Duration(hours: 1));
    return effectiveTime.isAfter(now) && effectiveTime.isBefore(oneHourFromNow);
  }

  /// Get formatted time remaining (Copied from Alarm entity)
  String get timeRemaining {
    final now = DateTime.now();
    final effectiveTime = snoozedUntil ?? alarmTime;
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

  /// 📅 Get repeat days as readable string
  String getRepeatString() {
    if (repeatDays.isEmpty) return 'Once';
    if (repeatDays.length == 7) return 'Every day';

    // Check for weekdays (Mon-Fri)
    final weekdays = [1, 2, 3, 4, 5];
    if (repeatDays.length == 5 &&
        weekdays.every((d) => repeatDays.contains(d))) {
      return 'Weekdays';
    }

    // Check for weekends (Sat-Sun)
    final weekends = [0, 6];
    if (repeatDays.length == 2 &&
        weekends.every((d) => repeatDays.contains(d))) {
      return 'Weekends';
    }

    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final sortedDays = List<int>.from(repeatDays)..sort();
    return sortedDays.map((d) => dayNames[d]).join(', ');
  }

  /// ⏰ Get formatted time string
  String getTimeString() {
    final hour = alarmTime.hour;
    final minute = alarmTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// 📅 Get next occurrence of the alarm
  DateTime getNextOccurrence() {
    final now = DateTime.now();

    if (isOneTime) {
      return alarmTime;
    }

    // For recurring alarms, find next valid day
    DateTime next = DateTime(
      now.year,
      now.month,
      now.day,
      alarmTime.hour,
      alarmTime.minute,
    );

    // If today's time has passed, start from tomorrow
    if (next.isBefore(now)) {
      next = next.add(const Duration(days: 1));
    }

    // Find next day that matches repeat pattern
    for (int i = 0; i < 7; i++) {
      final dayOfWeek = next.weekday % 7; // Convert to 0-6 (Sunday = 0)
      if (repeatDays.contains(dayOfWeek)) {
        return next;
      }
      next = next.add(const Duration(days: 1));
    }

    return next;
  }

  /// 🏭 Create AlarmParams from Alarm entity
  factory AlarmParams.fromAlarm(Alarm alarm) {
    return AlarmParams(
      alarmId: alarm.id,
      alarmTime: alarm.scheduledTime,
      title: alarm.message,
      description: '', // Description helper not present in Alarm?
      isEnabled: alarm.isEnabled,
      repeatDays: alarm.weekDays ?? const [],
      sound: alarm.soundPath,
      vibrate: alarm.vibrate,
      noteId: alarm.linkedNoteId,
      reminderId: null, // No reminderId in Alarm?
      hasSnooze: true,
      snoozeIntervalMinutes: 5,
      tags: const [],
      createdAt: alarm.createdAt,
      updatedAt: alarm.updatedAt,
      snoozedUntil: alarm.snoozedUntil,
      completedAt: alarm.completedAt,
      status: alarm.status,
    );
  }

  /// 🔄 Convert back to Alarm entity
  Alarm toAlarm() {
    return Alarm(
      id: alarmId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      message: title,
      scheduledTime: alarmTime,
      isEnabled: isEnabled,
      weekDays: repeatDays,
      soundPath: sound,
      vibrate: vibrate,
      linkedNoteId: noteId,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      snoozedUntil: snoozedUntil,
      completedAt: completedAt,
      status: status,
    );
  }

  /// 🏭 Create AlarmParams from Map
  factory AlarmParams.fromMap(Map<String, dynamic> map) {
    return AlarmParams(
      alarmId: map['alarmId'] as String?,
      alarmTime: map['alarmTime'] is DateTime
          ? map['alarmTime'] as DateTime
          : DateTime.parse(map['alarmTime'] as String),
      title: map['title'] as String? ?? 'Alarm',
      description: map['description'] as String? ?? '',
      isEnabled: map['isEnabled'] as bool? ?? true,
      repeatDays: map['repeatDays'] != null
          ? List<int>.from(map['repeatDays'] as List)
          : const [],
      sound: map['sound'] as String?,
      vibrate: map['vibrate'] as bool? ?? true,
      noteId: map['noteId'] as String?,
      reminderId: map['reminderId'] as String?,
      hasSnooze: map['hasSnooze'] as bool? ?? true,
      snoozeIntervalMinutes: map['snoozeIntervalMinutes'] as int? ?? 5,
      tags: map['tags'] != null
          ? List<String>.from(map['tags'] as List)
          : const [],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is DateTime
                ? map['createdAt'] as DateTime
                : DateTime.parse(map['createdAt'] as String))
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is DateTime
                ? map['updatedAt'] as DateTime
                : DateTime.parse(map['updatedAt'] as String))
          : null,
      snoozedUntil: map['snoozedUntil'] != null
          ? (map['snoozedUntil'] is DateTime
                ? map['snoozedUntil'] as DateTime
                : DateTime.parse(map['snoozedUntil'] as String))
          : null,
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] is DateTime
                ? map['completedAt'] as DateTime
                : DateTime.parse(map['completedAt'] as String))
          : null,
      status: map['status'] != null
          ? AlarmStatus.values.firstWhere(
              (e) => e.toString() == map['status'],
              orElse: () => AlarmStatus.scheduled,
            )
          : AlarmStatus.scheduled,
    );
  }

  /// 📤 Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'alarmId': alarmId,
      'alarmTime': alarmTime.toIso8601String(),
      'title': title,
      'description': description,
      'isEnabled': isEnabled,
      'repeatDays': repeatDays,
      'sound': sound,
      'vibrate': vibrate,
      'noteId': noteId,
      'reminderId': reminderId,
      'hasSnooze': hasSnooze,
      'snoozeIntervalMinutes': snoozeIntervalMinutes,
      'tags': tags,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'snoozedUntil': snoozedUntil?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'status': status.toString(),
    };
  }

  @override
  List<Object?> get props => [
    alarmId,
    alarmTime,
    title,
    description,
    isEnabled,
    repeatDays,
    sound,
    vibrate,
    noteId,
    reminderId,
    hasSnooze,
    snoozeIntervalMinutes,
    tags,
    createdAt,
    updatedAt,
    snoozedUntil,
    completedAt,
    status,
  ];

  @override
  String toString() {
    return 'AlarmParams(id: $alarmId, time: ${getTimeString()}, '
        'repeat: ${getRepeatString()}, enabled: $isEnabled, status: $status)';
  }
}
