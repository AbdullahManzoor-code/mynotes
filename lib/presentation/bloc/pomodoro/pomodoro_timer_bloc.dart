// ══════════════════════════════════════════════════════════════════════════════
// [F009/F010] DISABLED: Unused PomodoroTimerBloc system
// Reason: Use FocusBloc instead (includes stats integration + DateTime-based timer)
// Status: File kept for reference - NOT REGISTERED in DI container
// ══════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'pomodoro_timer_event.dart';
import 'pomodoro_timer_state.dart';

class PomodoroTimerBloc extends Bloc<PomodoroTimerEvent, PomodoroTimerState> {
  Timer? _timer;

  PomodoroTimerBloc() : super(PomodoroTimerState.initial()) {
    on<StartTimerEvent>(_onStartTimer);
    on<PauseTimerEvent>(_onPauseTimer);
    on<ResumeTimerEvent>(_onResumeTimer);
    on<ResetTimerEvent>(_onResetTimer);
    on<TickTimerEvent>(_onTickTimer);
    on<UpdateWorkDurationEvent>(_onUpdateWorkDuration);
    on<UpdateBreakDurationEvent>(_onUpdateBreakDuration);
    on<SwitchPhaseEvent>(_onSwitchPhase);
    on<SkipPhaseEvent>(_onSkipPhase);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void _onStartTimer(StartTimerEvent event, Emitter<PomodoroTimerState> emit) {
    if (state.isRunning) return;
    _startTicking(emit);
    emit(state.copyWith(isRunning: true));
  }

  void _onResumeTimer(
    ResumeTimerEvent event,
    Emitter<PomodoroTimerState> emit,
  ) {
    if (state.isRunning) return;
    _startTicking(emit);
    emit(state.copyWith(isRunning: true));
  }

  void _onPauseTimer(PauseTimerEvent event, Emitter<PomodoroTimerState> emit) {
    _timer?.cancel();
    emit(state.copyWith(isRunning: false));
  }

  void _onResetTimer(ResetTimerEvent event, Emitter<PomodoroTimerState> emit) {
    _timer?.cancel();
    emit(
      state.copyWith(isRunning: false, secondsRemaining: state.totalDuration),
    );
  }

  void _onTickTimer(TickTimerEvent event, Emitter<PomodoroTimerState> emit) {
    if (!state.isRunning) return;
    if (state.secondsRemaining > 1) {
      emit(state.copyWith(secondsRemaining: state.secondsRemaining - 1));
      return;
    }

    _timer?.cancel();

    final completedPhase = state.phase;
    var sessionsCompleted = state.sessionsCompleted;
    PomodoroTimerPhase nextPhase;
    int nextDuration;

    if (completedPhase == PomodoroTimerPhase.work) {
      sessionsCompleted += 1;
      if (sessionsCompleted % 4 == 0) {
        nextPhase = PomodoroTimerPhase.longBreak;
        nextDuration = state.longBreakDuration;
      } else {
        nextPhase = PomodoroTimerPhase.shortBreak;
        nextDuration = state.breakDuration;
      }
    } else {
      nextPhase = PomodoroTimerPhase.work;
      nextDuration = state.workDuration;
    }

    emit(
      state.copyWith(
        isRunning: false,
        phase: nextPhase,
        secondsRemaining: nextDuration,
        sessionsCompleted: sessionsCompleted,
        completionCount: state.completionCount + 1,
        lastCompletedPhase: completedPhase,
      ),
    );
  }

  void _onUpdateWorkDuration(
    UpdateWorkDurationEvent event,
    Emitter<PomodoroTimerState> emit,
  ) {
    final duration = event.durationInSeconds;
    emit(
      state.copyWith(
        workDuration: duration,
        secondsRemaining: _secondsForUpdate(duration, PomodoroTimerPhase.work),
      ),
    );
  }

  void _onUpdateBreakDuration(
    UpdateBreakDurationEvent event,
    Emitter<PomodoroTimerState> emit,
  ) {
    final duration = event.durationInSeconds;
    emit(
      state.copyWith(
        breakDuration: duration,
        secondsRemaining: _secondsForUpdate(
          duration,
          PomodoroTimerPhase.shortBreak,
        ),
      ),
    );
  }

  void _onSwitchPhase(
    SwitchPhaseEvent event,
    Emitter<PomodoroTimerState> emit,
  ) {
    if (state.phase == PomodoroTimerPhase.work) {
      emit(
        state.copyWith(
          phase: PomodoroTimerPhase.shortBreak,
          secondsRemaining: state.breakDuration,
          isRunning: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        phase: PomodoroTimerPhase.work,
        secondsRemaining: state.workDuration,
        isRunning: false,
      ),
    );
  }

  void _onSkipPhase(SkipPhaseEvent event, Emitter<PomodoroTimerState> emit) {
    if (state.phase != PomodoroTimerPhase.work) return;

    emit(
      state.copyWith(
        isRunning: false,
        phase: PomodoroTimerPhase.shortBreak,
        secondsRemaining: state.breakDuration,
      ),
    );
  }

  void _startTicking(Emitter<PomodoroTimerState> emit) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const TickTimerEvent());
    });
  }

  int _secondsForUpdate(int duration, PomodoroTimerPhase phase) {
    if (state.isRunning) return state.secondsRemaining;
    if (state.phase != phase) return state.secondsRemaining;
    return duration;
  }
}
