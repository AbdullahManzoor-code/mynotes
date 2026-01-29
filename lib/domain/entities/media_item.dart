import 'package:equatable/equatable.dart';

enum MediaType { image, audio, video }

class MediaItem extends Equatable {
  final String id;
  final MediaType type;
  final String filePath;
  final String name; // Added
  final int size; // Added
  final int durationMs; // 0 for images; else duration in ms
  final String thumbnailPath;
  final DateTime createdAt;

  MediaItem({
    required this.id,
    required this.type,
    required this.filePath,
    this.name = '',
    this.size = 0,
    this.durationMs = 0,
    this.thumbnailPath = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  List<Object?> get props => [
    id,
    type,
    filePath,
    name,
    size,
    durationMs,
    thumbnailPath,
    createdAt,
  ];

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': _typeToString(type),
    'filePath': filePath,
    'name': name,
    'size': size,
    'durationMs': durationMs,
    'thumbnailPath': thumbnailPath,
    'createdAt': createdAt.toIso8601String(),
  };

  static String _typeToString(MediaType t) {
    switch (t) {
      case MediaType.image:
        return 'image';
      case MediaType.audio:
        return 'audio';
      case MediaType.video:
        return 'video';
    }
  }

  static MediaType _stringToType(String s) {
    switch (s) {
      case 'image':
        return MediaType.image;
      case 'audio':
        return MediaType.audio;
      case 'video':
        return MediaType.video;
      default:
        return MediaType.image;
    }
  }

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] as String,
      type: _stringToType(json['type'] as String),
      filePath: json['filePath'] as String,
      name: (json['name'] as String?) ?? '',
      size: (json['size'] as int?) ?? 0,
      durationMs: (json['durationMs'] as int?) ?? 0,
      thumbnailPath: (json['thumbnailPath'] as String?) ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Copy with method for creating modified copies
  MediaItem copyWith({
    String? id,
    MediaType? type,
    String? filePath,
    String? name,
    int? size,
    int? durationMs,
    String? thumbnailPath,
    DateTime? createdAt,
  }) {
    return MediaItem(
      id: id ?? this.id,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      name: name ?? this.name,
      size: size ?? this.size,
      durationMs: durationMs ?? this.durationMs,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
