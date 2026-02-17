import 'package:equatable/equatable.dart';

enum PomodoroTimerPhase { work, shortBreak, longBreak }

class PomodoroTimerState extends Equatable {
  final bool isRunning;
  final PomodoroTimerPhase phase;
  final int secondsRemaining;
  final int workDuration;
  final int breakDuration;
  final int longBreakDuration;
  final int sessionsCompleted;
  final int completionCount;
  final PomodoroTimerPhase? lastCompletedPhase;

  const PomodoroTimerState({
    required this.isRunning,
    required this.phase,
    required this.secondsRemaining,
    required this.workDuration,
    required this.breakDuration,
    required this.longBreakDuration,
    required this.sessionsCompleted,
    required this.completionCount,
    required this.lastCompletedPhase,
  });

  factory PomodoroTimerState.initial() {
    const work = 25 * 60;
    const rest = 5 * 60;
    const longRest = 15 * 60;
    return const PomodoroTimerState(
      isRunning: false,
      phase: PomodoroTimerPhase.work,
      secondsRemaining: work,
      workDuration: work,
      breakDuration: rest,
      longBreakDuration: longRest,
      sessionsCompleted: 0,
      completionCount: 0,
      lastCompletedPhase: null,
    );
  }

  int get totalDuration {
    switch (phase) {
      case PomodoroTimerPhase.work:
        return workDuration;
      case PomodoroTimerPhase.shortBreak:
        return breakDuration;
      case PomodoroTimerPhase.longBreak:
        return longBreakDuration;
    }
  }

  double get progress {
    final total = totalDuration;
    if (total <= 0) return 0;
    return 1 - (secondsRemaining / total);
  }

  PomodoroTimerState copyWith({
    bool? isRunning,
    PomodoroTimerPhase? phase,
    int? secondsRemaining,
    int? workDuration,
    int? breakDuration,
    int? longBreakDuration,
    int? sessionsCompleted,
    int? completionCount,
    PomodoroTimerPhase? lastCompletedPhase,
  }) {
    return PomodoroTimerState(
      isRunning: isRunning ?? this.isRunning,
      phase: phase ?? this.phase,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      workDuration: workDuration ?? this.workDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      completionCount: completionCount ?? this.completionCount,
      lastCompletedPhase: lastCompletedPhase ?? this.lastCompletedPhase,
    );
  }

  @override
  List<Object?> get props => [
    isRunning,
    phase,
    secondsRemaining,
    workDuration,
    breakDuration,
    longBreakDuration,
    sessionsCompleted,
    completionCount,
    lastCompletedPhase,
  ];
}
