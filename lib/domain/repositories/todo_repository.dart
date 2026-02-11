import '../../domain/entities/todo_item.dart';

abstract class TodoRepository {
  Future<List<TodoItem>> getTodos({String? noteId});
  Future<TodoItem?> getTodoById(String id);
  Future<void> createTodo(TodoItem todo);
  Future<void> updateTodo(TodoItem todo);
  Future<void> deleteTodo(String id);
  Future<void> toggleTodo(String id);
  Future<List<TodoItem>> searchTodos(String query);
}
