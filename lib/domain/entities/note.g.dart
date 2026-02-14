// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Note _$NoteFromJson(Map<String, dynamic> json) => Note(
  id: json['id'] as String,
  title: json['title'] as String? ?? '',
  content: json['content'] as String? ?? '',
  media:
      (json['media'] as List<dynamic>?)
          ?.map((e) => MediaItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  links:
      (json['links'] as List<dynamic>?)
          ?.map((e) => Link.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  todos: (json['todos'] as List<dynamic>?)
      ?.map((e) => TodoItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  alarms: (json['alarms'] as List<dynamic>?)
      ?.map((e) => Alarm.fromJson(e as Map<String, dynamic>))
      .toList(),
  color:
      $enumDecodeNullable(_$NoteColorEnumMap, json['color']) ??
      NoteColor.defaultColor,
  isPinned: json['isPinned'] as bool? ?? false,
  isArchived: json['isArchived'] as bool? ?? false,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  priority: (json['priority'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'content': instance.content,
  'media': instance.media,
  'links': instance.links,
  'todos': instance.todos,
  'alarms': instance.alarms,
  'color': _$NoteColorEnumMap[instance.color]!,
  'isPinned': instance.isPinned,
  'isArchived': instance.isArchived,
  'tags': instance.tags,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'priority': instance.priority,
};

const _$NoteColorEnumMap = {
  NoteColor.defaultColor: 'defaultColor',
  NoteColor.red: 'red',
  NoteColor.pink: 'pink',
  NoteColor.purple: 'purple',
  NoteColor.blue: 'blue',
  NoteColor.green: 'green',
  NoteColor.yellow: 'yellow',
  NoteColor.orange: 'orange',
  NoteColor.brown: 'brown',
  NoteColor.grey: 'grey',
};
