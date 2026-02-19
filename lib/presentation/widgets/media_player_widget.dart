import 'package:flutter/material.dart';
import 'dart:io';
import '../design_system/design_system.dart';

/// Media Player Widget - Shows play button overlay for audio/video
class MediaPlayerWidget extends StatelessWidget {
  final String mediaPath;
  final String mediaType; // 'audio' or 'video'
  final String? thumbnailPath;
  final VoidCallback onPlay;

  const MediaPlayerWidget({
    super.key,
    required this.mediaPath,
    required this.mediaType,
    this.thumbnailPath,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCardBackground
            : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
        image: thumbnailPath != null
            ? DecorationImage(
                image: thumbnailPath!.startsWith('assets/')
                    ? AssetImage(thumbnailPath!) as ImageProvider
                    : FileImage(File(thumbnailPath!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Stack(
        children: [
          // Gradient overlay
          if (thumbnailPath != null)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.shadowDark],
                ),
              ),
            ),

          // Play button
          Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPlay,
                customBorder: const CircleBorder(),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.lightSurface.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowMedium,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    mediaType == 'audio' ? Icons.play_arrow : Icons.play_arrow,
                    color: AppColors.primaryColor,
                    size: 36,
                  ),
                ),
              ),
            ),
          ),

          // Media type indicator
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.overlayBlack,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    mediaType == 'audio' ? Icons.audiotrack : Icons.videocam,
                    color: AppColors.lightText,
                    size: 16,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    mediaType == 'audio' ? 'Audio' : 'Video',
                    style: const TextStyle(
                      color: AppColors.lightText,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Image Thumbnail Widget - Shows image with zoom capability
class ImageThumbnailWidget extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const ImageThumbnailWidget({
    super.key,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: imagePath.startsWith('assets/')
                ? AssetImage(imagePath) as ImageProvider
                : FileImage(File(imagePath)),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Zoom indicator
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.zoom_in, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
