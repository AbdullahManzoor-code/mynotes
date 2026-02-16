import 'package:equatable/equatable.dart';

/// Represents a reflection question
/// Can be preset or user-created
class ReflectionQuestion extends Equatable {
  final String id;
  final String questionText;
  final String category; // life, daily, career, mental_health
  final bool isUserCreated;
  final bool isPinned;
  final String frequency; // daily, weekly, monthly, once
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReflectionQuestion({
    required this.id,
    required this.questionText,
    required this.category,
    this.isUserCreated = false,
    this.isPinned = false,
    this.frequency = 'daily',
    required this.createdAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  ReflectionQuestion copyWith({
    String? id,
    String? questionText,
    String? category,
    bool? isUserCreated,
    bool? isPinned,
    String? frequency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReflectionQuestion(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      category: category ?? this.category,
      isUserCreated: isUserCreated ?? this.isUserCreated,
      isPinned: isPinned ?? this.isPinned,
      frequency: frequency ?? this.frequency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    questionText,
    category,
    isUserCreated,
    isPinned,
    frequency,
    createdAt,
    updatedAt,
  ];

  factory ReflectionQuestion.fromMap(Map<String, dynamic> map) {
    return ReflectionQuestion(
      id: (map['id'] as String?) ?? '',
      questionText: ((map['questionText'] ?? map['text']) as String?) ?? '',
      category: (map['category'] as String?) ?? 'General',
      isUserCreated: (map['isCustom'] as int?) == 1,
      isPinned: (map['isPinned'] as int?) == 1,
      frequency: (map['frequency'] as String?) ?? 'daily',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionText': questionText,
      'category': category,
      'isCustom': isUserCreated ? 1 : 0,
      'isPinned': isPinned ? 1 : 0,
      'frequency': frequency,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
