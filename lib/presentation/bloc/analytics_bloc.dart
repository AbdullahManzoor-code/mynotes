import 'package:flutter_bloc/flutter_bloc.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc() : super(AnalyticsInitial()) {
    on<LoadMoodAnalyticsEvent>(_onLoadMoodAnalytics);
    on<LoadNotesStatsEvent>(_onLoadNotesStats);
    on<LoadProductivityStatsEvent>(_onLoadProductivityStats);
    on<LoadReflectionStatsEvent>(_onLoadReflectionStats);
    on<ExportJournalEvent>(_onExportJournal);
  }

  Future<void> _onLoadMoodAnalytics(
    LoadMoodAnalyticsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      emit(AnalyticsLoading());

      // Simulate data loading
      await Future.delayed(Duration(milliseconds: 500));

      final analytics = MoodAnalytics(
        moodCounts: {'Happy': 15, 'Sad': 3, 'Neutral': 10},
        dailyMoods: {},
        averageMood: 4.2,
        mostFrequentMood: 'Happy',
        totalEntries: 28,
      );

      emit(MoodAnalyticsLoaded(analytics));
    } catch (e) {
      emit(AnalyticsError('Failed to load mood analytics: $e'));
    }
  }

  Future<void> _onLoadNotesStats(
    LoadNotesStatsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      emit(AnalyticsLoading());

      await Future.delayed(Duration(milliseconds: 500));

      final stats = NotesStatistics(
        totalNotes: 42,
        archivedNotes: 5,
        notesWithAttachments: 12,
        totalWords: 15420,
        averageNoteLength: 367,
        lastNoteDate: DateTime.now(),
      );

      emit(NotesStatsLoaded(stats));
    } catch (e) {
      emit(AnalyticsError('Failed to load notes stats: $e'));
    }
  }

  Future<void> _onLoadProductivityStats(
    LoadProductivityStatsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      emit(AnalyticsLoading());

      await Future.delayed(Duration(milliseconds: 500));

      final stats = ProductivityStatistics(
        totalTodosCompleted: 87,
        totalTodosCreated: 110,
        completionRate: 0.791,
        consecutiveDaysActive: 15,
        averageTaskDuration: Duration(minutes: 45),
        tasksCompletedThisWeek: 12,
      );

      emit(ProductivityStatsLoaded(stats));
    } catch (e) {
      emit(AnalyticsError('Failed to load productivity stats: $e'));
    }
  }

  Future<void> _onLoadReflectionStats(
    LoadReflectionStatsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      emit(AnalyticsLoading());

      await Future.delayed(Duration(milliseconds: 500));

      final stats = ReflectionStatistics(
        totalAnswers: 45,
        answersThisWeek: 8,
        topCategories: ['Personal', 'Growth'],
        consecutiveReflectionDays: 7,
        answersPerCategory: {'Personal': 20, 'Growth': 15, 'Health': 10},
      );

      emit(ReflectionStatsLoaded(stats));
    } catch (e) {
      emit(AnalyticsError('Failed to load reflection stats: $e'));
    }
  }

  Future<void> _onExportJournal(
    ExportJournalEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      emit(ExportInProgress());

      await Future.delayed(Duration(milliseconds: 1000));

      emit(
        ExportCompleted(
          fileName: 'journal_export_${DateTime.now().millisecondsSinceEpoch}',
          format: event.format,
        ),
      );
    } catch (e) {
      emit(AnalyticsError('Failed to export journal: $e'));
    }
  }
}
