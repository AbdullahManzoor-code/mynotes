import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'dart:ui' as ui;
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/presentation/widgets/media/media_card.dart';
import 'package:mynotes/presentation/widgets/media/media_filters.dart';
import 'package:mynotes/presentation/widgets/media/media_gallery.dart';
import 'package:mynotes/presentation/widgets/media/media_list.dart';
import 'package:mynotes/presentation/bloc/media/media_bloc.dart';
import 'package:mynotes/presentation/bloc/media/media_event.dart';
import 'package:mynotes/presentation/bloc/media/media_state.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// PHASE 4: MEDIA & ATTACHMENTS
/// Enhanced Media List Screen - StatelessWidget
/// ════════════════════════════════════════════════════════════════════════════
///
/// IMPLEMENTATION PLAN:
/// ════════════════════════════════════════════════════════════════════════════
/// 1. STATE MANAGEMENT: All state handled by MediaBloc (future)
///    - Media list (all/filtered)
///    - Upload queue and progress
///    - Search query and filtering
///    - Sort options (date, size, name)
///    - View mode (list/grid/gallery)
///
/// 2. MAIN BUILD STRUCTURE:
///    - Scaffold with FloatingActionButton for upload
///    - MediaFilters header with search, type filter, sort
///    - View mode toggle (List/Grid/Gallery)
///    - MediaList or MediaGallery displaying items
///
/// 3. WIDGET COMPOSITION:
///    - MediaFilters - Search, type filter, sort, count badge
///    - MediaList - List/grid view of all media
///    - MediaGallery - Masonry gallery view
///    - MediaCard - Individual media item with thumbnail
///
/// 4. RESPONSIVE DESIGN:
///    All widgets use flutter_screenutil (.w, .h, .r, .sp)
///    - Mobile: Single/dual column, auto-layout
///    - Tablet: Multi-column gallery view
///    - Desktop: Full width with constraints
///
/// 5. KEY FEATURES:
///    - Image/video preview with thumbnails
///    - File size indicators
///    - Upload progress tracking
///    - Linked note/todo support
///    - Gallery view with grid/list toggle
///    - Storage optimization indicators
/// ════════════════════════════════════════════════════════════════════════════

/// ════════════════════════════════════════════════════════════════════════════
/// PHASE 4: MEDIA & ATTACHMENTS
/// Enhanced Media List Screen - BLoC Integrated
/// ════════════════════════════════════════════════════════════════════════════

class EnhancedMediaListScreenRefactored extends StatelessWidget {
  const EnhancedMediaListScreenRefactored({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.i('Building EnhancedMediaListScreenRefactored with MediaBloc');

    return BlocListener<MediaBloc, MediaState>(
      listener: (context, state) {
        if (state is MediaError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        extendBodyBehindAppBar: true,
        floatingActionButton: _buildFAB(context),
        body: Stack(
          children: [_buildBackgroundGlow(context), _buildMainContent(context)],
        ),
      ),
    );
  }

  /// Main content with BLoC state
  Widget _buildMainContent(BuildContext context) {
    return BlocBuilder<MediaBloc, MediaState>(
      builder: (context, state) {
        final allMedia =
            (state is MediaLoaded ? state.mediaItems : []) as List<MediaItem>;

        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              SizedBox(height: kToolbarHeight),
              MediaFilters(
                totalCount: allMedia.length,
                onSearchChanged: (query) {
                  AppLogger.i('Search media: $query');
                  context.read<MediaBloc>().add(
                    FilterMediaEvent(searchQuery: query),
                  );
                },
                onTypeSelected: (type) {
                  AppLogger.i('Filter by type: $type');
                  context.read<MediaBloc>().add(FilterMediaEvent(type: type));
                },
                onSortChanged: (sort) {
                  AppLogger.i('Sort by: $sort');
                },
              ),
              Container(
                color: context.theme.cardColor,
                child: TabBar(
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: context.theme.disabledColor,
                  labelStyle: AppTypography.body2(
                    context,
                  ).copyWith(fontSize: 12.sp, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: AppTypography.body2(
                    context,
                  ).copyWith(fontSize: 12.sp),
                  tabs: const [
                    Tab(text: 'List'),
                    Tab(text: 'Grid'),
                    Tab(text: 'Gallery'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildListView(context, allMedia),
                    _buildGridView(context, allMedia),
                    _buildGalleryView(context, allMedia),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// List view
  Widget _buildListView(BuildContext context, List<MediaItem> media) {
    if (media.isEmpty) {
      return _buildEmptyState(context);
    }

    return MediaList(
      allMedia: media,
      uploading: [],
      isGridView: false,
      enableActions: true,
      onMediaTap: (item) {
        AppLogger.i('List media tapped: ${item.id}');
      },
      onMediaDelete: (id) {
        AppLogger.i('Delete media: $id');
      },
      onMediaDownload: (id) {
        AppLogger.i('Download media: $id');
      },
      onMediaShare: (id) {
        AppLogger.i('Share media: $id');
      },
    );
  }

  /// Grid view
  Widget _buildGridView(BuildContext context, List<MediaItem> media) {
    if (media.isEmpty) {
      return _buildEmptyState(context);
    }

    return MediaList(
      allMedia: media,
      uploading: [],
      isGridView: true,
      enableActions: true,
      onMediaTap: (item) {
        AppLogger.i('Grid media tapped: ${item.id}');
      },
      onMediaDelete: (id) {
        AppLogger.i('Delete media: $id');
      },
      onMediaDownload: (id) {
        AppLogger.i('Download media: $id');
      },
      onMediaShare: (id) {
        AppLogger.i('Share media: $id');
      },
    );
  }

  /// Gallery view
  Widget _buildGalleryView(BuildContext context, List<MediaItem> media) {
    if (media.isEmpty) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      child: MediaGallery(
        mediaItems: media,
        crossAxisCount: 2,
        enableActions: true,
        onMediaTap: (item) {
          AppLogger.i('Gallery media tapped: ${item.id}');
        },
        onMediaDelete: (id) {
          AppLogger.i('Delete media: $id');
        },
        onMediaDownload: (id) {
          AppLogger.i('Download media: $id');
        },
      ),
    );
  }

  /// Empty state
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 100.r,
            color: context.theme.disabledColor,
          ),
          SizedBox(height: 24.h),
          Text(
            'No Media Yet',
            style: AppTypography.heading2(
              context,
            ).copyWith(fontSize: 20.sp, color: context.theme.disabledColor),
          ),
          SizedBox(height: 8.h),
          Text(
            'Upload images, videos, and documents',
            textAlign: TextAlign.center,
            style: AppTypography.body2(context).copyWith(
              fontSize: 14.sp,
              color: context.theme.disabledColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Background glow
  Widget _buildBackgroundGlow(BuildContext context) {
    return Positioned(
      top: -100.h,
      right: -100.w,
      child: Container(
        width: 300.w,
        height: 300.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(0.08),
        ),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  /// FAB
  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'media_fab',
      onPressed: () {
        AppLogger.i('Upload media FAB pressed');
        _showUploadOptions(context);
      },
      backgroundColor: AppColors.primary,
      elevation: 8,
      label: Text(
        'Upload',
        style: AppTypography.buttonMedium(context, Colors.white),
      ),
      icon: const Icon(Icons.add_photo_alternate, color: Colors.white),
    );
  }

  /// Show upload options
  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildUploadOption(
                  context,
                  Icons.image,
                  'Choose from Gallery',
                  () {
                    AppLogger.i('Pick photo from gallery');
                    context.read<MediaBloc>().add(
                      PickPhotoFromGalleryEvent('current_note_id'),
                    );
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 8.h),
                _buildUploadOption(
                  context,
                  Icons.camera_alt,
                  'Take a Photo',
                  () {
                    AppLogger.i('Capture photo');
                    context.read<MediaBloc>().add(
                      CapturePhotoEvent('current_note_id'),
                    );
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 8.h),
                _buildUploadOption(
                  context,
                  Icons.video_camera_back,
                  'Record Video',
                  () {
                    AppLogger.i('Capture video');
                    context.read<MediaBloc>().add(
                      CaptureVideoEvent('current_note_id'),
                    );
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 8.h),
                _buildUploadOption(
                  context,
                  Icons.file_present,
                  'Choose Document',
                  () {
                    AppLogger.i('Scan document');
                    context.read<MediaBloc>().add(
                      ScanDocumentEvent('current_note_id', 'Document'),
                    );
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48.h),
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build upload option
  Widget _buildUploadOption(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      tileColor: context.theme.cardColor,
    );
  }
}
