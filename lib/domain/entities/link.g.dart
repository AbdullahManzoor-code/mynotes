// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Link _$LinkFromJson(Map<String, dynamic> json) => Link(
  id: json['id'] as String,
  url: json['url'] as String,
  title: json['title'] as String?,
  description: json['description'] as String?,
  iconUrl: json['iconUrl'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$LinkToJson(Link instance) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'title': instance.title,
  'description': instance.description,
  'iconUrl': instance.iconUrl,
  'createdAt': instance.createdAt.toIso8601String(),
};
