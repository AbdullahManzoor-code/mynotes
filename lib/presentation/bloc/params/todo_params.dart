import 'package:equatable/equatable.dart';
import '../../../domain/entities/todo_item.dart';

/// Complete Param Model for Todo Operations
/// 📦 Container for all todo-related data
/// Single object instead of multiple parameters
class TodoParams extends Equatable {
  final String? todoId;
  final String text; // Main field (not title)
  final String? notes;
  final TodoPriority priority;
  final TodoCategory category;
  final bool isCompleted;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TodoParams({
    this.todoId,
    this.text = '',
    this.notes,
    this.priority = TodoPriority.medium,
    this.category = TodoCategory.personal,
    this.isCompleted = false,
    this.dueDate,
    this.completedAt,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Create TodoParams from TodoItem entity
  factory TodoParams.fromTodoItem(TodoItem todo) {
    return TodoParams(
      todoId: todo.id,
      text: todo.text,
      notes: todo.notes,
      priority: todo.priority,
      category: todo.category,
      isCompleted: todo.isCompleted,
      dueDate: todo.dueDate,
      completedAt: todo.completedAt,
      tags: [],
      createdAt: todo.createdAt,
      updatedAt: todo.updatedAt,
    );
  }

  /// Convert TodoParams to TodoItem entity
  TodoItem toTodoItem() {
    return TodoItem(
      id: todoId ?? DateTime.now().toString(),
      text: text,
      notes: notes,
      priority: priority,
      category: category,
      isCompleted: isCompleted,
      dueDate: dueDate,
      completedAt: completedAt,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// ✨ Create a copy with modified fields
  TodoParams copyWith({
    String? todoId,
    String? text,
    String? notes,
    TodoPriority? priority,
    TodoCategory? category,
    bool? isCompleted,
    DateTime? dueDate,
    DateTime? completedAt,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoParams(
      todoId: todoId ?? this.todoId,
      text: text ?? this.text,
      notes: notes ?? this.notes,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Toggle completion status
  TodoParams toggleCompletion() {
    return copyWith(isCompleted: !isCompleted);
  }

  /// Change priority
  TodoParams withPriority(TodoPriority newPriority) {
    return copyWith(priority: newPriority);
  }

  /// Change category
  TodoParams withCategory(TodoCategory newCategory) {
    return copyWith(category: newCategory);
  }

  /// Set due date
  TodoParams withDueDate(DateTime date) {
    return copyWith(dueDate: date);
  }

  /// Clear due date
  TodoParams clearDueDate() {
    return copyWith(dueDate: null);
  }

  /// Add tag
  TodoParams withTag(String tag) {
    if (tags.contains(tag)) return this;
    return copyWith(tags: [...tags, tag]);
  }

  /// Remove tag
  TodoParams withoutTag(String tag) {
    return copyWith(tags: tags.where((t) => t != tag).toList());
  }

  @override
  List<Object?> get props => [
    todoId,
    text,
    notes,
    priority,
    category,
    isCompleted,
    dueDate,
    completedAt,
    tags,
    createdAt,
    updatedAt,
  ];
}
