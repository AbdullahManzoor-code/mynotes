import 'package:equatable/equatable.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// PHASE 6: FOCUS SESSIONS & POMODORO TIMER
/// Focus/Pomodoro Events
/// ════════════════════════════════════════════════════════════════════════════

abstract class FocusEvent extends Equatable {
  const FocusEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize focus session with default or custom durations
class InitializeFocusSession extends FocusEvent {
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int sessionsBeforeLongBreak;

  const InitializeFocusSession({
    this.focusMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.sessionsBeforeLongBreak = 4,
  });

  @override
  List<Object?> get props => [
    focusMinutes,
    shortBreakMinutes,
    longBreakMinutes,
    sessionsBeforeLongBreak,
  ];
}

/// Load existing focus sessions
class LoadFocusSessions extends FocusEvent {
  const LoadFocusSessions();
}

/// Start the timer
class StartFocusTimer extends FocusEvent {
  const StartFocusTimer();
}

/// Pause the timer
class PauseFocusTimer extends FocusEvent {
  const PauseFocusTimer();
}

/// Resume the paused timer
class ResumeFocusTimer extends FocusEvent {
  const ResumeFocusTimer();
}

/// Stop and reset the timer
class StopFocusTimer extends FocusEvent {
  const StopFocusTimer();
}

/// Skip to next session
class SkipFocusSession extends FocusEvent {
  const SkipFocusSession();
}

/// Advance to break session
class AdvanceToBreak extends FocusEvent {
  const AdvanceToBreak();
}

/// Advance to next focus session
class AdvanceToFocus extends FocusEvent {
  const AdvanceToFocus();
}

/// Tick event (1 second interval)
class TickFocusTimer extends FocusEvent {
  const TickFocusTimer();
}

/// Complete current session
class CompleteFocusSession extends FocusEvent {
  const CompleteFocusSession();
}

/// Add notes/goals for current session
class SetFocusNotes extends FocusEvent {
  final String notes;

  const SetFocusNotes({required this.notes});

  @override
  List<Object?> get props => [notes];
}

/// Save completed session to history
class SaveFocusSession extends FocusEvent {
  const SaveFocusSession();
}

/// Clear history
class ClearFocusHistory extends FocusEvent {
  const ClearFocusHistory();
}
