import 'package:equatable/equatable.dart';

/// Complete Param Model for Pomodoro Session Operations
/// 📦 Container for all pomodoro-related data
class PomodoroSessionParams extends Equatable {
  final int workDurationMinutes;
  final int breakDurationMinutes;
  final int sessionsCompleted;
  final String currentSessionType; // work, break, longBreak
  final bool isRunning;
  final int elapsedSeconds;
  final int totalSessionsGoal;
  final bool soundEnabled;
  final bool notificationsEnabled;

  const PomodoroSessionParams({
    this.workDurationMinutes = 25,
    this.breakDurationMinutes = 5,
    this.sessionsCompleted = 0,
    this.currentSessionType = 'work',
    this.isRunning = false,
    this.elapsedSeconds = 0,
    this.totalSessionsGoal = 8,
    this.soundEnabled = true,
    this.notificationsEnabled = true,
  });

  PomodoroSessionParams copyWith({
    int? workDurationMinutes,
    int? breakDurationMinutes,
    int? sessionsCompleted,
    String? currentSessionType,
    bool? isRunning,
    int? elapsedSeconds,
    int? totalSessionsGoal,
    bool? soundEnabled,
    bool? notificationsEnabled,
  }) {
    return PomodoroSessionParams(
      workDurationMinutes: workDurationMinutes ?? this.workDurationMinutes,
      breakDurationMinutes: breakDurationMinutes ?? this.breakDurationMinutes,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      currentSessionType: currentSessionType ?? this.currentSessionType,
      isRunning: isRunning ?? this.isRunning,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      totalSessionsGoal: totalSessionsGoal ?? this.totalSessionsGoal,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  PomodoroSessionParams start() => copyWith(isRunning: true);
  PomodoroSessionParams pause() => copyWith(isRunning: false);
  PomodoroSessionParams incrementSession() =>
      copyWith(sessionsCompleted: sessionsCompleted + 1);
  PomodoroSessionParams reset() => copyWith(
    sessionsCompleted: 0,
    elapsedSeconds: 0,
    isRunning: false,
    currentSessionType: 'work',
  );
  PomodoroSessionParams toggleSound() => copyWith(soundEnabled: !soundEnabled);
  PomodoroSessionParams toggleNotifications() =>
      copyWith(notificationsEnabled: !notificationsEnabled);

  @override
  List<Object?> get props => [
    workDurationMinutes,
    breakDurationMinutes,
    sessionsCompleted,
    currentSessionType,
    isRunning,
    elapsedSeconds,
    totalSessionsGoal,
    soundEnabled,
    notificationsEnabled,
  ];
}
