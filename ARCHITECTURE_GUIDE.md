# Architecture & Setup Guide

## 🏗️ Clean Architecture Overview

This app follows **clean architecture** principles for maintainability and testability.

### Three Layers

```
┌─────────────────────────────────────┐
│     PRESENTATION LAYER              │
│  (UI, BLoC, State Management)       │
└──────────────────┬──────────────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│     DOMAIN LAYER                    │
│  (Entities, Repositories Abstract)  │
└──────────────────┬──────────────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│     DATA LAYER                      │
│  (Repositories Impl, DataSources)   │
└─────────────────────────────────────┘
```

### Layer Responsibilities

#### 🎨 Presentation Layer
**Location:** `lib/presentation/`

Responsible for:
- Displaying UI to users
- Handling user interactions
- Managing screen state with BLoC
- Navigation

**Key Files:**
```
presentation/
├── bloc/              # BLoC pattern implementation
│   ├── note_bloc.dart
│   ├── note_event.dart
│   ├── note_state.dart
│   ├── media_bloc.dart
│   └── media_event.dart
│
├── pages/             # Full-screen pages
│   ├── home_page.dart
│   └── note_editor_page.dart
│
└── widgets/           # Reusable UI components
    ├── note_card_widget.dart
    ├── media_item_widget.dart
    └── empty_state_widget.dart
```

**BLoC Pattern Flow:**
```
User Action
    ↓
UI calls BLoC.add(Event)
    ↓
BLoC processes Event
    ↓
BLoC calls Repository
    ↓
Repository returns data
    ↓
BLoC emits State
    ↓
UI rebuilds based on State
```

#### 🧠 Domain Layer
**Location:** `lib/domain/`

Contains:
- **Entities** - Core business objects (independent of UI/DB)
- **Repository Interfaces** - Contracts for data access
- **Use Cases** - Optional business logic operations

**Key Files:**
```
domain/
├── entities/          # Pure Dart classes
│   ├── note.dart      # Note entity
│   ├── media_item.dart
│   ├── todo_item.dart
│   └── alarm.dart
│
└── repositories/      # Abstract interfaces
    ├── note_repository.dart
    └── media_repository.dart
```

**Entity Example:**
```dart
// Pure Dart, no dependencies
// Independent of UI/Database/API
class Note extends Equatable {
  final String id;
  final String title;
  final String content;
  final List<MediaItem> mediaItems;
  
  // Business logic methods
  bool get hasMedia => mediaItems.isNotEmpty;
  
  Note copyWith({...}) { ... }
  Note addTag(String tag) { ... }
  
  @override
  List<Object?> get props => [id, title, content, mediaItems];
}
```

#### 💾 Data Layer
**Location:** `lib/data/`

Responsible for:
- **Models** - Convert entities to/from JSON (for DB/API)
- **Data Sources** - Access local database or remote API
- **Repositories** - Implement domain interfaces, coordinate data sources

**Key Files:**
```
data/
├── models/            # JSON serialization
│   └── note_model.dart
│
├── datasources/       # Data access
│   └── local_datasource.dart
│
└── repositories/      # Implement interfaces
    └── note_repository_impl.dart
```

**Model vs Entity:**
```dart
// Domain (Pure business logic)
class Note {
  final String id;
  final String title;
  
  bool get hasMedia => mediaItems.isNotEmpty;
}

// Data (JSON serialization)
class NoteModel extends Note {
  NoteModel.fromJson(Map<String, dynamic> json)
    : super(
        id: json['id'],
        title: json['title'],
      );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
  };
}
```

### Dependency Injection

Setup in `main.dart`:

```dart
void main() async {
  // Initialize services
  await NotificationService().initialize();
  
  runApp(
    MultiRepositoryProvider(
      providers: [
        // Register repositories
        RepositoryProvider<MediaRepository>(
          create: (_) => MediaRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // Register BLoCs
          BlocProvider<MediaBloc>(
            create: (context) => MediaBloc(
              repository: context.read<MediaRepository>(),
            ),
          ),
        ],
        child: MaterialApp(...),
      ),
    ),
  );
}
```

## 🎯 BLoC Deep Dive

### Event → State Flow

```dart
// 1. Define Event
class CreateNoteEvent extends NoteEvent {
  final String title;
  const CreateNoteEvent(this.title);
}

// 2. Define State
class NoteCreated extends NoteState {
  final Note note;
  const NoteCreated(this.note);
}

// 3. Handle in BLoC
class NotesBloc extends Bloc<NoteEvent, NoteState> {
  NotesBloc() : super(NoteInitial()) {
    on<CreateNoteEvent>(_onCreateNote);
  }
  
  Future<void> _onCreateNote(
    CreateNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      emit(NoteLoading());
      
      final newNote = Note(
        id: generateId(),
        title: event.title,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _repository.createNote(newNote);
      emit(NoteCreated(newNote));
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }
}

// 4. Listen in UI
BlocBuilder<NotesBloc, NoteState>(
  builder: (context, state) {
    if (state is NoteCreated) {
      return Text('Note created!');
    }
    return Text('Initial state');
  },
)
```

### Why BLoC?

✅ **Separation of Concerns**
```dart
// UI doesn't know about business logic
// Business logic doesn't know about widgets
// Easy to test each independently
```

✅ **Reactive Programming**
```dart
// Streams handle state changes
// Multiple listeners can react to same event
// Automatic UI updates
```

✅ **Testable**
```dart
test('CreateNoteEvent emits NoteCreated state', () {
  final repository = MockNoteRepository();
  final bloc = NotesBloc(repository: repository);
  
  expect(
    bloc.stream,
    emitsInOrder([
      NoteLoading(),
      NoteCreated(testNote),
    ]),
  );
  
  bloc.add(CreateNoteEvent('Test'));
});
```

## 📱 UI Architecture

### Widget Hierarchy

```
MaterialApp
  └── Scaffold
      ├── AppBar
      ├── BlocBuilder<NotesBloc>
      │   └── GridView
      │       └── NoteCardWidget (x multiple)
      │           ├── Title
      │           ├── Preview
      │           ├── Metadata
      │           └── Actions
      └── FloatingActionButton
```

### Responsive Widget Pattern

```dart
// Pattern 1: Use ResponsiveUtils
Widget build(BuildContext context) {
  return ResponsiveUtils.responsive(
    context,
    mobile: MobileLayout(),
    tablet: TabletLayout(),
    desktop: DesktopLayout(),
  );
}

// Pattern 2: Use LayoutBuilder
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 600) {
        return MobileLayout();
      } else {
        return TabletLayout();
      }
    },
  );
}

// Pattern 3: Use GridView.builder with dynamic columns
final columns = ResponsiveUtils.getGridColumns(context);
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: columns,
  ),
  itemBuilder: ...
)
```

## 🗄️ Database Schema

### Notes Table
```sql
CREATE TABLE notes (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT,
  color INTEGER,
  is_pinned INTEGER DEFAULT 0,
  is_archived INTEGER DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

### Media Items Table
```sql
CREATE TABLE media_items (
  id TEXT PRIMARY KEY,
  note_id TEXT NOT NULL,
  type TEXT NOT NULL,      -- 'image', 'audio', 'video'
  file_path TEXT NOT NULL,
  thumbnail_path TEXT,
  duration_ms INTEGER,
  file_size INTEGER,
  created_at TEXT NOT NULL,
  FOREIGN KEY(note_id) REFERENCES notes(id)
);
```

### Todo Items Table
```sql
CREATE TABLE todo_items (
  id TEXT PRIMARY KEY,
  note_id TEXT NOT NULL,
  title TEXT NOT NULL,
  is_completed INTEGER DEFAULT 0,
  order_index INTEGER,
  created_at TEXT NOT NULL,
  completed_at TEXT,
  FOREIGN KEY(note_id) REFERENCES notes(id)
);
```

### Alarms Table
```sql
CREATE TABLE alarms (
  id TEXT PRIMARY KEY,
  note_id TEXT NOT NULL,
  alarm_time TEXT NOT NULL,
  is_active INTEGER DEFAULT 1,
  repeat_type TEXT,        -- 'none', 'daily', 'weekly', 'monthly'
  message TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY(note_id) REFERENCES notes(id)
);
```

## 🔄 State Management Flow

### Create Note Flow

```
HomePage
  ├─ FloatingActionButton pressed
  ├─ Navigate to NoteEditorPage
  │
  └─ NoteEditorPage
     ├─ User enters title & content
     ├─ User taps Save
     ├─ BlocBuilder receives:
     │  ├─ CreateNoteEvent
     │  ├─ NoteLoading (show spinner)
     │  ├─ Repository creates note
     │  ├─ NoteCreated (show success)
     │  └─ Navigate back
     │
     └─ HomePage rebuilds with new note
```

### Update Note with Media

```
NoteEditorPage
  ├─ User taps "Add Image"
  ├─ Image picker shows
  ├─ User selects image
  │
  ├─ BlocBuilder<MediaBloc> receives:
  │  ├─ AddImageToNoteEvent
  │  ├─ MediaLoading
  │  ├─ ImageCompressor compresses
  │  ├─ Save to file system
  │  ├─ MediaAdded (show preview)
  │  └─ Update UI
  │
  └─ Preview shown to user
```

## 🚀 Performance Optimization

### Image Loading
```dart
// Use cached image with compression
CachedNetworkImage(
  imageUrl: mediaItem.thumbnailPath,
  placeholder: (context, url) => Shimmer.fromColors(...),
  errorWidget: (context, url, error) => Icon(Icons.error),
);
```

### Lazy Loading
```dart
// Load notes on demand, not all at once
ListView.builder(
  itemCount: notes.length,
  itemBuilder: (context, index) {
    return NoteCardWidget(note: notes[index]);
  },
)
```

### Memory Management
```dart
// Close streams and controllers
@override
void dispose() {
  _controller.dispose();
  _subscription.cancel();
  super.dispose();
}

// Limit cached items
class NoteCache {
  static const maxSize = 100;
  final _cache = <String, Note>{};
}
```

## 🧪 Testing Strategy

### Unit Tests
```dart
test('Note.addTag adds tag to tags list', () {
  final note = Note(id: '1', title: 'Test', tags: []);
  final updated = note.addTag('Important');
  
  expect(updated.tags, contains('Important'));
});
```

### Widget Tests
```dart
testWidgets('NoteCardWidget displays title', (WidgetTester tester) async {
  const note = Note(id: '1', title: 'Test Note');
  
  await tester.pumpWidget(
    MaterialApp(home: NoteCardWidget(note: note))
  );
  
  expect(find.text('Test Note'), findsOneWidget);
});
```

### BLoC Tests
```dart
blocTest<NotesBloc, NoteState>(
  'emits [NoteLoading, NoteCreated] when CreateNoteEvent is added',
  build: () => NotesBloc(repository: mockRepository),
  act: (bloc) => bloc.add(CreateNoteEvent('Test')),
  expect: () => [
    NoteLoading(),
    NoteCreated(testNote),
  ],
);
```

## 📚 Best Practices

### ✅ DO
- ✅ Keep entities pure (no dependencies)
- ✅ Use BLoC for state management
- ✅ One BLoC per feature
- ✅ Use repository pattern
- ✅ Extract reusable widgets
- ✅ Use const constructors
- ✅ Handle errors gracefully
- ✅ Test business logic

### ❌ DON'T
- ❌ Mix UI logic with business logic
- ❌ Store raw bytes in database
- ❌ Use StatefulWidget for everything
- ❌ Block UI thread with synchronous operations
- ❌ Ignore permission requests
- ❌ Load huge images uncompressed
- ❌ Leave BLoCs open (dispose properly)
- ❌ Skip error handling

## 🔗 File References

### Core Files
- `lib/core/themes/app_theme.dart` - Centralized theming
- `lib/core/constants/app_constants.dart` - App-wide constants
- `lib/core/utils/responsive_utils.dart` - Responsive design helpers

### Media Files
- `lib/core/media/image_compressor.dart` - Image compression logic
- `lib/core/media/video_compressor.dart` - Video compression logic

### Service Files
- `lib/core/notifications/notification_service.dart` - Notifications
- `lib/core/pdf/pdf_export_service.dart` - PDF generation

### Architecture Files
- `lib/domain/entities/note.dart` - Core Note entity
- `lib/domain/repositories/note_repository.dart` - Interface
- `lib/data/repositories/note_repository_impl.dart` - Implementation

### Presentation Files
- `lib/presentation/bloc/note_bloc.dart` - Note BLoC
- `lib/presentation/pages/home_page.dart` - Home screen
- `lib/presentation/pages/note_editor_page.dart` - Edit screen
- `lib/presentation/widgets/note_card_widget.dart` - Note card

---

**This architecture ensures:**
✅ Scalability - Easy to add features
✅ Maintainability - Clear code organization
✅ Testability - Isolated layers
✅ Reusability - Shared components
✅ Performance - Optimized media handling
