import 'package:equatable/equatable.dart';

/// Todo Priority Levels (TD-006)
enum TodoPriority {
  low('Low', 'green', 1),
  medium('Medium', 'yellow', 2),
  high('High', 'orange', 3),
  urgent('Urgent', 'red', 4);

  const TodoPriority(this.displayName, this.color, this.level);

  final String displayName;
  final String color;
  final int level;
}

/// Todo Categories (TD-005)
enum TodoCategory {
  personal('Personal', '👤'),
  work('Work', '💼'),
  shopping('Shopping', '🛒'),
  health('Health', '🏥'),
  finance('Finance', '💰'),
  education('Education', '🎓'),
  home('Home', '🏠'),
  other('Other', '📝');

  const TodoCategory(this.displayName, this.icon);

  final String displayName;
  final String icon;
}

class TodoItem extends Equatable {
  final String id;
  final String text;
  final bool isCompleted;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final TodoPriority priority;
  final TodoCategory category;
  final String? notes; // TD-008
  final DateTime createdAt;
  final DateTime updatedAt;

  const TodoItem({
    required this.id,
    required this.text,
    this.isCompleted = false,
    this.dueDate,
    this.completedAt,
    this.priority = TodoPriority.medium,
    this.category = TodoCategory.personal,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  TodoItem toggleComplete() {
    return TodoItem(
      id: id,
      text: text,
      isCompleted: !isCompleted,
      dueDate: dueDate,
      completedAt: !isCompleted ? DateTime.now() : null,
      priority: priority,
      category: category,
      notes: notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  TodoItem copyWith({
    String? id,
    String? text,
    bool? isCompleted,
    DateTime? dueDate,
    DateTime? completedAt,
    TodoPriority? priority,
    TodoCategory? category,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    text,
    isCompleted,
    dueDate,
    completedAt,
    priority,
    category,
    notes,
    createdAt,
    updatedAt,
  ];

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'isCompleted': isCompleted,
    'dueDate': dueDate?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'priority': priority.name,
    'category': category.name,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] as String,
      text: json['text'] as String,
      isCompleted: (json['isCompleted'] as bool?) ?? false,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      priority: TodoPriority.values.firstWhere(
        (p) => p.name == (json['priority'] as String?),
        orElse: () => TodoPriority.medium,
      ),
      category: TodoCategory.values.firstWhere(
        (c) => c.name == (json['category'] as String?),
        orElse: () => TodoCategory.personal,
      ),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
