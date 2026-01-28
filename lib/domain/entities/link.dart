import 'package:equatable/equatable.dart';

/// Link entity for storing website/URL links in notes
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

  /// Convert to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'description': description,
      'iconUrl': iconUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from database map
  factory Link.fromMap(Map<String, dynamic> map) {
    return Link(
      id: map['id'] ?? '',
      url: map['url'] ?? '',
      title: map['title'],
      description: map['description'],
      iconUrl: map['iconUrl'],
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Validate URL format
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return url.startsWith('http://') || url.startsWith('https://');
    } catch (e) {
      return false;
    }
  }

  /// Ensure URL has scheme
  static String ensureScheme(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'https://$url';
    }
    return url;
  }

  @override
  List<Object?> get props => [id, url, title, description, iconUrl, createdAt];
}

