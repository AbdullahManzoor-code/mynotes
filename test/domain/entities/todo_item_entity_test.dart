import 'package:flutter_test/flutter_test.dart';
import 'package:mynotes/domain/entities/todo_item.dart';

void main() {
  group('TodoItem Entity Tests', () {
    test('TodoItem can be created with required fields', () {
      final now = DateTime.now();
      final todo = TodoItem(
        id: 't1',
        noteId: 'n1',
        text: 'Buy groceries',
        isCompleted: false,
        priority: TodoPriority.medium,
        createdAt: now,
        updatedAt: now,
      );

      expect(todo.id, 't1');
      expect(todo.noteId, 'n1');
      expect(todo.text, 'Buy groceries');
      expect(todo.isCompleted, false);
      expect(todo.priority, 1);
    });

    test('TodoItem can be marked as completed', () {
      final todo = TodoItem(
        id: 't1',
        noteId: 'n1',
        description: 'Task',
        isCompleted: false,
        priority: 1,
        createdAt: DateTime.now(),
      );

      final completed = todo.copyWith(isCompleted: true);

      expect(todo.isCompleted, false);
      expect(completed.isCompleted, true);
    });

    test('TodoItem priority levels should work correctly', () {
      final high = TodoItem(
        id: 't1',
        noteId: 'n1',
        description: 'High Priority',
        isCompleted: false,
        priority: 3,
        createdAt: DateTime.now(),
      );

      final low = TodoItem(
        id: 't2',
        noteId: 'n1',
        description: 'Low Priority',
        isCompleted: false,
        priority: 1,
        createdAt: DateTime.now(),
      );

      expect(high.priority, greaterThan(low.priority));
    });

    test('TodoItem with category should be created', () {
      final todo = TodoItem(
        id: 't1',
        noteId: 'n1',
        description: 'Categorized task',
        isCompleted: false,
        priority: 1,
        createdAt: DateTime.now(),
        category: 'Shopping',
      );

      expect(todo.category, 'Shopping');
    });

    test('Multiple TodoItems for same note should maintain relationships', () {
      final now = DateTime.now();
      final todos = List.generate(
        5,
        (index) => TodoItem(
          id: 't$index',
          noteId: 'n1',
          description: 'Todo $index',
          isCompleted: index % 2 == 0,
          priority: index + 1,
          createdAt: now.add(Duration(minutes: index)),
        ),
      );

      expect(todos, hasLength(5));
      expect(todos.where((t) => t.noteId == 'n1'), hasLength(5));
      expect(todos.where((t) => t.isCompleted), hasLength(3)); // 0, 2, 4
    });

    test('TodoItem equality should work correctly', () {
      final todo1 = TodoItem(
        id: 't1',
        noteId: 'n1',
        description: 'Task',
        isCompleted: false,
        priority: 1,
        createdAt: DateTime(2026, 2, 15),
      );

      final todo2 = TodoItem(
        id: 't1',
        noteId: 'n1',
        description: 'Task',
        isCompleted: false,
        priority: 1,
        createdAt: DateTime(2026, 2, 15),
      );

      expect(todo1, todo2);
    });
  });
}
