import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/domain/entities/note.dart';
import 'package:mynotes/core/constants/app_strings.dart';
import 'package:mynotes/core/extensions/extensions.dart';

/// Unified note metadata widget
/// Displays note information like dates, word count, and status
class NoteMetadata extends StatelessWidget {
  final Note note;
  final int? wordCount;
  final int? characterCount;
  final bool showFullInfo;

  const NoteMetadata({
    super.key,
    required this.note,
    this.wordCount,
    this.characterCount,
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
          // Main metadata row
          _buildMainMetadata(context),
          if (showFullInfo) ...[
            SizedBox(height: 12.h),
            Divider(height: 0, color: context.theme.dividerColor),
            SizedBox(height: 12.h),
            // Detailed metadata
            _buildDetailedMetadata(context),
          ],
        ],
      ),
    );
  }

  Widget _buildMainMetadata(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Created date
        _buildMetadataItem(
          context,
          icon: Icons.calendar_today,
          label: AppStrings.created,
          value: note.createdAt.formatDate(),
        ),
        // Updated date
        _buildMetadataItem(
          context,
          icon: Icons.update,
          label: AppStrings.updated,
          value: note.updatedAt.formatRelative(),
        ),
        // Word count
        if (wordCount != null)
          _buildMetadataItem(
            context,
            icon: Icons.text_fields,
            label: AppStrings.words,
            value: wordCount.toString(),
          ),
      ],
    );
  }

  Widget _buildDetailedMetadata(BuildContext context) {
    return Column(
      children: [
        // Status indicators
        _buildStatusRow(context),
        SizedBox(height: 12.h),
        // Character count and content preview
        _buildContentStats(context),
        ...[SizedBox(height: 12.h), _buildCategoryTag(context)],
      ],
    );
  }

  Widget _buildStatusRow(BuildContext context) {
    return Wrap(
      spacing: 16.w,
      runSpacing: 8.h,
      children: [
        if (note.isPinned)
          _buildStatusBadge(context, AppStrings.pinned, Colors.amber),
        if (note.isArchived)
          _buildStatusBadge(context, AppStrings.archived, Colors.grey),
        if (note.isFavorite)
          _buildStatusBadge(context, AppStrings.favorite, Colors.red),
        _buildStatusBadge(
          context,
          _getPriorityLabel(NotePriority.values[note.priority]),
          _getPriorityColor(NotePriority.values[note.priority]),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTypography.caption(context).copyWith(
              fontSize: 11.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentStats(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Character count
        if (characterCount != null)
          _buildMetadataItem(
            context,
            icon: Icons.abc,
            label: AppStrings.characters,
            value: characterCount.toString(),
            compact: true,
          ),
        // Media count
        if (note.media.isNotEmpty)
          _buildMetadataItem(
            context,
            icon: Icons.image,
            label: AppStrings.media,
            value: note.media.length.toString(),
            compact: true,
          ),
        // Links count
        if (note.links.isNotEmpty)
          _buildMetadataItem(
            context,
            icon: Icons.link,
            label: AppStrings.links,
            value: note.links.length.toString(),
            compact: true,
          ),
        // Todos count
        if ((note.todos ?? []).isNotEmpty)
          _buildMetadataItem(
            context,
            icon: Icons.checklist,
            label: AppStrings.todos,
            value: note.todos!.length.toString(),
            compact: true,
          ),
      ],
    );
  }

  Widget _buildCategoryTag(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      children: [
        Text(
          '${AppStrings.category}:',
          style: AppTypography.caption(
            context,
          ).copyWith(fontSize: 12.sp, fontWeight: FontWeight.w500),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: context.theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: context.theme.primaryColor.withOpacity(0.3),
            ),
          ),
          child: Text(
            note.category,
            style: AppTypography.caption(
              context,
            ).copyWith(fontSize: 11.sp, color: context.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool compact = false,
  }) {
    if (compact) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.r, color: context.primaryColor),
          SizedBox(height: 4.h),
          Text(
            value,
            style: AppTypography.caption(
              context,
            ).copyWith(fontSize: 10.sp, fontWeight: FontWeight.w600),
          ),
          Text(
            label,
            style: AppTypography.caption(
              context,
            ).copyWith(fontSize: 9.sp, color: Colors.grey.shade600),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.r, color: context.primaryColor),
            SizedBox(width: 6.w),
            Text(
              label,
              style: AppTypography.caption(
                context,
              ).copyWith(fontSize: 11.sp, color: Colors.grey.shade600),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: AppTypography.body2(
            context,
          ).copyWith(fontSize: 12.sp, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  String _getPriorityLabel(NotePriority? priority) {
    switch (priority) {
      case NotePriority.low:
        return AppStrings.lowPriority;
      case NotePriority.medium:
        return AppStrings.mediumPriority;
      case NotePriority.high:
        return AppStrings.highPriority;
      case NotePriority.urgent:
        return AppStrings.urgentPriority;
      default:
        return AppStrings.noData;
    }
  }

  Color _getPriorityColor(NotePriority? priority) {
    switch (priority) {
      case NotePriority.low:
        return Colors.green;
      case NotePriority.medium:
        return Colors.blue;
      case NotePriority.high:
        return Colors.orange;
      case NotePriority.urgent:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

enum NotePriority { low, medium, high, urgent }
