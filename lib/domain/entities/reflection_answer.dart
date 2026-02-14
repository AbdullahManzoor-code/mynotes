import 'package:equatable/equatable.dart';

/// Represents an answer to a reflection question
/// Answers are never deleted, only added to history
class ReflectionAnswer extends Equatable {
  final String id;
  final String questionId;
  final String answerText;
  final String? mood; // happy, sad, neutral, stressed, calm, grateful, anxious
  final int? moodValue; // 1-5
  final int? energyLevel; // 1-5
  final int? sleepQuality; // 1-5
  final List<String> activityTags;
  final bool isPrivate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime reflectionDate;
  final String? linkedNoteId;
  final String? linkedTodoId;
  final bool isDeleted;
  final String? draft; // For autosave drafts

  const ReflectionAnswer({
    required this.id,
    required this.questionId,
    required this.answerText,
    this.mood,
    this.moodValue,
    this.energyLevel,
    this.sleepQuality,
    this.activityTags = const [],
    this.isPrivate = false,
    required this.createdAt,
    DateTime? updatedAt,
    required this.reflectionDate,
    this.linkedNoteId,
    this.linkedTodoId,
    this.isDeleted = false,
    this.draft,
  }) : updatedAt = updatedAt ?? createdAt;

  ReflectionAnswer copyWith({
    String? id,
    String? questionId,
    String? answerText,
    String? mood,
    int? moodValue,
    int? energyLevel,
    int? sleepQuality,
    List<String>? activityTags,
    bool? isPrivate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? reflectionDate,
    String? linkedNoteId,
    String? linkedTodoId,
    bool? isDeleted,
    String? draft,
  }) {
    return ReflectionAnswer(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      answerText: answerText ?? this.answerText,
      mood: mood ?? this.mood,
      moodValue: moodValue ?? this.moodValue,
      energyLevel: energyLevel ?? this.energyLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      activityTags: activityTags ?? this.activityTags,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reflectionDate: reflectionDate ?? this.reflectionDate,
      linkedNoteId: linkedNoteId ?? this.linkedNoteId,
      linkedTodoId: linkedTodoId ?? this.linkedTodoId,
      isDeleted: isDeleted ?? this.isDeleted,
      draft: draft ?? this.draft,
    );
  }

  @override
  List<Object?> get props => [
    id,
    questionId,
    answerText,
    mood,
    moodValue,
    energyLevel,
    sleepQuality,
    activityTags,
    isPrivate,
    createdAt,
    updatedAt,
    reflectionDate,
    linkedNoteId,
    linkedTodoId,
    isDeleted,
    draft,
  ];

  factory ReflectionAnswer.fromMap(Map<String, dynamic> map) {
    return ReflectionAnswer(
      id: map['id'] as String,
      questionId: map['questionId'] as String,
      answerText: map['answerText'] as String,
      mood: map['mood'] as String?,
      moodValue: map['moodValue'] as int?,
      energyLevel: map['energyLevel'] as int?,
      sleepQuality: map['sleepQuality'] as int?,
      activityTags:
          (map['activityTags'] as String?)
              ?.split(',')
              .where((e) => e.isNotEmpty)
              .toList() ??
          [],
      isPrivate: (map['isPrivate'] as int?) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] ?? map['createdAt'] as String),
      reflectionDate: DateTime.parse(
        map['reflectionDate'] ?? map['createdAt'] as String,
      ),
      linkedNoteId: map['linkedNoteId'] as String?,
      linkedTodoId: map['linkedTodoId'] as String?,
      isDeleted: (map['isDeleted'] as int?) == 1,
      draft: map['draft'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
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
      'updatedAt': updatedAt.toIso8601String(),
      'reflectionDate': reflectionDate.toIso8601String().split('T')[0],
      'linkedNoteId': linkedNoteId,
      'linkedTodoId': linkedTodoId,
      'isDeleted': isDeleted ? 1 : 0,
      'draft': draft,
    };
  }

  // );
}

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'questionId': questionId,
//       'answerText': answerText,
//       'mood': mood,
//       'moodValue': moodValue,
//       'energyLevel': energyLevel,
//       'sleepQuality': sleepQuality,
//       'activityTags': activityTags.join(','),
//       'isPrivate': isPrivate ? 1 : 0,
//       'createdAt': createdAt.toIso8601String(),
//       'reflectionDate': reflectionDate.toIso8601String(),
//       'draft': draft,
//     };
//   }
// }
