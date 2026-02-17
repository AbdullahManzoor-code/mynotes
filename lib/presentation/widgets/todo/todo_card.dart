import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/domain/entities/todo_item.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/core/extensions/extensions.dart';
import 'package:mynotes/core/constants/app_strings.dart';

/// Unified todo card widget with responsive design
/// Displays todo with title, priority, checkmark, and actions
class TodoCard extends StatefulWidget {
  final TodoItem todo;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onComplete;
  final VoidCallback? onUncomplete;
  final bool isSelected;
  final bool enableActions;

  const TodoCard({
    super.key,
    required this.todo,
    required this.onTap,
    required this.onLongPress,
    this.onEdit,
    this.onDelete,
    this.onComplete,
    this.onUncomplete,
    this.isSelected = false,
    this.enableActions = true,
  });

  @override
  State<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  late final TodoItem todo;

  @override
  void initState() {
    super.initState();
    todo = widget.todo;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        elevation: widget.isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: widget.isSelected
                ? Border.all(color: context.primaryColor, width: 2)
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                SizedBox(height: 8.h),
                _buildContent(context),
                SizedBox(height: 8.h),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Checkbox
        GestureDetector(
          onTap: todo.isCompleted ? widget.onUncomplete : widget.onComplete,
          child: Container(
            width: 24.r,
            height: 24.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: todo.isCompleted ? Colors.green : Colors.grey,
                width: 2,
              ),
              color: todo.isCompleted ? Colors.green : Colors.transparent,
            ),
            child: todo.isCompleted
                ? Icon(Icons.check, size: 14.r, color: Colors.white)
                : null,
          ),
        ),
        SizedBox(width: 12.w),
        // Title
        Expanded(
          child: Text(
            todo.text.isEmpty ? AppStrings.todoTitle : todo.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.heading3(context).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              color: todo.isCompleted ? Colors.grey : null,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        // Priority badge
        _buildPriorityBadge(context),
        SizedBox(width: 8.w),
        // More menu
        if (widget.enableActions &&
            (widget.onEdit != null || widget.onDelete != null))
          PopupMenuButton(
            itemBuilder: (context) => [
              if (widget.onEdit != null)
                PopupMenuItem(
                  onTap: widget.onEdit,
                  child: Text(AppStrings.edit),
                ),
              if (widget.onDelete != null)
                PopupMenuItem(
                  onTap: widget.onDelete,
                  child: Text(
                    AppStrings.delete,
                    style: TextStyle(color: context.errorColor),
                  ),
                ),
            ],
            padding: EdgeInsets.zero,
            icon: Icon(Icons.more_vert, size: 20.r),
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (todo.text.isEmpty) return SizedBox.shrink();

    final preview = todo.text.length > 100
        ? '${todo.text.substring(0, 100)}...'
        : todo.text;

    return Text(
      preview,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.body2(context).copyWith(
        fontSize: 14.sp,
        color: context.theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Category
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: context.theme.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            todo.category.toString(),
            style: AppTypography.caption(
              context,
            ).copyWith(fontSize: 11.sp, color: context.primaryColor),
          ),
        ),
        // Due date
        if (todo.dueDate != null)
          Text(
            todo.dueDate!.formatRelative(),
            style: AppTypography.caption(
              context,
            ).copyWith(fontSize: 11.sp, color: _getDueDateColor(context)),
          ),
      ],
    );
  }

  Widget _buildPriorityBadge(BuildContext context) {
    final color = _getPriorityColor(todo.priority);
    final label = _getPriorityLabel(todo.priority);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        label,
        style: AppTypography.caption(
          context,
        ).copyWith(fontSize: 9.sp, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _getPriorityColor(TodoPriority? priority) {
    switch (priority) {
      case TodoPriority.low:
        return Colors.green;
      case TodoPriority.medium:
        return Colors.blue;
      case TodoPriority.high:
        return Colors.orange;
      case TodoPriority.urgent:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityLabel(TodoPriority? priority) {
    switch (priority) {
      case TodoPriority.low:
        return 'Low';
      case TodoPriority.medium:
        return 'Med';
      case TodoPriority.high:
        return 'High';
      case TodoPriority.urgent:
        return 'Urgent';
      default:
        return 'None';
    }
  }

  Color _getDueDateColor(BuildContext context) {
    if (todo.dueDate == null) return Colors.grey;

    final now = DateTime.now();
    final difference = todo.dueDate!.difference(now).inDays;

    if (difference < 0) {
      return Colors.red; // Overdue
    } else if (difference == 0) {
      return Colors.orange; // Today
    } else if (difference <= 3) {
      return Colors.blue; // Soon
    }

    return Colors.grey.shade600;
  }
}
