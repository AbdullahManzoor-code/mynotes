import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'package:mynotes/core/services/app_logger.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/presentation/widgets/media/media_card.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// PHASE 4: MEDIA & ATTACHMENTS
/// Media Header - Media details and upload options
/// ════════════════════════════════════════════════════════════════════════════

class MediaHeader extends StatefulWidget {
  final MediaItem? media;
  final String? title;
  final Function(String)? onTitleChanged;
  final Function()? onUploadPressed;
  final bool isEditing;

  const MediaHeader({
    super.key,
    this.media,
    this.title,
    this.onTitleChanged,
    this.onUploadPressed,
    this.isEditing = false,
  });

  @override
  State<MediaHeader> createState() => _MediaHeaderState();
}

class _MediaHeaderState extends State<MediaHeader> {
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        border: Border(
          bottom: BorderSide(color: context.theme.dividerColor, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title input
          if (widget.isEditing)
            TextFormField(
              controller: _titleController,
              onChanged: widget.onTitleChanged,
              style: AppTypography.heading2(
                context,
              ).copyWith(fontSize: 18.sp, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Enter media title',
                hintStyle: AppTypography.body1(
                  context,
                ).copyWith(fontSize: 16.sp, color: context.theme.disabledColor),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            )
          else
            Text(
              widget.title ?? 'Media Details',
              style: AppTypography.heading2(
                context,
              ).copyWith(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
          SizedBox(height: 16.h),
          // Media info grid
          if (widget.media != null)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem(
                      context,
                      Icons.insert_drive_file_outlined,
                      'Type',
                      _getMediaTypeLabel(widget.media!.type),
                    ),
                    _buildInfoItem(
                      context,
                      Icons.storage_outlined,
                      'Size',
                      _formatFileSize(widget.media!.sizeBytes),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                if (widget.media!.width != null && widget.media!.height != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem(
                        context,
                        Icons.aspect_ratio_outlined,
                        'Dimensions',
                        '${widget.media!.width}×${widget.media!.height}',
                      ),
                      _buildInfoItem(
                        context,
                        Icons.timer_outlined,
                        'Duration',
                        widget.media!.durationSeconds != null
                            ? _formatDuration(widget.media!.durationSeconds!)
                            : 'N/A',
                      ),
                    ],
                  ),
              ],
            ),
          SizedBox(height: 16.h),
          // Upload button
          if (widget.onUploadPressed != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  AppLogger.i('Upload media pressed');
                  widget.onUploadPressed?.call();
                },
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text('Upload Media'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build info item
  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16.r, color: AppColors.primary),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption(context).copyWith(
                    fontSize: 10.sp,
                    color: context.theme.disabledColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body2(
                    context,
                  ).copyWith(fontSize: 12.sp, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
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
}
