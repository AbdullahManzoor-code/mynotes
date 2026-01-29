part of 'analytics_bloc.dart';

class MoodAnalytics {
  final Map<String, int> moodCounts;
  final Map<DateTime, String> dailyMoods;
  final double averageMood;
  final String mostFrequentMood;
  final int totalEntries;

  MoodAnalytics({
    required this.moodCounts,
    required this.dailyMoods,
    required this.averageMood,
    required this.mostFrequentMood,
    required this.totalEntries,
  });
}

class NotesStatistics {
  final int totalNotes;
  final int archivedNotes;
  final int notesWithAttachments;
  final int totalWords;
  final double averageNoteLength;
  final DateTime lastNoteDate;

  NotesStatistics({
    required this.totalNotes,
    required this.archivedNotes,
    required this.notesWithAttachments,
    required this.totalWords,
    required this.averageNoteLength,
    required this.lastNoteDate,
  });
}

class ProductivityStatistics {
  final int totalTodosCompleted;
  final int totalTodosCreated;
  final double completionRate;
  final int consecutiveDaysActive;
  final Duration averageTaskDuration;
  final int tasksCompletedThisWeek;

  ProductivityStatistics({
    required this.totalTodosCompleted,
    required this.totalTodosCreated,
    required this.completionRate,
    required this.consecutiveDaysActive,
    required this.averageTaskDuration,
    required this.tasksCompletedThisWeek,
  });
}

class ReflectionStatistics {
  final int totalAnswers;
  final int answersThisWeek;
  final List<String> topCategories;
  final int consecutiveReflectionDays;
  final Map<String, int> answersPerCategory;

  ReflectionStatistics({
    required this.totalAnswers,
    required this.answersThisWeek,
    required this.topCategories,
    required this.consecutiveReflectionDays,
    required this.answersPerCategory,
  });
}

abstract class AnalyticsState {
  const AnalyticsState();
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

class MoodAnalyticsLoaded extends AnalyticsState {
  final MoodAnalytics analytics;

  const MoodAnalyticsLoaded(this.analytics);
}

class NotesStatsLoaded extends AnalyticsState {
  final NotesStatistics stats;

  const NotesStatsLoaded(this.stats);
}

class ProductivityStatsLoaded extends AnalyticsState {
  final ProductivityStatistics stats;

  const ProductivityStatsLoaded(this.stats);
}

class ReflectionStatsLoaded extends AnalyticsState {
  final ReflectionStatistics stats;

  const ReflectionStatsLoaded(this.stats);
}

class ExportInProgress extends AnalyticsState {
  const ExportInProgress();
}

class ExportCompleted extends AnalyticsState {
  final String fileName;
  final String format;

  const ExportCompleted({required this.fileName, required this.format});
}

class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError(this.message);
}
