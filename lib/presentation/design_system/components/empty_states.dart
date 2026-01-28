import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../design_system.dart';

/// Empty State Widget - Generic empty state display
/// Based on template: empty_state_notes_help & empty_state_todos_help
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Color? iconColor;
  final Color? backgroundColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.buttonText,
    this.onButtonPressed,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 48.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon Container
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color:
                    backgroundColor ??
                    (iconColor ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: (iconColor ?? AppColors.primary).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 56.sp,
                color: iconColor ?? AppColors.primary,
              ),
            ),
            SizedBox(height: 24.h),

            // Title
            Text(
              title,
              style: AppTypography.heading2(context, null, FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            // Description
            Text(
              description,
              style: AppTypography.bodyMedium(
                isDark ? AppColors.textSecondary : AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),

            // Button (if provided)
            if (buttonText != null && onButtonPressed != null) ...[
              SizedBox(height: 32.h),
              PrimaryButton(
                text: buttonText!,
                onPressed: onButtonPressed,
                isFullWidth: false,
                width: 200.w,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty State for Notes
class EmptyStateNotes extends StatelessWidget {
  final VoidCallback? onCreateNote;

  const EmptyStateNotes({super.key, this.onCreateNote});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.description_outlined,
      title: 'No notes yet',
      description:
          'Start capturing your thoughts, ideas, and important information.',
      buttonText: 'Create Note',
      onButtonPressed: onCreateNote,
      iconColor: AppColors.primary,
    );
  }
}

/// Empty State for Todos
class EmptyStateTodos extends StatelessWidget {
  final VoidCallback? onCreateTodo;

  const EmptyStateTodos({super.key, this.onCreateTodo});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.check_box_outlined,
      title: 'No todos yet',
      description:
          'Stay organized by creating your first task and tracking your progress.',
      buttonText: 'Create Todo',
      onButtonPressed: onCreateTodo,
      iconColor: AppColors.primary,
    );
  }
}

/// Empty State for Reminders
class EmptyStateReminders extends StatelessWidget {
  final VoidCallback? onCreateReminder;

  const EmptyStateReminders({super.key, this.onCreateReminder});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.notifications_outlined,
      title: 'No reminders yet',
      description: 'Never forget important tasks. Set your first reminder now.',
      buttonText: 'Create Reminder',
      onButtonPressed: onCreateReminder,
      iconColor: AppColors.accentOrange,
    );
  }
}

/// Empty Search Results
class EmptySearchResults extends StatelessWidget {
  final String query;

  const EmptySearchResults({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No results found',
      description: 'Try adjusting your search terms or filters.',
      iconColor: AppColors.textSecondary(context),
    );
  }
}
