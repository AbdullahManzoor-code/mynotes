import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Service for processing media (images and videos)
class MediaProcessingService {
  /// Compress image file
  Future<File?> compressImage(File file, {int quality = 80}) async {
    final filePath = file.absolute.path;
    final lastIndex = filePath.lastIndexOf(RegExp(r'.png|.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";

    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outPath,
        quality: quality,
      );

      if (result == null) return null;
      return File(result.path);
    } catch (e) {
      print('Image compression error: $e');
      return null;
    }
  }

  /// Compress video file
  Future<MediaInfo?> compressVideo(File file) async {
    try {
      final info = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false,
      );
      return info;
    } catch (e) {
      print('Video compression error: $e');
      return null;
    }
  }

  /// Generate video thumbnail
  Future<String?> generateVideoThumbnail(String videoPath) async {
    try {
      final uint8list = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200,
        quality: 75,
      );
      return uint8list;
    } catch (e) {
      print('Thumbnail generation error: $e');
      return null;
    }
  }

  /// Crop image
  Future<CroppedFile?> cropImage(String imagePath, BuildContext context) async {
    try {
      return await ImageCropper().cropImage(
        sourcePath: imagePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop Image'),
        ],
      );
    } catch (e) {
      print('Image cropping error: $e');
      return null;
    }
  }
}
