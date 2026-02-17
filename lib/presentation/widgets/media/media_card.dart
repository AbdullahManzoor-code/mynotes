import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'package:mynotes/core/extensions/date_extensions.dart';
import 'package:mynotes/core/services/app_logger.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// PHASE 4: MEDIA & ATTACHMENTS
/// Media Card - Individual media item display
/// ════════════════════════════════════════════════════════════════════════════

/// Media item data model
class MediaItem {
  final String id;
  final String name;
  final String type; // 'image', 'video', 'audio', 'document', 'pdf'
  final DateTime uploadedAt;
  final int sizeBytes;
  final String? thumbnailPath;
  final String filePath;
  final int? durationSeconds; // For video/audio
  final int? width; // For images/video
  final int? height; // For images/video
  final String? linkedNoteId;
  final String? linkedTodoId;
  final bool isUploading;
  final double uploadProgress; // 0.0 to 1.0

  MediaItem({
    required this.id,
    required this.name,
    required this.type,
    required this.uploadedAt,
    required this.sizeBytes,
    this.thumbnailPath,
    required this.filePath,
    this.durationSeconds,
    this.width,
    this.height,
    this.linkedNoteId,
    this.linkedTodoId,
    this.isUploading = false,
    this.uploadProgress = 0.0,
  });
}

/// Media Card Widget
class MediaCard extends StatelessWidget {
  final MediaItem media;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function(String)? onDelete;
  final Function(String)? onDownload;
  final Function(String)? onShare;
  final bool enableActions;

  const MediaCard({
    super.key,
    required this.media,
    this.onTap,
    this.onLongPress,
    this.onDelete,
    this.onDownload,
    this.onShare,
    this.enableActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
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
            // Thumbnail or type icon
            _buildThumbnail(context),
            // Content section
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // File name and type
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              media.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.body1(context).copyWith(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _getTypeLabel(),
                              style: AppTypography.caption(context).copyWith(
                                fontSize: 11.sp,
                                color: context.theme.disabledColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (enableActions) _buildActionMenu(context),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Size and date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatFileSize(media.sizeBytes),
                        style: AppTypography.caption(
                          context,
                        ).copyWith(fontSize: 10.sp),
                      ),
                      Text(
                        media.uploadedAt.formatDate(),
                        style: AppTypography.caption(
                          context,
                        ).copyWith(fontSize: 10.sp),
                      ),
                    ],
                  ),
                  // Duration badge (for video/audio)
                  if (media.durationSeconds != null)
                    Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          _formatDuration(media.durationSeconds!),
                          style: AppTypography.caption(context).copyWith(
                            fontSize: 9.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  // Upload progress bar
                  if (media.isUploading)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: LinearProgressIndicator(
                              value: media.uploadProgress,
                              minHeight: 3.h,
                              backgroundColor: context.theme.dividerColor
                                  .withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${(media.uploadProgress * 100).toStringAsFixed(0)}%',
                            style: AppTypography.caption(context).copyWith(
                              fontSize: 9.sp,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Linked item indicator
                  if (media.linkedNoteId != null || media.linkedTodoId != null)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Row(
                        children: [
                          Icon(
                            media.linkedNoteId != null
                                ? Icons.note_outlined
                                : Icons.check_circle_outline,
                            size: 12.r,
                            color: AppColors.primary.withOpacity(0.7),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            media.linkedNoteId != null
                                ? 'Linked to note'
                                : 'Linked to todo',
                            style: AppTypography.caption(context).copyWith(
                              fontSize: 9.sp,
                              color: AppColors.primary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build thumbnail or type icon
  Widget _buildThumbnail(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150.h,
      decoration: BoxDecoration(
        color: context.theme.disabledColor.withOpacity(0.05),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Thumbnail image if available
          if (media.thumbnailPath != null && media.type == 'image')
            Image.asset(
              media.thumbnailPath!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )
          else
            Icon(
              _getMediaTypeIcon(),
              size: 50.r,
              color: context.theme.disabledColor.withOpacity(0.3),
            ),
          // Upload/download progress overlay
          if (media.isUploading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(
                  value: media.uploadProgress,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          // Duration badge for video/audio
          if (media.durationSeconds != null && media.type == 'video')
            Positioned(
              bottom: 8.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  _formatDuration(media.durationSeconds!),
                  style: AppTypography.caption(context).copyWith(
                    fontSize: 10.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          // Dimensions badge for images
          if (media.width != null &&
              media.height != null &&
              media.type == 'image')
            Positioned(
              top: 8.w,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '${media.width}×${media.height}',
                  style: AppTypography.caption(
                    context,
                  ).copyWith(fontSize: 9.sp, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build action menu
  Widget _buildActionMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: 18.r),
      onSelected: (value) {
        AppLogger.i('Media action selected: $value for media ${media.id}');
        switch (value) {
          case 'download':
            onDownload?.call(media.id);
            break;
          case 'share':
            onShare?.call(media.id);
            break;
          case 'delete':
            onDelete?.call(media.id);
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'download',
          child: Row(
            children: [
              Icon(Icons.download, size: 16.r),
              SizedBox(width: 8.w),
              const Text('Download'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share, size: 16.r),
              SizedBox(width: 8.w),
              const Text('Share'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 16.r, color: Colors.red),
              SizedBox(width: 8.w),
              const Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  /// Get media type label
  String _getTypeLabel() {
    switch (media.type) {
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

  /// Get media type icon
  IconData _getMediaTypeIcon() {
    switch (media.type) {
      case 'image':
        return Icons.image_outlined;
      case 'video':
        return Icons.videocam_outlined;
      case 'audio':
        return Icons.audio_file_outlined;
      case 'document':
        return Icons.description_outlined;
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      default:
        return Icons.attachment_outlined;
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
}
