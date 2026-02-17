import 'package:equatable/equatable.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// PHASE 6: FOCUS SESSIONS & POMODORO TIMER
/// Focus/Pomodoro States
/// ════════════════════════════════════════════════════════════════════════════

enum SessionType { focus, shortBreak, longBreak }

class FocusSession extends Equatable {
  final String id;
  final String name;
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int sessionsBeforeLongBreak;
  final int remainingSeconds;
  final SessionType currentSession;
  final bool isRunning;
  final int completedSessions;
  final String notes;
  final DateTime createdAt;

  const FocusSession({
    required this.id,
    required this.name,
    this.focusMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.sessionsBeforeLongBreak = 4,
    this.remainingSeconds = 1500,
    this.currentSession = SessionType.focus,
    this.isRunning = false,
    this.completedSessions = 0,
    this.notes = '',
    required this.createdAt,
  });

  /// Get total seconds for current session
  int get totalSessionSeconds {
    switch (currentSession) {
      case SessionType.focus:
        return focusMinutes * 60;
      case SessionType.shortBreak:
        return shortBreakMinutes * 60;
      case SessionType.longBreak:
        return longBreakMinutes * 60;
    }
  }

  /// Get progress (0.0 to 1.0)
  double get progress => 1.0 - (remainingSeconds / totalSessionSeconds);

  /// Get formatted time string MM:SS
  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Copy with new values
  FocusSession copyWith({
    String? id,
    String? name,
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? sessionsBeforeLongBreak,
    int? remainingSeconds,
    SessionType? currentSession,
    bool? isRunning,
    int? completedSessions,
    String? notes,
    DateTime? createdAt,
  }) {
    return FocusSession(
      id: id ?? this.id,
      name: name ?? this.name,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      sessionsBeforeLongBreak:
          sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      currentSession: currentSession ?? this.currentSession,
      isRunning: isRunning ?? this.isRunning,
      completedSessions: completedSessions ?? this.completedSessions,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    focusMinutes,
    shortBreakMinutes,
    longBreakMinutes,
    sessionsBeforeLongBreak,
    remainingSeconds,
    currentSession,
    isRunning,
    completedSessions,
    notes,
    createdAt,
  ];
}

class SessionHistory extends Equatable {
  final String id;
  final SessionType type;
  final int durationSeconds;
  final DateTime completedAt;
  final bool isCompleted;

  const SessionHistory({
    required this.id,
    required this.type,
    required this.durationSeconds,
    required this.completedAt,
    this.isCompleted = true,
  });

  String get typeName {
    switch (type) {
      case SessionType.focus:
        return 'Focus';
      case SessionType.shortBreak:
        return 'Short Break';
      case SessionType.longBreak:
        return 'Long Break';
    }
  }

  @override
  List<Object?> get props => [
    id,
    type,
    durationSeconds,
    completedAt,
    isCompleted,
  ];
}

abstract class FocusState extends Equatable {
  const FocusState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class FocusInitial extends FocusState {
  const FocusInitial();
}

/// Loading state
class FocusLoading extends FocusState {
  const FocusLoading();
}

/// Session initialized and ready
class FocusReady extends FocusState {
  final FocusSession session;
  final List<SessionHistory> history;

  const FocusReady({required this.session, this.history = const []});

  @override
  List<Object?> get props => [session, history];
}

/// Timer is running
class FocusRunning extends FocusState {
  final FocusSession session;
  final List<SessionHistory> history;

  const FocusRunning({required this.session, this.history = const []});

  @override
  List<Object?> get props => [session, history];
}

/// Timer is paused
class FocusPaused extends FocusState {
  final FocusSession session;
  final List<SessionHistory> history;

  const FocusPaused({required this.session, this.history = const []});

  @override
  List<Object?> get props => [session, history];
}

/// Session completed
class FocusSessionComplete extends FocusState {
  final FocusSession session;
  final SessionHistory completedSession;
  final List<SessionHistory> history;

  const FocusSessionComplete({
    required this.session,
    required this.completedSession,
    this.history = const [],
  });

  @override
  List<Object?> get props => [session, completedSession, history];
}

/// Error state
class FocusError extends FocusState {
  final String message;

  const FocusError({required this.message});

  @override
  List<Object?> get props => [message];
}
