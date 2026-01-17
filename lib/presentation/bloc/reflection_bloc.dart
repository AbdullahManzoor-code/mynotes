import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/reflection_question.dart';
import '../../domain/entities/reflection_answer.dart';
import '../../domain/repositories/reflection_repository.dart';
import 'reflection_event.dart';
import 'reflection_state.dart';

class ReflectionBloc extends Bloc<ReflectionEvent, ReflectionState> {
  final ReflectionRepository repository;

  ReflectionBloc({required this.repository})
    : super(const ReflectionInitial()) {
    on<InitializeReflectionEvent>(_onInitializeReflection);
    on<LoadQuestionsEvent>(_onLoadQuestions);
    on<LoadQuestionsByCategoryEvent>(_onLoadQuestionsByCategory);
    on<AddQuestionEvent>(_onAddQuestion);
    on<UpdateQuestionEvent>(_onUpdateQuestion);
    on<DeleteQuestionEvent>(_onDeleteQuestion);
    on<SubmitAnswerEvent>(_onSubmitAnswer);
    on<LoadAnswersEvent>(_onLoadAnswers);
    on<SaveDraftEvent>(_onSaveDraft);
    on<LoadDraftEvent>(_onLoadDraft);
    on<LoadAllAnswersEvent>(_onLoadAllAnswers);
  }

  Future<void> _onInitializeReflection(
    InitializeReflectionEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    emit(const ReflectionLoading());
    try {
      final questions = await repository.getAllQuestions();
      final answeredToday = await repository.getAnswerCountForToday();
      emit(QuestionsLoaded(questions: questions, answeredToday: answeredToday));
    } catch (e) {
      emit(ReflectionError('Failed to initialize: ${e.toString()}'));
    }
  }

  Future<void> _onLoadQuestions(
    LoadQuestionsEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    emit(const ReflectionLoading());
    try {
      final questions = await repository.getAllQuestions();
      final answeredToday = await repository.getAnswerCountForToday();
      emit(QuestionsLoaded(questions: questions, answeredToday: answeredToday));
    } catch (e) {
      emit(ReflectionError('Failed to load questions: ${e.toString()}'));
    }
  }

  Future<void> _onLoadQuestionsByCategory(
    LoadQuestionsByCategoryEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    emit(const ReflectionLoading());
    try {
      final questions = await repository.getQuestionsByCategory(event.category);
      final answeredToday = await repository.getAnswerCountForToday();
      emit(QuestionsLoaded(questions: questions, answeredToday: answeredToday));
    } catch (e) {
      emit(
        ReflectionError('Failed to load category questions: ${e.toString()}'),
      );
    }
  }

  Future<void> _onAddQuestion(
    AddQuestionEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      final question = ReflectionQuestion(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        questionText: event.questionText,
        category: event.category,
        isUserCreated: true,
        frequency: event.frequency,
        createdAt: DateTime.now(),
      );
      await repository.addQuestion(question);
      emit(QuestionAdded('Question added successfully'));
      // Reload questions after adding
      add(const LoadQuestionsEvent());
    } catch (e) {
      emit(ReflectionError('Failed to add question: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateQuestion(
    UpdateQuestionEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      await repository.updateQuestion(event.question);
      emit(QuestionUpdated('Question updated successfully'));
      // Reload questions after updating
      add(const LoadQuestionsEvent());
    } catch (e) {
      emit(ReflectionError('Failed to update question: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteQuestion(
    DeleteQuestionEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      await repository.deleteQuestion(event.questionId);
      emit(QuestionDeleted('Question deleted successfully'));
      // Reload questions after deleting
      add(const LoadQuestionsEvent());
    } catch (e) {
      emit(ReflectionError('Failed to delete question: ${e.toString()}'));
    }
  }

  Future<void> _onSubmitAnswer(
    SubmitAnswerEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      final answer = ReflectionAnswer(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        questionId: event.questionId,
        answerText: event.answerText,
        mood: event.mood,
        createdAt: DateTime.now(),
        draft: null,
      );
      await repository.saveAnswer(answer);
      emit(AnswerSaved('Answer saved successfully'));
      // Reload questions to update answered count
      add(const LoadQuestionsEvent());
    } catch (e) {
      emit(ReflectionError('Failed to save answer: ${e.toString()}'));
    }
  }

  Future<void> _onLoadAnswers(
    LoadAnswersEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    emit(const ReflectionLoading());
    try {
      final answers = await repository.getAnswersByQuestion(event.questionId);
      emit(AnswersLoaded(answers));
    } catch (e) {
      emit(ReflectionError('Failed to load answers: ${e.toString()}'));
    }
  }

  Future<void> _onSaveDraft(
    SaveDraftEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      await repository.saveDraft(event.questionId, event.draftText);
      emit(
        DraftSaved(questionId: event.questionId, draftText: event.draftText),
      );
    } catch (e) {
      emit(ReflectionError('Failed to save draft: ${e.toString()}'));
    }
  }

  Future<void> _onLoadDraft(
    LoadDraftEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      final draft = await repository.getDraft(event.questionId);
      emit(DraftLoaded(draft));
    } catch (e) {
      emit(ReflectionError('Failed to load draft: ${e.toString()}'));
    }
  }

  Future<void> _onLoadAllAnswers(
    LoadAllAnswersEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    emit(const ReflectionLoading());
    try {
      final answers = await repository.getAllAnswers();
      emit(AllAnswersLoaded(answers));
    } catch (e) {
      emit(ReflectionError('Failed to load all answers: ${e.toString()}'));
    }
  }
}
