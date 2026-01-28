import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../design_system/design_system.dart';
import '../../domain/entities/note.dart';

/// Note Card Widget
/// Displays individual note in list view using the new Design System
class NoteCardWidget extends StatelessWidget {
  final Note note;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onDelete;
  final VoidCallback? onPin;
  final Function(dynamic)? onColorChange;

  const NoteCardWidget({
    Key? key,
    required this.note,
    this.isSelected = false,
    required this.onTap,
    required this.onLongPress,
    this.onDelete,
    this.onPin,
    this.onColorChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardBackground : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark
                      ? Colors.white.withOpacity(0.05)
                      : AppColors.borderLight),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title + Time Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (note.isPinned)
                        Padding(
                          padding: EdgeInsets.only(right: 6.w),
                          child: Icon(
                            Icons.push_pin,
                            size: 14.sp,
                            color: AppColors.primary,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          note.title.isEmpty ? 'Untitled' : note.title,
                          style: AppTypography.bodyMedium(
                            context,
                            null,
                            FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  _getTimeAgo(note.updatedAt).toUpperCase(),
                  style: AppTypography.caption(
                    AppColors.textMuted,
                    null,
                    FontWeight.w500,
                  ).copyWith(fontSize: 10.sp, letterSpacing: 0.3),
                ),
              ],
            ),

            // Content Preview
            if (note.content.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                note.content,
                style: AppTypography.bodySmall(
                  isDark ? const Color(0xFF9DB2B9) : AppColors.textMuted,
                ).copyWith(height: 1.5),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Tags
            if (note.tags.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 6.h,
                children: note.tags
                    .take(3)
                    .map((tag) => _buildTag(tag, isDark))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String tag, bool isDark) {
    final color = _getTagColor(tag);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        tag.toUpperCase(),
        style: AppTypography.caption(
          color,
          null,
          FontWeight.w700,
        ).copyWith(fontSize: 10.sp),
      ),
    );
  }

  Color _getTagColor(String tag) {
    final lowerTag = tag.toLowerCase();
    if (lowerTag.contains('work')) return AppColors.primary;
    if (lowerTag.contains('personal')) return AppColors.accentOrange;
    if (lowerTag.contains('journal') || lowerTag.contains('reflection')) {
      return AppColors.successGreen;
    }
    if (lowerTag.contains('travel')) return AppColors.accentBlue;
    if (lowerTag.contains('idea') || lowerTag.contains('brainstorm')) {
      return AppColors.accentPurple;
    }
    return AppColors.primary;
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}
