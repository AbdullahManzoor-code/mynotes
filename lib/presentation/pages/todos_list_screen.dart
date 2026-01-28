import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:ui';
import '../../core/services/speech_service.dart';
import '../../domain/entities/note.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_state.dart';
import '../bloc/note_event.dart';
import '../design_system/design_system.dart';
import '../widgets/empty_state_todos.dart' as widgets;
import 'advanced_todo_screen.dart';
import 'recurring_todo_schedule_screen.dart';
import 'empty_state_todos_help_screen.dart';
import 'settings_screen.dart';
import 'enhanced_note_editor_screen.dart';

/// Todos List Screen - Display all notes tagged as todos
/// Features: Quick voice entry, checkbox completion, filtering
class TodosListScreen extends StatefulWidget {
  const TodosListScreen({super.key});

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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EnhancedNoteEditorScreen(note: note)),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocListener<NotesBloc, NoteState>(
      listener: (context, state) {
        if (state is NoteCreated ||
            state is NoteUpdated ||
            state is NoteDeleted) {
          _loadTodos();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: Stack(
          children: [
            // Main content
            CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                _buildFilterSection(),
                _buildTodoListSection(),
                SliverToBoxAdapter(child: SizedBox(height: 200.h)),
              ],
            ),

            // Floating quick add at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildQuickAddSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.background(context).withOpacity(0.8),
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Tasks',
            style: AppTypography.heading1(null, null, FontWeight.bold),
          ),
          Text(
            'Stay focused and productive',
            style: AppTypography.caption(null, AppColors.textMuted, null),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.timer_outlined, size: 24.sp),
          onPressed: () => _openFocusMode(null),
          tooltip: 'Focus Mode',
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AppColors.primary),
          onSelected: (value) => _handleTodosMenu(value),
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'recurring',
              child: Row(
                children: [
                  Icon(Icons.repeat, size: 20),
                  SizedBox(width: 12),
                  Text('Recurring Tasks'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'advanced',
              child: Row(
                children: [
                  Icon(Icons.dashboard, size: 20),
                  SizedBox(width: 12),
                  Text('Advanced View'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'help',
              child: Row(
                children: [
                  Icon(Icons.help, size: 20),
                  SizedBox(width: 12),
                  Text('Getting Started'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, size: 20),
                  SizedBox(width: 12),
                  Text('Settings'),
                ],
              ),
            ),
          ],
        ),
      ],
      elevation: 0,
    );
  }

  Widget _buildQuickAddSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background(context).withOpacity(0),
            AppColors.background(context),
          ],
        ),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 40.h, 16.w, 20.h),
      child: GlassContainer(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _todoController,
                style: AppTypography.bodyLarge(null, null, FontWeight.w500),
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "What's on your mind?",
                  hintStyle: AppTypography.bodyLarge(
                    null,
                    AppColors.textMuted.withOpacity(0.5),
                    FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                ),
                onSubmitted: (_) => _addQuickTodo(),
              ),
            ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: _isListening ? _stopVoiceInput : _startVoiceInput,
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: _isListening
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.surface(context).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Icon(
                  Icons.mic,
                  size: 24.sp,
                  color: _isListening ? AppColors.primary : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final filters = [
      {'id': 'all', 'label': 'All'},
      {'id': 'active', 'label': 'Active'},
      {'id': 'completed', 'label': 'Done'},
    ];

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingHorizontal,
        vertical: 12.h,
      ),
      sliver: SliverToBoxAdapter(
        child: Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: AppColors.surface(context).withOpacity(0.5),
            borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
          ),
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: filters.map((f) {
              final isSelected = _filterBy == f['id'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _filterBy = f['id']!),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.surface(context)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      f['label']!,
                      style: AppTypography.bodySmall(
                        null,
                        isSelected ? AppColors.primary : AppColors.textMuted,
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTodoListSection() {
    return BlocBuilder<NotesBloc, NoteState>(
      builder: (context, state) {
        if (state is NoteLoading) {
          return const SliverFillRemaining(
            child: Center(child: AppLoadingIndicator()),
          );
        }
        if (state is NotesLoaded) {
          final todos = state.notes
              .where((n) => n.tags.contains('todo'))
              .toList();

          // Show empty state if no todos at all
          if (todos.isEmpty && _filterBy == 'all') {
            return SliverFillRemaining(child: widgets.EmptyStateTodos());
          }

          final filtered = _filterTodos(todos);

          if (filtered.isEmpty) {
            return SliverFillRemaining(
              child: Padding(
                padding: EdgeInsets.only(bottom: 100.h),
                child: EmptyStateWidget(
                  icon: Icons.check_circle_outline,
                  title: 'All caught up!',
                  description: 'No tasks to show for this filter.',
                ),
              ),
            );
          }

          return SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildTodoItem(filtered[index]),
                childCount: filtered.length,
              ),
            ),
          );
        }

        if (state is NoteError) {
          return SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading tasks',
                    style: AppTypography.heading3(
                      context,
                      AppColors.textPrimary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: AppTypography.bodyMedium(
                      context,
                      AppColors.textSecondary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotesBloc>().add(const LoadNotesEvent());
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return const SliverFillRemaining(
          child: Center(child: Text('Error loading tasks')),
        );
      },
    );
  }

  Widget _buildTodoItem(Note todo) {
    final isCompleted = todo.tags.contains('completed');
    return CardContainer(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      onTap: () => _openFocusMode(todo),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleTodoStatus(todo),
            child: Container(
              width: 24.r,
              height: 24.r,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.successColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: isCompleted
                      ? AppColors.successColor
                      : AppColors.divider(context),
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? Icon(Icons.check, size: 16.r, color: Colors.white)
                  : null,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              todo.title,
              style:
                  AppTypography.bodyMedium(
                    context,
                    isCompleted
                        ? AppColors.textSecondary(context)
                        : AppColors.textPrimary(context),
                  ).copyWith(
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
            ),
          ),
          AppIconButton(icon: Icons.more_vert, onPressed: () {}, size: 20),
        ],
      ),
    );
  }

  void _toggleTodoStatus(Note todo) {
    final tags = List<String>.from(todo.tags);
    if (tags.contains('completed')) {
      tags.remove('completed');
    } else {
      tags.add('completed');
    }
    context.read<NotesBloc>().add(UpdateNoteEvent(todo.copyWith(tags: tags)));
  }

  List<Note> _filterTodos(List<Note> notes) {
    if (_filterBy == 'all') return notes;
    if (_filterBy == 'completed') {
      return notes.where((n) => n.tags.contains('completed')).toList();
    }
    // active (not completed)
    return notes.where((n) => !n.tags.contains('completed')).toList();
  }

  void _handleTodosMenu(String value) {
    switch (value) {
      case 'recurring':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const RecurringTodoScheduleScreen(),
          ),
        );
        break;
      case 'advanced':
        // Create a blank note for advanced todo view
        final blankNote = Note(
          id: DateTime.now().toString(),
          title: '',
          content: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          tags: ['todo'],
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdvancedTodoScreen(note: blankNote),
          ),
        );
        break;
      case 'help':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EmptyStateTodosHelpScreen()),
        );
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        break;
    }
  }
}
