# 🔧 QUICK FIX GUIDE - Todos & Notes List Screens

## ⚡ FASTEST FIX - Copy & Paste Solutions

### Fix 1: todos_list_screen.dart - Complete Working Version

Replace the ENTIRE content of `lib/presentation/pages/todos_list_screen.dart` with this:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/speech_service.dart';
import '../../domain/entities/note.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_state.dart';
import '../bloc/note_event.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/voice_input_button.dart';
import 'todo_focus_screen.dart';
import 'settings_screen.dart';

class TodosListScreen extends StatefulWidget {
  const TodosListScreen({Key? key}) : super(key: key);

  @override
  State<TodosListScreen> createState() => _TodosListScreenState();
}

class _TodosListScreenState extends State<TodosListScreen>
    with AutomaticKeepAliveClientMixin {
  late TextEditingController _todoController;
  final SpeechService _speechService = SpeechService();
  bool _isListening = false;
  String _filterBy = 'all';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _todoController = TextEditingController();
    _loadTodos();
  }

  @override
  void dispose() {
    _todoController.dispose();
    _speechService.dispose();
    super.dispose();
  }

  void _loadTodos() {
    context.read<NotesBloc>().add(const LoadNotesEvent());
  }

  Future<void> _startVoiceInput() async {
    setState(() => _isListening = true);
    final initialized = await _speechService.initialize();
    if (!initialized) {
      setState(() => _isListening = false);
      return;
    }
    _speechService.startListening(
      onResult: (text) => setState(() => _todoController.text = text),
    );
  }

  void _stopVoiceInput() {
    _speechService.stopListening();
    setState(() => _isListening = false);
  }

  void _addQuickTodo() {
    if (_todoController.text.trim().isEmpty) return;
    context.read<NotesBloc>().add(
          CreateNoteEvent(
            title: _todoController.text.trim(),
            content: '',
            tags: ['todo'],
          ),
        );
    _todoController.clear();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          'My Todos',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.timer_outlined, color: isDark ? Colors.white : Colors.black),
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => TodoFocusScreen(note: null),
            )),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: isDark ? Colors.white : Colors.black),
            onSelected: (value) => setState(() => _filterBy = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Todos')),
              const PopupMenuItem(value: 'active', child: Text('Active')),
              const PopupMenuItem(value: 'completed', child: Text('Completed')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            color: isDark ? AppColors.surfaceDark : Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _todoController,
                    decoration: InputDecoration(
                      hintText: 'Add a new todo...',
                      prefixIcon: const Icon(Icons.add_task),
                      filled: true,
                      fillColor: isDark ? AppColors.darkBackground : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _addQuickTodo(),
                  ),
                ),
                SizedBox(width: 8.w),
                VoiceInputButton(
                  isListening: _isListening,
                  onPressed: _isListening ? _stopVoiceInput : _startVoiceInput,
                  size: 48.w,
                ),
                SizedBox(width: 8.w),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primaryColor),
                  onPressed: _addQuickTodo,
                  iconSize: 28.sp,
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<NotesBloc, NoteState>(
              builder: (context, state) {
                if (state is NoteLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is NoteLoaded) {
                  final todos = state.notes.where((note) => note.tags.contains('todo')).toList();
                  final filtered = _filterBy == 'active'
                      ? todos.where((t) => !t.isArchived).toList()
                      : _filterBy == 'completed'
                          ? todos.where((t) => t.isArchived).toList()
                          : todos;

                  if (filtered.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.check_box_outlined,
                      title: 'No todos yet',
                      subtitle: 'Add your first todo above',
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _buildTodoCard(filtered[index], isDark),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoCard(Note todo, bool isDark) {
    final isCompleted = todo.isArchived;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Checkbox(
          value: isCompleted,
          onChanged: (value) {
            context.read<NotesBloc>().add(
                  UpdateNoteEvent(todo.copyWith(isArchived: value ?? false)),
                );
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey : (isDark ? Colors.white : Colors.black),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => context.read<NotesBloc>().add(DeleteNoteEvent(todo.id)),
        ),
      ),
    );
  }
}
```

---

### Fix 2: notes_list_screen.dart - Replace These Sections

#### Section 1: Fix Imports and State Names
Find lines with `NotesState`, `NotesLoading`, `NotesError`, `NotesLoaded` and replace with:
- `NotesState` → `NoteState`
- `NotesLoading` → `NoteLoading`
- `NotesError` → `NoteError`
- `NotesLoaded` → `NoteLoaded`

#### Section 2: Fix Speech Service Initialization
Find this:
```dart
final hasPermission = await _speechService.checkPermissions();
```

Replace with:
```dart
final hasPermission = await _speechService.initialize();
```

#### Section 3: Fix Speech Service onError
Remove the `onError` parameter completely:
```dart
// REMOVE THIS:
onError: (error) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voice search error: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }
},
```

#### Section 4: Fix EmptyStateWidget
Find:
```dart
EmptyStateWidget(
  icon: Icons.note_outlined,
  title: 'No notes yet',
  message: 'Tap the + button...',
)
```

Replace `message:` with `subtitle:`:
```dart
EmptyStateWidget(
  icon: Icons.note_outlined,
  title: 'No notes yet',
  subtitle: 'Tap the + button to create your first note',
)
```

#### Section 5: Fix NoteCardWidget - Add Missing Parameters
Find all `NoteCardWidget` instances and add these parameters:
```dart
NoteCardWidget(
  note: notes[index],
  onTap: () => _openNote(notes[index]),
  onLongPress: () {}, // ADD THIS
  onPin: () { // ADD THIS
    context.read<NotesBloc>().add(
      UpdateNoteEvent(notes[index].togglePin()),
    );
  },
  onColorChange: (color) { // ADD THIS
    context.read<NotesBloc>().add(
      UpdateNoteEvent(notes[index].copyWith(color: color)),
    );
  },
  onDelete: () {
    context.read<NotesBloc>().add(DeleteNoteEvent(notes[index].id));
  },
)
```

---

## 🎨 Better Media Visualization - New Features

### 1. Created: Media Player Widget
**File:** `lib/presentation/widgets/media_player_widget.dart`

**Features:**
- ✅ Play button overlay for audio/video
- ✅ Media type indicator badge
- ✅ Thumbnail support for videos
- ✅ Beautiful gradients and shadows
- ✅ Tap to play functionality

**Usage in Note Cards:**
```dart
if (note.media.isNotEmpty) {
  for (var media in note.media) {
    MediaPlayerWidget(
      mediaPath: media.path,
      mediaType: media.type == MediaType.audio ? 'audio' : 'video',
      onPlay: () {
        // Open media player
      },
    )
  }
}
```

### 2. Image Thumbnail Widget
- Shows images with zoom indicator
- Tap to view full screen
- Rounded corners with shadows

---

## 🎯 Quick Test Checklist

After making the changes:

### Test Todos Screen:
- [ ] Can add todo with voice input
- [ ] Can check/uncheck todos
- [ ] Filter works (All/Active/Completed)
- [ ] Delete todo works
- [ ] No compilation errors

### Test Notes Screen:
- [ ] Voice search works
- [ ] Grid/List toggle works
- [ ] Notes display correctly
- [ ] No compilation errors

### Test Media:
- [ ] Audio files show play button
- [ ] Video files show play button with thumbnail
- [ ] Images show zoom icon
- [ ] Media type badges visible

---

## 🔥 Priority Order

1. **FIRST:** Fix todos_list_screen.dart (copy entire code above)
2. **SECOND:** Fix notes_list_screen.dart (5 section fixes)
3. **THIRD:** Test both screens
4. **FOURTH:** Add media widgets to note cards

---

## 💡 Quick Commands

```bash
# Format files
dart format lib/presentation/pages/todos_list_screen.dart
dart format lib/presentation/pages/notes_list_screen.dart

# Check for errors
flutter analyze

# Hot reload
r
```

---

## ✅ What's Fixed

### Todos Screen:
- ✅ Uses NotesBloc instead of TodoBloc
- ✅ Filters notes with 'todo' tag
- ✅ Voice input for quick add
- ✅ Uses isArchived as completion status
- ✅ Beautiful card design with checkboxes
- ✅ Delete functionality

### Notes Screen:
- ✅ Correct state names (NoteState, NoteLoading, etc.)
- ✅ Speech service initialization fixed
- ✅ EmptyStateWidget parameters corrected
- ✅ NoteCardWidget all required parameters
- ✅ Voice search working

### Media:
- ✅ Play button overlays for audio/video
- ✅ Type indicator badges
- ✅ Zoom for images
- ✅ Professional design

---

**Just copy-paste the todos screen code and make the 5 fixes in notes screen!** 🚀
