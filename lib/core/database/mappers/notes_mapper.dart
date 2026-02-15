import 'package:mynotes/domain/entities/note.dart' show Note, NoteColor;

class NotesMapper {
  /// Convert Note to database map
  static Map<String, dynamic> toMap(Note note) {
    return {
      'id': note.id,
      'title': note.title,
      'content': note.content,
      'color': note.color.index,
      'category': note.category,
      'isPinned': note.isPinned ? 1 : 0,
      'isArchived': note.isArchived ? 1 : 0,
      'isFavorite': note.isFavorite ? 1 : 0,
      'tags': note.tags.join(','),
      'priority': note.priority,
      'linkedReflectionId': note.linkedReflectionId,
      'linkedTodoId': note.linkedTodoId,
      'createdAt': note.createdAt.toIso8601String(),
      'updatedAt': note.updatedAt.toIso8601String(),
    };
  }

  /// Convert database map to Note
  static Note fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      color: NoteColor.values[map['color'] ?? 0],
      category: map['category'] ?? 'General',
      isPinned: map['isPinned'] == 1,
      isArchived: map['isArchived'] == 1,
      isFavorite: map['isFavorite'] == 1,
      priority: map['priority'] ?? 1,
      tags:
          (map['tags'] as String?)
              ?.split(',')
              .where((t) => t.isNotEmpty)
              .toList() ??
          [],
      linkedReflectionId: map['linkedReflectionId'],
      linkedTodoId: map['linkedTodoId'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
