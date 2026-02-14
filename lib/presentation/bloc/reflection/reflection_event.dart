import 'package:equatable/equatable.dart';
import '../../../domain/entities/reflection_question.dart';

abstract class ReflectionEvent extends Equatable {
  const ReflectionEvent();

  @override
  List<Object?> get props => [];
}

class InitializeReflectionEvent extends ReflectionEvent {
  const InitializeReflectionEvent();
}

class LoadQuestionsEvent extends ReflectionEvent {
  const LoadQuestionsEvent();
}

class LoadQuestionsByCategoryEvent extends ReflectionEvent {
  final String category;

  const LoadQuestionsByCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class AddQuestionEvent extends ReflectionEvent {
  final String questionText;
  final String category;
  final String frequency;

  const AddQuestionEvent({
    required this.questionText,
    required this.category,
    required this.frequency,
  });

  @override
  List<Object?> get props => [questionText, category, frequency];
}

class UpdateQuestionEvent extends ReflectionEvent {
  final ReflectionQuestion question;

  const UpdateQuestionEvent(this.question);

  @override
  List<Object?> get props => [question];
}

class DeleteQuestionEvent extends ReflectionEvent {
  final String questionId;

  const DeleteQuestionEvent(this.questionId);

  @override
  List<Object?> get props => [questionId];
}

class SubmitAnswerEvent extends ReflectionEvent {
  final String questionId;
  final String answerText;
  final String? mood;
  final int? moodValue;
  final int? energyLevel;
  final int? sleepQuality;
  final List<String> activityTags;
  final bool isPrivate;
  final DateTime reflectionDate;

  const SubmitAnswerEvent({
    required this.questionId,
    required this.answerText,
    this.mood,
    this.moodValue,
    this.energyLevel,
    this.sleepQuality,
    this.activityTags = const [],
    this.isPrivate = false,
    required this.reflectionDate,
  });

  @override
  List<Object?> get props => [
    questionId,
    answerText,
    mood,
    moodValue,
    energyLevel,
    sleepQuality,
    activityTags,
    isPrivate,
    reflectionDate,
  ];
}

class LoadAnswersEvent extends ReflectionEvent {
  final String questionId;

  const LoadAnswersEvent(this.questionId);

  @override
  List<Object?> get props => [questionId];
}

class SaveDraftEvent extends ReflectionEvent {
  final String questionId;
  final String draftText;

  const SaveDraftEvent({required this.questionId, required this.draftText});

  @override
  List<Object?> get props => [questionId, draftText];
}

class LoadDraftEvent extends ReflectionEvent {
  final String questionId;

  const LoadDraftEvent(this.questionId);

  @override
  List<Object?> get props => [questionId];
}

class LoadAllAnswersEvent extends ReflectionEvent {
  const LoadAllAnswersEvent();
}

class LoadTemplatesEvent extends ReflectionEvent {
  const LoadTemplatesEvent();
}

class SelectTemplateEvent extends ReflectionEvent {
  final String templateId;
  final String templateName;

  const SelectTemplateEvent({
    required this.templateId,
    required this.templateName,
  });

  @override
  List<Object?> get props => [templateId, templateName];
}

class CreateFromTemplateEvent extends ReflectionEvent {
  final String templateId;
  final Map<String, String> answers;

  const CreateFromTemplateEvent({
    required this.templateId,
    required this.answers,
  });

  @override
  List<Object?> get props => [templateId, answers];
}

class LogMoodEvent extends ReflectionEvent {
  final String mood;
  final DateTime timestamp;

  const LogMoodEvent({required this.mood, required this.timestamp});

  @override
  List<Object?> get props => [mood, timestamp];
}

class LoadRandomQuestionEvent extends ReflectionEvent {
  const LoadRandomQuestionEvent();
}

class PinQuestionEvent extends ReflectionEvent {
  final String questionId;
  const PinQuestionEvent(this.questionId);

  @override
  List<Object?> get props => [questionId];
}

class UnpinQuestionEvent extends ReflectionEvent {
  const UnpinQuestionEvent();
}

class ScheduleReflectionNotificationEvent extends ReflectionEvent {
  final DateTime time;
  const ScheduleReflectionNotificationEvent(this.time);

  @override
  List<Object?> get props => [time];
}

class CancelReflectionNotificationEvent extends ReflectionEvent {
  const CancelReflectionNotificationEvent();
}
