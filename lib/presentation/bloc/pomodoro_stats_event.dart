part of 'pomodoro_stats_bloc.dart';

abstract class PomodoroStatsEvent extends Equatable {
  const PomodoroStatsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPomodoroStatsEvent extends PomodoroStatsEvent {
  const LoadPomodoroStatsEvent();
}

class RecordPomodoroSessionEvent extends PomodoroStatsEvent {
  final int focusMinutes;
  final int breakMinutes;
  final String? taskTitle;

  const RecordPomodoroSessionEvent({
    required this.focusMinutes,
    required this.breakMinutes,
    this.taskTitle,
  });

  @override
  List<Object?> get props => [focusMinutes, breakMinutes, taskTitle];
}

class GetFocusStreakEvent extends PomodoroStatsEvent {
  const GetFocusStreakEvent();
}

class GetProductivityChartsEvent extends PomodoroStatsEvent {
  const GetProductivityChartsEvent();
}
