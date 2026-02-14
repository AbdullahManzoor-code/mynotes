// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Alarm _$AlarmFromJson(Map<String, dynamic> json) => Alarm(
  id: json['id'] as String,
  message: json['message'] as String,
  scheduledTime: DateTime.parse(json['scheduledTime'] as String),
  isActive: json['isActive'] as bool? ?? true,
  recurrence:
      $enumDecodeNullable(_$AlarmRecurrenceEnumMap, json['recurrence']) ??
      AlarmRecurrence.none,
  status:
      $enumDecodeNullable(_$AlarmStatusEnumMap, json['status']) ??
      AlarmStatus.scheduled,
  linkedNoteId: json['linkedNoteId'] as String?,
  linkedTodoId: json['linkedTodoId'] as String?,
  soundPath: json['soundPath'] as String?,
  vibrate: json['vibrate'] as bool? ?? true,
  isEnabled: json['isEnabled'] as bool? ?? true,
  snoozeCount: (json['snoozeCount'] as num?)?.toInt() ?? 0,
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  lastTriggered: json['lastTriggered'] == null
      ? null
      : DateTime.parse(json['lastTriggered'] as String),
  snoozedUntil: json['snoozedUntil'] == null
      ? null
      : DateTime.parse(json['snoozedUntil'] as String),
  weekDays: (json['weekDays'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$AlarmToJson(Alarm instance) => <String, dynamic>{
  'id': instance.id,
  'message': instance.message,
  'scheduledTime': instance.scheduledTime.toIso8601String(),
  'isActive': instance.isActive,
  'recurrence': _$AlarmRecurrenceEnumMap[instance.recurrence]!,
  'status': _$AlarmStatusEnumMap[instance.status]!,
  'linkedNoteId': instance.linkedNoteId,
  'linkedTodoId': instance.linkedTodoId,
  'soundPath': instance.soundPath,
  'vibrate': instance.vibrate,
  'isEnabled': instance.isEnabled,
  'snoozeCount': instance.snoozeCount,
  'completedAt': instance.completedAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'lastTriggered': instance.lastTriggered?.toIso8601String(),
  'snoozedUntil': instance.snoozedUntil?.toIso8601String(),
  'weekDays': instance.weekDays,
};

const _$AlarmRecurrenceEnumMap = {
  AlarmRecurrence.none: 'none',
  AlarmRecurrence.daily: 'daily',
  AlarmRecurrence.weekly: 'weekly',
  AlarmRecurrence.monthly: 'monthly',
  AlarmRecurrence.yearly: 'yearly',
};

const _$AlarmStatusEnumMap = {
  AlarmStatus.scheduled: 'scheduled',
  AlarmStatus.triggered: 'triggered',
  AlarmStatus.snoozed: 'snoozed',
  AlarmStatus.completed: 'completed',
};
