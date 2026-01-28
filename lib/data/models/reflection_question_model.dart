import '../../domain/entities/reflection_question.dart';

class ReflectionQuestionModel extends ReflectionQuestion {
  const ReflectionQuestionModel({
    required super.id,
    required super.questionText,
    required super.category,
    super.isUserCreated = false,
    super.frequency = 'daily',
    required super.createdAt,
  });

  /// Convert from entity to model
  factory ReflectionQuestionModel.fromEntity(ReflectionQuestion entity) {
    return ReflectionQuestionModel(
      id: entity.id,
      questionText: entity.questionText,
      category: entity.category,
      isUserCreated: entity.isUserCreated,
      frequency: entity.frequency,
      createdAt: entity.createdAt,
    );
  }

  /// Convert from JSON (database)
  factory ReflectionQuestionModel.fromJson(Map<String, dynamic> json) {
    return ReflectionQuestionModel(
      id: json['id'] as String,
      questionText: json['questionText'] as String,
      category: json['category'] as String,
      isUserCreated: (json['isUserCreated'] as int?) == 1,
      frequency: json['frequency'] as String? ?? 'daily',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert to JSON for database
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'category': category,
      'isUserCreated': isUserCreated ? 1 : 0,
      'frequency': frequency,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

