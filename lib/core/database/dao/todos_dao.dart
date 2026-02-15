import 'package:mynotes/domain/entities/todo_item.dart' show TodoItem;
import 'package:sqflite/sqflite.dart';
import '../mappers/todos_mapper.dart';
import 'tables_reference.dart';

class TodosDAO {
  final Database db;

  TodosDAO(this.db);

  /// Create a new todo
  Future<void> createTodo(TodoItem todo, [String? noteId]) async {
    await db.insert(
      TablesReference.todosTable,
      TodosMapper.toMap(todo, noteId),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all todos
  Future<List<TodoItem>> getAllTodos() async {
    final List<Map<String, dynamic>> maps = await db.query(
      TablesReference.todosTable,
      orderBy: 'isCompleted ASC, dueDate ASC, priority DESC',
    );
    return List.generate(maps.length, (i) => TodosMapper.fromMap(maps[i]));
  }

  /// Get a single todo by ID
  Future<TodoItem?> getTodoById(String id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      TablesReference.todosTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return TodosMapper.fromMap(maps.first);
  }

  /// Update an existing todo
  Future<void> updateTodo(TodoItem todo, [String? noteId]) async {
    await db.update(
      TablesReference.todosTable,
      TodosMapper.toMap(todo, noteId),
      where: 'id = ?',
      whereArgs: [todo.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Delete a todo by ID
  Future<void> deleteTodo(String id) async {
    await db.delete(
      TablesReference.todosTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get todos filtered by note or completion status
  Future<List<TodoItem>> getTodos({
    String? noteId,
    bool? isCompleted,
    String? category,
  }) async {
    String whereClause = '';
    List<dynamic> args = [];

    if (noteId != null) {
      whereClause += 'noteId = ?';
      args.add(noteId);
    }

    if (isCompleted != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'isCompleted = ?';
      args.add(isCompleted ? 1 : 0);
    }

    if (category != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'category = ?';
      args.add(category);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      TablesReference.todosTable,
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'isCompleted ASC, dueDate ASC, priority DESC',
    );
    return List.generate(maps.length, (i) => TodosMapper.fromMap(maps[i]));
  }

  /// Add multiple todos at once (batch insert)
  Future<void> addTodos(List<TodoItem> todos, [String? noteId]) async {
    for (final todo in todos) {
      await createTodo(todo, noteId);
    }
  }

  /// Search todos by title or description
  Future<List<TodoItem>> searchTodos(String query) async {
    if (query.isEmpty) return getAllTodos();

    final List<Map<String, dynamic>> maps = await db.query(
      TablesReference.todosTable,
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'isCompleted ASC, dueDate ASC, priority DESC',
    );
    return List.generate(maps.length, (i) => TodosMapper.fromMap(maps[i]));
  }
}
