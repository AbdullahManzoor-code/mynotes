part of 'analytics_bloc.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAnalyticsEvent extends AnalyticsEvent {
  const LoadAnalyticsEvent();
}

class RefreshAnalyticsEvent extends AnalyticsEvent {
  const RefreshAnalyticsEvent();
}

class RecordFocusSessionEvent extends AnalyticsEvent {
  final FocusSession session;
  const RecordFocusSessionEvent(this.session);

  @override
  List<Object?> get props => [session];
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

  @override
  List<Object?> get props => [format];
}
