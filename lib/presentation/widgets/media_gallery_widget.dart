import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/media_item.dart';
import '../bloc/media_bloc.dart';
import '../bloc/media_event.dart';
import '../bloc/media_state.dart';
import '../design_system/design_system.dart';

/// Media Gallery Widget - Browse and manage all media files
/// Supports filtering by type (images, videos, audio, documents)
/// Includes sorting, search, and bulk operations
class MediaGalleryWidget extends StatefulWidget {
  final Function(List<MediaItem>) onMediaSelected;
  final bool multiSelect;
  final String?
  initialFilter; // 'images', 'videos', 'audio', 'documents', null for all

  const MediaGalleryWidget({
    super.key,
    required this.onMediaSelected,
    this.multiSelect = true,
    this.initialFilter,
  });

  @override
  State<MediaGalleryWidget> createState() => _MediaGalleryWidgetState();
}

class _MediaGalleryWidgetState extends State<MediaGalleryWidget> {
  late String _selectedFilter;
  final TextEditingController _searchController = TextEditingController();
  List<MediaItem> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter ?? 'all';
    context.read<MediaBloc>().add(LoadMediaEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildFilterBar(),
        _buildSearchBar(),
        Expanded(child: _buildGalleryGrid()),
        if (widget.multiSelect && _selectedItems.isNotEmpty)
          _buildSelectionBar(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(Theme.of(context).brightness),
        border: Border(
          bottom: BorderSide(
            color: AppColors.getSecondaryTextColor(
              Theme.of(context).brightness,
            ).withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Media Gallery',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.getTextColor(Theme.of(context).brightness),
            ),
          ),
          if (widget.multiSelect && _selectedItems.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                '${_selectedItems.length} selected',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = [
      ('all', 'All', Icons.collections),
      ('images', 'Images', Icons.image),
      ('videos', 'Videos', Icons.video_library),
      ('audio', 'Audio', Icons.audio_file),
      ('documents', 'Documents', Icons.description),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter.$1;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filter.$3,
                      size: 14.sp,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                    SizedBox(width: 4.w),
                    Text(filter.$2),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) {
                  setState(() => _selectedFilter = filter.$1);
                  _applyFilter();
                },
                backgroundColor: Colors.transparent,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.primary,
                  fontSize: 12.sp,
                ),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.3),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search media by name or date...',
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.getSecondaryTextColor(
              Theme.of(context).brightness,
            ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    _applyFilter();
                  },
                  child: Icon(
                    Icons.clear,
                    color: AppColors.getSecondaryTextColor(
                      Theme.of(context).brightness,
                    ),
                  ),
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 10.h,
          ),
        ),
        onChanged: (_) {
          setState(() {});
          _applyFilter();
        },
      ),
    );
  }

  Widget _buildGalleryGrid() {
    return BlocBuilder<MediaBloc, MediaState>(
      builder: (context, state) {
        if (state is MediaLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is MediaLoaded) {
          var media = state.mediaItems;

          // Apply filter
          if (_selectedFilter != 'all') {
            media = media
                .where((m) => _getMediaType(m.filePath) == _selectedFilter)
                .toList();
          }

          // Apply search
          if (_searchController.text.isNotEmpty) {
            final query = _searchController.text.toLowerCase();
            media = media.where((m) {
              final fileName = m.filePath.split('/').last;
              return fileName.toLowerCase().contains(query);
            }).toList();
          }

          if (media.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 48.sp,
                    color: AppColors.getSecondaryTextColor(
                      Theme.of(context).brightness,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'No media found',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.getSecondaryTextColor(
                        Theme.of(context).brightness,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: EdgeInsets.all(8.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.w,
            ),
            itemCount: media.length,
            itemBuilder: (context, index) =>
                _buildMediaTile(media[index], context),
          );
        }

        if (state is MediaError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
                SizedBox(height: 12.h),
                Text(
                  state.message,
                  style: TextStyle(fontSize: 14.sp, color: AppColors.error),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMediaTile(MediaItem media, BuildContext context) {
    final isSelected = _selectedItems.contains(media);

    return GestureDetector(
      onTap: () {
        if (widget.multiSelect) {
          setState(() {
            if (isSelected) {
              _selectedItems.remove(media);
            } else {
              _selectedItems.add(media);
            }
          });
        } else {
          widget.onMediaSelected([media]);
          Navigator.pop(context);
        }
      },
      onLongPress: widget.multiSelect
          ? () {
              setState(() {
                if (isSelected) {
                  _selectedItems.remove(media);
                } else {
                  _selectedItems.add(media);
                }
              });
            }
          : null,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.getSecondaryTextColor(
                Theme.of(context).brightness,
              ).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: _buildMediaPreview(media),
          ),
          if (widget.multiSelect)
            Positioned(
              top: 4.w,
              right: 4.w,
              child: Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  border: Border.all(
                    color: AppColors.getSecondaryTextColor(
                      Theme.of(context).brightness,
                    ),
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: isSelected
                    ? Center(
                        child: Icon(
                          Icons.check,
                          size: 12.sp,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ),
          Positioned(
            bottom: 4.w,
            right: 4.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                _getMediaTypeLabel(media.filePath),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview(MediaItem media) {
    final mediaType = _getMediaType(media.filePath);

    switch (mediaType) {
      case 'images':
        return Image.asset(
          media.filePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(
              Icons.broken_image,
              size: 32.sp,
              color: AppColors.getSecondaryTextColor(
                Theme.of(context).brightness,
              ),
            ),
          ),
        );
      case 'videos':
        return Center(
          child: Icon(
            Icons.play_circle_outline,
            size: 32.sp,
            color: AppColors.getSecondaryTextColor(
              Theme.of(context).brightness,
            ),
          ),
        );
      case 'audio':
        return Center(
          child: Icon(
            Icons.audio_file,
            size: 32.sp,
            color: AppColors.getSecondaryTextColor(
              Theme.of(context).brightness,
            ),
          ),
        );
      case 'documents':
        return Center(
          child: Icon(
            Icons.description,
            size: 32.sp,
            color: AppColors.getSecondaryTextColor(
              Theme.of(context).brightness,
            ),
          ),
        );
      default:
        return Center(
          child: Icon(
            Icons.file_present,
            size: 32.sp,
            color: AppColors.getSecondaryTextColor(
              Theme.of(context).brightness,
            ),
          ),
        );
    }
  }

  Widget _buildSelectionBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(Theme.of(context).brightness),
        border: Border(
          top: BorderSide(
            color: AppColors.getSecondaryTextColor(
              Theme.of(context).brightness,
            ).withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              setState(() => _selectedItems.clear());
            },
            child: Text(
              'Clear',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onMediaSelected(_selectedItems);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            ),
            child: Text(
              'Add (${_selectedItems.length})',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMediaType(String path) {
    final extension = path.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      return 'images';
    } else if (['mp4', 'avi', 'mov', 'mkv', 'webm'].contains(extension)) {
      return 'videos';
    } else if (['mp3', 'm4a', 'wav', 'flac', 'aac'].contains(extension)) {
      return 'audio';
    } else if (['pdf', 'doc', 'docx', 'txt', 'xlsx'].contains(extension)) {
      return 'documents';
    }
    return 'other';
  }

  String _getMediaTypeLabel(String path) {
    final extension = path.split('.').last.toUpperCase();
    return extension;
  }

  void _applyFilter() {
    context.read<MediaBloc>().add(
      FilterMediaEvent(
        type: _selectedFilter == 'all' ? null : _selectedFilter,
        searchQuery: _searchController.text.isEmpty
            ? null
            : _searchController.text,
      ),
    );
  }
}
