import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/todo_item.dart';

/// Service for managing standalone todos with persistence
class TodoService {
  static const String _todosKey = 'app_todos';

  /// Load all todos from storage
  static Future<List<TodoItem>> loadTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = prefs.getStringList(_todosKey) ?? [];

      return todosJson
          .map((todoJson) => TodoItem.fromJson(json.decode(todoJson)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Save all todos to storage
  static Future<void> saveTodos(List<TodoItem> todos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = todos
          .map((todo) => json.encode(todo.toJson()))
          .toList();

      await prefs.setStringList(_todosKey, todosJson);
    } catch (e) {
      throw Exception('Failed to save todos: $e');
    }
  }

  /// Add a new todo
  static Future<List<TodoItem>> addTodo(TodoItem todo) async {
    final todos = await loadTodos();
    todos.add(todo);
    await saveTodos(todos);
    return todos;
  }

  /// Update an existing todo
  static Future<List<TodoItem>> updateTodo(TodoItem updatedTodo) async {
    final todos = await loadTodos();
    final index = todos.indexWhere((todo) => todo.id == updatedTodo.id);

    if (index != -1) {
      todos[index] = updatedTodo;
      await saveTodos(todos);
    }

    return todos;
  }

  /// Toggle todo completion
  static Future<List<TodoItem>> toggleTodo(String todoId) async {
    final todos = await loadTodos();
    final index = todos.indexWhere((todo) => todo.id == todoId);

    if (index != -1) {
      todos[index] = todos[index].toggleComplete();
      await saveTodos(todos);
    }

    return todos;
  }

  /// Delete a todo
  static Future<List<TodoItem>> deleteTodo(String todoId) async {
    final todos = await loadTodos();
    todos.removeWhere((todo) => todo.id == todoId);
    await saveTodos(todos);
    return todos;
  }

  /// Filter todos based on criteria
  static List<TodoItem> filterTodos(List<TodoItem> todos, TodoFilter filter) {
    switch (filter) {
      case TodoFilter.all:
        return todos;
      case TodoFilter.active:
        return todos.where((todo) => !todo.isCompleted).toList();
      case TodoFilter.completed:
        return todos.where((todo) => todo.isCompleted).toList();
      case TodoFilter.overdue:
        final now = DateTime.now();
        return todos
            .where(
              (todo) =>
                  !todo.isCompleted &&
                  todo.dueDate != null &&
                  todo.dueDate!.isBefore(now),
            )
            .toList();
      case TodoFilter.today:
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        return todos
            .where(
              (todo) =>
                  todo.dueDate != null &&
                  todo.dueDate!.isAfter(today) &&
                  todo.dueDate!.isBefore(tomorrow),
            )
            .toList();
      case TodoFilter.thisWeek:
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        return todos
            .where(
              (todo) =>
                  todo.dueDate != null &&
                  todo.dueDate!.isAfter(startOfWeek) &&
                  todo.dueDate!.isBefore(endOfWeek),
            )
            .toList();
    }
  }

  /// Sort todos based on criteria
  static List<TodoItem> sortTodos(
    List<TodoItem> todos,
    TodoSortOption sortOption,
    bool ascending,
  ) {
    final sortedTodos = List<TodoItem>.from(todos);

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
  static TodoStats getStats(List<TodoItem> todos) {
    final total = todos.length;
    final completed = todos.where((todo) => todo.isCompleted).length;
    final active = total - completed;

    final now = DateTime.now();
    final overdue = todos
        .where(
          (todo) =>
              !todo.isCompleted &&
              todo.dueDate != null &&
              todo.dueDate!.isBefore(now),
        )
        .length;

    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueToday = todos
        .where(
          (todo) =>
              !todo.isCompleted &&
              todo.dueDate != null &&
              todo.dueDate!.isAfter(today) &&
              todo.dueDate!.isBefore(tomorrow),
        )
        .length;

    return TodoStats(
      total: total,
      completed: completed,
      active: active,
      overdue: overdue,
      dueToday: dueToday,
    );
  }
}

/// Import the filter and sort enums
enum TodoFilter { all, active, completed, overdue, today, thisWeek }

enum TodoSortOption { dueDate, priority, category, createdDate, alphabetical }

/// Todo statistics
class TodoStats {
  final int total;
  final int completed;
  final int active;
  final int overdue;
  final int dueToday;

  const TodoStats({
    required this.total,
    required this.completed,
    required this.active,
    required this.overdue,
    required this.dueToday,
  });

  double get completionRate => total > 0 ? completed / total : 0.0;
}
