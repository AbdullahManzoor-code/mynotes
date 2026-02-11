import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/presentation/bloc/params/todo_params.dart';
import 'package:mynotes/presentation/bloc/todo_state.dart';
import 'package:mynotes/presentation/bloc/todo_event.dart';
import '../../domain/entities/todo_item.dart';
import '../bloc/todo_bloc.dart';
import '../design_system/design_system.dart';

/// Kanban Board View - Column-based task visualization
/// Supports drag-and-drop between columns for status management
class KanbanBoardWidget extends StatefulWidget {
  const KanbanBoardWidget({super.key});

  @override
  State<KanbanBoardWidget> createState() => _KanbanBoardWidgetState();
}

class _KanbanBoardWidgetState extends State<KanbanBoardWidget> {
  final List<String> _columns = ['To Do', 'In Progress', 'In Review', 'Done'];
  late Map<String, List<TodoItem>> _columnTasks;

  @override
  void initState() {
    super.initState();
    _columnTasks = {
      'To Do': [],
      'In Progress': [],
      'In Review': [],
      'Done': [],
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, state) {
        if (state is TodosLoaded) {
          _organizeTasks(state.todos);
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _columns.map((column) {
                return _buildColumn(
                  column,
                  _columnTasks[column] ?? [],
                  context,
                );
              }).toList(),
            ),
          );
        }

        if (state is TodoLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return Center(child: Text('No tasks yet'));
      },
    );
  }

  void _organizeTasks(List<TodoItem> todos) {
    // Reset columns
    _columnTasks = {
      'To Do': [],
      'In Progress': [],
      'In Review': [],
      'Done': [],
    };

    // Organize tasks by status
    for (var todo in todos) {
      if (todo.isCompleted) {
        _columnTasks['Done']?.add(todo);
      } else if (todo.priority == 'high') {
        _columnTasks['In Progress']?.add(todo);
      } else if (todo.priority == 'medium') {
        _columnTasks['In Review']?.add(todo);
      } else {
        _columnTasks['To Do']?.add(todo);
      }
    }
  }

  Widget _buildColumn(
    String columnTitle,
    List<TodoItem> tasks,
    BuildContext context,
  ) {
    return Container(
      width: 300.w,
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(Theme.of(context).brightness),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.getSecondaryTextColor(
            Theme.of(context).brightness,
          ).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildColumnHeader(columnTitle, tasks.length, context),
          Expanded(
            child: DragTarget<TodoItem>(
              onAccept: (todo) {
                _moveTaskToColumn(todo, columnTitle);
              },
              builder: (context, candidateData, rejectedData) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      ...tasks.map((task) => _buildTaskCard(task, context)),
                      if (tasks.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Text(
                            'Drop tasks here',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.getSecondaryTextColor(
                                Theme.of(context).brightness,
                              ),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnHeader(String title, int count, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.getSecondaryTextColor(
              Theme.of(context).brightness,
            ).withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.getTextColor(Theme.of(context).brightness),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '$count tasks',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.getSecondaryTextColor(
                    Theme.of(context).brightness,
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(TodoItem task, BuildContext context) {
    return Draggable<TodoItem>(
      data: task,
      feedback: Material(
        child: Container(
          width: 280.w,
          margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.getSurfaceColor(Theme.of(context).brightness),
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                task.text,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextColor(Theme.of(context).brightness),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (task.notes != null && task.notes!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    task.notes!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.getSecondaryTextColor(
                        Theme.of(context).brightness,
                      ),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: _getPriorityColor(task.priority).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: _getPriorityColor(task.priority).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.text,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextColor(
                        Theme.of(context).brightness,
                      ),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(task.priority),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    task.priority.displayName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            if (task.dueDate != null)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12.sp,
                      color: AppColors.getSecondaryTextColor(
                        Theme.of(context).brightness,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatDate(task.dueDate!),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.getSecondaryTextColor(
                          Theme.of(context).brightness,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(TodoPriority? priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Tomorrow';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  void _moveTaskToColumn(TodoItem task, String newStatus) {
    // Update task status based on column
    final newPriority = _getStatusPriority(newStatus);
    final params = TodoParams.fromTodoItem(
      task.copyWith(priority: newPriority),
    );
    context.read<TodoBloc>().add(UpdateTodoEvent(params: params));
  }

  TodoPriority _getStatusPriority(String status) {
    switch (status) {
      case 'To Do':
        return TodoPriority.low;
      case 'In Progress':
        return TodoPriority.high;
      case 'In Review':
        return TodoPriority.medium;
      case 'Done':
        return TodoPriority.low;
      default:
        return TodoPriority.low;
    }
  }
}
