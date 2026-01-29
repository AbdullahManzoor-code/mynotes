part of 'pomodoro_stats_bloc.dart';

abstract class PomodoroStatsState extends Equatable {
  const PomodoroStatsState();

  @override
  List<Object?> get props => [];
}

class PomodoroStatsInitial extends PomodoroStatsState {
  const PomodoroStatsInitial();
}

class PomodoroStatsLoading extends PomodoroStatsState {
  const PomodoroStatsLoading();
}

class PomodoroStatsLoaded extends PomodoroStatsState {
  final int totalSessions;
  final int totalFocusTime;
  final int longestStreak;
  final int currentStreak;

  const PomodoroStatsLoaded({
    required this.totalSessions,
    required this.totalFocusTime,
    required this.longestStreak,
    required this.currentStreak,
  });

  @override
  List<Object?> get props => [
    totalSessions,
    totalFocusTime,
    longestStreak,
    currentStreak,
  ];
}

class SessionRecorded extends PomodoroStatsState {
  final PomodoroSession session;

  const SessionRecorded(this.session);

  @override
  List<Object?> get props => [session];
}

class FocusStreakLoaded extends PomodoroStatsState {
  final int currentStreak;
  final int longestStreak;
  final List<PomodoroSession> sessions;

  const FocusStreakLoaded({
    required this.currentStreak,
    required this.longestStreak,
    required this.sessions,
  });

  @override
  List<Object?> get props => [currentStreak, longestStreak, sessions];
}

class ProductivityChartsLoaded extends PomodoroStatsState {
  final Map<String, int> dailyFocusData;
  final int totalSessions;
  final int averageFocusPerSession;

  const ProductivityChartsLoaded({
    required this.dailyFocusData,
    required this.totalSessions,
    required this.averageFocusPerSession,
  });

  @override
  List<Object?> get props => [
    dailyFocusData,
    totalSessions,
    averageFocusPerSession,
  ];
}

class PomodoroStatsError extends PomodoroStatsState {
  final String message;

  const PomodoroStatsError(this.message);

  @override
  List<Object?> get props => [message];
}
