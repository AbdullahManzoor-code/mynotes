import 'package:equatable/equatable.dart';
import '../../../domain/entities/reflection_question.dart';
import '../../../domain/entities/reflection_answer.dart';
import '../../../core/exceptions/app_exceptions.dart';

class ReflectionState extends Equatable {
  final List<ReflectionQuestion> questions;
  final List<ReflectionAnswer> answers;
  final List<ReflectionAnswer> allAnswers;
  final int answeredToday;
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final String? draftText;
  final List<Map<String, String>> templates;
  final String? selectedTemplateId;
  final int streakCount;
  final int longestStreak;
  final int totalReflectionsCount;

  const ReflectionState({
    this.questions = const [],
    this.answers = const [],
    this.allAnswers = const [],
    this.answeredToday = 0,
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.draftText,
    this.templates = const [],
    this.selectedTemplateId,
    this.streakCount = 0,
    this.longestStreak = 0,
    this.totalReflectionsCount = 0,
  });

  ReflectionState copyWith({
    List<ReflectionQuestion>? questions,
    List<ReflectionAnswer>? answers,
    List<ReflectionAnswer>? allAnswers,
    int? answeredToday,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? successMessage,
    String? draftText,
    List<Map<String, String>>? templates,
    String? selectedTemplateId,
    int? streakCount,
    int? longestStreak,
    int? totalReflectionsCount,
  }) {
    return ReflectionState(
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      allAnswers: allAnswers ?? this.allAnswers,
      answeredToday: answeredToday ?? this.answeredToday,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      successMessage: successMessage ?? this.successMessage,
      draftText: draftText ?? this.draftText,
      templates: templates ?? this.templates,
      selectedTemplateId: selectedTemplateId ?? this.selectedTemplateId,
      streakCount: streakCount ?? this.streakCount,
      longestStreak: longestStreak ?? this.longestStreak,
      totalReflectionsCount:
          totalReflectionsCount ?? this.totalReflectionsCount,
    );
  }

  @override
  List<Object?> get props => [
    questions,
    answers,
    allAnswers,
    answeredToday,
    isLoading,
    error,
    successMessage,
    draftText,
    templates,
    selectedTemplateId,
    streakCount,
    longestStreak,
    totalReflectionsCount,
  ];

  // Helper getters for backward compatibility
  String get message => successMessage ?? error ?? '';
}

class ReflectionInitial extends ReflectionState {
  const ReflectionInitial() : super();
}

class ReflectionLoading extends ReflectionState {
  const ReflectionLoading() : super(isLoading: true);
}

class ReflectionsLoaded extends ReflectionState {
  const ReflectionsLoaded({
    super.questions,
    super.answers,
    super.allAnswers,
    super.answeredToday,
    super.templates,
  });
}

class QuestionsLoaded extends ReflectionState {
  const QuestionsLoaded({required super.questions, super.answeredToday});
}

class AnswersLoaded extends ReflectionState {
  const AnswersLoaded(List<ReflectionAnswer> answers) : super(answers: answers);
}

class AllAnswersLoaded extends ReflectionState {
  const AllAnswersLoaded(List<ReflectionAnswer> allAnswers)
    : super(allAnswers: allAnswers, answers: allAnswers);
}

class AnswerSaved extends ReflectionState {
  const AnswerSaved(String message) : super(successMessage: message);
}

class DraftSaved extends ReflectionState {
  const DraftSaved({required super.draftText});
}

class DraftLoaded extends ReflectionState {
  const DraftLoaded(String? draftText) : super(draftText: draftText);
}

class QuestionAdded extends ReflectionState {
  const QuestionAdded(String message) : super(successMessage: message);
}

class QuestionUpdated extends ReflectionState {
  const QuestionUpdated(String message) : super(successMessage: message);
}

class QuestionDeleted extends ReflectionState {
  const QuestionDeleted(String message) : super(successMessage: message);
}

class ReflectionError extends ReflectionState {
  final AppException? exception;
  final String? code;

  const ReflectionError(String message, {this.code, this.exception})
    : super(error: message);

  @override
  List<Object?> get props => [...super.props, code, exception];
}

class ReflectionValidationError extends ReflectionState {
  final String field;

  const ReflectionValidationError(String message, {required this.field})
    : super(error: message);

  @override
  List<Object?> get props => [...super.props, field];
}

class TemplatesLoaded extends ReflectionState {
  const TemplatesLoaded(List<Map<String, String>> templates)
    : super(templates: templates);
}

class TemplateSelected extends ReflectionState {
  final String templateName;

  const TemplateSelected({
    required super.selectedTemplateId,
    required this.templateName,
  });

  @override
  List<Object?> get props => [...super.props, templateName];
}
