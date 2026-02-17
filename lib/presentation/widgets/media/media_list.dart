import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'package:mynotes/core/services/app_logger.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/presentation/widgets/media/media_card.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// PHASE 4: MEDIA & ATTACHMENTS
/// Media List - Reusable media items list component
/// ════════════════════════════════════════════════════════════════════════════

class MediaList extends StatelessWidget {
  final List<MediaItem> allMedia;
  final List<MediaItem> uploading;
  final Function(MediaItem)? onMediaTap;
  final Function(String)? onMediaDelete;
  final Function(String)? onMediaDownload;
  final Function(String)? onMediaShare;
  final bool showUploadingSection;
  final bool enableActions;
  final bool isGridView;

  const MediaList({
    super.key,
    required this.allMedia,
    this.uploading = const [],
    this.onMediaTap,
    this.onMediaDelete,
    this.onMediaDownload,
    this.onMediaShare,
    this.showUploadingSection = true,
    this.enableActions = true,
    this.isGridView = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Uploading section
        if (showUploadingSection && uploading.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8.r,
                        height: 8.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Uploading (${uploading.length})',
                        style: AppTypography.body1(context).copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildMediaGrid(context, uploading),
                ],
              ),
            ),
          ),
        // All media section
        if (allMedia.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8.r,
                        height: 8.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'All Media (${allMedia.length})',
                        style: AppTypography.body1(context).copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildMediaGrid(context, allMedia),
                ],
              ),
            ),
          ),
        // Empty state
        if (allMedia.isEmpty && uploading.isEmpty)
          SliverToBoxAdapter(child: _buildEmptyState(context)),
      ],
    );
  }

  /// Build media grid/list
  Widget _buildMediaGrid(BuildContext context, List<MediaItem> media) {
    if (isGridView) {
      return MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12.w,
        crossAxisSpacing: 12.w,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: media.length,
        itemBuilder: (context, index) => _buildMediaCard(context, media[index]),
      );
    } else {
      return Column(
        children: List.generate(
          media.length,
          (index) => Padding(
            padding: EdgeInsets.only(
              bottom: index < media.length - 1 ? 12.h : 0,
            ),
            child: _buildMediaCard(context, media[index]),
          ),
        ),
      );
    }
  }

  /// Build individual media card
  Widget _buildMediaCard(BuildContext context, MediaItem media) {
    return MediaCard(
      media: media,
      enableActions: enableActions,
      onTap: () {
        AppLogger.i('Media tapped: ${media.id}');
        onMediaTap?.call(media);
      },
      onDelete: onMediaDelete,
      onDownload: onMediaDownload,
      onShare: onMediaShare,
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 60.h),
          Icon(
            Icons.image_not_supported_outlined,
            size: 80.r,
            color: context.theme.disabledColor.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Media Yet',
            style: AppTypography.heading2(
              context,
            ).copyWith(fontSize: 16.sp, color: context.theme.disabledColor),
          ),
          SizedBox(height: 8.h),
          Text(
            'Upload images, videos, and documents',
            textAlign: TextAlign.center,
            style: AppTypography.body2(context).copyWith(
              fontSize: 12.sp,
              color: context.theme.disabledColor.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 60.h),
        ],
      ),
    );
  }
}
