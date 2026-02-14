import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/media/media_gallery/media_gallery_bloc.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<MediaGalleryBloc>().add(const LoadAllMediaEvent());
  }

  void _toggleMultiSelect(String mediaId) {
    context.read<MediaGalleryBloc>().add(SelectMediaEvent(mediaId: mediaId));
  }

  void _clearSelection() {
    context.read<MediaGalleryBloc>().add(const ClearSelectionEvent());
  }

  void _deleteSelectedMedia(Set<String> selectedIds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Media'),
        content: Text(
          'Delete ${selectedIds.length} item(s)? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              for (final mediaId in selectedIds) {
                context.read<MediaGalleryBloc>().add(
                  DeleteMediaEvent(mediaId: mediaId),
                );
              }
              _clearSelection();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${selectedIds.length} item(s) deleted'),
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
    return BlocBuilder<MediaGalleryBloc, MediaGalleryState>(
      builder: (context, state) {
        final isMultiSelectMode =
            state is MediaGalleryLoaded && state.selectedIds.isNotEmpty;
        final selectedIds = state is MediaGalleryLoaded
            ? state.selectedIds
            : <String>{};

        return Scaffold(
          appBar: _buildAppBar(context, state, isMultiSelectMode, selectedIds),
          body: _buildBody(state, isMultiSelectMode, selectedIds),
        );
      },
    );
  }

  Widget _buildBody(
    MediaGalleryState state,
    bool isMultiSelectMode,
    Set<String> selectedIds,
  ) {
    if (state is MediaGalleryLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is MediaGalleryError) {
      return Center(child: Text(state.message));
    }

    if (state is MediaGalleryLoaded) {
      return _buildMediaGrid(state.mediaItems, isMultiSelectMode, selectedIds);
    }

    return const Center(child: Text('Initialize media...'));
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    MediaGalleryState state,
    bool isMultiSelectMode,
    Set<String> selectedIds,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      elevation: 0,
      leading: isMultiSelectMode
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: _clearSelection,
            )
          : null,
      title: isMultiSelectMode
          ? Text(
              '${selectedIds.length} selected',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            )
          : Text(
              'Media Gallery',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
            ),
      actions: [
        if (isMultiSelectMode) ...[
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
            onPressed: () => _deleteSelectedMedia(selectedIds),
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
                onTap: () => showFilterBottomSheet(context, state),
              ),
              const PopupMenuItem(child: Text('Sort')),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMediaGrid(
    List<Map<String, dynamic>> items,
    bool isMultiSelectMode,
    Set<String> selectedIds,
  ) {
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
        final id = media['id'] as String;
        final type = media['type'] as MediaType;
        final isSelected = selectedIds.contains(id);

        return GestureDetector(
          onLongPress: () {
            _toggleMultiSelect(id);
          },
          onTap: isMultiSelectMode
              ? () => _toggleMultiSelect(id)
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
                child: _buildMediaThumbnail(type),
              ),
              // Selection overlay
              if (isMultiSelectMode)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: isSelected
                        ? Colors.blue.withOpacity(0.5)
                        : Colors.black.withOpacity(0.2),
                  ),
                ),
              // Selection checkmark
              if (isMultiSelectMode)
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
                child: _buildMediaTypeIcon(type),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMediaThumbnail(MediaType type) {
    switch (type) {
      case MediaType.image:
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.image, size: 32),
        );
      case MediaType.video:
        return Container(
          color: Colors.grey[400],
          child: const Icon(Icons.play_circle_outline, size: 32),
        );
      case MediaType.audio:
        return Container(
          color: Colors.grey[500],
          child: const Icon(Icons.audio_file, size: 32, color: Colors.white),
        );
      case MediaType.document:
        return Container(
          color: Colors.grey[600],
          child: const Icon(Icons.description, size: 32, color: Colors.white),
        );
    }
  }

  Widget _buildMediaTypeIcon(MediaType type) {
    final colors = {
      MediaType.image: Colors.blue,
      MediaType.video: Colors.orange,
      MediaType.audio: Colors.purple,
      MediaType.document: Colors.deepOrange,
    };

    final icons = {
      MediaType.image: Icons.image,
      MediaType.video: Icons.videocam,
      MediaType.audio: Icons.audiotrack,
      MediaType.document: Icons.description,
    };

    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, color: colors[type]),
      padding: EdgeInsets.all(4.w),
      child: Icon(icons[type]!, size: 12.sp, color: Colors.white),
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
                context.read<MediaGalleryBloc>().add(
                  SearchMediaEvent(query: _searchController.text),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void showFilterBottomSheet(BuildContext context, MediaGalleryState state) {
    String? currentFilter;
    if (state is MediaGalleryLoaded) {
      currentFilter = state.filterType;
    }

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
                  selected: currentFilter == 'all',
                  onSelected: (selected) {
                    context.read<MediaGalleryBloc>().add(
                      const FilterMediaEvent(filterType: 'all'),
                    );
                    Navigator.pop(context);
                  },
                ),
                FilterChip(
                  label: const Text('Images'),
                  selected: currentFilter == 'image',
                  onSelected: (selected) {
                    context.read<MediaGalleryBloc>().add(
                      const FilterMediaEvent(filterType: 'image'),
                    );
                    Navigator.pop(context);
                  },
                ),
                FilterChip(
                  label: const Text('Videos'),
                  selected: currentFilter == 'video',
                  onSelected: (selected) {
                    context.read<MediaGalleryBloc>().add(
                      const FilterMediaEvent(filterType: 'video'),
                    );
                    Navigator.pop(context);
                  },
                ),
                FilterChip(
                  label: const Text('Audio'),
                  selected: currentFilter == 'audio',
                  onSelected: (selected) {
                    context.read<MediaGalleryBloc>().add(
                      const FilterMediaEvent(filterType: 'audio'),
                    );
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
