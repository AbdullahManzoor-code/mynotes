import 'package:equatable/equatable.dart';

/// Subtask Entity - Nested tasks within a todo
class Subtask extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Subtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [id, title, isCompleted, createdAt, completedAt];

  Subtask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Subtask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Subtask toggleComplete() {
    return copyWith(
      isCompleted: !isCompleted,
      completedAt: !isCompleted ? DateTime.now() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}

/// Todo Category
enum TodoCategory {
  personal,
  work,
  shopping,
  health,
  finance,
  education,
  home,
  other;

  String get displayName {
    switch (this) {
      case TodoCategory.personal:
        return 'Personal';
      case TodoCategory.work:
        return 'Work';
      case TodoCategory.shopping:
        return 'Shopping';
      case TodoCategory.health:
        return 'Health';
      case TodoCategory.finance:
        return 'Finance';
      case TodoCategory.education:
        return 'Education';
      case TodoCategory.home:
        return 'Home';
      case TodoCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case TodoCategory.personal:
        return '👤';
      case TodoCategory.work:
        return '💼';
      case TodoCategory.shopping:
        return '🛒';
      case TodoCategory.health:
        return '💪';
      case TodoCategory.finance:
        return '💰';
      case TodoCategory.education:
        return '📚';
      case TodoCategory.home:
        return '🏠';
      case TodoCategory.other:
        return '📌';
    }
  }
}

/// Todo Priority
enum TodoPriority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case TodoPriority.low:
        return 'Low';
      case TodoPriority.medium:
        return 'Medium';
      case TodoPriority.high:
        return 'High';
      case TodoPriority.urgent:
        return 'Urgent';
    }
  }

  String get icon {
    switch (this) {
      case TodoPriority.low:
        return '🟢';
      case TodoPriority.medium:
        return '🟡';
      case TodoPriority.high:
        return '🟠';
      case TodoPriority.urgent:
        return '🔴';
    }
  }

  int get sortOrder {
    switch (this) {
      case TodoPriority.urgent:
        return 0;
      case TodoPriority.high:
        return 1;
      case TodoPriority.medium:
        return 2;
      case TodoPriority.low:
        return 3;
    }
  }
}
