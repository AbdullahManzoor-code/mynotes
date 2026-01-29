import 'package:flutter/material.dart';
import 'dart:async';

/// Pomodoro session status
enum PomodoroStatus {
  idle, // Not started
  working, // In work session
  shortBreak, // 5-minute break
  longBreak, // 15-minute break
  paused, // Paused
  completed, // Completed
}

/// Pomodoro session
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
}

/// Pomodoro timer service (POM-001 to POM-005)
class PomodoroService extends ChangeNotifier {
  static const int defaultWorkDuration = 25; // minutes
  static const int defaultShortBreakDuration = 5; // minutes
  static const int defaultLongBreakDuration = 15; // minutes

  int workDuration = defaultWorkDuration;
  int shortBreakDuration = defaultShortBreakDuration;
  int longBreakDuration = defaultLongBreakDuration;

  PomodoroSession? _currentSession;
  Timer? _timer;
  int _sessionsCompleted = 0;
  DateTime? _sessionStartTime;

  PomodoroSession? get currentSession => _currentSession;
  int get sessionsCompleted => _sessionsCompleted;
  bool get isRunning => _timer?.isActive ?? false;

  /// Start work session
  void startWorkSession({String? todoId, String todoTitle = 'Focused Work'}) {
    _sessionStartTime = DateTime.now();
    _currentSession = PomodoroSession(
      id: _sessionsCompleted + 1,
      selectedTodoId: todoId,
      selectedTodoTitle: todoTitle,
      status: PomodoroStatus.working,
      sessionsCompleted: _sessionsCompleted,
      elapsedTime: Duration.zero,
      totalDuration: Duration(minutes: workDuration),
      startedAt: DateTime.now(),
    );
    _startTimer();
    notifyListeners();
  }

  /// Start short break
  void startShortBreak() {
    _sessionStartTime = DateTime.now();
    _currentSession = PomodoroSession(
      id: _sessionsCompleted + 1,
      selectedTodoId: null,
      selectedTodoTitle: 'Short Break',
      status: PomodoroStatus.shortBreak,
      sessionsCompleted: _sessionsCompleted,
      elapsedTime: Duration.zero,
      totalDuration: Duration(minutes: shortBreakDuration),
      startedAt: DateTime.now(),
    );
    _startTimer();
    notifyListeners();
  }

  /// Start long break
  void startLongBreak() {
    _sessionStartTime = DateTime.now();
    _currentSession = PomodoroSession(
      id: _sessionsCompleted + 1,
      selectedTodoId: null,
      selectedTodoTitle: 'Long Break',
      status: PomodoroStatus.longBreak,
      sessionsCompleted: _sessionsCompleted,
      elapsedTime: Duration.zero,
      totalDuration: Duration(minutes: longBreakDuration),
      startedAt: DateTime.now(),
    );
    _startTimer();
    notifyListeners();
  }

  /// Pause session
  void pauseSession() {
    _timer?.cancel();
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        status: PomodoroStatus.paused,
      );
    }
    notifyListeners();
  }

  /// Resume session
  void resumeSession() {
    if (_currentSession != null) {
      _sessionStartTime = DateTime.now();
      _startTimer();
    }
  }

  /// Stop session
  void stopSession() {
    _timer?.cancel();
    _currentSession = null;
    _sessionStartTime = null;
    notifyListeners();
  }

  /// Complete session
  void completeSession() {
    _timer?.cancel();
    if (_currentSession != null) {
      _sessionsCompleted++;
      _currentSession = _currentSession!.copyWith(
        status: PomodoroStatus.completed,
      );
    }
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (_currentSession == null) return;

      final elapsed = DateTime.now().difference(_sessionStartTime!);
      if (elapsed >= _currentSession!.totalDuration) {
        completeSession();
      } else {
        _currentSession = _currentSession!.copyWith(elapsedTime: elapsed);
        notifyListeners();
      }
    });
  }

  /// Set custom work duration
  void setWorkDuration(int minutes) {
    workDuration = minutes;
    notifyListeners();
  }

  /// Set custom break duration
  void setShortBreakDuration(int minutes) {
    shortBreakDuration = minutes;
    notifyListeners();
  }

  /// Set custom long break duration
  void setLongBreakDuration(int minutes) {
    longBreakDuration = minutes;
    notifyListeners();
  }

  /// Get session statistics
  Map<String, int> getSessionStats() {
    return {
      'totalSessions': _sessionsCompleted,
      'cycle': (_sessionsCompleted % 4) + 1, // Sessions 1-4 in cycle
      'totalFocusMinutes': _sessionsCompleted * workDuration,
    };
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Extension for session copying
extension PomodoroSessionCopy on PomodoroSession {
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
