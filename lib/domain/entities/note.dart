import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'media_item.dart';
import 'todo_item.dart';
import 'link.dart';
import 'alarm.dart';

part 'note.g.dart';

enum NoteColor {
  defaultColor(0xFFFFFFFF, 0xFF1C1B1F),
  red(0xFFFFCDD2, 0xFFB71C1C),
  pink(0xFFF8BBD0, 0xFFC2185B),
  purple(0xFFE1BEE7, 0xFF7B1FA2),
  blue(0xFFBBDEFB, 0xFF1976D2),
  green(0xFFC8E6C9, 0xFF388E3C),
  yellow(0xFFFFF9C4, 0xFFFBC02D),
  orange(0xFFFFE0B2, 0xFFF57C00),
  brown(0xFFD7CCC8, 0xFF3E2723), // Added
  grey(0xFFF5F5F5, 0xFF212121); // Added

  final int lightColor;
  final int darkColor;

  const NoteColor(this.lightColor, this.darkColor);

  String get displayName => name[0].toUpperCase() + name.substring(1);

  // Helper for UI
  int getColorValue(bool isDarkMode) => isDarkMode ? darkColor : lightColor;

  Color toColor(bool isDarkMode) => Color(getColorValue(isDarkMode));

  static NoteColor fromColor(Color color) {
    for (var c in NoteColor.values) {
      if (Color(c.lightColor) == color || Color(c.darkColor) == color) {
        return c;
      }
    }
    return NoteColor.defaultColor;
  }
}

@JsonSerializable()
class Note extends Equatable {
  final String id;
  final String title;
  final String content;
  final List<MediaItem> media;
  final List<Link> links;
  final List<TodoItem>? todos;
  final List<Alarm>? alarms;

  final NoteColor color;
  final bool isPinned;
  final bool isArchived;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int priority;

  Note({
    required this.id,
    this.title = '',
    this.content = '',
    this.media = const [],
    this.links = const [],
    this.todos,
    this.alarms,
    this.color = NoteColor.defaultColor,
    this.isPinned = false,
    this.isArchived = false,
    this.tags = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.priority = 1,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  Map<String, dynamic> toJson() => _$NoteToJson(this);

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    media,
    links,
    todos,
    alarms,
    color,
    isPinned,
    isArchived,
    tags,
    createdAt,
    updatedAt,
    priority,
  ];

  Note copyWith({
    String? id,
    String? title,
    String? content,
    List<MediaItem>? media,
    List<Link>? links,
    List<TodoItem>? todos,
    List<Alarm>? alarms,
    NoteColor? color,
    bool? isPinned,
    bool? isArchived,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? priority,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      media: media ?? this.media,
      links: links ?? this.links,
      todos: todos ?? this.todos,
      alarms: alarms ?? this.alarms,
      color: color ?? this.color,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      priority: priority ?? this.priority,
    );
  }

  /// Toggle pin status
  Note togglePin() {
    return copyWith(isPinned: !isPinned, updatedAt: DateTime.now());
  }

  /// Toggle archive status
  Note toggleArchive() {
    return copyWith(isArchived: !isArchived, updatedAt: DateTime.now());
  }

  /// Add tag
  Note addTag(String tag) {
    if (tags.contains(tag)) return this;
    return copyWith(tags: [...tags, tag], updatedAt: DateTime.now());
  }

  /// Remove tag
  Note removeTag(String tag) {
    return copyWith(
      tags: tags.where((t) => t != tag).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Add alarm
  Note addAlarm(Alarm alarm) {
    final updatedAlarms = List<Alarm>.from(alarms ?? []);
    updatedAlarms.add(alarm);
    return copyWith(alarms: updatedAlarms, updatedAt: DateTime.now());
  }

  /// Remove alarm
  Note removeAlarm(String alarmId) {
    final updatedAlarms = List<Alarm>.from(alarms ?? []);
    updatedAlarms.removeWhere((a) => a.id == alarmId);
    return copyWith(alarms: updatedAlarms, updatedAt: DateTime.now());
  }

  /// Check if note has media
  bool get hasMedia => media.isNotEmpty;

  /// Check if note has todos
  bool get hasTodos => todos != null && todos!.isNotEmpty;

  /// Check if note has alarms
  bool get hasAlarms => alarms != null && alarms!.isNotEmpty;

  /// Get images count
  int get imagesCount {
    return media.where((item) => item.type == MediaType.image).length;
  }

  /// Get audio count
  int get audioCount {
    return media.where((item) => item.type == MediaType.audio).length;
  }

  /// Get video count
  int get videoCount {
    return media.where((item) => item.type == MediaType.video).length;
  }

  /// Get link count
  int get linkCount => links.length;

  /// Get completion percentage
  double get completionPercentage {
    if (todos == null || todos!.isEmpty) return 0.0;
    final completed = todos!.where((t) => t.isCompleted).length;
    return (completed / todos!.length) * 100;
  }

  // @override
  // List<Object?> get props => [
  //   id,
  //   title,
  //   content,
  //   media,
  //   links,
  //   todos,
  //   alarms,
  //   color,
  //   isPinned,
  //   isArchived,
  //   tags,
  //   createdAt,
  //   updatedAt,
  //   priority,
  // ];
}
