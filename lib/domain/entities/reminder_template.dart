import 'package:equatable/equatable.dart';

/// Reminder Template model
class ReminderTemplate extends Equatable {
  final String id;
  final String name;
  final String description;
  final String time;
  final String frequency;
  final String duration;
  final String category; // 'Work', 'Personal', 'Health'
  final bool isFavorite;
  final DateTime createdAt;
  final int usageCount;

  const ReminderTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.time,
    required this.frequency,
    required this.duration,
    required this.category,
    this.isFavorite = false,
    required this.createdAt,
    this.usageCount = 0,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    time,
    frequency,
    duration,
    category,
    isFavorite,
    createdAt,
    usageCount,
  ];

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'time': time,
    'frequency': frequency,
    'duration': duration,
    'category': category,
    'isFavorite': isFavorite ? 1 : 0,
    'createdAt': createdAt.toIso8601String(),
    'usageCount': usageCount,
  };

  /// Create from JSON
  factory ReminderTemplate.fromJson(Map<String, dynamic> json) {
    return ReminderTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      time: json['time'] as String,
      frequency: json['frequency'] as String,
      duration: json['duration'] as String,
      category: json['category'] as String,
      isFavorite: json['isFavorite'] == 1 || json['isFavorite'] == true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      usageCount: json['usageCount'] as int? ?? 0,
    );
  }

  /// Create a copy with modifications
  ReminderTemplate copyWith({
    String? id,
    String? name,
    String? description,
    String? time,
    String? frequency,
    String? duration,
    String? category,
    bool? isFavorite,
    DateTime? createdAt,
    int? usageCount,
  }) {
    return ReminderTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      time: time ?? this.time,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      usageCount: usageCount ?? this.usageCount,
    );
  }
}
