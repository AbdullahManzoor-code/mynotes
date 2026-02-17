import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'package:mynotes/core/extensions/date_extensions.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/presentation/widgets/media/media_card.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// PHASE 4: MEDIA & ATTACHMENTS
/// Media Metadata - Detailed media information and stats
/// ════════════════════════════════════════════════════════════════════════════

class MediaMetadata extends StatelessWidget {
  final MediaItem media;
  final bool showFullInfo;

  const MediaMetadata({
    super.key,
    required this.media,
    this.showFullInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.theme.dividerColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Storage info section
          _buildMetadataSection(context, 'Storage', [
            _buildMetadataItem(
              context,
              Icons.storage_outlined,
              'File Size',
              _formatFileSize(media.sizeBytes),
            ),
            if (media.width != null && media.height != null)
              _buildMetadataItem(
                context,
                Icons.aspect_ratio_outlined,
                'Dimensions',
                '${media.width}×${media.height}',
              ),
            if (media.durationSeconds != null)
              _buildMetadataItem(
                context,
                Icons.timer_outlined,
                'Duration',
                _formatDuration(media.durationSeconds!),
              ),
          ]),
          SizedBox(height: 16.h),
          // File info section
          _buildMetadataSection(context, 'File Information', [
            _buildMetadataItem(
              context,
              Icons.label_outlined,
              'Type',
              _getMediaTypeLabel(media.type),
            ),
            _buildMetadataItem(
              context,
              Icons.upload_outlined,
              'Uploaded',
              media.uploadedAt.formatDate(),
            ),
            _buildMetadataItem(
              context,
              Icons.file_present_outlined,
              'File ID',
              '${media.id.substring(0, 8)}...',
            ),
          ]),
          // Linked items section
          if (media.linkedNoteId != null || media.linkedTodoId != null) ...[
            SizedBox(height: 16.h),
            _buildMetadataSection(context, 'Linked Items', [
              if (media.linkedNoteId != null)
                _buildMetadataItem(
                  context,
                  Icons.note_outlined,
                  'Linked Note',
                  '${media.linkedNoteId!.substring(0, 8)}...',
                  onTap: () {
                    // Navigate to note
                  },
                ),
              if (media.linkedTodoId != null)
                _buildMetadataItem(
                  context,
                  Icons.check_circle_outline,
                  'Linked Todo',
                  '${media.linkedTodoId!.substring(0, 8)}...',
                  onTap: () {
                    // Navigate to todo
                  },
                ),
            ]),
          ],
          // Upload details section
          if (media.isUploading) ...[
            SizedBox(height: 16.h),
            _buildMetadataSection(context, 'Upload Progress', [
              _buildProgressItem(context, media.uploadProgress),
            ]),
          ],
          // Detailed stats section
          if (showFullInfo) ...[
            SizedBox(height: 16.h),
            _buildMetadataSection(context, 'Statistics', [
              _buildMetadataItem(
                context,
                Icons.folder_outlined,
                'Storage Used',
                _calculateStoragePercentage(media.sizeBytes),
              ),
              _buildMetadataItem(
                context,
                Icons.access_time_outlined,
                'Last Accessed',
                media.uploadedAt.formatDate(),
              ),
            ]),
          ],
        ],
      ),
    );
  }

  /// Build metadata section
  Widget _buildMetadataSection(
    BuildContext context,
    String title,
    List<Widget> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.body1(context).copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: context.theme.disabledColor,
          ),
        ),
        SizedBox(height: 8.h),
        ...items,
      ],
    );
  }

  /// Build metadata item
  Widget _buildMetadataItem(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 14.r,
                  color: AppColors.primary.withOpacity(0.6),
                ),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: AppTypography.body2(context).copyWith(
                    fontSize: 11.sp,
                    color: context.theme.disabledColor,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: AppTypography.body2(
                context,
              ).copyWith(fontSize: 11.sp, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  /// Build progress item
  Widget _buildProgressItem(BuildContext context, double progress) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upload Progress',
              style: AppTypography.body2(
                context,
              ).copyWith(fontSize: 11.sp, color: context.theme.disabledColor),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: AppTypography.body2(context).copyWith(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4.h,
            backgroundColor: context.theme.dividerColor.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }

  /// Get media type label
  String _getMediaTypeLabel(String type) {
    switch (type) {
      case 'image':
        return 'Image';
      case 'video':
        return 'Video';
      case 'audio':
        return 'Audio';
      case 'document':
        return 'Document';
      case 'pdf':
        return 'PDF';
      default:
        return 'Media';
    }
  }

  /// Format file size
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Format duration
  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  /// Calculate storage percentage
  String _calculateStoragePercentage(int bytes) {
    final totalStorage = 5 * 1024 * 1024 * 1024; // 5GB default
    final percentage = (bytes / totalStorage) * 100;
    return '${percentage.toStringAsFixed(1)}% of 5GB';
  }
}
