import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_typography.dart';
import '../design_system/app_spacing.dart';
import '../../domain/entities/todo_item.dart';
import '../bloc/todos/todos_bloc.dart';

/// Advanced Todo Detail Screen (View D1)
/// Refactored to use Design System, BLoC, and Stateless architecture
class AdvancedTodoScreen extends StatelessWidget {
  final TodoItem todo;

  const AdvancedTodoScreen({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodosBloc, TodosState>(
      builder: (context, state) {
        // Find the current todo in the state to get updated subtasks
        TodoItem currentTodo = todo;
        if (state is TodosLoaded) {
          try {
            currentTodo = state.allTodos.firstWhere((t) => t.id == todo.id);
          } catch (_) {
            // Todo might have been deleted
          }
        }

        return Scaffold(
          backgroundColor: AppColors.lightBackground,
          body: CustomScrollView(
            slivers: [
              // App Bar with Progress
              _buildAppBar(context, currentTodo),

              // Subtasks List
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 80.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return _SubtaskItem(
                      subtask: currentTodo.subtasks[index],
                      todoId: currentTodo.id,
                      index: index,
                      allSubtasks: currentTodo.subtasks,
                    );
                  }, childCount: currentTodo.subtasks.length),
                ),
              ),

              // Empty State
              if (currentTodo.subtasks.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_task,
                          size: 60.sp,
                          color: AppColors.grey400,
                        ),
                        AppSpacing.gapL,
                        Text(
                          'No subtasks yet',
                          style: AppTypography.bodyMedium(
                            context,
                            AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Bottom Input
          bottomNavigationBar: _BottomSubtaskInput(
            todoId: currentTodo.id,
            allSubtasks: currentTodo.subtasks,
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, TodoItem currentTodo) {
    return SliverAppBar(
      expandedHeight: 220.h,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primaryColor,
      actions: [
        IconButton(
          icon: Icon(
            currentTodo.isImportant ? Icons.star : Icons.star_border,
            color: currentTodo.isImportant
                ? AppColors.accentOrange
                : Colors.white,
          ),
          onPressed: () => context.read<TodosBloc>().add(
            ToggleImportantTodo(currentTodo.id),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryColor, AppColors.primaryColorDark],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: AppSpacing.paddingAllL,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Task Detail',
                    style: AppTypography.labelSmall(context, Colors.white70),
                  ),
                  AppSpacing.gapXS,
                  Text(
                    currentTodo.text,
                    style: AppTypography.displayMedium(context, Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (currentTodo.notes != null &&
                      currentTodo.notes!.isNotEmpty) ...[
                    AppSpacing.gapS,
                    Text(
                      currentTodo.notes!,
                      style: AppTypography.bodySmall(context, Colors.white60),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  AppSpacing.gapL,
                  _ProgressBar(currentTodo: currentTodo),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final TodoItem currentTodo;

  const _ProgressBar({required this.currentTodo});

  @override
  Widget build(BuildContext context) {
    final subtasks = currentTodo.subtasks;
    final double progress = subtasks.isEmpty
        ? (currentTodo.isCompleted ? 1.0 : 0.0)
        : subtasks.where((s) => s.isCompleted).length / subtasks.length;

    final completedCount = subtasks.where((s) => s.isCompleted).length;
    final totalCount = subtasks.length;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              totalCount == 0
                  ? (currentTodo.isCompleted ? 'Completed' : 'Pending')
                  : '$completedCount of $totalCount subtasks',
              style: AppTypography.labelSmall(context, Colors.white70),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: AppTypography.labelSmall(
                context,
                Colors.white,
                FontWeight.bold,
              ),
            ),
          ],
        ),
        AppSpacing.gapS,
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: progress),
          duration: const Duration(milliseconds: 600),
          builder: (context, value, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8.h,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SubtaskItem extends StatelessWidget {
  final SubTask subtask;
  final String todoId;
  final int index;
  final List<SubTask> allSubtasks;

  const _SubtaskItem({
    required this.subtask,
    required this.todoId,
    required this.index,
    required this.allSubtasks,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Slidable(
        key: Key(subtask.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (context) {
                final newSubtasks = List<SubTask>.from(allSubtasks)
                  ..removeAt(index);
                context.read<TodosBloc>().add(
                  UpdateSubtasks(todoId, newSubtasks),
                );
              },
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: BorderRadius.circular(12.r),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                final newSubtasks = List<SubTask>.from(allSubtasks);
                newSubtasks[index] = subtask.toggle();
                context.read<TodosBloc>().add(
                  UpdateSubtasks(todoId, newSubtasks),
                );
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: AppSpacing.paddingAllM,
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22.w,
                      height: 22.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: subtask.isCompleted
                            ? AppColors.success
                            : Colors.transparent,
                        border: Border.all(
                          color: subtask.isCompleted
                              ? AppColors.success
                              : AppColors.grey400,
                          width: 2,
                        ),
                      ),
                      child: subtask.isCompleted
                          ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                          : null,
                    ),
                    AppSpacing.gapM,
                    Expanded(
                      child: Text(
                        subtask.text,
                        style:
                            AppTypography.bodyMedium(
                              context,
                              subtask.isCompleted
                                  ? AppColors.grey400
                                  : AppColors.darkText,
                              subtask.isCompleted
                                  ? FontWeight.normal
                                  : FontWeight.w500,
                            ).copyWith(
                              decoration: subtask.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.drag_indicator,
                      color: AppColors.grey400.withOpacity(0.5),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomSubtaskInput extends StatefulWidget {
  final String todoId;
  final List<SubTask> allSubtasks;

  const _BottomSubtaskInput({required this.todoId, required this.allSubtasks});

  @override
  State<_BottomSubtaskInput> createState() => _BottomSubtaskInputState();
}

class _BottomSubtaskInputState extends State<_BottomSubtaskInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text.trim().isEmpty) return;

    final newSubtask = SubTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _controller.text.trim(),
      isCompleted: false,
    );

    final newSubtasks = List<SubTask>.from(widget.allSubtasks)..add(newSubtask);
    context.read<TodosBloc>().add(UpdateSubtasks(widget.todoId, newSubtasks));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: TextField(
                controller: _controller,
                style: AppTypography.bodyMedium(context, AppColors.darkText),
                decoration: InputDecoration(
                  hintText: 'Add subtask...',
                  border: InputBorder.none,
                  hintStyle: AppTypography.labelSmall(
                    context,
                    AppColors.grey400,
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
          ),
          AppSpacing.gapM,
          FloatingActionButton(
            onPressed: _submit,
            mini: true,
            elevation: 0,
            backgroundColor: AppColors.primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

