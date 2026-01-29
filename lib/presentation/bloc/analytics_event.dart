part of 'analytics_bloc.dart';

abstract class AnalyticsEvent {
  const AnalyticsEvent();
}

class LoadMoodAnalyticsEvent extends AnalyticsEvent {
  const LoadMoodAnalyticsEvent();
}

class LoadNotesStatsEvent extends AnalyticsEvent {
  const LoadNotesStatsEvent();
}

class LoadProductivityStatsEvent extends AnalyticsEvent {
  const LoadProductivityStatsEvent();
}

class LoadReflectionStatsEvent extends AnalyticsEvent {
  const LoadReflectionStatsEvent();
}

class ExportJournalEvent extends AnalyticsEvent {
  final String format; // pdf, markdown

  const ExportJournalEvent(this.format);
}
