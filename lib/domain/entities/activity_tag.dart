/// Activity tag entity for mood tracking
class ActivityTag {
  final String id;
  final String tagName;
  final String? color;
  final String? icon;
  final int usageCount;
  final DateTime? lastUsedAt;
  final DateTime createdAt;
  final int? order;
  final bool isDeleted;

  const ActivityTag({
    required this.id,
    required this.tagName,
    this.color,
    this.icon,
    this.usageCount = 0,
    this.lastUsedAt,
    required this.createdAt,
    this.order,
    this.isDeleted = false,
  });

  /// Create from JSON map (from database)
  factory ActivityTag.fromMap(Map<String, dynamic> map) {
    return ActivityTag(
      id: map['id'] as String,
      tagName: map['tagName'] as String,
      color: map['color'] as String?,
      icon: map['icon'] as String?,
      usageCount: map['usageCount'] as int? ?? 0,
      lastUsedAt: map['lastUsedAt'] != null
          ? DateTime.parse(map['lastUsedAt'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      order: map['order'] as int?,
      isDeleted: (map['isDeleted'] as int?) == 1,
    );
  }

  /// Convert to JSON map (for database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tagName': tagName,
      'color': color,
      'icon': icon,
      'usageCount': usageCount,
      'lastUsedAt': lastUsedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'order': order,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  /// Copy with modifications
  ActivityTag copyWith({
    String? id,
    String? tagName,
    String? color,
    String? icon,
    int? usageCount,
    DateTime? lastUsedAt,
    DateTime? createdAt,
    int? order,
    bool? isDeleted,
  }) {
    return ActivityTag(
      id: id ?? this.id,
      tagName: tagName ?? this.tagName,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      usageCount: usageCount ?? this.usageCount,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      createdAt: createdAt ?? this.createdAt,
      order: order ?? this.order,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
