import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../core/constants/media_constants.dart';
import '../../core/services/permission_service.dart';
import '../../domain/repositories/media_repository.dart';
import '../../domain/entities/media_item.dart';
import '../datasources/local_database.dart';

/// Real MediaRepository implementation with image/video picker and audio recording
class MediaRepositoryImpl implements MediaRepository {
  final NotesDatabase database;
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Uuid _uuid = const Uuid();

  MediaRepositoryImpl({required this.database});

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
      );

      // Save to database
      await database.addMediaToNote(noteId, mediaItem);

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
      );

      // Save to database
      await database.addMediaToNote(noteId, mediaItem);

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
      await database.removeMediaFromNote(noteId, mediaId);
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

        return media.copyWith(filePath: compressedFile.path);
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
        );

        // Save to database
        await database.addMediaToNote(noteId, mediaItem);
      }
    } catch (e) {
      throw Exception('Failed to stop recording: $e');
    }
  }

  @override
  Future<void> playMedia(String noteId, String mediaId) async {
    try {
      // Get media item from database
      final mediaItems = await database.getMediaForNote(noteId);
      final media = mediaItems.firstWhere((m) => m.id == mediaId);

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

  /// Dispose resources
  Future<void> dispose() async {
    await _recorder.dispose();
    await _audioPlayer.dispose();
  }
}

