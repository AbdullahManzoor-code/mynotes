import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

part 'pomodoro_stats_event.dart';
part 'pomodoro_stats_state.dart';

class PomodoroSession {
  final String id;
  final int focusMinutes;
  final int breakMinutes;
  final DateTime completedAt;
  final String? taskTitle;

  PomodoroSession({
    required this.id,
    required this.focusMinutes,
    required this.breakMinutes,
    required this.completedAt,
    this.taskTitle,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'focusMinutes': focusMinutes,
    'breakMinutes': breakMinutes,
    'completedAt': completedAt.toIso8601String(),
    'taskTitle': taskTitle,
  };

  factory PomodoroSession.fromJson(Map<String, dynamic> json) =>
      PomodoroSession(
        id: json['id'] as String,
        focusMinutes: json['focusMinutes'] as int,
        breakMinutes: json['breakMinutes'] as int,
        completedAt: DateTime.parse(json['completedAt'] as String),
        taskTitle: json['taskTitle'] as String?,
      );
}

class PomodoroStatsBloc extends Bloc<PomodoroStatsEvent, PomodoroStatsState> {
  late SharedPreferences _prefs;
  static const String _statsKey = 'pomodoro_stats';
  int _totalSessions = 0;
  int _totalFocusTime = 0;
  int _longestStreak = 0;
  int _currentStreak = 0;
  final List<PomodoroSession> _sessions = [];

  PomodoroStatsBloc() : super(const PomodoroStatsInitial()) {
    on<LoadPomodoroStatsEvent>(_onLoadStats);
    on<RecordPomodoroSessionEvent>(_onRecordSession);
    on<GetFocusStreakEvent>(_onGetFocusStreak);
    on<GetProductivityChartsEvent>(_onGetProductivityCharts);
  }

  Future<void> _onLoadStats(
    LoadPomodoroStatsEvent event,
    Emitter<PomodoroStatsState> emit,
  ) async {
    try {
      emit(const PomodoroStatsLoading());

      _prefs = await SharedPreferences.getInstance();
      _totalSessions = _prefs.getInt('total_sessions') ?? 0;
      _totalFocusTime = _prefs.getInt('total_focus_time') ?? 0;
      _longestStreak = _prefs.getInt('longest_streak') ?? 0;
      _currentStreak = _prefs.getInt('current_streak') ?? 0;

      emit(
        PomodoroStatsLoaded(
          totalSessions: _totalSessions,
          totalFocusTime: _totalFocusTime,
          longestStreak: _longestStreak,
          currentStreak: _currentStreak,
        ),
      );
    } catch (e) {
      emit(PomodoroStatsError(e.toString()));
    }
  }

  Future<void> _onRecordSession(
    RecordPomodoroSessionEvent event,
    Emitter<PomodoroStatsState> emit,
  ) async {
    try {
      _totalSessions++;
      _totalFocusTime += event.focusMinutes;

      final session = PomodoroSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        focusMinutes: event.focusMinutes,
        breakMinutes: event.breakMinutes,
        completedAt: DateTime.now(),
        taskTitle: event.taskTitle,
      );

      _sessions.add(session);

      final today = DateTime.now();
      if (_sessions.isNotEmpty) {
        final lastSession = _sessions[_sessions.length - 2];
        final dayDiff = today.difference(lastSession.completedAt).inDays;
        if (dayDiff == 0) {
          _currentStreak++;
        } else if (dayDiff == 1) {
          _currentStreak++;
        } else {
          _currentStreak = 1;
        }

        if (_currentStreak > _longestStreak) {
          _longestStreak = _currentStreak;
        }
      }

      _prefs = await SharedPreferences.getInstance();
      await _prefs.setInt('total_sessions', _totalSessions);
      await _prefs.setInt('total_focus_time', _totalFocusTime);
      await _prefs.setInt('longest_streak', _longestStreak);
      await _prefs.setInt('current_streak', _currentStreak);

      emit(SessionRecorded(session));
    } catch (e) {
      emit(PomodoroStatsError(e.toString()));
    }
  }

  Future<void> _onGetFocusStreak(
    GetFocusStreakEvent event,
    Emitter<PomodoroStatsState> emit,
  ) async {
    try {
      emit(
        FocusStreakLoaded(
          currentStreak: _currentStreak,
          longestStreak: _longestStreak,
          sessions: List.from(_sessions),
        ),
      );
    } catch (e) {
      emit(PomodoroStatsError(e.toString()));
    }
  }

  Future<void> _onGetProductivityCharts(
    GetProductivityChartsEvent event,
    Emitter<PomodoroStatsState> emit,
  ) async {
    try {
      emit(const PomodoroStatsLoading());

      final chartData = <String, int>{};
      for (final session in _sessions) {
        final dateKey = session.completedAt.toString().split(' ')[0];
        chartData[dateKey] = (chartData[dateKey] ?? 0) + session.focusMinutes;
      }

      emit(
        ProductivityChartsLoaded(
          dailyFocusData: chartData,
          totalSessions: _totalSessions,
          averageFocusPerSession:
              _totalFocusTime ~/ (_totalSessions > 0 ? _totalSessions : 1),
        ),
      );
    } catch (e) {
      emit(PomodoroStatsError(e.toString()));
    }
  }
}
