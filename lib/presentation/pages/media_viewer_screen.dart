import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/media_item.dart';
import '../widgets/voice_message_widget.dart';

/// Media Viewer Screen
/// Full-screen viewer for images, videos, and audio
/// Supports pinch-to-zoom, swipe navigation, and media playback
class MediaViewerScreen extends StatefulWidget {
  final List<MediaItem> mediaItems;
  final int initialIndex;
  final Function(MediaItem)? onDelete;

  const MediaViewerScreen({
    super.key,
    required this.mediaItems,
    this.initialIndex = 0,
    this.onDelete,
  });

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _deleteCurrentMedia() {
    if (widget.onDelete != null) {
      final mediaToDelete = widget.mediaItems[_currentIndex];
      widget.onDelete!(mediaToDelete);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.mediaItems.length}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _deleteCurrentMedia,
            ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: widget.mediaItems.length,
        itemBuilder: (context, index) {
          final media = widget.mediaItems[index];
          return _buildMediaView(media);
        },
      ),
      bottomNavigationBar: _buildBottomInfo(),
    );
  }

  Widget _buildMediaView(MediaItem media) {
    switch (media.type) {
      case MediaType.image:
        return _buildImageView(media);
      case MediaType.video:
        return _buildVideoView(media);
      case MediaType.audio:
        return _buildAudioView(media);
    }
  }

  Widget _buildImageView(MediaItem media) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.file(
          File(media.filePath),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildErrorWidget(),
        ),
      ),
    );
  }

  Widget _buildVideoView(MediaItem media) {
    // TODO: Integrate video_player package for full video playback
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (media.thumbnailPath.isNotEmpty)
            Image.file(File(media.thumbnailPath), fit: BoxFit.contain),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Open video player
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Video player integration pending'),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Play Video'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioView(MediaItem media) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // WhatsApp-style voice message widget
            VoiceMessageWidget(
              audioPath: media.filePath,
              duration: media.durationMs > 0
                  ? Duration(milliseconds: media.durationMs)
                  : null,
              isSent: true,
            ),

            const SizedBox(height: 32),

            // Audio info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.audiotrack_rounded,
                        color: AppColors.audioColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Voice Recording',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  if (media.durationMs > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      _formatDuration(Duration(milliseconds: media.durationMs)),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInfo() {
    final media = widget.mediaItems[_currentIndex];
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Row(
          children: [
            Icon(
              _getMediaIcon(media.type),
              color: _getMediaColor(media.type),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getMediaTypeLabel(media.type),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (media.durationMs > 0)
                    Text(
                      _formatDuration(Duration(milliseconds: media.durationMs)),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {
                // TODO: Implement share functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share feature coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.white54),
          SizedBox(height: 16),
          Text('Failed to load media', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  IconData _getMediaIcon(MediaType type) {
    switch (type) {
      case MediaType.image:
        return Icons.image;
      case MediaType.video:
        return Icons.videocam;
      case MediaType.audio:
        return Icons.audiotrack;
    }
  }

  Color _getMediaColor(MediaType type) {
    switch (type) {
      case MediaType.image:
        return AppColors.imageColor;
      case MediaType.video:
        return AppColors.videoColor;
      case MediaType.audio:
        return AppColors.audioColor;
    }
  }

  String _getMediaTypeLabel(MediaType type) {
    switch (type) {
      case MediaType.image:
        return 'Image';
      case MediaType.video:
        return 'Video';
      case MediaType.audio:
        return 'Audio Recording';
    }
  }
}

