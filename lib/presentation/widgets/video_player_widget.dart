import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:io';
import '../design_system/design_system.dart';

/// Video metadata
class VideoMetadata {
  final String filePath;
  final String fileName;
  final int fileSize;
  final Duration duration;
  final String? thumbnailPath;
  final DateTime createdAt;

  VideoMetadata({
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.duration,
    this.thumbnailPath,
    required this.createdAt,
  });

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Widget for playing video attachments with a premium feel
class VideoPlayerWidget extends StatefulWidget {
  final VideoMetadata video;
  final VoidCallback? onDelete;

  const VideoPlayerWidget({super.key, required this.video, this.onDelete});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.file(
        File(widget.video.filePath),
      );

      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
          backgroundColor: AppColors.lightSurface.withOpacity(0.2),
          bufferedColor: AppColors.lightSurface.withOpacity(0.5),
        ),
        placeholder: widget.video.thumbnailPath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.file(
                  File(widget.video.thumbnailPath!),
                  fit: BoxFit.cover,
                ),
              )
            : Container(
                color: AppColors.darkText,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: AppColors.lightText),
            ),
          );
        },
      );

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
      debugPrint('Error initializing video player: $e');
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      borderRadius: 20.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.videocam_rounded,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.video.fileName,
                      style: AppTypography.heading4(
                        context,
                      ).copyWith(fontSize: 14.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${widget.video.formattedSize} • ${widget.video.formattedDuration}',
                      style: AppTypography.bodySmall(context),
                    ),
                  ],
                ),
              ),
              if (widget.onDelete != null)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.errorLight,
                    size: 22.sp,
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    widget.onDelete!();
                  },
                ),
            ],
          ),
          SizedBox(height: 12.h),
          if (_hasError)
            _buildErrorState()
          else if (_isInitialized && _chewieController != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: Chewie(controller: _chewieController!),
              ),
            )
          else
            Container(
              height: 200.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 150.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_camera_back_rounded,
            color: AppColors.errorDark,
            size: 32.sp,
          ),
          SizedBox(height: 8.h),
          Text('Video unavailable', style: AppTypography.bodyMedium(context)),
          SizedBox(height: 4.h),
          TextButton(
            onPressed: _initializePlayer,
            child: Text('Retry', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

/// Video thumbnail preview for collection lists
class VideoThumbnailPreview extends StatelessWidget {
  final String filePath;
  final String fileName;
  final Duration duration;
  final String? thumbnailPath;
  final VoidCallback? onDelete;

  const VideoThumbnailPreview({
    super.key,
    required this.filePath,
    required this.fileName,
    required this.duration,
    this.thumbnailPath,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GlassContainer(
          padding: EdgeInsets.zero,
          borderRadius: 16.r,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              width: 140.w,
              height: 140.h,
              color: Colors.black.withOpacity(0.05),
              child: thumbnailPath != null
                  ? Image.file(
                      File(thumbnailPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.lightBackground,
                          child: Center(
                            child: Icon(
                              Icons.movie_rounded,
                              color: AppColors.primary.withOpacity(0.2),
                              size: 40.sp,
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(
                        Icons.movie_rounded,
                        color: AppColors.primary.withOpacity(0.2),
                        size: 40.sp,
                      ),
                    ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.darkText.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                color: AppColors.lightSurface.withOpacity(0.9),
                size: 44.sp,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10.h,
          right: 10.w,
          child: GlassContainer(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            borderRadius: 8.r,
            blur: 10,
            color: AppColors.darkText.withOpacity(0.4),
            child: Text(
              _formatDuration(duration),
              style: TextStyle(
                color: AppColors.lightText,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (onDelete != null)
          Positioned(
            top: 6.h,
            right: 6.w,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                onDelete!();
              },
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(
                  color: AppColors.errorColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: AppColors.lightText,
                  size: 14.sp,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Video attachment list widget
class VideoAttachmentsList extends StatelessWidget {
  final List<VideoMetadata> videos;
  final Function(int) onVideoDelete;
  final Function(int) onVideoTap;

  const VideoAttachmentsList({
    super.key,
    required this.videos,
    required this.onVideoDelete,
    required this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h, top: 16.h),
          child: Text(
            'Video Clips',
            style: AppTypography.heading4(context).copyWith(
              color: AppColors.textSecondary(context),
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(
          height: 150.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: GestureDetector(
                  onTap: () => onVideoTap(index),
                  child: VideoThumbnailPreview(
                    filePath: videos[index].filePath,
                    fileName: videos[index].fileName,
                    duration: videos[index].duration,
                    thumbnailPath: videos[index].thumbnailPath,
                    onDelete: () => onVideoDelete(index),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
