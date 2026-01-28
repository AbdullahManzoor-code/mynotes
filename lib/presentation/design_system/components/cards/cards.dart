import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app_colors.dart';
import '../../app_spacing.dart';
import '../../app_typography.dart';

/// Note card with glass effect
class NoteCard extends StatelessWidget {
  final String title;
  final String? content;
  final String? category;
  final Color? categoryColor;
  final DateTime? createdAt;
  final bool isPinned;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? margin;

  const NoteCard({
    super.key,
    required this.title,
    this.content,
    this.category,
    this.categoryColor,
    this.createdAt,
    this.isPinned = false,
    this.onTap,
    this.onLongPress,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.only(bottom: AppSpacing.md.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: EdgeInsets.all(AppSpacing.md.w),
                decoration: BoxDecoration(
                  color: AppColors.surface(context).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(
                    color: categoryColor ?? AppColors.border(context),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        if (category != null) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm.w,
                              vertical: AppSpacing.xxs.h,
                            ),
                            decoration: BoxDecoration(
                              color: (categoryColor ?? AppColors.primary)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm,
                              ),
                            ),
                            child: Text(
                              category!,
                              style: AppTypography.caption().copyWith(
                                color: categoryColor ?? AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm.w),
                        ],
                        const Spacer(),
                        if (isPinned)
                          Icon(
                            Icons.push_pin,
                            size: 16.sp,
                            color: AppColors.textSecondary(context),
                          ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm.h),

                    // Title
                    Text(
                      title,
                      style: AppTypography.noteTitle(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Content
                    if (content != null && content!.isNotEmpty) ...[
                      SizedBox(height: AppSpacing.xs.h),
                      Text(
                        content!,
                        style: AppTypography.noteContent(),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Footer
                    if (createdAt != null) ...[
                      SizedBox(height: AppSpacing.sm.h),
                      Text(
                        _formatDate(createdAt!),
                        style: AppTypography.caption(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Todo card with checkbox
class TodoCard extends StatelessWidget {
  final String title;
  final String? description;
  final bool isCompleted;
  final String? priority;
  final Color? priorityColor;
  final DateTime? dueDate;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onCheckboxChanged;
  final EdgeInsetsGeometry? margin;

  const TodoCard({
    super.key,
    required this.title,
    this.description,
    required this.isCompleted,
    this.priority,
    this.priorityColor,
    this.dueDate,
    this.onTap,
    this.onCheckboxChanged,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.only(bottom: AppSpacing.md.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: EdgeInsets.all(AppSpacing.md.w),
                decoration: BoxDecoration(
                  color: AppColors.surface(context).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(
                    color: AppColors.border(context),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Checkbox
                    Checkbox(
                      value: isCompleted,
                      onChanged: onCheckboxChanged,
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm.w),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title with strike-through if completed
                          Text(
                            title,
                            style: AppTypography.todoTitle().copyWith(
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isCompleted
                                  ? AppColors.textSecondary(context)
                                  : AppColors.textPrimary(context),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // Description
                          if (description != null &&
                              description!.isNotEmpty) ...[
                            SizedBox(height: AppSpacing.xxs.h),
                            Text(
                              description!,
                              style: AppTypography.caption(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],

                          // Footer row
                          if (priority != null || dueDate != null) ...[
                            SizedBox(height: AppSpacing.xs.h),
                            Row(
                              children: [
                                if (priority != null)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm.w,
                                      vertical: AppSpacing.xxs.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (priorityColor ?? AppColors.error)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusSm,
                                      ),
                                    ),
                                    child: Text(
                                      priority!,
                                      style: AppTypography.caption().copyWith(
                                        color: priorityColor ?? AppColors.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                if (priority != null && dueDate != null)
                                  SizedBox(width: AppSpacing.sm.w),
                                if (dueDate != null)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 12.sp,
                                        color: AppColors.textSecondary(context),
                                      ),
                                      SizedBox(width: AppSpacing.xxs.w),
                                      Text(
                                        _formatDueDate(dueDate!),
                                        style: AppTypography.caption(),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
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

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Reminder card
class ReminderCard extends StatelessWidget {
  final String title;
  final DateTime dateTime;
  final String? repeat;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final EdgeInsetsGeometry? margin;

  const ReminderCard({
    super.key,
    required this.title,
    required this.dateTime,
    this.repeat,
    this.icon,
    this.iconColor,
    this.onTap,
    this.onDismiss,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.only(bottom: AppSpacing.md.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: EdgeInsets.all(AppSpacing.md.w),
                decoration: BoxDecoration(
                  color: AppColors.surface(context).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(
                    color: AppColors.border(context),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm.w),
                      decoration: BoxDecoration(
                        color: (iconColor ?? AppColors.primary).withOpacity(
                          0.1,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                      child: Icon(
                        icon ?? Icons.notifications_outlined,
                        color: iconColor ?? AppColors.primary,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md.w),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.reminderTitle(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: AppSpacing.xxs.h),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 14.sp,
                                color: AppColors.textSecondary(context),
                              ),
                              SizedBox(width: AppSpacing.xxs.w),
                              Text(
                                _formatDateTime(dateTime),
                                style: AppTypography.caption(),
                              ),
                              if (repeat != null) ...[
                                SizedBox(width: AppSpacing.sm.w),
                                Icon(
                                  Icons.repeat,
                                  size: 14.sp,
                                  color: AppColors.textSecondary(context),
                                ),
                                SizedBox(width: AppSpacing.xxs.w),
                                Text(repeat!, style: AppTypography.caption()),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Dismiss button
                    if (onDismiss != null)
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: AppColors.textSecondary(context),
                        ),
                        onPressed: onDismiss,
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (dateOnly == today) {
      dateStr = 'Today';
    } else if (dateOnly == tomorrow) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$dateStr at $hour:$minute';
  }
}

/// Stats card for dashboard
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: EdgeInsets.all(AppSpacing.md.w),
              decoration: BoxDecoration(
                color:
                    backgroundColor ??
                    AppColors.surface(context).withOpacity(0.7),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.border(context), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm.w),
                    decoration: BoxDecoration(
                      color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? AppColors.primary,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md.h),

                  // Value
                  Text(value, style: AppTypography.display1()),
                  SizedBox(height: AppSpacing.xxs.h),

                  // Title
                  Text(title, style: AppTypography.caption()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Quick action card
class QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: EdgeInsets.all(AppSpacing.md.w),
              decoration: BoxDecoration(
                color: AppColors.surface(context).withOpacity(0.7),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.border(context), width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: iconColor ?? AppColors.primary,
                    size: 32.sp,
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  Text(
                    title,
                    style: AppTypography.body2(),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Empty state card
class EmptyStateCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const EmptyStateCard({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64.sp,
              color: AppColors.textSecondary(context).withOpacity(0.5),
            ),
            SizedBox(height: AppSpacing.lg.h),
            Text(
              title,
              style: AppTypography.heading2(),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm.h),
            Text(
              message,
              style: AppTypography.body1().copyWith(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onActionPressed != null) ...[
              SizedBox(height: AppSpacing.lg.h),
              ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl.w,
                    vertical: AppSpacing.md.h,
                  ),
                ),
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
