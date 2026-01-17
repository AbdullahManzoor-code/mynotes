import 'package:equatable/equatable.dart';
import '../../domain/entities/reflection_question.dart';
import '../../domain/entities/reflection_answer.dart';

class ReflectionState extends Equatable {
  const ReflectionState();

  @override
  List<Object?> get props => [];
}

class ReflectionInitial extends ReflectionState {
  const ReflectionInitial();
}

class ReflectionLoading extends ReflectionState {
  const ReflectionLoading();
}

class QuestionsLoaded extends ReflectionState {
  final List<ReflectionQuestion> questions;
  final int answeredToday;

  const QuestionsLoaded({required this.questions, this.answeredToday = 0});

  @override
  List<Object?> get props => [questions, answeredToday];
}

class AnswersLoaded extends ReflectionState {
  final List<ReflectionAnswer> answers;

  const AnswersLoaded(this.answers);

  @override
  List<Object?> get props => [answers];
}

class AllAnswersLoaded extends ReflectionState {
  final List<ReflectionAnswer> answers;

  const AllAnswersLoaded(this.answers);

  @override
  List<Object?> get props => [answers];
}

class AnswerSaved extends ReflectionState {
  final String message;

  const AnswerSaved(this.message);

  @override
  List<Object?> get props => [message];
}

class DraftSaved extends ReflectionState {
  final String questionId;
  final String draftText;

  const DraftSaved({required this.questionId, required this.draftText});

  @override
  List<Object?> get props => [questionId, draftText];
}

class DraftLoaded extends ReflectionState {
  final String? draftText;

  const DraftLoaded(this.draftText);

  @override
  List<Object?> get props => [draftText];
}

class QuestionAdded extends ReflectionState {
  final String message;

  const QuestionAdded(this.message);

  @override
  List<Object?> get props => [message];
}

class QuestionUpdated extends ReflectionState {
  final String message;

  const QuestionUpdated(this.message);

  @override
  List<Object?> get props => [message];
}

class QuestionDeleted extends ReflectionState {
  final String message;

  const QuestionDeleted(this.message);

  @override
  List<Object?> get props => [message];
}

class ReflectionError extends ReflectionState {
  final String message;

  const ReflectionError(this.message);

  @override
  List<Object?> get props => [message];
}
