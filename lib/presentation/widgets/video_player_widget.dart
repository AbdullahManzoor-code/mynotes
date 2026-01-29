import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

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
    if (fileSize < 1024 * 1024)
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Widget for playing video attachments
class VideoPlayerWidget extends StatefulWidget {
  final VideoMetadata video;
  final VoidCallback? onDelete;

  const VideoPlayerWidget({Key? key, required this.video, this.onDelete})
    : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.video.filePath));
    _initializeVideoPlayer = _controller.initialize().then((_) {
      setState(() {});
    });

    _controller.addListener(_handleVideoStateChange);
  }

  void _handleVideoStateChange() {
    setState(() {
      _isPlaying = _controller.value.isPlaying;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Video container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FutureBuilder<void>(
            future: _initializeVideoPlayer,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    if (!_isPlaying)
                      IconButton(
                        icon: Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 48,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                    if (_isPlaying)
                      IconButton(
                        icon: Icon(
                          Icons.pause_circle_filled,
                          color: Colors.white,
                          size: 48,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                  ],
                );
              } else {
                return AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        ),

        SizedBox(height: 12),

        // Video info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.video.fileName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${widget.video.formattedDuration} • ${widget.video.formattedSize}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (widget.onDelete != null)
              IconButton(
                icon: Icon(Icons.delete_outline),
                onPressed: widget.onDelete,
              ),
          ],
        ),
      ],
    );
  }
}

/// Video thumbnail preview
class VideoThumbnailPreview extends StatelessWidget {
  final String filePath;
  final String fileName;
  final Duration duration;
  final VoidCallback? onDelete;

  const VideoThumbnailPreview({
    Key? key,
    required this.filePath,
    required this.fileName,
    required this.duration,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(File(filePath)),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _formatDuration(duration),
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        if (onDelete != null)
          Positioned(
            top: -8,
            right: -8,
            child: CircleAvatar(
              backgroundColor: Colors.red,
              radius: 14,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 12),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 28, minHeight: 28),
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
    Key? key,
    required this.videos,
    required this.onVideoDelete,
    required this.onVideoTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Video Attachments',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => onVideoTap(index),
              child: VideoThumbnailPreview(
                filePath: videos[index].filePath,
                fileName: videos[index].fileName,
                duration: videos[index].duration,
                onDelete: () => onVideoDelete(index),
              ),
            );
          },
        ),
      ],
    );
  }
}
