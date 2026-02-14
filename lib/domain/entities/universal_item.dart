import '../../domain/entities/note.dart';

enum ItemPriority { high, medium, low }

/// Universal Item Model - Unified data model for the Atom Action System.
/// This allows any item to be "promoted" or "converted" between types
/// (Note, Todo, Reminder) seamlessly across the BLoC and Repository layers.
class UniversalItem {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isTodo;
  final bool isCompleted;
  final DateTime? reminderTime;
  final ItemPriority? priority;
  final String category;
  final bool hasVoiceNote;
  final bool hasImages;
  final List<String>? tags;

  UniversalItem({
    required this.id,
    required this.title,
    this.content = '',
    required this.createdAt,
    required this.updatedAt,
    this.isTodo = false,
    this.isCompleted = false,
    this.reminderTime,
    this.priority,
    this.category = '',
    this.hasVoiceNote = false,
    this.hasImages = false,
    this.tags,
  });

  bool get isNote => !isTodo && reminderTime == null;
  bool get isReminder => reminderTime != null;
  bool get isOverdue => isReminder && reminderTime!.isBefore(DateTime.now());

  // --- Atomic Action Promoters ---

  /// Promotes a Note to a Todo item
  UniversalItem promoteToTodo({ItemPriority priority = ItemPriority.medium}) {
    return copyWith(
      isTodo: true,
      category: 'Todo',
      priority: priority,
      updatedAt: DateTime.now(),
    );
  }

  /// Promotes any item to a Reminder by adding a schedule
  UniversalItem promoteToReminder(DateTime scheduledTime) {
    return copyWith(
      reminderTime: scheduledTime,
      category: isTodo ? 'Todo Reminder' : 'Reminder',
      updatedAt: DateTime.now(),
    );
  }

  /// Converts a Todo/Reminder back to a generic Note
  UniversalItem convertToNote() {
    return copyWith(
      isTodo: false,
      reminderTime: null,
      category: 'Note',
      updatedAt: DateTime.now(),
    );
  }

  // --- Factory Constructors ---

  factory UniversalItem.fromNote(Note note) {
    return UniversalItem(
      id: note.id,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
      category: 'Note',
      hasImages: note.media.isNotEmpty,
      tags: note.tags,
    );
  }

  factory UniversalItem.todo({
    required String id,
    required String title,
    String content = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isCompleted = false,
    DateTime? reminderTime,
    ItemPriority? priority,
    String category = 'Todo',
    bool hasVoiceNote = false,
  }) {
    return UniversalItem(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      isTodo: true,
      isCompleted: isCompleted,
      reminderTime: reminderTime,
      priority: priority,
      category: category,
      hasVoiceNote: hasVoiceNote,
    );
  }

  factory UniversalItem.reminder({
    required String id,
    required String title,
    required DateTime reminderTime,
    String content = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    ItemPriority? priority,
    String category = 'Reminder',
  }) {
    return UniversalItem(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      reminderTime: reminderTime,
      priority: priority,
      category: category,
    );
  }

  factory UniversalItem.fromMap(Map<String, dynamic> map) {
    return UniversalItem(
      id: (map['id'] ?? '') as String,
      title: (map['title'] ?? '') as String,
      content: (map['content'] ?? '') as String,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isTodo: (map['isTodo'] == 1),
      isCompleted: (map['isCompleted'] == 1),
      reminderTime: map['reminderTime'] != null
          ? DateTime.tryParse(map['reminderTime'] as String)
          : null,
      category: (map['category'] ?? '') as String,
      priority: map['priority'] != null
          ? ItemPriority.values.firstWhere(
              (e) =>
                  e.toString() == map['priority'] || e.name == map['priority'],
              orElse: () => ItemPriority.medium,
            )
          : null,
      hasVoiceNote: map['hasVoiceNote'] == 1,
      hasImages: map['hasImages'] == 1,
      tags: map['tags'] != null ? List<String>.from(map['tags'] as List) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isTodo': isTodo ? 1 : 0,
      'isCompleted': isCompleted ? 1 : 0,
      'reminderTime': reminderTime?.toIso8601String(),
      'category': category,
      'priority': priority?.name,
      'hasVoiceNote': hasVoiceNote ? 1 : 0,
      'hasImages': hasImages ? 1 : 0,
      'tags': tags,
    };
  }

  /// Converts to Note entity
  Note toNote() {
    return Note(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isPinned: false,
      isArchived: false,
      tags: tags ?? [],
      color: NoteColor.defaultColor, // Default white or similar
    );
  }

  UniversalItem copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isTodo,
    bool? isCompleted,
    DateTime? reminderTime,
    ItemPriority? priority,
    String? category,
    bool? hasVoiceNote,
    bool? hasImages,
    List<String>? tags,
  }) {
    return UniversalItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isTodo: isTodo ?? this.isTodo,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderTime: reminderTime ?? this.reminderTime,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      hasVoiceNote: hasVoiceNote ?? this.hasVoiceNote,
      hasImages: hasImages ?? this.hasImages,
      tags: tags ?? this.tags,
    );
  }
}
