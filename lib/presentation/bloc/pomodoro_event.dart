part of 'pomodoro_bloc.dart';

abstract class PomodoroEvent extends Equatable {
  const PomodoroEvent();

  @override
  List<Object?> get props => [];
}

class StartWorkSessionEvent extends PomodoroEvent {
  final String? todoId;
  final String todoTitle;

  const StartWorkSessionEvent({this.todoId, this.todoTitle = 'Focused Work'});

  @override
  List<Object?> get props => [todoId, todoTitle];
}

class StartShortBreakEvent extends PomodoroEvent {
  const StartShortBreakEvent();
}

class StartLongBreakEvent extends PomodoroEvent {
  const StartLongBreakEvent();
}

class PauseSessionEvent extends PomodoroEvent {
  const PauseSessionEvent();
}

class ResumeSessionEvent extends PomodoroEvent {
  const ResumeSessionEvent();
}

class StopSessionEvent extends PomodoroEvent {
  const StopSessionEvent();
}

class CompleteSessionEvent extends PomodoroEvent {
  const CompleteSessionEvent();
}

class UpdateTimerEvent extends PomodoroEvent {
  const UpdateTimerEvent();
}

class SetWorkDurationEvent extends PomodoroEvent {
  final int minutes;

  const SetWorkDurationEvent(this.minutes);

  @override
  List<Object?> get props => [minutes];
}

class SetBreakDurationEvent extends PomodoroEvent {
  final int minutes;

  const SetBreakDurationEvent(this.minutes);

  @override
  List<Object?> get props => [minutes];
}

class SetLongBreakDurationEvent extends PomodoroEvent {
  final int minutes;

  const SetLongBreakDurationEvent(this.minutes);

  @override
  List<Object?> get props => [minutes];
}
