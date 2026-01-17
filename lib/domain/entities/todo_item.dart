import 'package:equatable/equatable.dart';

class TodoItem extends Equatable {
  final String id;
  final String text;
  final bool completed;
  final DateTime? dueDate;

  const TodoItem({
    required this.id,
    required this.text,
    this.completed = false,
    this.dueDate,
  });

  TodoItem toggleComplete() {
    return TodoItem(
      id: id,
      text: text,
      completed: !completed,
      dueDate: dueDate,
    );
  }

  TodoItem copyWith({
    String? id,
    String? text,
    bool? completed,
    DateTime? dueDate,
  }) {
    return TodoItem(
      id: id ?? this.id,
      text: text ?? this.text,
      completed: completed ?? this.completed,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  @override
  List<Object?> get props => [id, text, completed, dueDate];

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'completed': completed,
    'dueDate': dueDate?.toIso8601String(),
  };

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] as String,
      text: json['text'] as String,
      completed: (json['completed'] as bool?) ?? false,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
    );
  }
}
