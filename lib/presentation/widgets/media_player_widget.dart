import 'package:flutter/material.dart';

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
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        image: thumbnailPath != null
            ? DecorationImage(
                image: AssetImage(thumbnailPath!),
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
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    mediaType == 'audio' ? Icons.play_arrow : Icons.play_arrow,
                    color: Colors.blue.shade700,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    mediaType == 'audio' ? Icons.audiotrack : Icons.videocam,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    mediaType == 'audio' ? 'Audio' : 'Video',
                    style: const TextStyle(
                      color: Colors.white,
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
            image: AssetImage(imagePath),
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
                padding: const EdgeInsets.all(6),
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
