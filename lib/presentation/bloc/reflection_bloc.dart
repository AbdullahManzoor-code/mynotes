import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/reflection_question.dart';
import '../../domain/entities/reflection_answer.dart';
import '../../domain/repositories/reflection_repository.dart';
import '../../core/exceptions/app_exceptions.dart';
import 'reflection_event.dart';
import 'reflection_state.dart';

/// Reflection BLoC with comprehensive error handling
/// Manages reflection questions, answers, and drafts with validation
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
    on<LoadTemplatesEvent>(_onLoadTemplates);
    on<SelectTemplateEvent>(_onSelectTemplate);
    on<CreateFromTemplateEvent>(_onCreateFromTemplate);
  }

  /// Validate answer input
  void _validateAnswerInput(String answer) {
    if (answer.isEmpty) {
      throw ReflectionException(
        message: 'Answer cannot be empty',
        code: 'EMPTY_ANSWER',
      );
    }
    if (answer.length > 10000) {
      throw ReflectionException(
        message: 'Answer is too long (max 10000 characters)',
        code: 'ANSWER_TOO_LONG',
      );
    }
  }

  /// Validate question input
  void _validateQuestionInput(String question) {
    if (question.isEmpty) {
      throw ReflectionException(
        message: 'Question cannot be empty',
        code: 'EMPTY_QUESTION',
      );
    }
    if (question.length > 500) {
      throw ReflectionException(
        message: 'Question is too long (max 500 characters)',
        code: 'QUESTION_TOO_LONG',
      );
    }
  }

  Future<void> _onInitializeReflection(
    InitializeReflectionEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      emit(const ReflectionLoading());
      debugPrint('[ReflectionBloc] Initializing reflection');

      final questions = await repository.getAllQuestions();
      final answeredToday = await repository.getAnswerCountForToday();

      emit(QuestionsLoaded(questions: questions, answeredToday: answeredToday));
      debugPrint('[ReflectionBloc] Initialization complete');
    } on AppException catch (e) {
      debugPrint('[ReflectionBloc] App exception: ${e.message}');
      emit(ReflectionError(e.message, code: e.code, exception: e));
    } catch (e, stackTrace) {
      debugPrint('[ReflectionBloc] Unexpected error: $e\n$stackTrace');
      emit(
        ReflectionError(
          'Failed to initialize reflection: ${e.toString()}',
          code: 'INIT_ERROR',
        ),
      );
    }
  }

  Future<void> _onLoadQuestions(
    LoadQuestionsEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      emit(const ReflectionLoading());
      debugPrint('[ReflectionBloc] Loading all questions');

      final questions = await repository.getAllQuestions();
      final answeredToday = await repository.getAnswerCountForToday();

      emit(QuestionsLoaded(questions: questions, answeredToday: answeredToday));
      debugPrint('[ReflectionBloc] Questions loaded: ${questions.length}');
    } on AppException catch (e) {
      debugPrint('[ReflectionBloc] App exception: ${e.message}');
      emit(ReflectionError(e.message, code: e.code, exception: e));
    } catch (e, stackTrace) {
      debugPrint('[ReflectionBloc] Unexpected error: $e\n$stackTrace');
      emit(
        ReflectionError(
          'Failed to load questions: ${e.toString()}',
          code: 'LOAD_ERROR',
        ),
      );
    }
  }

  Future<void> _onLoadQuestionsByCategory(
    LoadQuestionsByCategoryEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      emit(const ReflectionLoading());
      debugPrint(
        '[ReflectionBloc] Loading questions for category: ${event.category}',
      );

      final questions = await repository.getQuestionsByCategory(event.category);
      final answeredToday = await repository.getAnswerCountForToday();

      emit(QuestionsLoaded(questions: questions, answeredToday: answeredToday));
      debugPrint(
        '[ReflectionBloc] Category questions loaded: ${questions.length}',
      );
    } on AppException catch (e) {
      debugPrint('[ReflectionBloc] App exception: ${e.message}');
      emit(ReflectionError(e.message, code: e.code, exception: e));
    } catch (e, stackTrace) {
      debugPrint('[ReflectionBloc] Unexpected error: $e\n$stackTrace');
      emit(
        ReflectionError(
          'Failed to load category questions: ${e.toString()}',
          code: 'CATEGORY_LOAD_ERROR',
        ),
      );
    }
  }

  Future<void> _onAddQuestion(
    AddQuestionEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      _validateQuestionInput(event.questionText);
      debugPrint('[ReflectionBloc] Adding custom question');

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
      debugPrint('[ReflectionBloc] Question added: ${question.id}');

      // Reload questions after adding
      add(const LoadQuestionsEvent());
    } on AppException catch (e) {
      debugPrint('[ReflectionBloc] App exception: ${e.message}');
      // Treat validation errors differently based on code
      if (e.code == 'EMPTY_QUESTION' || e.code == 'QUESTION_TOO_LONG') {
        emit(ReflectionValidationError(e.message, field: 'question_text'));
      } else {
        emit(ReflectionError(e.message, code: e.code, exception: e));
      }
    } catch (e, stackTrace) {
      debugPrint('[ReflectionBloc] Unexpected error: $e\n$stackTrace');
      emit(
        ReflectionError(
          'Failed to add question: ${e.toString()}',
          code: 'ADD_ERROR',
        ),
      );
    }
  }

  Future<void> _onUpdateQuestion(
    UpdateQuestionEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      debugPrint('[ReflectionBloc] Updating question: ${event.question.id}');

      await repository.updateQuestion(event.question);
      emit(QuestionUpdated('Question updated successfully'));
      debugPrint('[ReflectionBloc] Question updated');

      // Reload questions after updating
      add(const LoadQuestionsEvent());
    } on AppException catch (e) {
      debugPrint('[ReflectionBloc] App exception: ${e.message}');
      emit(ReflectionError(e.message, code: e.code, exception: e));
    } catch (e, stackTrace) {
      debugPrint('[ReflectionBloc] Unexpected error: $e\n$stackTrace');
      emit(
        ReflectionError(
          'Failed to update question: ${e.toString()}',
          code: 'UPDATE_ERROR',
        ),
      );
    }
  }

  Future<void> _onDeleteQuestion(
    DeleteQuestionEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      debugPrint('[ReflectionBloc] Deleting question: ${event.questionId}');

      await repository.deleteQuestion(event.questionId);
      emit(QuestionDeleted('Question deleted successfully'));
      debugPrint('[ReflectionBloc] Question deleted');

      // Reload questions after deleting
      add(const LoadQuestionsEvent());
    } on AppException catch (e) {
      debugPrint('[ReflectionBloc] App exception: ${e.message}');
      emit(ReflectionError(e.message, code: e.code, exception: e));
    } catch (e, stackTrace) {
      debugPrint('[ReflectionBloc] Unexpected error: $e\n$stackTrace');
      emit(
        ReflectionError(
          'Failed to delete question: ${e.toString()}',
          code: 'DELETE_ERROR',
        ),
      );
    }
  }

  Future<void> _onSubmitAnswer(
    SubmitAnswerEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      _validateAnswerInput(event.answerText);
      debugPrint(
        '[ReflectionBloc] Submitting answer for question: ${event.questionId}',
      );

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
      debugPrint('[ReflectionBloc] Answer submitted: ${answer.id}');

      // Reload questions to update answered count
      add(const LoadQuestionsEvent());
    } on AppException catch (e) {
      debugPrint('[ReflectionBloc] App exception: ${e.message}');
      // Treat validation errors differently based on code
      if (e.code == 'EMPTY_ANSWER' || e.code == 'ANSWER_TOO_LONG') {
        emit(ReflectionValidationError(e.message, field: 'answer_text'));
      } else {
        emit(ReflectionError(e.message, code: e.code, exception: e));
      }
    } catch (e, stackTrace) {
      debugPrint('[ReflectionBloc] Unexpected error: $e\n$stackTrace');
      emit(
        ReflectionError(
          'Failed to submit answer: ${e.toString()}',
          code: 'SUBMIT_ERROR',
        ),
      );
    }
  }

  Future<void> _onLoadAnswers(
    LoadAnswersEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      emit(const ReflectionLoading());
      debugPrint(
        '[ReflectionBloc] Loading answers for question: ${event.questionId}',
      );

      final answers = await repository.getAnswersByQuestion(event.questionId);
      emit(AnswersLoaded(answers));
      debugPrint('[ReflectionBloc] Answers loaded: ${answers.length}');
    } on AppException catch (e) {
      debugPrint('[ReflectionBloc] App exception: ${e.message}');
      emit(ReflectionError(e.message, code: e.code, exception: e));
    } catch (e, stackTrace) {
      debugPrint('[ReflectionBloc] Unexpected error: $e\n$stackTrace');
      emit(
        ReflectionError(
          'Failed to load answers: ${e.toString()}',
          code: 'LOAD_ANSWERS_ERROR',
        ),
      );
    }
  }

  Future<void> _onSaveDraft(
    SaveDraftEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      debugPrint(
        '[ReflectionBloc] Saving draft for question: ${event.questionId}',
      );

      await repository.saveDraft(event.questionId, event.draftText);
      emit(
        DraftSaved(questionId: event.questionId, draftText: event.draftText),
      );
      debugPrint('[ReflectionBloc] Draft saved');
    } on AppException catch (e) {
      debugPrint('[ReflectionBloc] App exception: ${e.message}');
      emit(ReflectionError(e.message, code: e.code, exception: e));
    } catch (e, stackTrace) {
      debugPrint('[ReflectionBloc] Unexpected error: $e\n$stackTrace');
      emit(
        ReflectionError(
          'Failed to save draft: ${e.toString()}',
          code: 'DRAFT_ERROR',
        ),
      );
    }
  }

  Future<void> _onLoadDraft(
    LoadDraftEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      debugPrint(
        '[ReflectionBloc] Loading draft for question: ${event.questionId}',
      );

      final draft = await repository.getDraft(event.questionId);
      emit(DraftLoaded(draft));
      debugPrint('[ReflectionBloc] Draft loaded');
    } on AppException catch (e) {
      debugPrint('[ReflectionBloc] App exception: ${e.message}');
      emit(ReflectionError(e.message, code: e.code, exception: e));
    } catch (e, stackTrace) {
      debugPrint('[ReflectionBloc] Unexpected error: $e\n$stackTrace');
      emit(
        ReflectionError(
          'Failed to load draft: ${e.toString()}',
          code: 'LOAD_DRAFT_ERROR',
        ),
      );
    }
  }

  Future<void> _onLoadAllAnswers(
    LoadAllAnswersEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      emit(const ReflectionLoading());
      debugPrint('[ReflectionBloc] Loading all answers');

      final answers = await repository.getAllAnswers();
      emit(AllAnswersLoaded(answers));
      debugPrint('[ReflectionBloc] All answers loaded: ${answers.length}');
    } on AppException catch (e) {
      debugPrint('[ReflectionBloc] App exception: ${e.message}');
      emit(ReflectionError(e.message, code: e.code, exception: e));
    } catch (e, stackTrace) {
      debugPrint('[ReflectionBloc] Unexpected error: $e\n$stackTrace');
      emit(
        ReflectionError(
          'Failed to load all answers: ${e.toString()}',
          code: 'LOAD_ALL_ANSWERS_ERROR',
        ),
      );
    }
  }

  Future<void> _onLoadTemplates(
    LoadTemplatesEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    emit(const ReflectionLoading());
    try {
      // Load predefined templates
      final templates = [
        {'id': 'journal', 'name': 'Daily Journal'},
        {'id': 'gratitude', 'name': 'Gratitude Practice'},
        {'id': 'goals', 'name': 'Goals & Milestones'},
        {'id': 'lessons', 'name': 'Lessons Learned'},
        {'id': 'mindfulness', 'name': 'Mindfulness Check-in'},
        {'id': 'progress', 'name': 'Progress Review'},
        {'id': 'decision', 'name': 'Decision Analysis'},
        {'id': 'emotion', 'name': 'Emotion Exploration'},
        {'id': 'reflection', 'name': 'Deep Reflection'},
        {'id': 'custom', 'name': 'Custom Questions'},
      ];
      emit(TemplatesLoaded(templates));
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(ReflectionError(errorMsg));
    }
  }

  Future<void> _onSelectTemplate(
    SelectTemplateEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      emit(
        TemplateSelected(
          templateId: event.templateId,
          templateName: event.templateName,
        ),
      );
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(ReflectionError(errorMsg));
    }
  }

  Future<void> _onCreateFromTemplate(
    CreateFromTemplateEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      emit(const ReflectionLoading());
      // Template answers would be saved as regular answers
      // For each answer in the map, create a corresponding reflection answer
      emit(const ReflectionInitial());
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(ReflectionError(errorMsg));
    }
  }
}
