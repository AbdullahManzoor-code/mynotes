import 'package:equatable/equatable.dart';
import '../../../domain/entities/media_item.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/entities/alarm.dart';
import '../../../domain/entities/todo_item.dart';

/// Complete Param Model for Note Operations
/// 📦 Container for all note-related data
/// Eliminates need to pass multiple individual parameters to BLoC
class NoteParams extends Equatable {
  final String? noteId;
  final String title;
  final String content;
  final NoteColor color;
  final List<MediaItem> media;
  final List<String> tags;
  final bool isPinned;
  final bool isArchived;
  final List<Alarm> alarms;
  final List<TodoItem> todos;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NoteParams({
    this.noteId,
    this.title = '',
    this.content = '',
    this.color = NoteColor.defaultColor,
    this.media = const [],
    this.tags = const [],
    this.isPinned = false,
    this.isArchived = false,
    this.alarms = const [],
    this.todos = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Create NoteParams from Note entity
  factory NoteParams.fromNote(Note note) {
    return NoteParams(
      noteId: note.id,
      title: note.title,
      content: note.content,
      media: note.media,
      color: note.color,
      tags: note.tags,
      isPinned: note.isPinned,
      isArchived: note.isArchived,
      alarms: note.alarms ?? const [],
      todos: note.todos ?? const [],
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }

  /// Convert NoteParams to Note entity
  Note toNote() {
    return Note(
      id: noteId ?? DateTime.now().toString(),
      title: title,
      content: content,
      media: media,
      color: color,
      tags: tags,
      alarms: alarms,
      todos: todos,
      isPinned: isPinned,
      isArchived: isArchived,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// ✨ Create a copy with modified fields
  /// Allows updating just one variable without rebuilding the whole object
  NoteParams copyWith({
    String? noteId,
    String? title,
    String? content,
    List<MediaItem>? media,
    NoteColor? color,
    List<String>? tags,
    List<Alarm>? alarms,
    List<TodoItem>? todos,
    bool? isPinned,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteParams(
      noteId: noteId ?? this.noteId,
      title: title ?? this.title,
      content: content ?? this.content,
      media: media ?? this.media,
      color: color ?? this.color,
      tags: tags ?? this.tags,
      alarms: alarms ?? this.alarms,
      todos: todos ?? this.todos,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Add a tag while keeping other properties intact
  NoteParams withTag(String tag) {
    if (tags.contains(tag)) return this;
    return copyWith(tags: [...tags, tag]);
  }

  /// Remove a tag while keeping other properties intact
  NoteParams withoutTag(String tag) {
    return copyWith(tags: tags.where((t) => t != tag).toList());
  }

  /// Toggle pin status
  NoteParams togglePin() {
    return copyWith(isPinned: !isPinned);
  }

  /// Toggle archive status
  NoteParams toggleArchive() {
    return copyWith(isArchived: !isArchived);
  }

  /// Change note color
  NoteParams withColor(NoteColor newColor) {
    return copyWith(color: newColor);
  }

  @override
  List<Object?> get props => [
    noteId,
    title,
    content,
    media,
    color,
    tags,
    alarms,
    todos,
    isPinned,
    isArchived,
    createdAt,
    updatedAt,
  ];
}
