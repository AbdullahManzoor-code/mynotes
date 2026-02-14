part of 'recurrence_bloc.dart';

abstract class RecurrenceEvent extends Equatable {
  const RecurrenceEvent();

  @override
  List<Object?> get props => [];
}

class UpdateFrequencyEvent extends RecurrenceEvent {
  final String frequency;
  const UpdateFrequencyEvent(this.frequency);

  @override
  List<Object?> get props => [frequency];
}

class ToggleDayEvent extends RecurrenceEvent {
  final int day;
  const ToggleDayEvent(this.day);

  @override
  List<Object?> get props => [day];
}

class UpdateCustomPatternEvent extends RecurrenceEvent {
  final String pattern;
  const UpdateCustomPatternEvent(this.pattern);

  @override
  List<Object?> get props => [pattern];
}
