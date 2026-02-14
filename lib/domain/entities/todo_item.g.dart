// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubTask _$SubTaskFromJson(Map<String, dynamic> json) => SubTask(
  id: json['id'] as String,
  text: json['text'] as String,
  isCompleted: json['isCompleted'] as bool? ?? false,
);

Map<String, dynamic> _$SubTaskToJson(SubTask instance) => <String, dynamic>{
  'id': instance.id,
  'text': instance.text,
  'isCompleted': instance.isCompleted,
};

TodoItem _$TodoItemFromJson(Map<String, dynamic> json) => TodoItem(
  id: json['id'] as String,
  text: json['text'] as String,
  isCompleted: json['isCompleted'] as bool? ?? false,
  isImportant: json['isImportant'] as bool? ?? false,
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  priority:
      $enumDecodeNullable(_$TodoPriorityEnumMap, json['priority']) ??
      TodoPriority.medium,
  category:
      $enumDecodeNullable(_$TodoCategoryEnumMap, json['category']) ??
      TodoCategory.personal,
  notes: json['notes'] as String?,
  noteId: json['noteId'] as String?,
  subtasks:
      (json['subtasks'] as List<dynamic>?)
          ?.map((e) => SubTask.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  attachmentPaths:
      (json['attachmentPaths'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  hasReminder: json['hasReminder'] as bool? ?? false,
  reminderId: json['reminderId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$TodoItemToJson(TodoItem instance) => <String, dynamic>{
  'id': instance.id,
  'text': instance.text,
  'isCompleted': instance.isCompleted,
  'isImportant': instance.isImportant,
  'dueDate': instance.dueDate?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'priority': _$TodoPriorityEnumMap[instance.priority]!,
  'category': _$TodoCategoryEnumMap[instance.category]!,
  'notes': instance.notes,
  'noteId': instance.noteId,
  'subtasks': instance.subtasks,
  'attachmentPaths': instance.attachmentPaths,
  'hasReminder': instance.hasReminder,
  'reminderId': instance.reminderId,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$TodoPriorityEnumMap = {
  TodoPriority.low: 'low',
  TodoPriority.medium: 'medium',
  TodoPriority.high: 'high',
  TodoPriority.urgent: 'urgent',
};

const _$TodoCategoryEnumMap = {
  TodoCategory.personal: 'personal',
  TodoCategory.work: 'work',
  TodoCategory.shopping: 'shopping',
  TodoCategory.health: 'health',
  TodoCategory.finance: 'finance',
  TodoCategory.education: 'education',
  TodoCategory.home: 'home',
  TodoCategory.other: 'other',
};
