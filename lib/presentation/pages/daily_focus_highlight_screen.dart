import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/domain/entities/todo_item.dart';
import 'package:mynotes/presentation/bloc/note_bloc.dart';
import 'package:mynotes/presentation/bloc/note_state.dart';
import 'package:mynotes/presentation/bloc/focus_bloc.dart';
import 'package:mynotes/presentation/design_system/app_typography.dart';
import 'package:mynotes/core/constants/app_colors.dart';
import 'package:mynotes/core/routes/app_routes.dart';

/// Screen: Daily Highlight Summary - G4
/// Displays today's highlight task, progress, and time spent.
class DailyFocusHighlightScreen extends StatelessWidget {
  const DailyFocusHighlightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Daily Highlight', style: AppTypography.heading3(context)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<NotesBloc, NoteState>(
        builder: (context, noteState) {
          if (noteState is NotesLoaded) {
            // Logic to find "Highlight": 
            // 1. Tagged with #highlight
            // 2. OR Priority = Urgent
            // 3. OR First High priority
            final highlightTask = _findHighlightTask(noteState.notes.whereType<TodoItem>().toList());

            if (highlightTask == null) {
              return _buildEmptyState(context);
            }

            return _buildHighlightContent(context, highlightTask);
          }
           return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  TodoItem? _findHighlightTask(List<TodoItem> todos) {
    // Try finding one with explicit tag in text
    try {
      return todos.firstWhere((t) => t.text.toLowerCase().contains('#highlight') && !t.isCompleted);
    } catch (_) {}

    // Try finding first urgent
    try {
       return todos.firstWhere((t) => t.priority == TodoPriority.urgent && !t.isCompleted);
    } catch (_) {
      return null;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white70 : Colors.black54;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_border, size: 64.sp, color: color),
          SizedBox(height: 16.h),
          Text(
            'No Daily Highlight Set',
            style: AppTypography.heading3(context).copyWith(color: color),
          ),
          SizedBox(height: 8.h),
          Text(
            'Mark a task as "Urgent" or add #highlight to set it.',
            style: AppTypography.bodyMedium(context).copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightContent(BuildContext context, TodoItem task) {
    return BlocBuilder<FocusBloc, FocusState>(
      builder: (context, focusState) {
        final completion = task.completionPercentage;
        final cardColor = Theme.of(context).cardColor;

        return Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'TODAY\'S HIGHLIGHT',
                      style: AppTypography.caption(context, AppColors.primary).copyWith(letterSpacing: 2, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      task.text.replaceAll('#highlight', '').trim(),
                      textAlign: TextAlign.center,
                      style: AppTypography.heading2(context),
                    ),
                    SizedBox(height: 24.h),
                    LinearProgressIndicator(
                      value: completion,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 8.h,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '${(completion * 100).toInt()}% Complete',
                      style: AppTypography.bodySmall(context, Colors.grey),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              Text('Related Subtasks', style: AppTypography.heading3(context)),
              SizedBox(height: 16.h),
              Expanded(
                child: task.subtasks.isEmpty 
                  ? const Center(child: Text('No subtasks', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: task.subtasks.length,
                      itemBuilder: (context, index) {
                        final sub = task.subtasks[index];
                        final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
                        return ListTile(
                          leading: Icon(
                            sub.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                            color: sub.isCompleted ? AppColors.accentGreen : Colors.grey,
                          ),
                          title: Text(
                            sub.text,
                            style: TextStyle(
                              decoration: sub.isCompleted ? TextDecoration.lineThrough : null,
                              color: sub.isCompleted ? Colors.grey : textColor,
                            ),
                          ),
                        );
                      },
                    ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to Focus Session with this task
                    Navigator.pushNamed(
                      context, 
                      AppRoutes.focusSession,
                      arguments: {
                        'todoTitle': task.text,
                        'todoId': task.id,
                      }
                    );
                  },
                  icon: const Icon(Icons.timer),
                  label: const Text('Focus on Highlight'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
