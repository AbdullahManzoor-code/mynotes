// ══════════════════════════════════════════════════════════════════════════════
// [F009/F010] DISABLED: Unused Pomodoro BLoC system
// Reason: Use FocusBloc instead (includes stats integration + DateTime-based timer)
// Status: File kept for reference - NOT REGISTERED in DI container
// ══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';

part 'pomodoro_event.dart';
part 'pomodoro_state.dart';

class PomodoroBloc extends Bloc<PomodoroEvent, PomodoroState> {
  Timer? _timer;
  int workDuration = 25;
  int shortBreakDuration = 5;
  int longBreakDuration = 15;
  int sessionsCompleted = 0;
  DateTime? _sessionStartTime;

  PomodoroBloc() : super(PomodoroInitial()) {
    on<StartWorkSessionEvent>(_onStartWorkSession);
    on<StartShortBreakEvent>(_onStartShortBreak);
    on<StartLongBreakEvent>(_onStartLongBreak);
    on<PauseSessionEvent>(_onPauseSession);
    on<ResumeSessionEvent>(_onResumeSession);
    on<StopSessionEvent>(_onStopSession);
    on<CompleteSessionEvent>(_onCompleteSession);
    on<UpdateTimerEvent>(_onUpdateTimer);
    on<SetWorkDurationEvent>(_onSetWorkDuration);
    on<SetBreakDurationEvent>(_onSetBreakDuration);
    on<SetLongBreakDurationEvent>(_onSetLongBreakDuration);
  }

  Future<void> _onStartWorkSession(
    StartWorkSessionEvent event,
    Emitter<PomodoroState> emit,
  ) async {
    _timer?.cancel();
    _sessionStartTime = DateTime.now();
    final session = PomodoroSession(
      id: sessionsCompleted + 1,
      selectedTodoId: event.todoId,
      selectedTodoTitle: event.todoTitle,
      status: PomodoroStatus.working,
      sessionsCompleted: sessionsCompleted,
      elapsedTime: Duration.zero,
      totalDuration: Duration(minutes: workDuration),
      startedAt: DateTime.now(),
    );
    _startTimer(emit, session);
    emit(PomodoroSessionActive(session));
  }

  Future<void> _onStartShortBreak(
    StartShortBreakEvent event,
    Emitter<PomodoroState> emit,
  ) async {
    _timer?.cancel();
    _sessionStartTime = DateTime.now();
    final session = PomodoroSession(
      id: sessionsCompleted + 1,
      selectedTodoId: null,
      selectedTodoTitle: 'Short Break',
      status: PomodoroStatus.shortBreak,
      sessionsCompleted: sessionsCompleted,
      elapsedTime: Duration.zero,
      totalDuration: Duration(minutes: shortBreakDuration),
      startedAt: DateTime.now(),
    );
    _startTimer(emit, session);
    emit(PomodoroSessionActive(session));
  }

  Future<void> _onStartLongBreak(
    StartLongBreakEvent event,
    Emitter<PomodoroState> emit,
  ) async {
    _timer?.cancel();
    _sessionStartTime = DateTime.now();
    final session = PomodoroSession(
      id: sessionsCompleted + 1,
      selectedTodoId: null,
      selectedTodoTitle: 'Long Break',
      status: PomodoroStatus.longBreak,
      sessionsCompleted: sessionsCompleted,
      elapsedTime: Duration.zero,
      totalDuration: Duration(minutes: longBreakDuration),
      startedAt: DateTime.now(),
    );
    _startTimer(emit, session);
    emit(PomodoroSessionActive(session));
  }

  Future<void> _onPauseSession(
    PauseSessionEvent event,
    Emitter<PomodoroState> emit,
  ) async {
    _timer?.cancel();
    if (state is PomodoroSessionActive) {
      final current = (state as PomodoroSessionActive).session;
      final pausedSession = current.copyWith(status: PomodoroStatus.paused);
      emit(PomodoroSessionActive(pausedSession));
    }
  }

  Future<void> _onResumeSession(
    ResumeSessionEvent event,
    Emitter<PomodoroState> emit,
  ) async {
    if (state is PomodoroSessionActive) {
      final current = (state as PomodoroSessionActive).session;
      _sessionStartTime = DateTime.now();
      final resumedSession = current.copyWith(status: PomodoroStatus.working);
      _startTimer(emit, resumedSession);
      emit(PomodoroSessionActive(resumedSession));
    }
  }

  Future<void> _onStopSession(
    StopSessionEvent event,
    Emitter<PomodoroState> emit,
  ) async {
    _timer?.cancel();
    _sessionStartTime = null;
    emit(PomodoroInitial());
  }

  Future<void> _onCompleteSession(
    CompleteSessionEvent event,
    Emitter<PomodoroState> emit,
  ) async {
    _timer?.cancel();
    if (state is PomodoroSessionActive) {
      sessionsCompleted++;
      final current = (state as PomodoroSessionActive).session;
      final completedSession = current.copyWith(
        status: PomodoroStatus.completed,
      );
      emit(
        PomodoroSessionCompleted(
          completedSession,
          sessionsCompleted,
          sessionsCompleted * workDuration,
        ),
      );
    }
  }

  Future<void> _onUpdateTimer(
    UpdateTimerEvent event,
    Emitter<PomodoroState> emit,
  ) async {
    if (state is PomodoroSessionActive) {
      final current = (state as PomodoroSessionActive).session;
      final elapsed = DateTime.now().difference(_sessionStartTime!);

      if (elapsed >= current.totalDuration) {
        add(CompleteSessionEvent());
      } else {
        final updatedSession = current.copyWith(elapsedTime: elapsed);
        emit(PomodoroSessionActive(updatedSession));
      }
    }
  }

  void _startTimer(Emitter<PomodoroState> emit, PomodoroSession session) {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      add(UpdateTimerEvent());
    });
  }

  Future<void> _onSetWorkDuration(
    SetWorkDurationEvent event,
    Emitter<PomodoroState> emit,
  ) async {
    workDuration = event.minutes;
    emit(
      PomodoroSettingsUpdated(
        workDuration,
        shortBreakDuration,
        longBreakDuration,
      ),
    );
  }

  Future<void> _onSetBreakDuration(
    SetBreakDurationEvent event,
    Emitter<PomodoroState> emit,
  ) async {
    shortBreakDuration = event.minutes;
    emit(
      PomodoroSettingsUpdated(
        workDuration,
        shortBreakDuration,
        longBreakDuration,
      ),
    );
  }

  Future<void> _onSetLongBreakDuration(
    SetLongBreakDurationEvent event,
    Emitter<PomodoroState> emit,
  ) async {
    longBreakDuration = event.minutes;
    emit(
      PomodoroSettingsUpdated(
        workDuration,
        shortBreakDuration,
        longBreakDuration,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
