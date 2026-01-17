import 'package:equatable/equatable.dart';

/// Represents an answer to a reflection question
/// Answers are never deleted, only added to history
class ReflectionAnswer extends Equatable {
  final String id;
  final String questionId;
  final String answerText;
  final String? mood; // happy, sad, neutral, stressed, calm, grateful, anxious
  final DateTime createdAt;
  final String? draft; // For autosave drafts

  const ReflectionAnswer({
    required this.id,
    required this.questionId,
    required this.answerText,
    this.mood,
    required this.createdAt,
    this.draft,
  });

  ReflectionAnswer copyWith({
    String? id,
    String? questionId,
    String? answerText,
    String? mood,
    DateTime? createdAt,
    String? draft,
  }) {
    return ReflectionAnswer(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      answerText: answerText ?? this.answerText,
      mood: mood ?? this.mood,
      createdAt: createdAt ?? this.createdAt,
      draft: draft ?? this.draft,
    );
  }

  @override
  List<Object?> get props => [
    id,
    questionId,
    answerText,
    mood,
    createdAt,
    draft,
  ];
}
