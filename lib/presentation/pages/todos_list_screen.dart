import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../core/services/speech_service.dart';
import '../../domain/entities/note.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_state.dart';
import '../bloc/note_event.dart';
import '../design_system/design_system.dart';
import '../widgets/voice_input_button.dart';
import '../widgets/empty_state_widget.dart';
import 'todo_focus_screen.dart';
import 'settings_screen.dart';
import 'note_editor_page.dart';

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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorPage(note: note)),
    );
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

    return BlocListener<NotesBloc, NoteState>(
      listener: (context, state) {
        if (state is NoteCreated ||
            state is NoteUpdated ||
            state is NoteDeleted) {
          _loadTodos();
        }
      },
      child: AppScaffold(
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            _buildInputSection(),
            _buildFilterSection(),
            _buildTodoListSection(),
            SliverToBoxAdapter(child: SizedBox(height: 100.r)),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Tasks',
                  style: AppTypography.displayLarge(
                    context,
                    null,
                    FontWeight.bold,
                  ),
                ),
                Text(
                  'Stay focused and productive',
                  style: AppTypography.bodySmall(
                    context,
                    AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
            AppIconButton(
              icon: Icons.timer_outlined,
              onPressed: () => _openFocusMode(null),
              tooltip: 'Focus Mode',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverToBoxAdapter(
        child: CardContainer(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _todoController,
                  style: AppTypography.bodyMedium(context),
                  decoration: InputDecoration(
                    hintText: 'Add a new task...',
                    hintStyle: AppTypography.bodyMedium(
                      context,
                      AppColors.textSecondary(context).withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _addQuickTodo(),
                ),
              ),
              VoiceInputButton(
                isListening: _isListening,
                onPressed: _isListening ? _stopVoiceInput : _startVoiceInput,
                size: 40.r,
              ),
              SizedBox(width: AppSpacing.xs),
              AppIconButton(
                icon: Icons.add_circle,
                onPressed: _addQuickTodo,
                iconColor: AppColors.primaryColor,
                size: 32.r,
              ),
            ],
          ),
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
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      sliver: SliverToBoxAdapter(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((f) {
              final isSelected = _filterBy == f['id'];
              return GestureDetector(
                onTap: () => setState(() => _filterBy = f['id']!),
                child: Container(
                  margin: EdgeInsets.only(right: AppSpacing.sm),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryColor
                        : AppColors.surface(context),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.divider(context),
                    ),
                  ),
                  child: Text(
                    f['label']!,
                    style: AppTypography.captionSmall(
                      context,
                      isSelected
                          ? Colors.white
                          : AppColors.textPrimary(context),
                      isSelected ? FontWeight.bold : FontWeight.normal,
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
          final filtered = _filterTodos(todos);

          if (filtered.isEmpty) {
            return SliverFillRemaining(
              child: Padding(
                padding: EdgeInsets.only(bottom: 100.h),
                child: EmptyStateWidget(
                  icon: Icons.check_circle_outline,
                  title: 'All caught up!',
                  subtitle: 'No tasks to show for this filter.',
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

  Widget _buildTodoCard(Note note) {
    final isCompleted = note.isArchived;

    return CardContainer(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      onTap: () => _openFocusMode(note),
      child: Row(
        children: [
          Checkbox(
            value: isCompleted,
            onChanged: (value) {
              final updatedNote = note.copyWith(
                isArchived: value ?? false,
                updatedAt: DateTime.now(),
              );
              context.read<NotesBloc>().add(UpdateNoteEvent(updatedNote));
            },
            activeColor: AppColors.successColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style:
                      AppTypography.heading4(
                        context,
                        isCompleted ? AppColors.textSecondary(context) : null,
                      ).copyWith(
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                ),
                if (note.content.isNotEmpty)
                  Text(
                    note.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.captionSmall(context),
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: AppColors.textSecondary(context),
            ),
            onSelected: (value) {
              if (value == 'delete') {
                context.read<NotesBloc>().add(DeleteNoteEvent(note.id));
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}
