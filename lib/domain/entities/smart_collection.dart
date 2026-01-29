import 'package:equatable/equatable.dart';

/// Smart Collection model for rule-based collections
class SmartCollection extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<CollectionRule> rules;
  final int itemCount;
  final DateTime lastUpdated;
  final bool isActive;

  const SmartCollection({
    required this.id,
    required this.name,
    required this.description,
    required this.rules,
    required this.itemCount,
    required this.lastUpdated,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    rules,
    itemCount,
    lastUpdated,
    isActive,
  ];

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'rules': rules.map((r) => r.toJson()).toList(),
    'itemCount': itemCount,
    'lastUpdated': lastUpdated.toIso8601String(),
    'isActive': isActive,
  };

  /// Create from JSON
  factory SmartCollection.fromJson(Map<String, dynamic> json) {
    return SmartCollection(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      rules:
          (json['rules'] as List<dynamic>?)
              ?.map((r) => CollectionRule.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      itemCount: json['itemCount'] as int? ?? 0,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Create a copy with modifications
  SmartCollection copyWith({
    String? id,
    String? name,
    String? description,
    List<CollectionRule>? rules,
    int? itemCount,
    DateTime? lastUpdated,
    bool? isActive,
  }) {
    return SmartCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      rules: rules ?? this.rules,
      itemCount: itemCount ?? this.itemCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Rule for smart collections
class CollectionRule extends Equatable {
  final String type; // 'tag', 'priority', 'type', etc.
  final String operator; // 'contains', 'equals', 'not_equals'
  final String value;

  const CollectionRule({
    required this.type,
    required this.operator,
    required this.value,
  });

  @override
  List<Object?> get props => [type, operator, value];

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'type': type,
    'operator': operator,
    'value': value,
  };

  /// Create from JSON
  factory CollectionRule.fromJson(Map<String, dynamic> json) {
    return CollectionRule(
      type: json['type'] as String,
      operator: json['operator'] as String,
      value: json['value'] as String,
    );
  }
}
