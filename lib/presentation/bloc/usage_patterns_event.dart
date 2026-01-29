part of 'usage_patterns_bloc.dart';

abstract class UsagePatternsEvent extends Equatable {
  const UsagePatternsEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsagePatternsEvent extends UsagePatternsEvent {
  const LoadUsagePatternsEvent();
}

class TrackFeatureUsageEvent extends UsagePatternsEvent {
  final String featureName;

  const TrackFeatureUsageEvent(this.featureName);

  @override
  List<Object?> get props => [featureName];
}

class TrackSessionEvent extends UsagePatternsEvent {
  final DateTime startTime;
  final DateTime endTime;

  const TrackSessionEvent({required this.startTime, required this.endTime});

  @override
  List<Object?> get props => [startTime, endTime];
}

class GetDailyUsageEvent extends UsagePatternsEvent {
  final DateTime date;

  const GetDailyUsageEvent(this.date);

  @override
  List<Object?> get props => [date];
}

class GetActiveHoursEvent extends UsagePatternsEvent {
  const GetActiveHoursEvent();
}

class GetFeatureBreakdownEvent extends UsagePatternsEvent {
  const GetFeatureBreakdownEvent();
}
