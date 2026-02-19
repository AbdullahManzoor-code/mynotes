import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../injection_container.dart';
import '../bloc/media/media_picker/media_picker_bloc.dart';
import '../design_system/design_system.dart' hide TextButton;

/// Media Picker Screen
/// Allows selecting images/videos from gallery or camera
class MediaPickerScreen extends StatelessWidget {
  final String mediaType; // 'image', 'video', or 'all'
  final bool multiSelect;
  final int maxSelection;

  const MediaPickerScreen({
    super.key,
    this.mediaType = 'all',
    this.multiSelect = true,
    this.maxSelection = 10,
  });

  Future<void> _captureFromCamera({
    required BuildContext context,
    required bool isVideo,
  }) async {
    AppLogger.i('MediaPickerScreen: Capturing from camera (isVideo: $isVideo)');
    final ImagePicker picker = ImagePicker();
    try {
      XFile? file;
      if (isVideo) {
        file = await picker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(seconds: 60),
        );
      } else {
        file = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
      }

      if (file != null && context.mounted) {
        AppLogger.i('MediaPickerScreen: Captured successfully: ${file.path}');
        Navigator.pop(context, [
          {
            'path': file.path,
            'type': isVideo ? 'video' : 'image',
            'isFromCamera': true,
          },
        ]);
      }
    } catch (e) {
      AppLogger.e('MediaPickerScreen: Failed to capture from camera', e);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to capture: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<MediaPickerBloc>()
            ..add(CheckPermissionAndLoadAssetsEvent(mediaType: mediaType)),
      child: DefaultTabController(
        length: 2,
        child: BlocConsumer<MediaPickerBloc, MediaPickerState>(
          listener: (context, state) {
            if (state is MediaPickerLoaded && state.error != null) {
              AppLogger.e(
                'MediaPickerScreen: Error loading assets: ${state.error}',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  duration: const Duration(seconds: 2),
                ),
              );
            } else if (state is MediaPickerSelectionConfirmed) {
              AppLogger.i(
                'MediaPickerScreen: Selection confirmed with ${state.selectedFiles.length} files',
              );
              Navigator.pop(context, state.selectedFiles);
            }
          },
          builder: (context, state) {
            final selectedCount = (state is MediaPickerLoaded)
                ? state.selectedAssets.length
                : 0;

            return Scaffold(
              backgroundColor: AppColors.background(context),
              appBar: AppBar(
                backgroundColor: AppColors.background(context),
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: AppColors.textPrimary(context),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  mediaType == 'image'
                      ? 'Select Photos'
                      : (mediaType == 'video'
                            ? 'Select Videos'
                            : 'Select Media'),
                  style: AppTypography.bodyLarge(
                    context,
                    AppColors.textPrimary(context),
                    FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                actions: [
                  if (selectedCount > 0)
                    TextButton(
                      onPressed: () => context.read<MediaPickerBloc>().add(
                        const ConfirmSelectionEvent(),
                      ),
                      child: Text(
                        'Done ($selectedCount)',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                ],
                bottom: TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary(context),
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'Gallery'),
                    Tab(text: 'Camera'),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  _buildGalleryTab(context, state),
                  _buildCameraTab(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGalleryTab(BuildContext context, MediaPickerState state) {
    if (state is MediaPickerLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (state is MediaPickerPermissionDenied) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64.sp,
              color: AppColors.textSecondary(context),
            ),
            SizedBox(height: 16.h),
            Text(
              'Photo library access required',
              style: AppTypography.bodyLarge(
                context,
                AppColors.textPrimary(context),
                FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please grant access to select photos',
              style: AppTypography.bodyMedium(
                context,
                AppColors.textSecondary(context),
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => openAppSettings(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    }

    if (state is MediaPickerLoaded) {
      if (state.assets.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_outlined,
                size: 64.sp,
                color: AppColors.textSecondary(context),
              ),
              SizedBox(height: 16.h),
              Text(
                'No media found',
                style: AppTypography.bodyLarge(
                  context,
                  AppColors.textPrimary(context),
                  FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }

      final assets = state.assets;
      final selectedAssets = state.selectedAssets;

      return Column(
        children: [
          // Selection info
          if (selectedAssets.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              color: AppColors.primary.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${selectedAssets.length} of $maxSelection selected',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),

          // Grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(4.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 4.w,
                crossAxisSpacing: 4.w,
              ),
              itemCount: assets.length,
              itemBuilder: (context, index) {
                final asset = assets[index];
                final isSelected = selectedAssets.contains(asset);
                final selectionIndex = selectedAssets.toList().indexOf(asset);

                return GestureDetector(
                  onTap: () => context.read<MediaPickerBloc>().add(
                    ToggleAssetSelectionEvent(
                      asset: asset,
                      maxSelection: maxSelection,
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Thumbnail
                      FutureBuilder<Uint8List?>(
                        future: asset.thumbnailDataWithSize(
                          const ThumbnailSize(200, 200),
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                            );
                          }
                          return Container(
                            color: AppColors.surface(context),
                            child: Icon(
                              asset.type == AssetType.video
                                  ? Icons.videocam
                                  : Icons.image,
                              color: AppColors.textSecondary(context),
                            ),
                          );
                        },
                      ),

                      // Video duration indicator
                      if (asset.type == AssetType.video)
                        Positioned(
                          bottom: 4.h,
                          right: 4.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              _formatDuration(asset.videoDuration),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                        ),

                      // Selection overlay
                      if (isSelected)
                        Container(color: AppColors.primary.withOpacity(0.3)),

                      // Selection indicator
                      Positioned(
                        top: 4.h,
                        right: 4.w,
                        child: Container(
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Text(
                                    '${selectionIndex + 1}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _buildCameraTab(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (mediaType != 'video') ...[
            _buildCameraOption(
              context,
              icon: Icons.camera_alt,
              title: 'Take Photo',
              subtitle: 'Capture a new photo',
              onTap: () => _captureFromCamera(context: context, isVideo: false),
            ),
            SizedBox(height: 16.h),
          ],
          if (mediaType != 'image') ...[
            _buildCameraOption(
              context,
              icon: Icons.videocam,
              title: 'Record Video',
              subtitle: 'Record up to 60 seconds',
              onTap: () => _captureFromCamera(context: context, isVideo: true),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCameraOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: AppColors.primary, size: 28.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge(
                      context,
                      AppColors.textPrimary(context),
                      FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall(
                      context,
                      AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary(context)),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}


