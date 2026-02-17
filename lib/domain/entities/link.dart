import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../core/utils/url_validator_util.dart';

part 'link.g.dart';

/// Link entity for storing website/URL links in notes
@JsonSerializable()
class Link extends Equatable {
  final String id;
  final String url;
  final String? title;
  final String? description;
  final String? iconUrl;
  final DateTime createdAt;

  const Link({
    required this.id,
    required this.url,
    this.title,
    this.description,
    this.iconUrl,
    required this.createdAt,
  });

  /// Create a copy with modified fields
  Link copyWith({
    String? id,
    String? url,
    String? title,
    String? description,
    String? iconUrl,
    DateTime? createdAt,
  }) {
    return Link(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Link.fromJson(Map<String, dynamic> json) => _$LinkFromJson(json);

  Map<String, dynamic> toJson() => _$LinkToJson(this);

  /// Validate URL format
  static bool isValidUrl(String url) => UrlValidatorUtil.isValidUrl(url);

  /// Ensure URL has scheme
  static String ensureScheme(String url) => UrlValidatorUtil.normalizeUrl(url);

  @override
  List<Object?> get props => [id, url, title, description, iconUrl, createdAt];
}
