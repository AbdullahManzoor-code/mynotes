import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'package:mynotes/core/extensions/date_extensions.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// PHASE 6: REFLECTIONS & INSIGHTS
/// Reflection Card - Individual reflection/insight display
/// ════════════════════════════════════════════════════════════════════════════

class Reflection {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final List<String> tags;
  final int? relatedNoteId;
  final int? relatedTodoId;
  final ReflectionMood mood; // happy, neutral, sad, inspired, grateful
  final int? insightScore; // 0-100 confidence

  Reflection({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.tags = const [],
    this.relatedNoteId,
    this.relatedTodoId,
    this.mood = ReflectionMood.neutral,
    this.insightScore,
  });
}

enum ReflectionMood { happy, neutral, sad, inspired, grateful }

class ReflectionCard extends StatelessWidget {
  final Reflection reflection;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final Function(String)? onDelete;
  final bool enableActions;

  const ReflectionCard({
    super.key,
    required this.reflection,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.enableActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: context.theme.dividerColor, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with mood and date
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildMoodEmoji(reflection.mood),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reflection.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.body1(context).copyWith(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            reflection.createdAt.formatDate(),
                            style: AppTypography.caption(context).copyWith(
                              fontSize: 10.sp,
                              color: context.theme.disabledColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (enableActions)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, size: 16.r),
                      onSelected: (value) {
                        if (value == 'edit') onEdit?.call();
                        if (value == 'delete') onDelete?.call(reflection.id);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // Content preview
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                reflection.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body2(context).copyWith(
                  fontSize: 11.sp,
                  color: context.theme.disabledColor,
                  height: 1.4,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            // Tags
            if (reflection.tags.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Wrap(
                  spacing: 4.w,
                  children: reflection.tags
                      .map(
                        (tag) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            tag,
                            style: AppTypography.caption(context).copyWith(
                              fontSize: 8.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            SizedBox(height: 10.h),
            // Insight score if available
            if (reflection.insightScore != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Insight Score',
                          style: AppTypography.caption(context).copyWith(
                            fontSize: 9.sp,
                            color: context.theme.disabledColor,
                          ),
                        ),
                        Text(
                          '${reflection.insightScore}%',
                          style: AppTypography.body2(context).copyWith(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: (reflection.insightScore ?? 0) / 100,
                        minHeight: 2.h,
                        backgroundColor: context.theme.dividerColor.withOpacity(
                          0.3,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodEmoji(ReflectionMood mood) {
    final emoji = switch (mood) {
      ReflectionMood.happy => '😊',
      ReflectionMood.neutral => '😐',
      ReflectionMood.sad => '😔',
      ReflectionMood.inspired => '🌟',
      ReflectionMood.grateful => '🙏',
    };

    return Text(emoji, style: TextStyle(fontSize: 20.sp));
  }
}
