import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'media_item.g.dart';

enum MediaType { image, audio, video, document }

@JsonSerializable()
class MediaItem extends Equatable {
  final String id;
  final MediaType type;
  final String filePath;
  final String name; // Added
  final int size; // Added
  final int durationMs; // 0 for images; else duration in ms
  final String thumbnailPath;
  final Map<String, dynamic> metadata; // New: for annotations, trim info, etc.
  final DateTime createdAt;

  MediaItem({
    required this.id,
    required this.type,
    required this.filePath,
    this.name = '',
    this.size = 0,
    this.durationMs = 0,
    this.thumbnailPath = '',
    this.metadata = const {},
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
    metadata,
    createdAt,
  ];

  factory MediaItem.fromJson(Map<String, dynamic> json) =>
      _$MediaItemFromJson(json);

  Map<String, dynamic> toJson() => _$MediaItemToJson(this);

  /// Copy with method for creating modified copies
  MediaItem copyWith({
    String? id,
    MediaType? type,
    String? filePath,
    String? name,
    int? size,
    int? durationMs,
    String? thumbnailPath,
    Map<String, dynamic>? metadata,
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
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
