import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/design_system/app_colors.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../domain/entities/media_item.dart';
import '../widgets/voice_message_widget.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/note_overlay_widget.dart';
import '../../domain/entities/annotation_stroke.dart';
import '../bloc/media_viewer/media_viewer_bloc.dart';
import '../bloc/media_viewer/media_viewer_event.dart';
import '../bloc/media_viewer/media_viewer_state.dart';
import '../../injection_container.dart';
import '../../core/services/app_logger.dart';
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

  @override
  void initState() {
    super.initState();
    AppLogger.i(
      'MediaViewerScreen: initState (initialIndex: ${widget.initialIndex})',
    );
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    AppLogger.i('MediaViewerScreen: dispose');
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<MediaViewerBloc>()
        ..add(
          MediaViewerInitEvent(
            mediaItems: widget.mediaItems,
            initialIndex: widget.initialIndex,
          ),
        ),
      child: BlocConsumer<MediaViewerBloc, MediaViewerState>(
        listener: (context, state) {
          if (state is MediaViewerDeleted) {
            AppLogger.i(
              'MediaViewerScreen: Media item deleted: ${state.media.id}',
            );
            if (widget.onDelete != null) {
              widget.onDelete!(state.media);
            }
            Navigator.pop(context);
          } else if (state is MediaViewerUpdated && state.message != null) {
            AppLogger.i('MediaViewerScreen: Media updated: ${state.message}');
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message!)));
          } else if (state is MediaViewerFailure) {
            AppLogger.e('MediaViewerScreen: Viewer error: ${state.error}');
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          if (state is! MediaViewerUpdated) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final currentIndex = state.currentIndex;
          final currentMedia = state.mediaItems[currentIndex];
          final isMarkupEnabled = state.isMarkupEnabled;

          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black87,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  AppLogger.i('MediaViewerScreen: Close button pressed');
                  Navigator.pop(context);
                },
              ),
              title: Text(
                '${currentIndex + 1} / ${state.mediaItems.length}',
                style: const TextStyle(color: Colors.white),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    isMarkupEnabled ? Icons.brush : Icons.brush_outlined,
                    color: isMarkupEnabled ? Colors.orange : Colors.white,
                  ),
                  onPressed: () {
                    AppLogger.i(
                      'MediaViewerScreen: Toggle markup pressed (current: $isMarkupEnabled)',
                    );
                    context.read<MediaViewerBloc>().add(
                      const ToggleMarkupEvent(),
                    );
                  },
                ),
                if (currentMedia.type == MediaType.image ||
                    currentMedia.type == MediaType.video)
                  IconButton(
                    icon: const Icon(Icons.download, color: Colors.white),
                    onPressed: () {
                      AppLogger.i(
                        'MediaViewerScreen: Save to gallery pressed: ${currentMedia.id}',
                      );
                      context.read<MediaViewerBloc>().add(
                        SaveMediaToGalleryEvent(currentMedia),
                      );
                    },
                    tooltip: 'Save to Gallery',
                  ),
                if (currentMedia.type == MediaType.image ||
                    currentMedia.type == MediaType.video ||
                    (currentMedia.type == MediaType.document &&
                        currentMedia.name.endsWith('.txt')))
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      AppLogger.i(
                        'MediaViewerScreen: Edit media pressed: ${currentMedia.id}',
                      );
                      _editCurrentMedia(context, state);
                    },
                  ),
                if (widget.onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () {
                      AppLogger.i(
                        'MediaViewerScreen: Delete media pressed: ${currentMedia.id}',
                      );
                      context.read<MediaViewerBloc>().add(
                        DeleteMediaItemEvent(currentMedia),
                      );
                    },
                  ),
              ],
            ),
            body: PhotoViewGallery.builder(
              scrollPhysics: isMarkupEnabled
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                final media = state.mediaItems[index];

                if (media.type != MediaType.image) {
                  return PhotoViewGalleryPageOptions.customChild(
                    child: Stack(
                      children: [
                        _buildMediaView(media),
                        NoteOverlayWidget(
                          strokes: state.annotationsByPage[index] ?? [],
                          isDrawingMode:
                              isMarkupEnabled && currentIndex == index,
                          onStrokeAdded: (stroke) {
                            context.read<MediaViewerBloc>().add(
                              AddStrokeEvent(index, stroke),
                            );
                          },
                        ),
                      ],
                    ),
                    initialScale: PhotoViewComputedScale.contained,
                  );
                }

                return PhotoViewGalleryPageOptions.customChild(
                  child: Stack(
                    children: [
                      PhotoView(
                        imageProvider: media.filePath.startsWith('assets/')
                            ? AssetImage(media.filePath) as ImageProvider
                            : FileImage(File(media.filePath)),
                        initialScale: PhotoViewComputedScale.contained,
                        minScale: PhotoViewComputedScale.contained * 0.8,
                        maxScale: PhotoViewComputedScale.covered * 2.0,
                        heroAttributes: PhotoViewHeroAttributes(tag: media.id),
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.black,
                        ),
                      ),
                      NoteOverlayWidget(
                        strokes: state.annotationsByPage[index] ?? [],
                        isDrawingMode: isMarkupEnabled && currentIndex == index,
                        onStrokeAdded: (stroke) {
                          context.read<MediaViewerBloc>().add(
                            AddStrokeEvent(index, stroke),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
              itemCount: state.mediaItems.length,
              loadingBuilder: (context, event) =>
                  const Center(child: CircularProgressIndicator()),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              pageController: _pageController,
              onPageChanged: (index) {
                context.read<MediaViewerBloc>().add(PageChangedEvent(index));
              },
            ),
            bottomNavigationBar: _buildBottomInfo(context, state),
          );
        },
      ),
    );
  }

  void _editCurrentMedia(BuildContext context, MediaViewerUpdated state) {
    final media = state.mediaItems[state.currentIndex];
    final bloc = context.read<MediaViewerBloc>();
    final index = state.currentIndex;

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
              bloc.add(UpdateMediaItemEvent(index, updatedMedia));
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
              bloc.add(UpdateMediaItemEvent(index, updatedMedia));
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
              bloc.add(UpdateMediaItemEvent(index, updatedMedia));
            },
          ),
        ),
      );
    }
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
                      Icon(
                        Icons.audiotrack_rounded,
                        color: AppColors.accentBlue,
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

  Widget _buildBottomInfo(BuildContext context, MediaViewerUpdated state) {
    final media = state.mediaItems[state.currentIndex];
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
        return AppColors.accentPink;
      case MediaType.video:
        return AppColors.accentGreen;
      case MediaType.audio:
        return AppColors.accentBlue;
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
