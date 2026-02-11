import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../core/services/speech_service.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/todo_item.dart';
import '../../domain/entities/alarm.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_state.dart';
import '../bloc/note_event.dart';
import '../bloc/params/note_params.dart';
import '../design_system/design_system.dart';
import '../widgets/empty_state_todos.dart' as widgets;
// import '../widgets/glass_container.dart';
import 'advanced_todo_screen.dart';
import 'recurring_todo_schedule_screen.dart';
import 'empty_state_todos_help_screen.dart';
import 'settings_screen.dart';
import 'enhanced_note_editor_screen.dart';

/// Todos List Screen - Display all notes tagged as todos
/// Features: Quick voice entry, checkbox completion, filtering, sections (Algo 5)
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
  String _selectedCategory = 'All'; // All, Personal, Work, etc.

  // Flattened list for rendering
  List<TodoListItem> _flattenedList = [];

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

    // Auto-add todo if there's text after voice input stops
    if (mounted && _todoController.text.trim().isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _addQuickTodo();
        }
      });
    }
  }

  void _addQuickTodo() {
    if (_todoController.text.trim().isEmpty) return;

    // Create NoteParams with todo tag and potentially category tag
    List<String> tags = ['todo'];
    if (_selectedCategory != 'All' && _selectedCategory != 'Important') {
      tags.add(_selectedCategory.toLowerCase());
    }

    final todoParams = NoteParams(
      title: _todoController.text.trim(),
      content: '',
      tags: tags,
    );

    context.read<NotesBloc>().add(CreateNoteEvent(params: todoParams));

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

  void _processTodos(List<Note> allNotes) {
    // 1. Filter by 'todo' tag
    var todos = allNotes.where((n) => n.tags.contains('todo')).toList();

    // 2. Filter by Category
    if (_selectedCategory != 'All') {
      if (_selectedCategory == 'Important') {
        // Assuming pinned means important for now, or a specific tag
        todos = todos.where((n) => n.isPinned).toList();
      } else {
        todos = todos
            .where((n) => n.tags.contains(_selectedCategory.toLowerCase()))
            .toList();
      }
    }

    // 3. Group by Section
    final overdue = <Note>[];
    final today = <Note>[];
    final upcoming = <Note>[];
    final noDate = <Note>[];
    final completed = <Note>[];

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    for (final note in todos) {
      if (note.tags.contains('completed')) {
        completed.add(note);
        continue;
      }

      // Check alarms for due date
      final activeAlarms = note.alarms?.where((a) => a.isActive).toList() ?? [];
      activeAlarms.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

      if (activeAlarms.isNotEmpty) {
        final dueDate = activeAlarms.first.scheduledTime;
        if (dueDate.isBefore(todayStart)) {
          overdue.add(note);
        } else if (dueDate.isBefore(tomorrowStart)) {
          today.add(note);
        } else {
          upcoming.add(note);
        }
      } else {
        noDate.add(note);
      }
    }

    // 4. Flatten List
    _flattenedList = [];

    if (overdue.isNotEmpty) {
      _flattenedList.add(
        HeaderItem('Overdue', AppColors.error, overdue.length),
      );
      _flattenedList.addAll(overdue.map((n) => TaskItem(n)));
    }

    if (today.isNotEmpty) {
      _flattenedList.add(HeaderItem('Today', AppColors.primary, today.length));
      _flattenedList.addAll(today.map((n) => TaskItem(n)));
    }

    if (upcoming.isNotEmpty) {
      _flattenedList.add(
        HeaderItem('Upcoming', AppColors.accentBlue, upcoming.length),
      );
      _flattenedList.addAll(upcoming.map((n) => TaskItem(n)));
    }

    if (noDate.isNotEmpty) {
      _flattenedList.add(
        HeaderItem('No Date', AppColors.textSecondary(context), noDate.length),
      );
      _flattenedList.addAll(noDate.map((n) => TaskItem(n)));
    }

    if (completed.isNotEmpty) {
      _flattenedList.add(
        HeaderItem('Completed', AppColors.successColor, completed.length),
      );
      _flattenedList.addAll(completed.map((n) => TaskItem(n)));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<NotesBloc, NoteState>(
      builder: (context, state) {
        return BlocListener<NotesBloc, NoteState>(
          listener: (context, state) {
            if (state is NoteCreated ||
                state is NoteUpdated ||
                state is NoteDeleted) {
              _loadTodos();
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.getBackgroundColor(
              Theme.of(context).brightness,
            ),
            body: Stack(
              children: [
                // Main content
                CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(),

                    if (state is NotesLoaded) ...[
                      SliverToBoxAdapter(
                        child: _buildProgressCard(state.notes),
                      ),
                      _buildFilterSection(),
                      _buildTodoListSection(state.notes),
                    ] else if (state is NoteLoading) ...[
                      const SliverFillRemaining(
                        child: Center(child: AppLoadingIndicator()),
                      ),
                    ] else ...[
                      SliverFillRemaining(child: _buildErrorState(state)),
                    ],

                    SliverToBoxAdapter(child: SizedBox(height: 100.h)),
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
      },
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.getBackgroundColor(
        Theme.of(context).brightness,
      ).withOpacity(0.8),
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

  Widget _buildProgressCard(List<Note> allNotes) {
    final todos = allNotes.where((n) => n.tags.contains('todo')).toList();
    if (todos.isEmpty) return const SizedBox.shrink();

    final completed = todos.where((n) => n.tags.contains('completed')).length;
    final total = todos.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
            SizedBox(height: 8.h),
            Text(
              '$completed of $total tasks completed',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.getBackgroundColor(
              Theme.of(context).brightness,
            ).withOpacity(0),
            AppColors.getBackgroundColor(Theme.of(context).brightness),
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
                  hintText: "Add a task...",
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
            // Voice input button
            GestureDetector(
              onTap: _isListening ? _stopVoiceInput : _startVoiceInput,
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: _isListening
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.surface(context).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: _isListening
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  size: 24.sp,
                  color: _isListening
                      ? AppColors.primary
                      : AppColors.getTextColor(Theme.of(context).brightness),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Add button
            GestureDetector(
              onTap: _todoController.text.trim().isEmpty ? null : _addQuickTodo,
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: _todoController.text.trim().isEmpty
                      ? AppColors.surface(context).withOpacity(0.3)
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Icon(
                  Icons.add,
                  size: 24.sp,
                  color: _todoController.text.trim().isEmpty
                      ? Colors.grey
                      : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final categories = ['All', 'Personal', 'Work', 'Important'];

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingHorizontal,
        vertical: 12.h,
      ),
      sliver: SliverToBoxAdapter(
        child: SizedBox(
          height: 36.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory == category;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = category),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surface(context),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.divider(context),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary(context),
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTodoListSection(List<Note> allNotes) {
    _processTodos(allNotes);

    if (_flattenedList.isEmpty) {
      return SliverFillRemaining(
        child: Padding(
          padding: EdgeInsets.only(bottom: 100.h),
          child: widgets.EmptyStateTodos(),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = _flattenedList[index];
          if (item is HeaderItem) {
            return Padding(
              padding: EdgeInsets.only(top: 24.h, bottom: 12.h),
              child: Row(
                children: [
                  Container(
                    width: 4.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    item.title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: AppColors.getSecondaryTextColor(
                        Theme.of(context).brightness,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '${item.count}',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: item.color,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (item is TaskItem) {
            return _buildTodoItem(item.note);
          }
          return const SizedBox.shrink();
        }, childCount: _flattenedList.length),
      ),
    );
  }

  Widget _buildErrorState(NoteState state) {
    String message = 'Error loading tasks';
    if (state is NoteError) message = state.message;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.errorColor),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTypography.heading3(
              context,
              AppColors.textPrimary(context),
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
    );
  }

  Widget _buildTodoItem(Note todo) {
    final isCompleted = todo.tags.contains('completed');

    // Check for alarm Info
    String? alarmText;
    final activeAlarm = todo.alarms?.where((a) => a.isActive).firstOrNull;
    if (activeAlarm != null && !isCompleted) {
      alarmText = DateFormat('MMM d, h:mm a').format(activeAlarm.scheduledTime);
    }

    return CardContainer(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
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
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style:
                      AppTypography.bodyMedium(
                        context,
                        isCompleted
                            ? AppColors.textSecondary(context)
                            : AppColors.textPrimary(context),
                      ).copyWith(
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                ),
                if (alarmText != null) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.alarm,
                        size: 12.sp,
                        color: activeAlarm!.isOverdue
                            ? AppColors.error
                            : AppColors.textSecondary(context),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        alarmText,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: activeAlarm.isOverdue
                              ? AppColors.error
                              : AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
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
    final params = NoteParams.fromNote(todo.copyWith(tags: tags));
    context.read<NotesBloc>().add(UpdateNoteEvent(params));
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
        // Create a blank todo for advanced todo view
        final dummyTodo = TodoItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdvancedTodoScreen(todo: dummyTodo),
          ),
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

// Helper classes for flattened list
abstract class TodoListItem {}

class HeaderItem extends TodoListItem {
  final String title;
  final Color color;
  final int count;

  HeaderItem(this.title, this.color, this.count);
}

class TaskItem extends TodoListItem {
  final Note note;

  TaskItem(this.note);
}
