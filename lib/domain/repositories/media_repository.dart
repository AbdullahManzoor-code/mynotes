import '../../domain/entities/media_item.dart';

abstract class MediaRepository {
  Future<MediaItem> addImageToNote(String noteId, String imagePath);
  Future<MediaItem> addVideoToNote(String noteId, String videoPath, {String? thumbnailPath});
  Future<void> removeMediaFromNote(String noteId, String mediaId);
  Future<MediaItem> compressMedia(MediaItem media);
  Future<void> startAudioRecording(String noteId);
  Future<void> stopAudioRecording(String noteId);
  Future<void> playMedia(String noteId, String mediaId);
  Future<void> pauseMedia(String noteId, String mediaId);
}

