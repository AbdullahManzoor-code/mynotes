part of 'usage_patterns_bloc.dart';

abstract class UsagePatternsState extends Equatable {
  const UsagePatternsState();

  @override
  List<Object?> get props => [];
}

class UsagePatternsInitial extends UsagePatternsState {
  const UsagePatternsInitial();
}

class UsagePatternsLoading extends UsagePatternsState {
  const UsagePatternsLoading();
}

class UsagePatternsLoaded extends UsagePatternsState {
  final Map<String, dynamic> patterns;

  const UsagePatternsLoaded({required this.patterns});

  @override
  List<Object?> get props => [patterns];
}

class FeatureUsageTracked extends UsagePatternsState {
  final String feature;
  final int count;

  const FeatureUsageTracked({required this.feature, required this.count});

  @override
  List<Object?> get props => [feature, count];
}

class SessionTracked extends UsagePatternsState {
  final Duration duration;

  const SessionTracked({required this.duration});

  @override
  List<Object?> get props => [duration];
}

class DailyUsageCalculated extends UsagePatternsState {
  final DateTime date;
  final int usageSeconds;

  const DailyUsageCalculated({required this.date, required this.usageSeconds});

  @override
  List<Object?> get props => [date, usageSeconds];
}

class ActiveHoursAnalyzed extends UsagePatternsState {
  final Map<int, int> hourlyActivity; // hour -> count

  const ActiveHoursAnalyzed({required this.hourlyActivity});

  @override
  List<Object?> get props => [hourlyActivity];
}

class FeatureBreakdownCalculated extends UsagePatternsState {
  final Map<String, int> breakdown;

  const FeatureBreakdownCalculated({required this.breakdown});

  @override
  List<Object?> get props => [breakdown];
}

class UsagePatternsError extends UsagePatternsState {
  final String message;

  const UsagePatternsError(this.message);

  @override
  List<Object?> get props => [message];
}
