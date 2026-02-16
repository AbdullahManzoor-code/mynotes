import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mynotes/domain/entities/note.dart';
import 'package:mynotes/domain/entities/todo_item.dart';
import 'package:mynotes/domain/entities/alarm.dart';
import 'package:mynotes/data/repositories/note_repository_impl.dart';
import 'package:mynotes/core/database/core_database.dart';
import '../fixtures/test_fixtures.dart';

// Mock CoreDatabase
class MockCoreDatabase extends Mock implements CoreDatabase {}

void main() {
  group('NoteRepository Tests', () {
    late MockCoreDatabase mockDatabase;
    late NoteRepositoryImpl noteRepository;

    setUp(() {
      mockDatabase = MockCoreDatabase();
      noteRepository = NoteRepositoryImpl(database: mockDatabase);
    });

    test('createNote should call database.createNote', () async {
      final note = TestFixtures.simpleNote;

      when(() => mockDatabase.createNote(note)).thenAnswer((_) async {});

      await noteRepository.createNote(note);

      verify(() => mockDatabase.createNote(note)).called(1);
    });

    test('getNoteById should return note from database', () async {
      final note = TestFixtures.complexNote;

      when(() => mockDatabase.getNoteById('note_2'))
          .thenAnswer((_) async => note);

      final result = await noteRepository.getNoteById('note_2');

      expect(result, note);
      verify(() => mockDatabase.getNoteById('note_2')).called(1);
    });

    test('getAllNotes should return all notes', () async {
      final notes = TestFixtures.allNotes;

      when(() => mockDatabase.getAllNotes()).thenAnswer((_) async => notes);

      final result = await noteRepository.getAllNotes();

      expect(result, hasLength(6));
      expect(result, notes);
      verify(() => mockDatabase.getAllNotes()).called(1);
    });

    test('updateNote should call database.updateNote', () async {
      final note = TestFixtures.simpleNote
          .copyWith(title: 'Updated Title');

      when(() => mockDatabase.updateNote(note)).thenAnswer((_) async {});

      await noteRepository.updateNote(note);

      verify(() => mockDatabase.updateNote(note)).called(1);
    });

    test('deleteNote should call database.deleteNote', () async {
      when(() => mockDatabase.deleteNote('note_1')).thenAnswer((_) async {});

      await noteRepository.deleteNote('note_1');

      verify(() => mockDatabase.deleteNote('note_1')).called(1);
    });

    test('searchNotes should return matching notes', () async {
      final notes = [TestFixtures.complexNote];

      when(() => mockDatabase.searchNotes('Complex'))
          .thenAnswer((_) async => notes);

      final result = await noteRepository.searchNotes('Complex');

      expect(result, hasLength(1));
      expect(result.first.title, contains('Complex'));
    });

    test('getNotesByCategory should return notes in category', () async {
      final notes = [TestFixtures.workNote, TestFixtures.personalNote];

      when(() => mockDatabase.getNotesByCategory('Work'))
          .thenAnswer((_) async => [TestFixtures.workNote]);

      final result = await noteRepository.getNotesByCategory('Work');

      expect(result, hasLength(1));
      expect(result.first.category, 'Work');
    });

    test('getPinnedNotes should return only pinned notes', () async {
      when(() => mockDatabase.getPinnedNotes())
          .thenAnswer((_) async => [TestFixtures.pinnedNote, TestFixtures.complexNote]);

      final result = await noteRepository.getPinnedNotes();

      expect(result, everyElement(
        isA<Note>().having((n) => n.isPinned, 'isPinned', true)
      ));
    });

    test('getFavoriteNotes should return only favorite notes', () async {
      when(() => mockDatabase.getFavoriteNotes())
          .thenAnswer((_) async => [TestFixtures.favoriteNote, TestFixtures.complexNote]);

      final result = await noteRepository.getFavoriteNotes();

      expect(result, everyElement(
        isA<Note>().having((n) => n.isFavorite, 'isFavorite', true)
      ));
    });

    test('note with todos should enrich with todo data', () async {
      final noteWithTodos = TestFixtures.complexNote;

      when(() => mockDatabase.getNoteById('note_2'))
          .thenAnswer((_) async => noteWithTodos);
      when(() => mockDatabase.getTodos(noteId: 'note_2'))
          .thenAnswer((_) async => TestFixtures.allTodos.sublist(0, 3));

      final result = await noteRepository.getNoteById('note_2');

      expect(result.todos, isNotNull);
      expect(result.todos, hasLength(3));
    });

    test('note with alarms should enrich with alarm data', () async {
      final noteWithAlarms = TestFixtures.complexNote;

      when(() => mockDatabase.getNoteById('note_2'))
          .thenAnswer((_) async => noteWithAlarms);
      when(() => mockDatabase.getAlarms())
          .thenAnswer((_) async => TestFixtures.allAlarms.sublist(0, 2));

      final result = await noteRepository.getNoteById('note_2');

      expect(result.alarms, isNotNull);
      expect(result.alarms, hasLength(2));
    });

    test('handle database errors gracefully', () async {
      when(() => mockDatabase.getNoteById('invalid'))
          .thenThrow(Exception('Database error'));

      expect(
        () => noteRepository.getNoteById('invalid'),
        throwsException,
      );
    });

    test('bulk operations should work', () async {
      final notes = TestFixtures.generateNotes(10);

      for (final note in notes) {
        when(() => mockDatabase.createNote(note)).thenAnswer((_) async {});
      }

      for (final note in notes) {
        await noteRepository.createNote(note);
        verify(() => mockDatabase.createNote(note)).called(1);
      }
    });
  });
}
