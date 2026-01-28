import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
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

/// Todos List Screen - Display all notes tagged as todos
/// Features: Quick voice entry, checkbox completion, filtering
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
  String _filterBy = 'all'; // all, active, completed

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission required'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isListening = false);
      return;
    }

    _speechService.startListening(
      onResult: (text) {
        setState(() {
          _todoController.text = text;
        });
      },
    );
  }

  void _stopVoiceInput() {
    _speechService.stopListening();
    setState(() => _isListening = false);
  }

  void _addQuickTodo() {
    if (_todoController.text.trim().isEmpty) return;

    // Create a new todo note with proper tags
    context.read<NotesBloc>().add(
      CreateNoteEvent(
        title: _todoController.text.trim(),
        content: '',
        tags: ['todo'], // Properly tag as todo
      ),
    );

    _todoController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Todo added successfully'),
        duration: Duration(seconds: 1),
        backgroundColor: AppColors.successColor,
      ),
    );
  }

  void _openFocusMode(Note? note) {
    if (note == null) {
      // Create a dummy note for focus mode without a specific todo
      final dummyNote = Note(
        id: 'temp',
        title: 'Focus Session',
        content: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TodoFocusScreen(note: dummyNote)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TodoFocusScreen(note: note)),
      );
    }
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<NotesBloc, NoteState>(
      listener: (context, state) {
        // Auto-refresh todos when notes change
        if (state is NoteCreated ||
            state is NoteUpdated ||
            state is NoteDeleted) {
          _loadTodos();
        }
      },
      child: _buildContent(isDark),
    );
  }

  Widget _buildContent(bool isDark) {
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
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
            icon: Icon(
              Icons.timer_outlined,
              color: isDark ? Colors.white : Colors.black,
            ),
            tooltip: 'Focus Mode (Pomodoro)',
            onPressed: () => _openFocusMode(null),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.filter_list,
              color: isDark ? Colors.white : Colors.black,
            ),
            onSelected: (value) {
              setState(() => _filterBy = value);
              _loadTodos();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Todos')),
              const PopupMenuItem(value: 'active', child: Text('Active')),
              const PopupMenuItem(value: 'completed', child: Text('Completed')),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Add Todo with Voice
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
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: const Icon(
                        Icons.add_task,
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkBackground
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
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

          // Todos List
          Expanded(
            child: BlocBuilder<NotesBloc, NoteState>(
              builder: (context, state) {
                if (state is NoteLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is NoteError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64.sp,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Error loading todos',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton(
                          onPressed: _loadTodos,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is NotesLoaded) {
                  final todos = state.notes
                      .where((note) => note.tags.contains('todo'))
                      .toList();
                  final filtered = _filterTodos(todos);

                  if (filtered.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.check_box_outlined,
                      title: _filterBy == 'all'
                          ? 'No todos yet'
                          : 'No $_filterBy todos',
                      subtitle: _filterBy == 'all'
                          ? 'Add your first todo above or use voice input'
                          : 'Create some todos to see them here',
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadTodos(),
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return _buildTodoCard(filtered[index], isDark);
                      },
                    ),
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

  List<Note> _filterTodos(List<Note> todos) {
    List<Note> filtered = todos;

    // Apply filter - use isArchived as completion status
    if (_filterBy == 'active') {
      filtered = todos.where((todo) => !todo.isArchived).toList();
    } else if (_filterBy == 'completed') {
      filtered = todos.where((todo) => todo.isArchived).toList();
    }

    // Sort by created date (default)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  Widget _buildTodoCard(Note todo, bool isDark) {
    final isCompleted = todo.isArchived; // Use isArchived as completion status

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Checkbox(
          value: isCompleted,
          onChanged: (value) {
            final updatedNote = todo.copyWith(
              isArchived: value ?? false,
              updatedAt: DateTime.now(),
            );
            context.read<NotesBloc>().add(UpdateNoteEvent(updatedNote));
          },
          activeColor: AppColors.successColor,
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            decoration: isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: isCompleted
                ? Colors.grey
                : (isDark ? Colors.white : Colors.black),
          ),
        ),
        subtitle: todo.content.isNotEmpty
            ? Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  todo.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
              )
            : null,
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: isDark ? Colors.white : Colors.black,
          ),
          onSelected: (value) {
            if (value == 'delete') {
              context.read<NotesBloc>().add(DeleteNoteEvent(todo.id));
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}

