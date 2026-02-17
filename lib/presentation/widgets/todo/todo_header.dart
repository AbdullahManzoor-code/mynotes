import 'package:flutter/material.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'package:mynotes/domain/entities/todo_item.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/core/constants/app_strings.dart';

/// Unified todo header widget with title, priority, category
/// Handles title input and metadata customization for todos
class TodoHeader extends StatefulWidget {
  final TodoItem todo;
  final TextEditingController titleController;
  final ValueChanged<TodoPriority> onPriorityChanged;
  final ValueChanged<String>? onCategoryChanged;
  final bool isEditing;

  const TodoHeader({
    super.key,
    required this.todo,
    required this.titleController,
    required this.onPriorityChanged,
    this.onCategoryChanged,
    this.isEditing = true,
  });

  @override
  State<TodoHeader> createState() => _TodoHeaderState();
}

class _TodoHeaderState extends State<TodoHeader> {
  late final TodoItem todo;
  late final TextEditingController titleController;
  late final TextEditingController categoryController;

  @override
  void initState() {
    super.initState();
    todo = widget.todo;
    titleController = widget.titleController;
    categoryController = TextEditingController(
      text: (todo.category as String?) ?? '',
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title input
        _buildTitleField(context),
        SizedBox(height: 16.h),
        // Priority and Category row
        _buildPriorityAndCategoryRow(context),
      ],
    );
  }

  Widget _buildTitleField(BuildContext context) {
    return TextFormField(
      controller: titleController,
      readOnly: !widget.isEditing,
      maxLines: null,
      style: AppTypography.heading2(
        context,
      ).copyWith(fontSize: 24.sp, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: AppStrings.todoTitle,
        hintStyle: AppTypography.heading2(
          context,
        ).copyWith(fontSize: 24.sp, color: Colors.grey.shade400),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildPriorityAndCategoryRow(BuildContext context) {
    return Row(
      children: [
        // Priority picker
        _buildPriorityPicker(context),
        SizedBox(width: 16.w),
        // Category field
        Expanded(
          child: TextField(
            controller: categoryController,
            readOnly: !widget.isEditing,
            style: AppTypography.body1(context).copyWith(fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: AppStrings.category,
              prefixIcon: Icon(Icons.category, size: 18.r),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
            ),
            onChanged: widget.onCategoryChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityPicker(BuildContext context) {
    return PopupMenuButton<TodoPriority>(
      onSelected: widget.onPriorityChanged,
      itemBuilder: (context) => TodoPriority.values.map((priority) {
        return PopupMenuItem(
          value: priority,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.r,
                height: 12.r,
                decoration: BoxDecoration(
                  color: _getPriorityColor(priority),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Text(_getPriorityLabel(priority)),
              if (todo.priority == priority) ...[
                SizedBox(width: 12.w),
                Icon(Icons.check, size: 18.r, color: context.primaryColor),
              ],
            ],
          ),
        );
      }).toList(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          border: Border.all(color: context.theme.dividerColor),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.r,
              height: 12.r,
              decoration: BoxDecoration(
                color: _getPriorityColor(todo.priority),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              _getPriorityLabel(todo.priority),
              style: AppTypography.body2(context).copyWith(fontSize: 12.sp),
            ),
            SizedBox(width: 4.w),
            Icon(Icons.expand_more, size: 16.r),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.low:
        return Colors.green;
      case TodoPriority.medium:
        return Colors.blue;
      case TodoPriority.high:
        return Colors.orange;
      case TodoPriority.urgent:
        return Colors.red;
    }
  }

  String _getPriorityLabel(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.low:
        return AppStrings.lowPriority;
      case TodoPriority.medium:
        return AppStrings.mediumPriority;
      case TodoPriority.high:
        return AppStrings.highPriority;
      case TodoPriority.urgent:
        return AppStrings.urgentPriority;
    }
  }
}
