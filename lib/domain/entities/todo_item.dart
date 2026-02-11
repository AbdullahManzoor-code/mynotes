import 'package:equatable/equatable.dart';

/// Todo filtering options
enum TodoFilter { all, active, completed, overdue, today, thisWeek }

/// Todo sorting options
enum TodoSortOption { dueDate, priority, category, createdDate, alphabetical }

/// Todo statistics
class TodoStats {
  final int total;
  final int active;
  final int completed;
  final int overdue;
  final int today;

  TodoStats({
    required this.total,
    required this.active,
    required this.completed,
    required this.overdue,
    required this.today,
  });

  /// Create empty stats
  factory TodoStats.empty() =>
      TodoStats(total: 0, active: 0, completed: 0, overdue: 0, today: 0);
}

/// Todo Priority Levels (TD-006)
enum TodoPriority {
  low('Low', 'green', 1),
  medium('Medium', 'yellow', 2),
  high('High', 'orange', 3),
  urgent('Urgent', 'red', 4);

  const TodoPriority(this.displayName, this.color, this.level);

  final String displayName;
  final String color;
  final int level;
}

/// Todo Categories (TD-005)
enum TodoCategory {
  personal('Personal', '👤'),
  work('Work', '💼'),
  shopping('Shopping', '🛒'),
  health('Health', '🏥'),
  finance('Finance', '💰'),
  education('Education', '🎓'),
  home('Home', '🏠'),
  other('Other', '📝');

  const TodoCategory(this.displayName, this.icon);

  final String displayName;
  final String icon;
}

/// Subtask for a Todo (TD-007)
class SubTask extends Equatable {
  final String id;
  final String text;
  final bool isCompleted;

  const SubTask({
    required this.id,
    required this.text,
    this.isCompleted = false,
  });

  SubTask toggle() => SubTask(id: id, text: text, isCompleted: !isCompleted);

  SubTask copyWith({String? id, String? text, bool? isCompleted}) {
    return SubTask(
      id: id ?? this.id,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [id, text, isCompleted];

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'isCompleted': isCompleted,
  };

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'] as String,
      text: json['text'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

class TodoItem extends Equatable {
  final String id;
  final String text;
  final bool isCompleted;
  final bool isImportant; // TD-011 (Starred)
  final DateTime? dueDate;
  final DateTime? completedAt;
  final TodoPriority priority;
  final TodoCategory category;
  final String? notes; // TD-008
  final String? noteId; // TD-012 (Linked Note)
  final List<SubTask> subtasks; // TD-007
  final List<String> attachmentPaths; // TD-013 (Media)
  final bool hasReminder; // NEW: Algorithm 4 - Has linked reminder
  final String? reminderId; // NEW: Algorithm 4 - Linked reminder ID
  final DateTime createdAt;
  final DateTime updatedAt;

  const TodoItem({
    required this.id,
    required this.text,
    this.isCompleted = false,
    this.isImportant = false,
    this.dueDate,
    this.completedAt,
    this.priority = TodoPriority.medium,
    this.category = TodoCategory.personal,
    this.notes,
    this.noteId,
    this.subtasks = const [],
    this.attachmentPaths = const [],
    this.hasReminder = false,
    this.reminderId,
    required this.createdAt,
    required this.updatedAt,
  });

  TodoItem toggleComplete() {
    return copyWith(
      isCompleted: !isCompleted,
      completedAt: !isCompleted ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );
  }

  TodoItem toggleImportant() {
    return copyWith(isImportant: !isImportant, updatedAt: DateTime.now());
  }

  TodoItem copyWith({
    String? id,
    String? text,
    bool? isCompleted,
    bool? isImportant,
    DateTime? dueDate,
    DateTime? completedAt,
    TodoPriority? priority,
    TodoCategory? category,
    String? notes,
    String? noteId,
    List<SubTask>? subtasks,
    List<String>? attachmentPaths,
    bool? hasReminder,
    String? reminderId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearReminder = false,
  }) {
    return TodoItem(
      id: id ?? this.id,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      isImportant: isImportant ?? this.isImportant,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      noteId: noteId ?? this.noteId,
      subtasks: subtasks ?? this.subtasks,
      attachmentPaths: attachmentPaths ?? this.attachmentPaths,
      hasReminder: clearReminder ? false : (hasReminder ?? this.hasReminder),
      reminderId: clearReminder ? null : (reminderId ?? this.reminderId),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    text,
    isCompleted,
    isImportant,
    dueDate,
    completedAt,
    priority,
    category,
    notes,
    noteId,
    subtasks,
    attachmentPaths,
    hasReminder,
    reminderId,
    createdAt,
    updatedAt,
  ];

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'isCompleted': isCompleted,
    'isImportant': isImportant,
    'dueDate': dueDate?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'priority': priority.name,
    'category': category.name,
    'notes': notes,
    'noteId': noteId,
    'subtasks': subtasks.map((s) => s.toJson()).toList(),
    'attachmentPaths': attachmentPaths,
    'hasReminder': hasReminder,
    'reminderId': reminderId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] as String,
      text: json['text'] as String,
      isCompleted: (json['isCompleted'] as bool?) ?? false,
      isImportant: (json['isImportant'] as bool?) ?? false,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      priority: TodoPriority.values.firstWhere(
        (p) => p.name == (json['priority'] as String?),
        orElse: () => TodoPriority.medium,
      ),
      category: TodoCategory.values.firstWhere(
        (c) => c.name == (json['category'] as String?),
        orElse: () => TodoCategory.personal,
      ),
      notes: json['notes'] as String?,
      noteId: json['noteId'] as String?,
      subtasks: json['subtasks'] != null
          ? (json['subtasks'] as List)
                .map((s) => SubTask.fromJson(s as Map<String, dynamic>))
                .toList()
          : const [],
      attachmentPaths: json['attachmentPaths'] != null
          ? List<String>.from(json['attachmentPaths'] as List)
          : const [],
      hasReminder: (json['hasReminder'] as bool?) ?? false,
      reminderId: json['reminderId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  double get completionPercentage {
    if (subtasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    final completed = subtasks.where((s) => s.isCompleted).length;
    return completed / subtasks.length;
  }
}

/// Helper methods for handling lists of todos
extension TodoListExtension on List<TodoItem> {
  /// Filter todos based on criteria
  List<TodoItem> filter(TodoFilter filter) {
    switch (filter) {
      case TodoFilter.all:
        return this;
      case TodoFilter.active:
        return where((todo) => !todo.isCompleted).toList();
      case TodoFilter.completed:
        return where((todo) => todo.isCompleted).toList();
      case TodoFilter.overdue:
        final now = DateTime.now();
        return where(
          (todo) =>
              !todo.isCompleted &&
              todo.dueDate != null &&
              todo.dueDate!.isBefore(now),
        ).toList();
      case TodoFilter.today:
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        return where(
          (todo) =>
              todo.dueDate != null &&
              todo.dueDate!.isAfter(today) &&
              todo.dueDate!.isBefore(tomorrow),
        ).toList();
      case TodoFilter.thisWeek:
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        return where(
          (todo) =>
              todo.dueDate != null &&
              todo.dueDate!.isAfter(startOfWeek) &&
              todo.dueDate!.isBefore(endOfWeek),
        ).toList();
    }
  }

  /// Sort todos based on criteria
  List<TodoItem> sortBy(TodoSortOption sortOption, bool ascending) {
    final sortedTodos = List<TodoItem>.from(this);

    switch (sortOption) {
      case TodoSortOption.dueDate:
        sortedTodos.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return ascending
              ? a.dueDate!.compareTo(b.dueDate!)
              : b.dueDate!.compareTo(a.dueDate!);
        });
        break;
      case TodoSortOption.priority:
        sortedTodos.sort(
          (a, b) => ascending
              ? a.priority.level.compareTo(b.priority.level)
              : b.priority.level.compareTo(a.priority.level),
        );
        break;
      case TodoSortOption.category:
        sortedTodos.sort(
          (a, b) => ascending
              ? a.category.name.compareTo(b.category.name)
              : b.category.name.compareTo(a.category.name),
        );
        break;
      case TodoSortOption.createdDate:
        sortedTodos.sort(
          (a, b) => ascending
              ? a.createdAt.compareTo(b.createdAt)
              : b.createdAt.compareTo(a.createdAt),
        );
        break;
      case TodoSortOption.alphabetical:
        sortedTodos.sort(
          (a, b) => ascending
              ? a.text.toLowerCase().compareTo(b.text.toLowerCase())
              : b.text.toLowerCase().compareTo(a.text.toLowerCase()),
        );
        break;
    }

    return sortedTodos;
  }

  /// Get statistics for todos
  TodoStats get stats {
    final total = length;
    final completed = where((todo) => todo.isCompleted).length;
    final active = total - completed;

    final now = DateTime.now();
    final overdue = where(
      (todo) =>
          !todo.isCompleted &&
          todo.dueDate != null &&
          todo.dueDate!.isBefore(now),
    ).length;

    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueToday = where(
      (todo) =>
          !todo.isCompleted &&
          todo.dueDate != null &&
          todo.dueDate!.isAfter(today) &&
          todo.dueDate!.isBefore(tomorrow),
    ).length;

    return TodoStats(
      total: total,
      active: active,
      completed: completed,
      overdue: overdue,
      today: dueToday,
    );
  }
}
