import 'dart:convert';

import 'package:mynotes/domain/entities/todo_item.dart' show TodoItem, TodoPriority, TodoCategory, SubTask;


class TodosMapper {
  /// Convert TodoItem to database map
  static Map<String, dynamic> toMap(TodoItem todo, [String? noteId]) {
    return {
      'id': todo.id,
      'noteId': noteId ?? todo.noteId,
      'title': todo.text,
      'description': todo.notes,
      'category': todo.category.displayName,
      'priority': todo.priority.level,
      'isCompleted': todo.isCompleted ? 1 : 0,
      'isImportant': todo.isImportant ? 1 : 0,
      'hasReminder': todo.hasReminder ? 1 : 0,
      'reminderId': todo.reminderId,
      'dueDate': todo.dueDate?.toIso8601String(),
      'completedAt': todo.completedAt?.toIso8601String(),
      'subtasksJson': jsonEncode(todo.subtasks.map((s) => s.toJson()).toList()),
      'attachmentsJson': jsonEncode(todo.attachmentPaths),
      'createdAt': todo.createdAt.toIso8601String(),
      'updatedAt': todo.updatedAt.toIso8601String(),
    };
  }

  /// Convert database map to TodoItem
  static TodoItem fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'],
      text: map['title'] ?? '',
      isCompleted: (map['isCompleted'] ?? 0) == 1,
      isImportant: (map['isImportant'] ?? 0) == 1,
      hasReminder: (map['hasReminder'] ?? 0) == 1,
      reminderId: map['reminderId'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      priority: _parseTodoPriority(map['priority'] ?? 2),
      category: _parseTodoCategory(map['category'] ?? 'Personal'),
      notes: map['description'],
      subtasks: map['subtasksJson'] != null
          ? (jsonDecode(map['subtasksJson']) as List)
                .map((s) => SubTask.fromJson(Map<String, dynamic>.from(s)))
                .toList()
          : [],
      attachmentPaths: map['attachmentsJson'] != null
          ? (jsonDecode(map['attachmentsJson']) as List)
                .map((a) => a as String)
                .toList()
          : [],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }

  /// Parse priority int to TodoPriority enum
  static TodoPriority _parseTodoPriority(int level) {
    switch (level) {
      case 1:
        return TodoPriority.low;
      case 2:
        return TodoPriority.medium;
      case 3:
        return TodoPriority.high;
      case 4:
        return TodoPriority.urgent;
      default:
        return TodoPriority.medium;
    }
  }

  /// Parse category string to TodoCategory enum
  static TodoCategory _parseTodoCategory(String category) {
    return TodoCategory.values.firstWhere(
      (cat) => cat.displayName == category,
      orElse: () => TodoCategory.personal,
    );
  }
}
