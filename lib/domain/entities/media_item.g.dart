// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaItem _$MediaItemFromJson(Map<String, dynamic> json) => MediaItem(
  id: json['id'] as String,
  type: $enumDecode(_$MediaTypeEnumMap, json['type']),
  filePath: json['filePath'] as String,
  name: json['name'] as String? ?? '',
  size: (json['size'] as num?)?.toInt() ?? 0,
  durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
  thumbnailPath: json['thumbnailPath'] as String? ?? '',
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$MediaItemToJson(MediaItem instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$MediaTypeEnumMap[instance.type]!,
  'filePath': instance.filePath,
  'name': instance.name,
  'size': instance.size,
  'durationMs': instance.durationMs,
  'thumbnailPath': instance.thumbnailPath,
  'metadata': instance.metadata,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$MediaTypeEnumMap = {
  MediaType.image: 'image',
  MediaType.audio: 'audio',
  MediaType.video: 'video',
  MediaType.document: 'document',
};
