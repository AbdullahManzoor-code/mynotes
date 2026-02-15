import 'dart:convert';

import 'package:mynotes/domain/entities/media_item.dart'
    show MediaItem, MediaType;

class MediaMapper {
  /// Convert MediaItem to database map
  static Map<String, dynamic> toMap(String noteId, MediaItem media) {
    return {
      'id': media.id,
      'noteId': noteId,
      'type': media.type.toString().split('.').last,
      'name': media.name,
      'size': media.size,
      'filePath': media.filePath,
      'thumbnailPath': media.thumbnailPath,
      'durationMs': media.durationMs,
      'metadata': jsonEncode(media.metadata),
      'createdAt': media.createdAt.toIso8601String(),
    };
  }

  /// Convert database map to MediaItem
  static MediaItem fromMap(Map<String, dynamic> map) {
    MediaType type;
    switch (map['type']) {
      case 'image':
        type = MediaType.image;
        break;
      case 'video':
        type = MediaType.video;
        break;
      case 'audio':
        type = MediaType.audio;
        break;
      default:
        type = MediaType.image;
    }

    return MediaItem(
      id: map['id'],
      type: type,
      name: map['name'] ?? '',
      size: map['size'] ?? 0,
      filePath: map['filePath'],
      thumbnailPath: map['thumbnailPath'],
      durationMs: map['durationMs'] ?? 0,
      metadata: map['metadata'] != null
          ? jsonDecode(map['metadata'])
          : const {},
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
