import '../../domain/entities/media_item.dart';

abstract class MediaRepository {
  // Note-centric methods (from v1)
  Future<MediaItem> addImageToNote(String noteId, String imagePath);
  Future<MediaItem> addVideoToNote(
    String noteId,
    String videoPath, {
    String? thumbnailPath,
  });
  Future<void> removeMediaFromNote(String noteId, String mediaId);
  Future<MediaItem> compressMedia(MediaItem media);
  Future<void> startAudioRecording(String noteId);
  Future<void> stopAudioRecording(String noteId);
  Future<void> playMedia(String noteId, String mediaId);
  Future<void> pauseMedia(String noteId, String mediaId);

  // Gallery-centric methods (from v2)
  Future<List<MediaItem>> getAllMedia();
  Future<List<MediaItem>> filterMediaByType(String type);
  Future<List<MediaItem>> searchMedia(String query);
  Future<MediaItem?> getMediaById(String id);
  Future<bool> deleteMedia(String id);
  Future<bool> archiveMedia(String id);
  Future<Map<String, int>> getMediaStats();
  Future<List<MediaItem>> getRecentMedia({int limit = 10});
  Future<String> addMedia(MediaItem item);
  Future<bool> updateMedia(MediaItem item);
  Future<List<MediaItem>> getArchivedMedia();
  Future<bool> restoreMedia(String id);
}
