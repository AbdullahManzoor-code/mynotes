import 'package:flutter/material.dart';
import 'package:mynotes/domain/entities/todo_item.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/core/extensions/extensions.dart';
import 'package:mynotes/core/constants/app_strings.dart';

/// Unified todo metadata widget
/// Displays todo information like due date, completion status, and timestamps
class TodoMetadata extends StatelessWidget {
  final TodoItem todo;
  final int? subtasksCompleted;
  final int? subtasksTotal;
  final bool showFullInfo;

  const TodoMetadata({
    super.key,
    required this.todo,
    this.subtasksCompleted,
    this.subtasksTotal,
    this.showFullInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.theme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.theme.dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDueDateSection(context),
          if (subtasksTotal != null && subtasksTotal! > 0) ...[
            SizedBox(height: 12.h),
            _buildSubtasksSection(context),
          ],
          // if (todo. != null) ...[
          //   SizedBox(height: 12.h),
          //   _buildLinkedNoteSection(context),
          // ],
          if (showFullInfo) ...[
            SizedBox(height: 12.h),
            Divider(height: 0, color: context.theme.dividerColor),
            SizedBox(height: 12.h),
            _buildDetailedSection(context),
          ],
        ],
      ),
    );
  }

  Widget _buildDueDateSection(BuildContext context) {
    if (todo.dueDate == null) {
      return _buildMetadataItem(
        context,
        icon: Icons.calendar_today,
        label: AppStrings.dueDate,
        value: 'Not set',
        color: Colors.grey,
      );
    }

    final difference = todo.dueDate!.difference(DateTime.now()).inDays;
    final color = difference < 0
        ? Colors
              .red // Overdue
        : difference == 0
        ? Colors
              .orange // Today
        : difference <= 3
        ? Colors
              .blue // Soon
        : Colors.green; // Coming up

    return _buildMetadataItem(
      context,
      icon: Icons.calendar_today,
      label: AppStrings.dueDate,
      value: todo.dueDate!.formatDate(),
      color: color,
    );
  }

  Widget _buildSubtasksSection(BuildContext context) {
    final progress = (subtasksCompleted ?? 0) / (subtasksTotal ?? 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.todos,
              style: AppTypography.caption(
                context,
              ).copyWith(fontSize: 11.sp, fontWeight: FontWeight.w600),
            ),
            Text(
              '$subtasksCompleted/$subtasksTotal',
              style: AppTypography.body2(
                context,
              ).copyWith(fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6.h,
            backgroundColor: context.theme.disabledColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(
              progress >= 1.0 ? Colors.green : context.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedSection(BuildContext context) {
    return Column(
      children: [
        _buildMetadataItem(
          context,
          icon: Icons.access_time,
          label: AppStrings.created,
          value: todo.createdAt.formatDate(),
        ),
        SizedBox(height: 8.h),
        _buildMetadataItem(
          context,
          icon: Icons.update,
          label: AppStrings.updated,
          value: todo.updatedAt.formatRelative(),
        ),
        if (todo.isCompleted && todo.completedAt != null) ...[
          SizedBox(height: 8.h),
          _buildMetadataItem(
            context,
            icon: Icons.check_circle,
            label: 'Completed',
            value: todo.completedAt!.formatRelative(),
            color: Colors.green,
          ),
        ],
      ],
    );
  }

  Widget _buildMetadataItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.r, color: color ?? context.primaryColor),
            SizedBox(width: 6.w),
            Text(
              label,
              style: AppTypography.caption(
                context,
              ).copyWith(fontSize: 11.sp, color: Colors.grey.shade600),
            ),
          ],
        ),
        Text(
          value,
          style: AppTypography.body2(context).copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
