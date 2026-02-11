import '../../domain/entities/todo_item.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/local_database.dart';

class TodoRepositoryImpl implements TodoRepository {
  final NotesDatabase _database;

  TodoRepositoryImpl({required NotesDatabase database}) : _database = database;

  @override
  Future<List<TodoItem>> getTodos({String? noteId}) async {
    if (noteId != null) {
      return await _database.getTodos(noteId);
    }
    return await _database.getAllTodos();
  }

  @override
  Future<TodoItem?> getTodoById(String id) async {
    return await _database.getTodoById(id);
  }

  @override
  Future<void> createTodo(TodoItem todo) async {
    await _database.createTodo(todo);
  }

  @override
  Future<void> updateTodo(TodoItem todo) async {
    await _database.updateTodo(todo);
  }

  @override
  Future<void> deleteTodo(String id) async {
    await _database.deleteTodo(id);
  }

  @override
  Future<void> toggleTodo(String id) async {
    final todo = await _database.getTodoById(id);
    if (todo != null) {
      final updatedTodo = todo.copyWith(
        isCompleted: !todo.isCompleted,
        completedAt: !todo.isCompleted ? DateTime.now() : null,
        updatedAt: DateTime.now(),
      );
      await _database.updateTodo(updatedTodo);
    }
  }

  @override
  Future<List<TodoItem>> searchTodos(String query) async {
    return await _database.searchTodos(query);
  }
}
