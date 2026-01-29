import 'package:sqflite/sqflite.dart';
import 'package:mynotes/data/datasources/local/media_local_datasource.dart';
import 'package:mynotes/domain/entities/media_item.dart';

/// Implementation of MediaLocalDataSource using SQLite
class MediaLocalDataSourceImpl implements MediaLocalDataSource {
  final Database database;

  MediaLocalDataSourceImpl({required this.database});

  static const String tableName = 'media';
  static const String tableMediaTags = 'media_tags';

  @override
  Future<List<MediaItem>> getAllMedia() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(tableName);
      return List<MediaItem>.from(maps.map((x) => MediaItem.fromJson(x)));
    } catch (e) {
      throw Exception('Failed to load media: $e');
    }
  }

  @override
  Future<int> insertMedia(MediaItem item) async {
    try {
      return await database.insert(tableName, item.toJson());
    } catch (e) {
      throw Exception('Failed to insert media: $e');
    }
  }

  @override
  Future<int> addMediaToNote(String noteId, MediaItem item) async {
    try {
      final map = item.toJson();
      map['noteId'] = noteId;
      return await database.insert(
        tableName,
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to add media to note: $e');
    }
  }

  @override
  Future<int> removeMediaFromNote(String noteId, String mediaId) async {
    try {
      return await database.delete(
        tableName,
        where: 'noteId = ? AND id = ?',
        whereArgs: [noteId, mediaId],
      );
    } catch (e) {
      throw Exception('Failed to remove media from note: $e');
    }
  }

  @override
  Future<int> updateMedia(MediaItem item) async {
    try {
      return await database.update(
        tableName,
        item.toJson(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
    } catch (e) {
      throw Exception('Failed to update media: $e');
    }
  }

  @override
  Future<int> deleteMedia(String id) async {
    try {
      await database.delete(
        tableMediaTags,
        where: 'mediaId = ?',
        whereArgs: [id],
      );
      return await database.delete(tableName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Failed to delete media: $e');
    }
  }

  @override
  Future<List<MediaItem>> getMediaByType(String type) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        tableName,
        where: 'type = ?',
        whereArgs: [type],
      );
      return List<MediaItem>.from(maps.map((x) => MediaItem.fromJson(x)));
    } catch (e) {
      throw Exception('Failed to get media by type: $e');
    }
  }

  @override
  Future<List<MediaItem>> searchMediaByName(String query) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        tableName,
        where: 'name LIKE ?',
        whereArgs: ['%$query%'],
      );
      return List<MediaItem>.from(maps.map((x) => MediaItem.fromJson(x)));
    } catch (e) {
      throw Exception('Failed to search media: $e');
    }
  }

  @override
  Future<MediaItem?> getMediaById(String id) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return MediaItem.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get media: $e');
    }
  }

  @override
  Future<List<MediaItem>> getArchivedMedia() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        tableName,
        where: 'isArchived = ?',
        whereArgs: [1],
      );
      return List<MediaItem>.from(maps.map((x) => MediaItem.fromJson(x)));
    } catch (e) {
      throw Exception('Failed to get archived media: $e');
    }
  }

  @override
  Future<Map<String, int>> getMediaStats() async {
    try {
      final totalResult = await database.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE isArchived = 0',
      );
      final imageResult = await database.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE type = ? AND isArchived = 0',
        ['image'],
      );
      final videoResult = await database.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE type = ? AND isArchived = 0',
        ['video'],
      );
      final audioResult = await database.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE type = ? AND isArchived = 0',
        ['audio'],
      );

      return {
        'total': totalResult.first['count'] as int? ?? 0,
        'image': imageResult.first['count'] as int? ?? 0,
        'video': videoResult.first['count'] as int? ?? 0,
        'audio': audioResult.first['count'] as int? ?? 0,
      };
    } catch (e) {
      throw Exception('Failed to get media stats: $e');
    }
  }

  @override
  Future<List<MediaItem>> getRecentMedia(int limit) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        tableName,
        where: 'isArchived = ?',
        whereArgs: [0],
        orderBy: 'createdAt DESC',
        limit: limit,
      );
      return List<MediaItem>.from(maps.map((x) => MediaItem.fromJson(x)));
    } catch (e) {
      throw Exception('Failed to get recent media: $e');
    }
  }

  @override
  Future<int> archiveMedia(String id) async {
    try {
      return await database.update(
        tableName,
        {'isArchived': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to archive media: $e');
    }
  }

  @override
  Future<int> restoreMedia(String id) async {
    try {
      return await database.update(
        tableName,
        {'isArchived': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to restore media: $e');
    }
  }

  @override
  Future<int> deleteMultipleMedia(List<String> ids) async {
    try {
      final placeholders = List.filled(ids.length, '?').join(',');
      return await database.delete(
        tableName,
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
    } catch (e) {
      throw Exception('Failed to delete multiple media: $e');
    }
  }

  @override
  Future<List<String>> getMediaTags(String mediaId) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        tableMediaTags,
        where: 'mediaId = ?',
        whereArgs: [mediaId],
      );
      return List<String>.from(maps.map((x) => x['tag']));
    } catch (e) {
      throw Exception('Failed to get media tags: $e');
    }
  }

  @override
  Future<int> addMediaTag(String mediaId, String tag) async {
    try {
      return await database.insert(tableMediaTags, {
        'mediaId': mediaId,
        'tag': tag,
      });
    } catch (e) {
      throw Exception('Failed to add media tag: $e');
    }
  }

  @override
  Future<int> clearAllMedia() async {
    try {
      await database.delete(tableMediaTags);
      return await database.delete(tableName);
    } catch (e) {
      throw Exception('Failed to clear media: $e');
    }
  }
}
