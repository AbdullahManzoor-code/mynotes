part of 'analytics_bloc.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

class AnalyticsLoaded extends AnalyticsState {
  final Map<String, int> itemCounts;
  final Map<String, double> weeklyActivity;
  final List<Map<String, dynamic>> categoryBreakdown;
  final Map<String, dynamic> productivityInsights;
  final int streak;
  final List<UniversalItem> recentItems;
  final List<UniversalItem> overdueItems;
  final List<String> dailyHighlights;

  const AnalyticsLoaded({
    required this.itemCounts,
    required this.weeklyActivity,
    required this.categoryBreakdown,
    required this.productivityInsights,
    required this.streak,
    required this.recentItems,
    required this.overdueItems,
    required this.dailyHighlights,
  });

  @override
  List<Object?> get props => [
    itemCounts,
    weeklyActivity,
    categoryBreakdown,
    productivityInsights,
    streak,
    recentItems,
    overdueItems,
    dailyHighlights,
  ];
}

class MoodAnalyticsLoaded extends AnalyticsState {
  final Map<String, int> moodCounts;
  const MoodAnalyticsLoaded(this.moodCounts);

  @override
  List<Object?> get props => [moodCounts];
}

class AnalyticsError extends AnalyticsState {
  final String message;
  const AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ExportInProgress extends AnalyticsState {
  const ExportInProgress();
}

class ExportCompleted extends AnalyticsState {
  final String fileName;
  final String format;

  const ExportCompleted({required this.fileName, required this.format});

  @override
  List<Object?> get props => [fileName, format];
}

// Keep legacy classes for now to avoid breaking existing imports if any
class MoodAnalytics {
  final Map<String, int> moodCounts;
  MoodAnalytics({required this.moodCounts});
}
