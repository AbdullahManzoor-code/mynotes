import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/note.dart';
import 'media_player_widget.dart';

/// Note Card Widget
/// Displays individual note in grid/list view
class NoteCardWidget extends StatelessWidget {
  final Note note;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;
  final VoidCallback onPin;
  final Function(NoteColor) onColorChange;

  const NoteCardWidget({
    Key? key,
    required this.note,
    this.isSelected = false,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
    required this.onPin,
    required this.onColorChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Color(
      isDark ? note.color.darkColor : note.color.lightColor,
    );

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        color: backgroundColor.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          side: BorderSide(
            color: isSelected ? AppColors.primaryLight : Colors.transparent,
            width: isSelected ? 3 : 0,
          ),
        ),
        elevation: isSelected
            ? AppConstants.highElevation
            : AppConstants.defaultElevation,
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    note.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Content preview
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text content
                        if (note.content.isNotEmpty)
                          Text(
                            note.content,
                            maxLines: note.hasMedia ? 2 : 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),

                        // Media preview
                        if (note.hasMedia) ...[
                          SizedBox(height: 8.h),
                          SizedBox(
                            height: 60.h,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: note.media.length > 3
                                  ? 3
                                  : note.media.length,
                              itemBuilder: (context, index) {
                                final mediaItem = note.media[index];
                                return Padding(
                                  padding: EdgeInsets.only(right: 8.w),
                                  child: MediaPlayerWidget(
                                    mediaPath: mediaItem.filePath,
                                    mediaType: mediaItem.type.name,
                                    thumbnailPath: mediaItem.thumbnailPath,
                                    onPlay: () {
                                      // Handle media play - could open full screen player
                                      // For now, just trigger the card tap
                                      onTap();
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Metadata row
                  Row(
                    children: [
                      // Date
                      Expanded(
                        child: Text(
                          AppDateUtils.getRelativeTime(note.updatedAt),
                          style: Theme.of(context).textTheme.labelSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Media indicators
                      if (note.hasMedia)
                        Row(
                          children: [
                            if (note.imagesCount > 0)
                              Tooltip(
                                message: '${note.imagesCount} images',
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  child: Icon(
                                    Icons.image,
                                    size: 14,
                                    color: AppColors.imageColor.withOpacity(
                                      0.7,
                                    ),
                                  ),
                                ),
                              ),
                            if (note.audioCount > 0)
                              Tooltip(
                                message: '${note.audioCount} audio',
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  child: Icon(
                                    Icons.mic,
                                    size: 14,
                                    color: AppColors.audioColor.withOpacity(
                                      0.7,
                                    ),
                                  ),
                                ),
                              ),
                            if (note.videoCount > 0)
                              Tooltip(
                                message: '${note.videoCount} videos',
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  child: Icon(
                                    Icons.videocam,
                                    size: 14,
                                    color: AppColors.videoColor.withOpacity(
                                      0.7,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                      // Alarm indicator
                      if (note.hasAlarms)
                        Row(
                          children: [
                            SizedBox(width: 4.w),
                            Tooltip(
                              message:
                                  '${note.alarms!.length} reminder${note.alarms!.length > 1 ? 's' : ''}',
                              child: Icon(
                                Icons.alarm,
                                size: 14,
                                color: AppColors.warningColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  // Todo progress
                  if (note.hasTodos) ...[
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: note.completionPercentage / 100,
                              minHeight: 4,
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.successColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '${note.todos!.where((t) => t.isCompleted).length}/${note.todos!.length}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: AppColors.onPrimary,
                    size: 16.sp,
                  ),
                ),
              ),

            // Pin indicator
            if (note.isPinned)
              Positioned(
                top: 8.r,
                left: 8.r,
                child: Icon(
                  Icons.push_pin,
                  size: 16.sp,
                  color: AppColors.grey600,
                ),
              ),

            // Popup menu
            Positioned(
              bottom: 8.r,
              right: 8.r,
              child: PopupMenuButton<String>(
                onSelected: (value) => _handleAction(value),
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: 'pin',
                    child: Row(
                      children: [
                        Icon(
                          note.isPinned
                              ? Icons.push_pin_outlined
                              : Icons.push_pin,
                          size: 18,
                        ),
                        SizedBox(width: 8.w),
                        Text(note.isPinned ? 'Unpin' : 'Pin'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'share',
                    child: const Row(
                      children: [
                        Icon(Icons.share, size: 18),
                        SizedBox(width: 8),
                        Text('Share'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete,
                          size: 18.sp,
                          color: AppColors.errorColor,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Delete',
                          style: TextStyle(color: AppColors.errorColor),
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

  void _handleAction(String action) {
    switch (action) {
      case 'pin':
        onPin();
        break;
      case 'delete':
        onDelete();
        break;
      case 'share':
        _shareNote();
        break;
    }
  }

  void _shareNote() {
    final shareText =
        '''
${note.title}

${note.content}

Shared from My Notes
    '''
            .trim();

    Share.share(shareText, subject: note.title);
  }
}
