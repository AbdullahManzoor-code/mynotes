import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../domain/entities/reflection_question.dart';
import '../../../domain/entities/reflection_answer.dart';
import '../../../domain/repositories/reflection_repository.dart';
import '../../../core/exceptions/app_exceptions.dart';
import 'reflection_event.dart';
import 'reflection_state.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../data/datasources/reflection_database.dart';

/// Reflection BLoC with comprehensive error handling
/// Manages reflection questions, answers, and drafts with validation
class ReflectionBloc extends Bloc<ReflectionEvent, ReflectionState> {
  final ReflectionRepository repository;
  final NotificationService notificationService;

  static const int reflectionNotificationId = 999;

  ReflectionBloc({required this.repository, required this.notificationService})
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
    on<LogMoodEvent>(_onLogMood);
    on<LoadRandomQuestionEvent>(_onLoadRandomQuestion);
    on<PinQuestionEvent>(_onPinQuestion);
    on<UnpinQuestionEvent>(_onUnpinQuestion);
    on<ScheduleReflectionNotificationEvent>(_onScheduleNotification);
    on<CancelReflectionNotificationEvent>(_onCancelNotification);
  }

  Future<void> _onPinQuestion(
    PinQuestionEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      await repository.pinQuestion(event.questionId);
      add(const LoadRandomQuestionEvent()); // Refresh to show pinned question
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onUnpinQuestion(
    UnpinQuestionEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      await repository.unpinAllQuestions();
      add(const LoadRandomQuestionEvent());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onScheduleNotification(
    ScheduleReflectionNotificationEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      await notificationService.schedule(
        id: reflectionNotificationId,
        title: 'Daily Reflection',
        body: 'Time for your daily reflection! Take a moment for yourself.',
        scheduledTime: event.time,
        repeatDays: [0, 1, 2, 3, 4, 5, 6], // Daily
      );
    } catch (e) {
      emit(state.copyWith(error: 'Failed to schedule notification: $e'));
    }
  }

  Future<void> _onCancelNotification(
    CancelReflectionNotificationEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      await notificationService.cancel(reflectionNotificationId);
    } catch (e) {
      emit(state.copyWith(error: 'Failed to cancel notification: $e'));
    }
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
      emit(state.copyWith(isLoading: true));
      debugPrint('[ReflectionBloc] Initializing reflection');

      // Check if questions exist, if not seed them
      var questions = await repository.getAllQuestions();
      if (questions.isEmpty) {
        debugPrint('[ReflectionBloc] No questions found, seeding defaults');
        await _seedDefaultQuestions();
        questions = await repository.getAllQuestions();
      }

      final answeredToday = await repository.getAnswerCountForToday();
      final allAnswers = await repository.getAllAnswers();
      final streakCount = await repository.getStreakCount();
      final longestStreak = await repository.getLongestStreak();
      final totalReflectionsCount = await repository.getTotalReflectionsCount();

      emit(
        state.copyWith(
          questions: questions,
          answeredToday: answeredToday,
          allAnswers: allAnswers,
          streakCount: streakCount,
          longestStreak: longestStreak,
          totalReflectionsCount: totalReflectionsCount,
          isLoading: false,
        ),
      );
      debugPrint('[ReflectionBloc] Initialization complete');
    } on AppException catch (e) {
      debugPrint('[ReflectionBloc] App exception: ${e.message}');
      emit(state.copyWith(error: e.message, isLoading: false));
    } catch (e, stackTrace) {
      debugPrint('[ReflectionBloc] Unexpected error: $e\n$stackTrace');
      emit(
        state.copyWith(
          error: 'Failed to initialize reflection: ${e.toString()}',
          isLoading: false,
        ),
      );
    }
  }

  Future<void> _onLoadRandomQuestion(
    LoadRandomQuestionEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));
      final question = await repository.getRandomQuestion();
      final answeredToday = await repository.getAnswerCountForToday();
      if (question != null) {
        emit(
          state.copyWith(
            questions: [question],
            answeredToday: answeredToday,
            isLoading: false,
          ),
        );
      } else {
        emit(
          state.copyWith(
            answeredToday: answeredToday,
            error: 'No questions available',
            isLoading: false,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> _onLoadQuestions(
    LoadQuestionsEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));
      debugPrint('[ReflectionBloc] Loading all questions');

      final questions = await repository.getAllQuestions();
      final answeredToday = await repository.getAnswerCountForToday();

      emit(
        state.copyWith(
          questions: questions,
          answeredToday: answeredToday,
          isLoading: false,
        ),
      );
      debugPrint('[ReflectionBloc] Questions loaded: ${questions.length}');
    } on AppException catch (e) {
      debugPrint('[ReflectionBloc] App exception: ${e.message}');
      emit(state.copyWith(error: e.message, isLoading: false));
    } catch (e, stackTrace) {
      debugPrint('[ReflectionBloc] Unexpected error: $e\n$stackTrace');
      emit(
        state.copyWith(
          error: 'Failed to load questions: ${e.toString()}',
          isLoading: false,
        ),
      );
    }
  }

  Future<void> _onLoadQuestionsByCategory(
    LoadQuestionsByCategoryEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));
      debugPrint(
        '[ReflectionBloc] Loading questions for category: ${event.category}',
      );

      final questions = await repository.getQuestionsByCategory(event.category);
      final answeredToday = await repository.getAnswerCountForToday();

      emit(
        state.copyWith(
          questions: questions,
          answeredToday: answeredToday,
          isLoading: false,
        ),
      );
      debugPrint(
        '[ReflectionBloc] Category questions loaded: ${questions.length}',
      );
    } on AppException catch (e) {
      debugPrint('[ReflectionBloc] App exception: ${e.message}');
      emit(state.copyWith(error: e.message, isLoading: false));
    } catch (e, stackTrace) {
      debugPrint('[ReflectionBloc] Unexpected error: $e\n$stackTrace');
      emit(
        state.copyWith(
          error: 'Failed to load category questions: ${e.toString()}',
          isLoading: false,
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
        moodValue: event.moodValue,
        energyLevel: event.energyLevel,
        sleepQuality: event.sleepQuality,
        activityTags: event.activityTags,
        isPrivate: event.isPrivate,
        createdAt: DateTime.now(),
        reflectionDate: event.reflectionDate,
        draft: null,
      );

      await repository.saveAnswer(answer);
      emit(AnswerSaved('Answer saved successfully'));
      debugPrint('[ReflectionBloc] Answer submitted: ${answer.id}');

      // Reload questions to update answered count
      add(const LoadQuestionsEvent());
      // Refresh stats (streak, etc.)
      add(const InitializeReflectionEvent());
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
      emit(state.copyWith(isLoading: true));
      debugPrint(
        '[ReflectionBloc] Loading answers for question: ${event.questionId}',
      );

      final answers = await repository.getAnswersByQuestion(event.questionId);
      emit(state.copyWith(answers: answers, isLoading: false));
      debugPrint('[ReflectionBloc] Answers loaded: ${answers.length}');
    } on AppException catch (e) {
      debugPrint('[ReflectionBloc] App exception: ${e.message}');
      emit(state.copyWith(error: e.message, isLoading: false));
    } catch (e, stackTrace) {
      debugPrint('[ReflectionBloc] Unexpected error: $e\n$stackTrace');
      emit(
        state.copyWith(
          error: 'Failed to load answers: ${e.toString()}',
          isLoading: false,
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
      emit(DraftSaved(draftText: event.draftText));
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
      emit(state.copyWith(isLoading: true));
      debugPrint('[ReflectionBloc] Loading all answers');

      final answers = await repository.getAllAnswers();
      emit(state.copyWith(allAnswers: answers, isLoading: false));
      debugPrint('[ReflectionBloc] All answers loaded: ${answers.length}');
    } on AppException catch (e) {
      debugPrint('[ReflectionBloc] App exception: ${e.message}');
      emit(state.copyWith(error: e.message, isLoading: false));
    } catch (e, stackTrace) {
      debugPrint('[ReflectionBloc] Unexpected error: $e\n$stackTrace');
      emit(
        state.copyWith(
          error: 'Failed to load all answers: ${e.toString()}',
          isLoading: false,
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
          selectedTemplateId: event.templateId,
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

  Future<void> _onLogMood(
    LogMoodEvent event,
    Emitter<ReflectionState> emit,
  ) async {
    try {
      debugPrint('[ReflectionBloc] Logging mood: ${event.mood}');
      // For now, we save it as an answer to a special "Mood" question
      final answer = ReflectionAnswer(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        questionId: 'daily_mood',
        answerText: 'Mood logged: ${event.mood}',
        mood: event.mood,
        createdAt: event.timestamp,
        reflectionDate: event.timestamp,
      );
      await repository.saveAnswer(answer);
      emit(AnswerSaved('Mood logged successfully'));

      // Reload everything to update streak if needed
      add(const InitializeReflectionEvent());
    } catch (e) {
      emit(ReflectionError('Failed to log mood: ${e.toString()}'));
    }
  }

  Future<void> _seedDefaultQuestions() async {
    final now = DateTime.now();

    // Ensure system questions exist (like Mood)
    final moodQuestion = ReflectionQuestion(
      id: 'daily_mood',
      questionText: 'How are you feeling today?',
      category: 'daily',
      frequency: 'daily',
      isUserCreated: false,
      createdAt: now,
    );
    await repository.addQuestion(moodQuestion);

    // Seed preset prompts
    for (final promptData in ReflectionDatabase.presetPrompts) {
      final question = ReflectionQuestion(
        id: ReflectionDatabase.generateId(),
        questionText: promptData['prompt'] ?? '',
        category: promptData['category'] ?? 'General',
        frequency: promptData['frequency'] ?? 'daily',
        isUserCreated: false,
        createdAt: now,
      );
      await repository.addQuestion(question);
    }
  }
}
