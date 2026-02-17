import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'package:mynotes/core/services/app_logger.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/presentation/widgets/media/media_card.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// PHASE 4: MEDIA & ATTACHMENTS
/// Media Gallery - Advanced gallery view with masonry layout
/// ════════════════════════════════════════════════════════════════════════════

class MediaGallery extends StatelessWidget {
  final List<MediaItem> mediaItems;
  final Function(MediaItem)? onMediaTap;
  final Function(String)? onMediaDelete;
  final Function(String)? onMediaDownload;
  final int crossAxisCount;
  final bool enableActions;

  const MediaGallery({
    super.key,
    required this.mediaItems,
    this.onMediaTap,
    this.onMediaDelete,
    this.onMediaDownload,
    this.crossAxisCount = 2,
    this.enableActions = true,
  });

  @override
  Widget build(BuildContext context) {
    if (mediaItems.isEmpty) {
      return _buildEmptyState(context);
    }

    return Padding(
      padding: EdgeInsets.all(12.w),
      child: MasonryGridView.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12.w,
        crossAxisSpacing: 12.w,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: mediaItems.length,
        itemBuilder: (context, index) =>
            _buildGalleryItem(context, mediaItems[index]),
      ),
    );
  }

  /// Build gallery item
  Widget _buildGalleryItem(BuildContext context, MediaItem media) {
    return GestureDetector(
      onTap: () {
        AppLogger.i('Gallery media tapped: ${media.id}');
        onMediaTap?.call(media);
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: context.theme.dividerColor, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Thumbnail
            Container(
              decoration: BoxDecoration(
                color: context.theme.disabledColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: media.thumbnailPath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.asset(
                        media.thumbnailPath!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  : Center(
                      child: Icon(
                        _getMediaIcon(media.type),
                        size: 40.r,
                        color: context.theme.disabledColor.withOpacity(0.3),
                      ),
                    ),
            ),
            // Overlay gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                ),
              ),
            ),
            // Bottom info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      media.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption(context).copyWith(
                        fontSize: 10.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatFileSize(media.sizeBytes),
                          style: AppTypography.caption(context).copyWith(
                            fontSize: 8.sp,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        if (media.durationSeconds != null)
                          Text(
                            _formatDuration(media.durationSeconds!),
                            style: AppTypography.caption(context).copyWith(
                              fontSize: 8.sp,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Action buttons
            if (enableActions)
              Positioned(
                top: 4.w,
                right: 4.w,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 14.r,
                      color: Colors.white,
                    ),
                    onSelected: (value) {
                      AppLogger.i('Gallery action: $value');
                      switch (value) {
                        case 'download':
                          onMediaDownload?.call(media.id);
                          break;
                        case 'delete':
                          onMediaDelete?.call(media.id);
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'download',
                        child: Row(
                          children: [
                            Icon(Icons.download, size: 14),
                            SizedBox(width: 6),
                            Text('Download', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 14, color: Colors.red),
                            SizedBox(width: 6),
                            const Text(
                              'Delete',
                              style: TextStyle(fontSize: 12, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 64.r,
              color: context.theme.disabledColor.withOpacity(0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              'No Media Found',
              style: AppTypography.heading2(
                context,
              ).copyWith(fontSize: 14.sp, color: context.theme.disabledColor),
            ),
            SizedBox(height: 8.h),
            Text(
              'Try adjusting your filters',
              textAlign: TextAlign.center,
              style: AppTypography.body2(context).copyWith(
                fontSize: 12.sp,
                color: context.theme.disabledColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get media icon
  IconData _getMediaIcon(String type) {
    switch (type) {
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
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Format duration
  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}
