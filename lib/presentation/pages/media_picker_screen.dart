import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import '../design_system/design_system.dart';

/// Media Picker Screen
/// Allows selecting images/videos from gallery or camera
class MediaPickerScreen extends StatefulWidget {
  final String mediaType; // 'image', 'video', or 'all'
  final bool multiSelect;
  final int maxSelection;

  const MediaPickerScreen({
    super.key,
    this.mediaType = 'all',
    this.multiSelect = true,
    this.maxSelection = 10,
  });

  @override
  State<MediaPickerScreen> createState() => _MediaPickerScreenState();
}

class _MediaPickerScreenState extends State<MediaPickerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();

  List<AssetEntity> _assets = [];
  final Set<AssetEntity> _selectedAssets = {};
  bool _isLoading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkPermissionAndLoadAssets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissionAndLoadAssets() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      setState(() {
        _hasPermission = true;
      });
      await _loadAssets();
    } else {
      setState(() {
        _hasPermission = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAssets() async {
    setState(() {
      _isLoading = true;
    });

    RequestType requestType;
    switch (widget.mediaType) {
      case 'image':
        requestType = RequestType.image;
        break;
      case 'video':
        requestType = RequestType.video;
        break;
      default:
        requestType = RequestType.common;
    }

    final albums = await PhotoManager.getAssetPathList(type: requestType);
    if (albums.isNotEmpty) {
      final recentAlbum = albums.first;
      final assets = await recentAlbum.getAssetListPaged(page: 0, size: 100);

      setState(() {
        _assets = assets;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleSelection(AssetEntity asset) {
    setState(() {
      if (_selectedAssets.contains(asset)) {
        _selectedAssets.remove(asset);
      } else if (_selectedAssets.length < widget.maxSelection) {
        _selectedAssets.add(asset);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Maximum ${widget.maxSelection} items can be selected',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  Future<void> _captureFromCamera({required bool isVideo}) async {
    try {
      XFile? file;
      if (isVideo) {
        file = await _picker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(seconds: 60),
        );
      } else {
        file = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
      }

      if (file != null && mounted) {
        Navigator.pop(context, [
          {
            'path': file.path,
            'type': isVideo ? 'video' : 'image',
            'isFromCamera': true,
          },
        ]);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to capture: $e')));
    }
  }

  Future<void> _confirmSelection() async {
    if (_selectedAssets.isEmpty) return;

    final List<Map<String, dynamic>> selectedFiles = [];

    for (final asset in _selectedAssets) {
      final file = await asset.file;
      if (file != null) {
        selectedFiles.add({
          'path': file.path,
          'type': asset.type == AssetType.video ? 'video' : 'image',
          'isFromCamera': false,
        });
      }
    }

    if (mounted) {
      Navigator.pop(context, selectedFiles);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.mediaType == 'image'
              ? 'Select Photos'
              : (widget.mediaType == 'video'
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
          if (_selectedAssets.isNotEmpty)
            TextButton(
              onPressed: _confirmSelection,
              child: Text(
                'Done (${_selectedAssets.length})',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
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
        controller: _tabController,
        children: [_buildGalleryTab(), _buildCameraTab()],
      ),
    );
  }

  Widget _buildGalleryTab() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (!_hasPermission) {
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

    if (_assets.isEmpty) {
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

    return Column(
      children: [
        // Selection info
        if (_selectedAssets.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            color: AppColors.primary.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.primary, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  '${_selectedAssets.length} of ${widget.maxSelection} selected',
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
            itemCount: _assets.length,
            itemBuilder: (context, index) {
              final asset = _assets[index];
              final isSelected = _selectedAssets.contains(asset);
              final selectionIndex = _selectedAssets.toList().indexOf(asset);

              return GestureDetector(
                onTap: () => _toggleSelection(asset),
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

  Widget _buildCameraTab() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.mediaType != 'video') ...[
            _buildCameraOption(
              icon: Icons.camera_alt,
              title: 'Take Photo',
              subtitle: 'Capture a new photo',
              onTap: () => _captureFromCamera(isVideo: false),
            ),
            SizedBox(height: 16.h),
          ],
          if (widget.mediaType != 'image') ...[
            _buildCameraOption(
              icon: Icons.videocam,
              title: 'Record Video',
              subtitle: 'Record up to 60 seconds',
              onTap: () => _captureFromCamera(isVideo: true),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCameraOption({
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

