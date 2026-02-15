import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:mynotes/domain/entities/note.dart' show Note;

import '../../core/services/speech_service.dart';
import '../../domain/entities/todo_item.dart';
import '../bloc/todos/todos_bloc.dart';
import '../bloc/params/todo_params.dart';
import '../design_system/design_system.dart';
import '../widgets/empty_state_todos.dart' as widgets;
import '../widgets/animated_list_grid_view.dart';
import '../widgets/svg_image_widget.dart';

/// Todos List Screen - Display all todos using TodosBloc
class TodosListScreen extends StatelessWidget {
  const TodosListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todoController = TextEditingController();
    final speechService = SpeechService();

    return BlocBuilder<TodosBloc, TodosState>(
      builder: (context, state) {
        if (state is TodosInitial) {
          AppLogger.i('TodosInitial state, loading todos...');
          context.read<TodosBloc>().add(LoadTodos());
        }

        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(
            Theme.of(context).brightness,
          ),
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  _buildSliverAppBar(context, state),
                  if (state is TodosLoaded) ...[
                    SliverToBoxAdapter(
                      child: _buildProgressCard(context, state.allTodos),
                    ),
                    _buildFilterSection(context, state),
                    _buildTodoListSection(context, state.filteredTodos),
                  ] else if (state is TodosLoading) ...[
                    const SliverFillRemaining(
                      child: Center(child: AppLoadingIndicator()),
                    ),
                  ] else ...[
                    SliverFillRemaining(
                      child: _buildErrorState(context, state),
                    ),
                  ],
                  SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildQuickAddSection(
                  context,
                  state,
                  todoController,
                  speechService,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, TodosState state) {
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
      title: Text('My Todos', style: AppTypography.heading2(context)),
      actions: [
        IconButton(
          icon: context.icon('info', size: 24),
          onPressed: () {
            // Stats logic
          },
        ),
        IconButton(
          icon: context.icon('more_options', size: 24),
          onPressed: () {
            // Settings logic
          },
        ),
      ],
    );
  }

  Widget _buildProgressCard(BuildContext context, List<TodoItem> todos) {
    final completedCount = todos.where((t) => t.isCompleted).length;
    final totalCount = todos.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Progress',
                  style: AppTypography.bodyLarge(context).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$completedCount of $totalCount tasks completed',
                  style: AppTypography.bodyMedium(context),
                ),
                SizedBox(height: 12.h),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 50.w,
                height: 50.w,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTypography.bodyMedium(
                  context,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, TodosLoaded state) {
    final categories = [
      'All',
      'Personal',
      'Work',
      'Health',
      'Finance',
      'Shopping',
    ];

    return SliverToBoxAdapter(
      child: Container(
        height: 50.h,
        padding: EdgeInsets.only(left: 16.w),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = state.selectedCategory == category;

            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: ChoiceChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    AppLogger.i('Todo category filter changed to: $category');
                    context.read<TodosBloc>().add(ChangeCategory(category));
                  }
                },
                selectedColor: AppColors.primary.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTodoListSection(BuildContext context, List<TodoItem> todos) {
    if (todos.isEmpty) {
      return const SliverFillRemaining(child: widgets.EmptyStateTodos());
    }

    return SliverToBoxAdapter(
      child: AnimatedListView(
        items: todos,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final todo = todos[index];
          return _buildTodoItem(context, todo);
        },
      ),
    );
  }

  Widget _buildTodoItem(BuildContext context, TodoItem todo) {
    return Slidable(
      key: ValueKey(todo.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              AppLogger.i('Todo item delete swiped: ${todo.id}');
              context.read<TodosBloc>().add(DeleteTodo(todo.id));
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          AppLogger.i('Todo item tapped: ${todo.id}');
          // Open details
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Checkbox(
                value: todo.isCompleted,
                onChanged: (value) {
                  AppLogger.i(
                    'Todo item checkbox toggled: ${todo.id} to $value',
                  );
                  context.read<TodosBloc>().add(
                    ToggleTodo(TodoParams.fromTodoItem(todo)),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
                activeColor: AppColors.primary,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.text,
                      style: AppTypography.bodyLarge(context).copyWith(
                        decoration: todo.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: todo.isCompleted ? Colors.grey : null,
                      ),
                    ),
                    if (todo.dueDate != null)
                      Text(
                        DateFormat('MMM d, h:mm a').format(todo.dueDate!),
                        style: AppTypography.caption(
                          context,
                        ).copyWith(color: AppColors.primary),
                      ),
                  ],
                ),
              ),
              if (todo.priority == TodoPriority.high ||
                  todo.priority == TodoPriority.urgent)
                context.icon('checkmark', size: 20, color: Colors.orange),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAddSection(
    BuildContext context,
    TodosState state,
    TextEditingController controller,
    SpeechService speechService,
  ) {
    bool isListening = false;
    if (state is TodosLoaded) {
      isListening = state.isListening;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Add a quick todo...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () async {
              if (isListening) {
                speechService.stopListening();
                context.read<TodosBloc>().add(SetListening(false));

                if (controller.text.isNotEmpty) {
                  context.read<TodosBloc>().add(
                    AddTodo(TodoParams(todoId: '', text: controller.text)),
                  );
                  controller.clear();
                }
              } else {
                final initialized = await speechService.initialize();
                if (initialized) {
                  context.read<TodosBloc>().add(SetListening(true));
                  speechService.startListening(
                    onResult: (text) {
                      controller.text = text;
                    },
                  );
                }
              }
            },
            child: CircleAvatar(
              backgroundColor: isListening ? Colors.red : AppColors.primary,
              child: Icon(
                isListening ? Icons.stop : Icons.mic,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () {
              if (controller.text.isNotEmpty) {
                context.read<TodosBloc>().add(
                  AddTodo(TodoParams(todoId: '', text: controller.text)),
                );
                controller.clear();
              }
            },
            child: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, TodosState state) {
    String message = 'Something went wrong';
    if (state is TodosError) message = state.message;
    return Center(child: Text(message));
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
