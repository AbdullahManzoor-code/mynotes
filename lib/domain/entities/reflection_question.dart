import 'package:equatable/equatable.dart';

/// Represents a reflection question
/// Can be preset or user-created
class ReflectionQuestion extends Equatable {
  final String id;
  final String questionText;
  final String category; // life, daily, career, mental_health
  final bool isUserCreated;
  final String frequency; // daily, weekly, monthly, once
  final DateTime createdAt;

  const ReflectionQuestion({
    required this.id,
    required this.questionText,
    required this.category,
    this.isUserCreated = false,
    this.frequency = 'daily',
    required this.createdAt,
  });

  ReflectionQuestion copyWith({
    String? id,
    String? questionText,
    String? category,
    bool? isUserCreated,
    String? frequency,
    DateTime? createdAt,
  }) {
    return ReflectionQuestion(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      category: category ?? this.category,
      isUserCreated: isUserCreated ?? this.isUserCreated,
      frequency: frequency ?? this.frequency,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    questionText,
    category,
    isUserCreated,
    frequency,
    createdAt,
  ];
}

