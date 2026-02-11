import '../../domain/entities/reflection_answer.dart';

class ReflectionAnswerModel extends ReflectionAnswer {
  const ReflectionAnswerModel({
    required super.id,
    required super.questionId,
    required super.answerText,
    super.mood,
    super.moodValue,
    super.energyLevel,
    super.sleepQuality,
    super.activityTags,
    super.isPrivate,
    required super.createdAt,
    required super.reflectionDate,
    super.draft,
  });

  /// Convert from entity to model
  factory ReflectionAnswerModel.fromEntity(ReflectionAnswer entity) {
    return ReflectionAnswerModel(
      id: entity.id,
      questionId: entity.questionId,
      answerText: entity.answerText,
      mood: entity.mood,
      moodValue: entity.moodValue,
      energyLevel: entity.energyLevel,
      sleepQuality: entity.sleepQuality,
      activityTags: entity.activityTags,
      isPrivate: entity.isPrivate,
      createdAt: entity.createdAt,
      reflectionDate: entity.reflectionDate,
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
      moodValue: json['moodValue'] as int?,
      energyLevel: json['energyLevel'] as int?,
      sleepQuality: json['sleepQuality'] as int?,
      activityTags:
          (json['activityTags'] as String?)
              ?.split(',')
              .where((e) => e.isNotEmpty)
              .toList() ??
          [],
      isPrivate: (json['isPrivate'] as int?) == 1,
      createdAt: DateTime.parse(json['createdAt'] as String),
      reflectionDate: DateTime.parse(
        json['reflectionDate'] ?? json['createdAt'] as String,
      ),
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
      'moodValue': moodValue,
      'energyLevel': energyLevel,
      'sleepQuality': sleepQuality,
      'activityTags': activityTags.join(','),
      'isPrivate': isPrivate ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'reflectionDate': reflectionDate.toIso8601String(),
      'draft': draft,
    };
  }
}
