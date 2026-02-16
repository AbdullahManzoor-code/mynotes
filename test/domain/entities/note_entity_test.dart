import 'package:flutter_test/flutter_test.dart';
import 'package:mynotes/domain/entities/note.dart';
import 'package:mynotes/domain/entities/todo_item.dart';
import 'package:mynotes/domain/entities/alarm.dart';
import 'package:mynotes/domain/entities/media_item.dart';

void main() {
  group('Note Entity Tests', () {
    test('Note can be created with required fields', () {
      final note = Note(
        id: '1',
        title: 'Test Note',
        content: 'Test content',
        createdAt: DateTime.now(),
      );

      expect(note.id, '1');
      expect(note.title, 'Test Note');
      expect(note.content, 'Test content');
      expect(note.createdAt, isNotNull);
    });

    test('Note with all fields should be created correctly', () {
      final now = DateTime.now();
      final todos = [
        TodoItem(
          id: 't1',
          noteId: '1',
          description: 'Todo 1',
          isCompleted: false,
          priority: 1,
          createdAt: now,
        ),
      ];

      final alarms = [
        Alarm(
          id: 'a1',
          noteId: '1',
          scheduledTime: now.add(const Duration(hours: 1)),
          recurrence: AlarmRecurrence.daily,
          status: AlarmStatus.scheduled,
          createdAt: now,
        ),
      ];

      final media = [
        MediaItem(
          id: 'm1',
          noteId: '1',
          filePath: '/path/to/image.jpg',
          type: MediaType.image,
          createdAt: now,
        ),
      ];

      final note = Note(
        id: '1',
        title: 'Complete Note',
        content: 'Full content',
        createdAt: now,
        todos: todos,
        alarms: alarms,
        media: media,
        tags: ['tag1', 'tag2'],
        category: 'Work',
        isPinned: true,
      );

      expect(note.todos, hasLength(1));
      expect(note.alarms, hasLength(1));
      expect(note.media, hasLength(1));
      expect(note.tags, hasLength(2));
      expect(note.category, 'Work');
      expect(note.isPinned, true);
    });

    test('Note equality should work correctly', () {
      final note1 = Note(
        id: '1',
        title: 'Test',
        content: 'Content',
        createdAt: DateTime(2026, 2, 15),
      );

      final note2 = Note(
        id: '1',
        title: 'Test',
        content: 'Content',
        createdAt: DateTime(2026, 2, 15),
      );

      expect(note1, note2);
    });

    test('Note copyWith should create new instance with updated fields', () {
      final original = Note(
        id: '1',
        title: 'Original',
        content: 'Content',
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(title: 'Updated', isPinned: true);

      expect(updated.id, original.id);
      expect(updated.title, 'Updated');
      expect(updated.content, original.content);
      expect(updated.isPinned, true);
    });

    test('Note with empty content should be valid', () {
      final note = Note(
        id: '1',
        title: 'Title Only',
        content: '',
        createdAt: DateTime.now(),
      );

      expect(note.content, isEmpty);
      expect(note.title, 'Title Only');
    });

    test('Note should handle null optional fields', () {
      final note = Note(
        id: '1',
        title: 'Test',
        content: 'Content',
        createdAt: DateTime.now(),
        todos: null,
        alarms: null,
        media: null,
        tags: null,
      );

      expect(note.todos, isNull);
      expect(note.alarms, isNull);
      expect(note.media, isNull);
      expect(note.tags, isNull);
    });
  });
}
