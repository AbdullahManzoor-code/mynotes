import 'package:equatable/equatable.dart';

class FocusSession extends Equatable {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final String? taskTitle;
  final String category;
  final bool isCompleted;
  final int? rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FocusSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
    this.taskTitle,
    this.category = 'Focus',
    this.isCompleted = false,
    this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  FocusSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    String? taskTitle,
    String? category,
    bool? isCompleted,
    int? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FocusSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      taskTitle: taskTitle ?? this.taskTitle,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    startTime,
    endTime,
    durationSeconds,
    taskTitle,
    category,
    isCompleted,
    rating,
    createdAt,
    updatedAt,
  ];
}
