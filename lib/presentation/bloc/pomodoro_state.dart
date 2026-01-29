part of 'pomodoro_bloc.dart';

enum PomodoroStatus { idle, working, shortBreak, longBreak, paused, completed }

class PomodoroSession {
  final int id;
  final String? selectedTodoId;
  final String selectedTodoTitle;
  final PomodoroStatus status;
  final int sessionsCompleted;
  final Duration elapsedTime;
  final Duration totalDuration;
  final DateTime startedAt;

  PomodoroSession({
    required this.id,
    this.selectedTodoId,
    required this.selectedTodoTitle,
    required this.status,
    required this.sessionsCompleted,
    required this.elapsedTime,
    required this.totalDuration,
    required this.startedAt,
  });

  double get progress => totalDuration.inSeconds > 0
      ? elapsedTime.inSeconds / totalDuration.inSeconds
      : 0;

  String get formattedTime {
    final remaining = totalDuration - elapsedTime;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get statusLabel {
    switch (status) {
      case PomodoroStatus.idle:
        return 'Ready to Start';
      case PomodoroStatus.working:
        return 'Work Session';
      case PomodoroStatus.shortBreak:
        return 'Short Break';
      case PomodoroStatus.longBreak:
        return 'Long Break';
      case PomodoroStatus.paused:
        return 'Paused';
      case PomodoroStatus.completed:
        return 'Completed';
    }
  }

  Color get statusColor {
    switch (status) {
      case PomodoroStatus.idle:
        return Colors.grey;
      case PomodoroStatus.working:
        return Colors.red;
      case PomodoroStatus.shortBreak:
        return Colors.blue;
      case PomodoroStatus.longBreak:
        return Colors.green;
      case PomodoroStatus.paused:
        return Colors.orange;
      case PomodoroStatus.completed:
        return Colors.green;
    }
  }

  PomodoroSession copyWith({
    int? id,
    String? selectedTodoId,
    String? selectedTodoTitle,
    PomodoroStatus? status,
    int? sessionsCompleted,
    Duration? elapsedTime,
    Duration? totalDuration,
    DateTime? startedAt,
  }) {
    return PomodoroSession(
      id: id ?? this.id,
      selectedTodoId: selectedTodoId ?? this.selectedTodoId,
      selectedTodoTitle: selectedTodoTitle ?? this.selectedTodoTitle,
      status: status ?? this.status,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      totalDuration: totalDuration ?? this.totalDuration,
      startedAt: startedAt ?? this.startedAt,
    );
  }
}

abstract class PomodoroState extends Equatable {
  const PomodoroState();

  @override
  List<Object?> get props => [];
}

class PomodoroInitial extends PomodoroState {
  const PomodoroInitial();
}

class PomodoroSessionActive extends PomodoroState {
  final PomodoroSession session;

  const PomodoroSessionActive(this.session);

  @override
  List<Object?> get props => [session];
}

class PomodoroSessionPaused extends PomodoroState {
  final PomodoroSession session;

  const PomodoroSessionPaused(this.session);

  @override
  List<Object?> get props => [session];
}

class PomodoroSessionCompleted extends PomodoroState {
  final PomodoroSession session;
  final int totalSessions;
  final int totalFocusMinutes;

  const PomodoroSessionCompleted(
    this.session,
    this.totalSessions,
    this.totalFocusMinutes,
  );

  @override
  List<Object?> get props => [session, totalSessions, totalFocusMinutes];
}

class PomodoroSettingsUpdated extends PomodoroState {
  final int workDuration;
  final int shortBreakDuration;
  final int longBreakDuration;

  const PomodoroSettingsUpdated(
    this.workDuration,
    this.shortBreakDuration,
    this.longBreakDuration,
  );

  @override
  List<Object?> get props => [
    workDuration,
    shortBreakDuration,
    longBreakDuration,
  ];
}

class PomodoroError extends PomodoroState {
  final String message;

  const PomodoroError(this.message);

  @override
  List<Object?> get props => [message];
}
