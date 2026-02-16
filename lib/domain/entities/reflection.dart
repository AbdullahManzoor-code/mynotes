/// Reflection entity for journaling/daily prompts
class Reflection {
  final String id;
  final String questionId;
  final String answerText;
  final String? mood;
  final int? moodValue;
  final int? energyLevel;
  final int? sleepQuality;
  final List<String> activityTags;
  final bool isPrivate;
  final String? linkedNoteId;
  final String? linkedTodoId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime reflectionDate;
  final bool isDeleted;
  final String? draft;

  const Reflection({
    required this.id,
    required this.questionId,
    required this.answerText,
    this.mood,
    this.moodValue,
    this.energyLevel,
    this.sleepQuality,
    this.activityTags = const [],
    this.isPrivate = false,
    this.linkedNoteId,
    this.linkedTodoId,
    required this.createdAt,
    required this.updatedAt,
    required this.reflectionDate,
    this.isDeleted = false,
    this.draft,
  });

  /// Create from JSON map (from database)
  factory Reflection.fromMap(Map<String, dynamic> map) {
    return Reflection(
      id: (map['id'] as String?) ?? '',
      questionId: (map['questionId'] as String?) ?? '',
      answerText: (map['answerText'] as String?) ?? '',
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
      linkedNoteId: map['linkedNoteId'] as String?,
      linkedTodoId: map['linkedTodoId'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
      reflectionDate: map['reflectionDate'] != null
          ? DateTime.parse(map['reflectionDate'] as String)
          : DateTime.now(),
      isDeleted: (map['isDeleted'] as int?) == 1,
      draft: map['draft'] as String?,
    );
  }

  /// Convert to JSON map (for database)
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
      'linkedNoteId': linkedNoteId,
      'linkedTodoId': linkedTodoId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'reflectionDate': reflectionDate.toIso8601String().split('T')[0],
      'isDeleted': isDeleted ? 1 : 0,
      'draft': draft,
    };
  }

  /// Copy with modifications
  Reflection copyWith({
    String? id,
    String? questionId,
    String? answerText,
    String? mood,
    int? moodValue,
    int? energyLevel,
    int? sleepQuality,
    List<String>? activityTags,
    bool? isPrivate,
    String? linkedNoteId,
    String? linkedTodoId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? reflectionDate,
    bool? isDeleted,
    String? draft,
  }) {
    return Reflection(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      answerText: answerText ?? this.answerText,
      mood: mood ?? this.mood,
      moodValue: moodValue ?? this.moodValue,
      energyLevel: energyLevel ?? this.energyLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      activityTags: activityTags ?? this.activityTags,
      isPrivate: isPrivate ?? this.isPrivate,
      linkedNoteId: linkedNoteId ?? this.linkedNoteId,
      linkedTodoId: linkedTodoId ?? this.linkedTodoId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reflectionDate: reflectionDate ?? this.reflectionDate,
      isDeleted: isDeleted ?? this.isDeleted,
      draft: draft ?? this.draft,
    );
  }
}
