import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:uuid/uuid.dart';

import 'package:mynotes/core/constants/media_constants.dart';
import 'package:mynotes/core/services/permission_service.dart';
import 'package:mynotes/data/datasources/local/media_local_datasource.dart';
import 'package:mynotes/domain/entities/media_item.dart';
import 'package:mynotes/domain/repositories/media_repository.dart';

/// Implementation of MediaRepository (Merged v1 and v2)
class MediaRepositoryImpl implements MediaRepository {
  final MediaLocalDataSource localDataSource;
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Uuid _uuid = const Uuid();

  MediaRepositoryImpl({required this.localDataSource});

  // ==================== Note-centric methods (from v1) ====================

  @override
  Future<MediaItem> addImageToNote(String noteId, String imagePath) async {
    try {
      // Check storage permission
      final hasPermission = await PermissionService.requestPhotosPermission();
      if (!hasPermission) {
        throw Exception(
          'Photo library access denied. Please enable in device settings',
        );
      }

      // Pick image from gallery if path is empty
      String finalPath = imagePath;

      if (imagePath.isEmpty) {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: MediaConstants.maxImageWidth.toDouble(),
          maxHeight: MediaConstants.maxImageHeight.toDouble(),
          imageQuality: MediaConstants.imageCompressionQuality,
        );

        if (image == null) {
          throw Exception('No image was selected');
        }

        finalPath = image.path;
      }

      final mediaItem = MediaItem(
        id: _uuid.v4(),
        type: MediaType.image,
        filePath: finalPath,
        createdAt: DateTime.now(),
        name: path.basename(finalPath), // Set name
        size: await File(finalPath).length(), // Set size
      );

      // Save to database
      await localDataSource.addMediaToNote(noteId, mediaItem);

      return mediaItem;
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Failed to add image to note: $e');
    }
  }

  @override
  Future<MediaItem> addVideoToNote(
    String noteId,
    String videoPath, {
    String? thumbnailPath,
  }) async {
    try {
      // Pick video from gallery if path is empty
      String finalPath = videoPath;

      if (videoPath.isEmpty) {
        final XFile? video = await _picker.pickVideo(
          source: ImageSource.gallery,
          maxDuration: Duration(
            minutes: MediaConstants.maxVideoDurationMinutes,
          ),
        );

        if (video == null) {
          throw Exception('No video was selected');
        }

        finalPath = video.path;
      }

      final mediaItem = MediaItem(
        id: _uuid.v4(),
        type: MediaType.video,
        filePath: finalPath,
        thumbnailPath: thumbnailPath ?? '',
        createdAt: DateTime.now(),
        name: path.basename(finalPath),
        size: await File(finalPath).length(),
      );

      // Save to database
      await localDataSource.addMediaToNote(noteId, mediaItem);

      return mediaItem;
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Failed to add video to note: $e');
    }
  }

  @override
  Future<void> removeMediaFromNote(String noteId, String mediaId) async {
    try {
      await localDataSource.removeMediaFromNote(noteId, mediaId);
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Could not remove media from note: $e');
    }
  }

  @override
  Future<MediaItem> compressMedia(MediaItem media) async {
    try {
      if (media.type == MediaType.image) {
        // Compress image using flutter_image_compress
        final file = File(media.filePath);
        final dir = await getTemporaryDirectory();
        final targetPath = path.join(
          dir.path,
          'compressed_${path.basename(media.filePath)}',
        );

        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path,
          targetPath,
          quality: MediaConstants.compressedImageQuality,
          minWidth: MediaConstants.compressedMinWidth,
          minHeight: MediaConstants.compressedMinHeight,
        );

        if (compressedFile == null) {
          return media; // Return original if compression fails
        }

        return media.copyWith(
          filePath: compressedFile.path,
          size: await compressedFile.length(),
        );
      }

      // For video, return as-is (video compression is complex and slow)
      return media;
    } catch (e) {
      // Return original media if compression fails
      return media;
    }
  }

  @override
  Future<void> startAudioRecording(String noteId) async {
    try {
      // Request microphone permission
      final hasPermission =
          await PermissionService.requestMicrophonePermission();
      if (!hasPermission) {
        throw Exception('Microphone permission denied');
      }

      if (await _recorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final audioPath = path.join(
          dir.path,
          'audio_${DateTime.now().millisecondsSinceEpoch}.${MediaConstants.audioFormat}',
        );

        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: audioPath,
        );
      } else {
        throw Exception('Microphone permission denied');
      }
    } catch (e) {
      throw Exception('Failed to start recording: $e');
    }
  }

  @override
  Future<void> stopAudioRecording(String noteId) async {
    try {
      final audioPath = await _recorder.stop();

      if (audioPath != null) {
        // Create audio media item
        final mediaItem = MediaItem(
          id: _uuid.v4(),
          type: MediaType.audio,
          filePath: audioPath,
          createdAt: DateTime.now(),
          name: path.basename(audioPath),
          size: await File(audioPath).length(),
        );

        // Save to database
        await localDataSource.addMediaToNote(noteId, mediaItem);
      }
    } catch (e) {
      throw Exception('Failed to stop recording: $e');
    }
  }

  @override
  Future<void> playMedia(String noteId, String mediaId) async {
    try {
      // Get media item from database
      final media = await getMediaById(mediaId);
      if (media == null) throw Exception('Media not found');

      if (media.type == MediaType.audio) {
        await _audioPlayer.play(DeviceFileSource(media.filePath));
      }
    } catch (e) {
      throw Exception('Failed to play media: $e');
    }
  }

  @override
  Future<void> pauseMedia(String noteId, String mediaId) async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      throw Exception('Failed to pause media: $e');
    }
  }

  // ==================== Gallery-centric methods (from v2) ====================

  @override
  Future<List<MediaItem>> getAllMedia() async {
    return await localDataSource.getAllMedia();
  }

  @override
  Future<List<MediaItem>> filterMediaByType(String type) async {
    return await localDataSource.getMediaByType(type);
  }

  @override
  Future<List<MediaItem>> searchMedia(String query) async {
    return await localDataSource.searchMediaByName(query);
  }

  @override
  Future<MediaItem?> getMediaById(String id) async {
    return await localDataSource.getMediaById(id);
  }

  @override
  Future<bool> deleteMedia(String id) async {
    final result = await localDataSource.deleteMedia(id);
    return result > 0;
  }

  @override
  Future<bool> archiveMedia(String id) async {
    final result = await localDataSource.archiveMedia(id);
    return result > 0;
  }

  @override
  Future<Map<String, int>> getMediaStats() async {
    return await localDataSource.getMediaStats();
  }

  @override
  Future<List<MediaItem>> getRecentMedia({int limit = 10}) async {
    return await localDataSource.getRecentMedia(limit);
  }

  @override
  Future<String> addMedia(MediaItem item) async {
    final result = await localDataSource.insertMedia(item);
    return result > 0 ? item.id : '';
  }

  @override
  Future<bool> updateMedia(MediaItem item) async {
    final result = await localDataSource.updateMedia(item);
    return result > 0;
  }

  @override
  Future<List<MediaItem>> getArchivedMedia() async {
    return await localDataSource.getArchivedMedia();
  }

  @override
  Future<bool> restoreMedia(String id) async {
    final result = await localDataSource.restoreMedia(id);
    return result > 0;
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _recorder.dispose();
    await _audioPlayer.dispose();
  }
}
