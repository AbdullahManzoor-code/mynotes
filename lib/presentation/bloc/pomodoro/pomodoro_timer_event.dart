import 'package:equatable/equatable.dart';

abstract class PomodoroTimerEvent extends Equatable {
  const PomodoroTimerEvent();

  @override
  List<Object?> get props => [];
}

class StartTimerEvent extends PomodoroTimerEvent {
  const StartTimerEvent();
}

class PauseTimerEvent extends PomodoroTimerEvent {
  const PauseTimerEvent();
}

class ResumeTimerEvent extends PomodoroTimerEvent {
  const ResumeTimerEvent();
}

class ResetTimerEvent extends PomodoroTimerEvent {
  const ResetTimerEvent();
}

class TickTimerEvent extends PomodoroTimerEvent {
  const TickTimerEvent();
}

class UpdateWorkDurationEvent extends PomodoroTimerEvent {
  final int durationInSeconds;
  const UpdateWorkDurationEvent(this.durationInSeconds);

  @override
  List<Object?> get props => [durationInSeconds];
}

class UpdateBreakDurationEvent extends PomodoroTimerEvent {
  final int durationInSeconds;
  const UpdateBreakDurationEvent(this.durationInSeconds);

  @override
  List<Object?> get props => [durationInSeconds];
}

class SwitchPhaseEvent extends PomodoroTimerEvent {
  const SwitchPhaseEvent();
}

class SkipPhaseEvent extends PomodoroTimerEvent {
  const SkipPhaseEvent();
}
