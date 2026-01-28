import 'package:equatable/equatable.dart';
import '../../domain/entities/reflection_question.dart';

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

  const SubmitAnswerEvent({
    required this.questionId,
    required this.answerText,
    this.mood,
  });

  @override
  List<Object?> get props => [questionId, answerText, mood];
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

