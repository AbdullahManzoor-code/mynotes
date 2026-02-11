import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/media_item.dart';
import '../widgets/voice_message_widget.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/note_overlay_widget.dart';
import '../../domain/entities/annotation_stroke.dart';
import 'image_editor_screen.dart';
import 'video_editor_screen.dart';
import 'text_editor_screen.dart';

/// Media Viewer Screen
/// Full-screen viewer for images, videos, and audio
/// Supports pinch-to-zoom, swipe navigation, and media playback
class MediaViewerScreen extends StatefulWidget {
  final List<MediaItem> mediaItems;
  final int initialIndex;
  final Function(MediaItem)? onDelete;
  final Function(MediaItem oldItem, MediaItem newItem)? onUpdate;

  const MediaViewerScreen({
    super.key,
    required this.mediaItems,
    this.initialIndex = 0,
    this.onDelete,
    this.onUpdate,
  });

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isMarkupEnabled = false;
  late Map<int, List<AnnotationStroke>> _annotationsByPage;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _annotationsByPage = {};
    _loadAnnotations();
  }

  void _loadAnnotations() {
    for (int i = 0; i < widget.mediaItems.length; i++) {
      final media = widget.mediaItems[i];
      if (media.metadata.containsKey('annotations')) {
        final list = media.metadata['annotations'] as List;
        _annotationsByPage[i] = list
            .map(
              (item) => AnnotationStroke.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else {
        _annotationsByPage[i] = [];
      }
    }
  }

  void _saveAnnotations() {
    final media = widget.mediaItems[_currentIndex];
    final strokes = _annotationsByPage[_currentIndex] ?? [];
    final updatedMedia = media.copyWith(
      metadata: {
        ...media.metadata,
        'annotations': strokes.map((s) => s.toJson()).toList(),
      },
    );
    if (widget.onUpdate != null) {
      widget.onUpdate!(media, updatedMedia);
    }
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

  void _editCurrentMedia() {
    final media = widget.mediaItems[_currentIndex];
    if (media.type == MediaType.image) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageEditorScreen(
            mediaItem: media,
            onSave: (editedPath) {
              final updatedMedia = media.copyWith(filePath: editedPath);
              if (widget.onUpdate != null) {
                widget.onUpdate!(media, updatedMedia);
              }
              // Update local state to reflect changes in viewer
              setState(() {
                widget.mediaItems[_currentIndex] = updatedMedia;
              });
            },
          ),
        ),
      );
    } else if (media.type == MediaType.video) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoEditorScreen(
            mediaItem: media,
            onSave: (editedPath) {
              final updatedMedia = media.copyWith(filePath: editedPath);
              if (widget.onUpdate != null) {
                widget.onUpdate!(media, updatedMedia);
              }
              setState(() {
                widget.mediaItems[_currentIndex] = updatedMedia;
              });
            },
          ),
        ),
      );
    } else if (media.type == MediaType.document &&
        media.name.endsWith('.txt')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SimpleTextEditorScreen(
            mediaItem: media,
            onSave: (editedPath) {
              final updatedMedia = media.copyWith(filePath: editedPath);
              if (widget.onUpdate != null) {
                widget.onUpdate!(media, updatedMedia);
              }
              setState(() {
                widget.mediaItems[_currentIndex] = updatedMedia;
              });
            },
          ),
        ),
      );
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
          IconButton(
            icon: Icon(
              _isMarkupEnabled ? Icons.brush : Icons.brush_outlined,
              color: _isMarkupEnabled ? Colors.orange : Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isMarkupEnabled = !_isMarkupEnabled;
              });
              if (!_isMarkupEnabled) {
                _saveAnnotations();
              }
            },
          ),
          if (widget.mediaItems[_currentIndex].type == MediaType.image ||
              widget.mediaItems[_currentIndex].type == MediaType.video ||
              (widget.mediaItems[_currentIndex].type == MediaType.document &&
                  widget.mediaItems[_currentIndex].name.endsWith('.txt')))
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _editCurrentMedia,
            ),
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
          return Stack(
            children: [
              _buildMediaView(media),
              NoteOverlayWidget(
                strokes: _annotationsByPage[index] ?? [],
                isDrawingMode: _isMarkupEnabled && _currentIndex == index,
                onStrokeAdded: (stroke) {
                  setState(() {
                    _annotationsByPage[index] = [
                      ...(_annotationsByPage[index] ?? []),
                      stroke,
                    ];
                  });
                },
              ),
            ],
          );
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
      case MediaType.document:
        return _buildDocumentView(media);
    }
  }

  Widget _buildImageView(MediaItem media) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: media.filePath.startsWith('assets/')
            ? Image.asset(
                media.filePath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _buildErrorWidget(),
              )
            : Image.file(
                File(media.filePath),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _buildErrorWidget(),
              ),
      ),
    );
  }

  Widget _buildVideoView(MediaItem media) {
    return Center(
      child: VideoPlayerWidget(
        video: VideoMetadata(
          filePath: media.filePath,
          fileName: media.name,
          fileSize: media.size,
          duration: Duration(milliseconds: media.durationMs),
          thumbnailPath: media.thumbnailPath,
          createdAt: media.createdAt,
        ),
      ),
    );
  }

  Widget _buildDocumentView(MediaItem media) {
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
            const Icon(
              Icons.description_outlined,
              color: Colors.orange,
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              media.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '${(media.size / 1024).toStringAsFixed(1)} KB',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Open with external app or show preview
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open Document'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
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
      case MediaType.document:
        return Icons.description;
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
      case MediaType.document:
        return Colors.orange;
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
      case MediaType.document:
        return 'Document';
    }
  }
}
