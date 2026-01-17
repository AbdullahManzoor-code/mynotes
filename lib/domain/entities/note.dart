import 'package:equatable/equatable.dart';
import 'media_item.dart';
import 'todo_item.dart';
import 'link.dart';

// Note Color Enum
enum NoteColor {
  defaultColor(0xFFFFFFFF, 0xFF1C1B1F),
  red(0xFFFFCDD2, 0xFFB71C1C),
  pink(0xFFF8BBD0, 0xFFC2185B),
  purple(0xFFE1BEE7, 0xFF7B1FA2),
  blue(0xFFBBDEFB, 0xFF1976D2),
  green(0xFFC8E6C9, 0xFF388E3C),
  yellow(0xFFFFF9C4, 0xFFFBC02D),
  orange(0xFFFFE0B2, 0xFFF57C00);

  final int lightColor;
  final int darkColor;

  const NoteColor(this.lightColor, this.darkColor);
}

class Note extends Equatable {
  final String id;
  final String title;
  final String content; // Could be richer (rich text) in a real app
  final List<MediaItem> media; // Attached media (images, audio, video)
  final List<Link> links; // Attached website links
  final List<TodoItem>? todos; // Task list
  final List<dynamic>? alarms; // Alarms (using dynamic to avoid import issues)
  final NoteColor color;
  final bool isPinned;
  final bool isArchived;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    this.title = '',
    this.content = '',
    List<MediaItem>? media,
    List<Link>? links,
    this.todos,
    this.alarms,
    this.color = NoteColor.defaultColor,
    this.isPinned = false,
    this.isArchived = false,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : media = media ?? [],
       links = links ?? [],
       tags = tags ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Note copyWith({
    String? id,
    String? title,
    String? content,
    List<MediaItem>? media,
    List<Link>? links,
    List<TodoItem>? todos,
    List<dynamic>? alarms,
    NoteColor? color,
    bool? isPinned,
    bool? isArchived,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
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

  /// Add alarm (placeholder)
  Note addAlarm(dynamic alarm) {
    return copyWith(updatedAt: DateTime.now());
  }

  /// Remove alarm (placeholder)
  Note removeAlarm(String alarmId) {
    return copyWith(updatedAt: DateTime.now());
  }

  /// Check if note has media
  bool get hasMedia => media.isNotEmpty;

  /// Check if note has todos
  bool get hasTodos => false; // Simplified

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

  /// Get completion percentage (placeholder)
  double get completionPercentage => 0.0;

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    media,
    links,
    color,
    isPinned,
    isArchived,
    tags,
    createdAt,
    updatedAt,
  ];
}
