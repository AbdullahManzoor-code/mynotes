import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/media_bloc.dart';
import '../bloc/media_state.dart';
import '../bloc/media_event.dart';
import '../design_system/design_system.dart';
import '../../domain/entities/media_item.dart';

/// Full Media Gallery Screen
/// Browse all media files, filter by type, search, batch operations
class FullMediaGalleryScreen extends StatefulWidget {
  const FullMediaGalleryScreen({super.key});

  @override
  State<FullMediaGalleryScreen> createState() => _FullMediaGalleryScreenState();
}

class _FullMediaGalleryScreenState extends State<FullMediaGalleryScreen> {
  final TextEditingController _searchController = TextEditingController();
  MediaType? _selectedType;
  final Set<String> _selectedMediaIds = {};
  bool _isMultiSelectMode = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<MediaBloc>().add(const LoadAllMediaEvent());
  }

  void _toggleMultiSelect(String mediaId) {
    setState(() {
      if (_selectedMediaIds.contains(mediaId)) {
        _selectedMediaIds.remove(mediaId);
        if (_selectedMediaIds.isEmpty) {
          _isMultiSelectMode = false;
        }
      } else {
        _selectedMediaIds.add(mediaId);
        _isMultiSelectMode = true;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedMediaIds.clear();
      _isMultiSelectMode = false;
    });
  }

  void _deleteSelectedMedia() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Media'),
        content: Text(
          'Delete ${_selectedMediaIds.length} item(s)? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              for (final mediaId in _selectedMediaIds) {
                context.read<MediaBloc>().add(
                  RemoveImageFromNoteEvent('', mediaId),
                );
              }
              _clearSelection();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${_selectedMediaIds.length} item(s) deleted'),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: BlocBuilder<MediaBloc, MediaState>(
        builder: (context, state) {
          if (state is MediaLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // For now, return empty state (will be populated from BLoC)
          return _buildMediaGrid([]);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      elevation: 0,
      leading: _isMultiSelectMode
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: _clearSelection,
            )
          : null,
      title: _isMultiSelectMode
          ? Text(
              '${_selectedMediaIds.length} selected',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            )
          : Text(
              'Media Gallery',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
            ),
      actions: [
        if (_isMultiSelectMode) ...[
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteSelectedMedia,
          ),
        ] else ...[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearchDialog(context);
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Filter'),
                onTap: () => showFilterBottomSheet(context),
              ),
              const PopupMenuItem(child: Text('Sort')),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMediaGrid(List<MediaItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              'No media files',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(12.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.w,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final media = items[index];
        final isSelected = _selectedMediaIds.contains(media.id);

        return GestureDetector(
          onLongPress: () {
            _toggleMultiSelect(media.id);
          },
          onTap: _isMultiSelectMode
              ? () => _toggleMultiSelect(media.id)
              : () {
                  // View media details
                },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: Colors.grey[300],
                ),
                child: _buildMediaThumbnail(media),
              ),
              // Selection overlay
              if (_isMultiSelectMode)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: isSelected
                        ? Colors.blue.withOpacity(0.5)
                        : Colors.black.withOpacity(0.2),
                  ),
                ),
              // Selection checkmark
              if (_isMultiSelectMode)
                Positioned(
                  top: 4.w,
                  right: 4.w,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.blue : Colors.grey[400],
                    ),
                    padding: EdgeInsets.all(4.w),
                    child: Icon(
                      isSelected ? Icons.check : Icons.circle_outlined,
                      size: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              // Media type icon
              Positioned(
                bottom: 4.w,
                left: 4.w,
                child: _buildMediaTypeIcon(media.type),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMediaThumbnail(MediaItem media) {
    switch (media.type) {
      case MediaType.image:
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.image, size: 32),
        );
      case MediaType.video:
        return Container(
          color: Colors.grey[400],
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(color: Colors.grey[400]),
              const Icon(Icons.play_circle_outline, size: 32),
            ],
          ),
        );
      case MediaType.audio:
        return Container(
          color: Colors.grey[500],
          child: const Icon(Icons.audio_file, size: 32, color: Colors.white),
        );
    }
  }

  Widget _buildMediaTypeIcon(MediaType type) {
    final colors = {
      MediaType.image: Colors.blue,
      MediaType.video: Colors.orange,
      MediaType.audio: Colors.purple,
    };

    final icons = {
      MediaType.image: Icons.image,
      MediaType.video: Icons.videocam,
      MediaType.audio: Icons.audiotrack,
    };

    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, color: colors[type]),
      padding: EdgeInsets.all(4.w),
      child: Icon(icons[type], size: 12.sp, color: Colors.white),
    );
  }

  void showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Media'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search by filename...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                // Trigger search
              }
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Type',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 8.w,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedType == null,
                  onSelected: (selected) {
                    setState(() => _selectedType = null);
                    Navigator.pop(context);
                  },
                ),
                FilterChip(
                  label: const Text('Images'),
                  selected: _selectedType == MediaType.image,
                  onSelected: (selected) {
                    setState(() => _selectedType = MediaType.image);
                    Navigator.pop(context);
                  },
                ),
                FilterChip(
                  label: const Text('Videos'),
                  selected: _selectedType == MediaType.video,
                  onSelected: (selected) {
                    setState(() => _selectedType = MediaType.video);
                    Navigator.pop(context);
                  },
                ),
                FilterChip(
                  label: const Text('Audio'),
                  selected: _selectedType == MediaType.audio,
                  onSelected: (selected) {
                    setState(() => _selectedType = MediaType.audio);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder events for full media gallery
class LoadAllMediaEvent extends MediaEvent {
  const LoadAllMediaEvent();
  @override
  List<Object?> get props => [];
}

class SearchMediaEvent extends MediaEvent {
  final String query;
  const SearchMediaEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class FilterMediaByTypeEvent extends MediaEvent {
  final MediaType type;
  const FilterMediaByTypeEvent(this.type);
  @override
  List<Object?> get props => [type];
}

