import 'package:equatable/equatable.dart';

class TodoItem extends Equatable {
  final String id;
  final String text;
  final bool isCompleted;
  final DateTime? dueDate;

  const TodoItem({
    required this.id,
    required this.text,
    this.isCompleted = false,
    this.dueDate,
  });

  TodoItem toggleComplete() {
    return TodoItem(
      id: id,
      text: text,
      isCompleted: !isCompleted,
      dueDate: dueDate,
    );
  }

  TodoItem copyWith({
    String? id,
    String? text,
    bool? isCompleted,
    DateTime? dueDate,
  }) {
    return TodoItem(
      id: id ?? this.id,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  @override
  List<Object?> get props => [id, text, isCompleted, dueDate];

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'isCompleted': isCompleted,
    'dueDate': dueDate?.toIso8601String(),
  };

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] as String,
      text: json['text'] as String,
      isCompleted: (json['isCompleted'] as bool?) ?? false,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
    );
  }
}
