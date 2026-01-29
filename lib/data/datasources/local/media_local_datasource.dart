import 'package:mynotes/domain/entities/media_item.dart';

/// Local data source for media - handles SQLite operations
abstract class MediaLocalDataSource {
  /// Load all media from database
  Future<List<MediaItem>> getAllMedia();

  /// Insert new media record
  Future<int> insertMedia(MediaItem item);

  /// Add media to note
  Future<int> addMediaToNote(String noteId, MediaItem item);

  /// Remove media from note
  Future<int> removeMediaFromNote(String noteId, String mediaId);

  /// Update media record
  Future<int> updateMedia(MediaItem item);

  /// Delete media record
  Future<int> deleteMedia(String id);

  /// Query media by type
  Future<List<MediaItem>> getMediaByType(String type);

  /// Query media by name (search)
  Future<List<MediaItem>> searchMediaByName(String query);

  /// Get media by ID
  Future<MediaItem?> getMediaById(String id);

  /// Get archived media
  Future<List<MediaItem>> getArchivedMedia();

  /// Get media count by type
  Future<Map<String, int>> getMediaStats();

  /// Get recent media
  Future<List<MediaItem>> getRecentMedia(int limit);

  /// Mark media as archived
  Future<int> archiveMedia(String id);

  /// Restore archived media
  Future<int> restoreMedia(String id);

  /// Delete multiple media
  Future<int> deleteMultipleMedia(List<String> ids);

  /// Get media tags
  Future<List<String>> getMediaTags(String mediaId);

  /// Add tag to media
  Future<int> addMediaTag(String mediaId, String tag);

  /// Clear all media (for testing)
  Future<int> clearAllMedia();
}
