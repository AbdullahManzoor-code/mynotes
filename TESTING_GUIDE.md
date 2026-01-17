# Testing Guide - MyNotes App

## Unit Tests

### Entity Tests

Create `test/domain/entities/note_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mynotes/domain/entities/note.dart';
import 'package:mynotes/domain/entities/media_item.dart';

void main() {
  group('Note Entity Tests', () {
    final testNote = Note(
      id: '1',
      title: 'Test Note',
      content: 'Test content',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('Note.copyWith updates fields', () {
      final updated = testNote.copyWith(title: 'Updated');
      
      expect(updated.title, 'Updated');
      expect(updated.id, '1');
    });

    test('Note.togglePin toggles pin status', () {
      expect(testNote.isPinned, false);
      
      final pinned = testNote.togglePin();
      expect(pinned.isPinned, true);
      
      final unpinned = pinned.togglePin();
      expect(unpinned.isPinned, false);
    });

    test('Note.addTag adds tag to tags list', () {
      final withTag = testNote.addTag('Important');
      
      expect(withTag.tags, contains('Important'));
      expect(testNote.tags, isEmpty); // Original unchanged
    });

    test('Note.removeTag removes tag from tags list', () {
      final withTag = testNote.addTag('Important');
      final withoutTag = withTag.removeTag('Important');
      
      expect(withoutTag.tags, isEmpty);
    });

    test('Note.completionPercentage calculates correctly', () {
      expect(testNote.completionPercentage, 0.0); // No todos
      
      // TODO: Test with todos once TodoItem added
    });
  });
}
```

## BLoC Tests

Create `test/presentation/bloc/note_bloc_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mynotes/presentation/bloc/note_bloc.dart';
import 'package:mynotes/presentation/bloc/note_event.dart';
import 'package:mynotes/presentation/bloc/note_state.dart';
import 'package:mynotes/domain/entities/note.dart';
import 'package:mocktail/mocktail.dart';

// Mock repository
class MockNoteRepository extends Mock implements NoteRepository {}

void main() {
  late NotesBloc notesBloc;
  late MockNoteRepository mockRepository;

  setUp(() {
    mockRepository = MockNoteRepository();
    notesBloc = NotesBloc(noteRepository: mockRepository);
  });

  tearDown(() {
    notesBloc.close();
  });

  group('NotesBloc', () {
    final testNote = Note(
      id: '1',
      title: 'Test',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    blocTest<NotesBloc, NoteState>(
      'emits [NoteLoading, NotesLoaded] when LoadNotesEvent is added',
      setUp: () {
        when(() => mockRepository.getNotes())
            .thenAnswer((_) async => [testNote]);
      },
      build: () => notesBloc,
      act: (bloc) => bloc.add(const LoadNotesEvent()),
      expect: () => [
        const NoteLoading(),
        NotesLoaded([testNote], totalCount: 1),
      ],
    );

    blocTest<NotesBloc, NoteState>(
      'emits [NoteLoading, NoteCreated] when CreateNoteEvent is added',
      setUp: () {
        when(() => mockRepository.createNote(any()))
            .thenAnswer((_) async => Future.value());
      },
      build: () => notesBloc,
      act: (bloc) => bloc.add(CreateNoteEvent('New Note')),
      expect: () => [
        const NoteLoading(),
        isA<NoteCreated>(),
      ],
    );

    blocTest<NotesBloc, NoteState>(
      'emits [NoteLoading, NoteDeleted] when DeleteNoteEvent is added',
      setUp: () {
        when(() => mockRepository.deleteNote(any()))
            .thenAnswer((_) async => Future.value());
      },
      build: () => notesBloc,
      act: (bloc) => bloc.add(DeleteNoteEvent('1')),
      expect: () => [
        NoteDeleted('1'),
      ],
    );

    blocTest<NotesBloc, NoteState>(
      'emits search results when SearchNotesEvent is added',
      setUp: () {
        when(() => mockRepository.getNotes())
            .thenAnswer((_) async => [testNote]);
      },
      build: () => notesBloc,
      act: (bloc) => bloc.add(SearchNotesEvent('Test')),
      expect: () => [
        isA<SearchResultsLoaded>(),
      ],
    );
  });
}
```

## Widget Tests

Create `test/presentation/widgets/note_card_widget_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mynotes/domain/entities/note.dart';
import 'package:mynotes/presentation/widgets/note_card_widget.dart';

void main() {
  late Note testNote;

  setUp(() {
    testNote = Note(
      id: '1',
      title: 'Test Note',
      content: 'Test content',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  });

  testWidgets('NoteCardWidget displays note title', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoteCardWidget(
            note: testNote,
            onTap: () {},
            onLongPress: () {},
            onDelete: () {},
            onPin: () {},
            onColorChange: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Test Note'), findsOneWidget);
  });

  testWidgets('NoteCardWidget shows selection indicator when selected', 
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoteCardWidget(
            note: testNote,
            isSelected: true,
            onTap: () {},
            onLongPress: () {},
            onDelete: () {},
            onPin: () {},
            onColorChange: (_) {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('NoteCardWidget calls onTap when tapped',
      (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoteCardWidget(
            note: testNote,
            onTap: () => tapped = true,
            onLongPress: () {},
            onDelete: () {},
            onPin: () {},
            onColorChange: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(NoteCardWidget));
    expect(tapped, true);
  });

  testWidgets('NoteCardWidget calls onDelete when delete is tapped',
      (WidgetTester tester) async {
    bool deleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoteCardWidget(
            note: testNote,
            onTap: () {},
            onLongPress: () {},
            onDelete: () => deleted = true,
            onPin: () {},
            onColorChange: (_) {},
          ),
        ),
      ),
    );

    // Open popup menu
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    // Tap delete
    await tester.tap(find.text('Delete'));
    expect(deleted, true);
  });
}
```

## Integration Tests

Create `test_driver/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mynotes/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MyNotes App Integration Tests', () {
    testWidgets('Create note and verify it appears', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap create note button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Enter title
      await tester.tap(find.byType(TextField).first);
      await tester.typeText(find.byType(TextField).first, 'Test Note');

      // Enter content
      await tester.tap(find.byType(TextField).last);
      await tester.typeText(find.byType(TextField).last, 'Test content');

      // Save
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      // Verify note appears
      expect(find.text('Test Note'), findsOneWidget);
    });

    testWidgets('Search for note', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Open search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Search
      await tester.typeText(find.byType(TextField), 'Test');
      await tester.pumpAndSettle();

      // Should find results
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Delete note', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find note card and long press
      await tester.longPress(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Delete
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Confirm
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Should see empty state
      expect(find.text('No Notes Yet'), findsOneWidget);
    });
  });
}
```

## Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/domain/entities/note_test.dart

# Run with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart

# Run on specific device
flutter test -d chrome
```

## Test Coverage

Generate coverage report:

```bash
# Generate coverage
flutter test --coverage

# View in browser (macOS/Linux)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# View in browser (Windows)
genhtml coverage/lcov.info -o coverage/html
# Then open coverage/html/index.html in browser
```

## Best Practices

### ✅ DO
- ✅ Test business logic (entities, BLoCs)
- ✅ Test user interactions
- ✅ Use meaningful test names
- ✅ Keep tests focused (one thing per test)
- ✅ Mock external dependencies
- ✅ Test error cases
- ✅ Maintain >80% code coverage

### ❌ DON'T
- ❌ Test implementation details
- ❌ Skip testing edge cases
- ❌ Create flaky tests
- ❌ Ignore test failures
- ❌ Test UI details (colors, fonts)
- ❌ Skip error scenarios
- ❌ Write tests after code is broken

## Continuous Integration

Add to `.github/workflows/test.yml`:

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v2
```

---

**Happy Testing! 🧪**
