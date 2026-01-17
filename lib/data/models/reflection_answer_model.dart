import '../../domain/entities/reflection_answer.dart';

class ReflectionAnswerModel extends ReflectionAnswer {
  const ReflectionAnswerModel({
    required super.id,
    required super.questionId,
    required super.answerText,
    super.mood,
    required super.createdAt,
    super.draft,
  });

  /// Convert from entity to model
  factory ReflectionAnswerModel.fromEntity(ReflectionAnswer entity) {
    return ReflectionAnswerModel(
      id: entity.id,
      questionId: entity.questionId,
      answerText: entity.answerText,
      mood: entity.mood,
      createdAt: entity.createdAt,
      draft: entity.draft,
    );
  }

  /// Convert from JSON (database)
  factory ReflectionAnswerModel.fromJson(Map<String, dynamic> json) {
    return ReflectionAnswerModel(
      id: json['id'] as String,
      questionId: json['questionId'] as String,
      answerText: json['answerText'] as String,
      mood: json['mood'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      draft: json['draft'] as String?,
    );
  }

  /// Convert to JSON for database
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'answerText': answerText,
      'mood': mood,
      'createdAt': createdAt.toIso8601String(),
      'draft': draft,
    };
  }
}
