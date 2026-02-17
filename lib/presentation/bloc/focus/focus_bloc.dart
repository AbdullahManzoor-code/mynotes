import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/dnd_service.dart';
import '../../../domain/entities/focus_session.dart';
import '../../../domain/repositories/stats_repository.dart';

// Session Type Enum
enum SessionType { work, shortBreak, longBreak }

// Events
abstract class FocusEvent extends Equatable {
  const FocusEvent();
  @override
  List<Object?> get props => [];
}

class StartFocusSessionEvent extends FocusEvent {
  final int minutes;
  final String? taskTitle;
  final String category;
  final String? todoId;

  const StartFocusSessionEvent({
    required this.minutes,
    this.taskTitle,
    this.category = 'Focus',
    this.todoId,
  });

  @override
  List<Object?> get props => [minutes, taskTitle, category, todoId];
}

class PauseFocusSessionEvent extends FocusEvent {
  const PauseFocusSessionEvent();
}

class ResumeFocusSessionEvent extends FocusEvent {
  const ResumeFocusSessionEvent();
}

class StopFocusSessionEvent extends FocusEvent {
  const StopFocusSessionEvent();
}

class SkipBreakEvent extends FocusEvent {
  const SkipBreakEvent();
}

class StartBreakSessionEvent extends FocusEvent {
  const StartBreakSessionEvent();
}

class TickFocusEvent extends FocusEvent {
  final int secondsRemaining;
  const TickFocusEvent(this.secondsRemaining);
}

class LoadFocusHistoryEvent extends FocusEvent {
  const LoadFocusHistoryEvent();
}

class RateFocusSessionEvent extends FocusEvent {
  final int rating;
  const RateFocusSessionEvent(this.rating);

  @override
  List<Object?> get props => [rating];
}

class UpdateFocusSettingsEvent extends FocusEvent {
  final int? minutes;
  final String? category;
  final String? taskTitle;
  final int? shortBreakMinutes;
  final int? longBreakMinutes;
  final int? sessionsBeforeLongBreak;

  const UpdateFocusSettingsEvent({
    this.minutes,
    this.category,
    this.taskTitle,
    this.shortBreakMinutes,
    this.longBreakMinutes,
    this.sessionsBeforeLongBreak,
  });

  @override
  List<Object?> get props => [
    minutes,
    category,
    taskTitle,
    shortBreakMinutes,
    longBreakMinutes,
    sessionsBeforeLongBreak,
  ];
}

class ToggleTaskSelectionEvent extends FocusEvent {
  final bool isTaskSelection;

  const ToggleTaskSelectionEvent(this.isTaskSelection);

  @override
  List<Object?> get props => [isTaskSelection];
}

class ToggleSettingsEvent extends FocusEvent {
  const ToggleSettingsEvent();
}

class UpdateDistractionFreeModeEvent extends FocusEvent {
  final bool enabled;

  const UpdateDistractionFreeModeEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class SetAutoDndPreferenceEvent extends FocusEvent {
  final bool enabled;

  const SetAutoDndPreferenceEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateAmbientSoundEvent extends FocusEvent {
  final String sound;

  const UpdateAmbientSoundEvent(this.sound);

  @override
  List<Object?> get props => [sound];
}

class LoadFocusLockSettingsEvent extends FocusEvent {
  const LoadFocusLockSettingsEvent();
}

class LoadAutoDndPreferenceEvent extends FocusEvent {
  const LoadAutoDndPreferenceEvent();
}

class ToggleFocusLockEvent extends FocusEvent {
  final bool enabled;

  const ToggleFocusLockEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateFocusLockPinEvent extends FocusEvent {
  final String? pin;

  const UpdateFocusLockPinEvent(this.pin);

  @override
  List<Object?> get props => [pin];
}

class SelectTaskEvent extends FocusEvent {
  final String title;
  final String? todoId;

  const SelectTaskEvent({required this.title, this.todoId});

  @override
  List<Object?> get props => [title, todoId];
}

// States
enum FocusStatus { initial, active, paused, completed }

class FocusState extends Equatable {
  final FocusStatus status;
  final SessionType sessionType;
  final int secondsRemaining;
  final int totalSeconds;
  final String? currentTaskTitle;
  final String currentCategory;
  final List<FocusSession> sessions;
  final DateTime? sessionStartTime;
  // final DateTime? sessionStartTime;
  final String? linkedTodoId;
  final String? lastCompletedSessionId;

  // Settings
  final int initialMinutes;
  final String initialCategory;
  final String initialTaskTitle;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int sessionsBeforeLongBreak;

  // Session tracking
  final int completedWorkSessions;
  final int todayTotalFocusMinutes;

  // UI State
  final bool isTaskSelectionStep;
  final bool showSettings;
  final bool distractionFreeMode;
  final bool autoDndEnabled;
  final bool autoDndAsked;
  final String selectedSound;
  final bool isLockEnabled;
  final String? lockPin;

  const FocusState({
    this.status = FocusStatus.initial,
    this.sessionType = SessionType.work,
    this.secondsRemaining = 1500,
    this.totalSeconds = 1500,
    this.currentTaskTitle,
    this.currentCategory = 'Focus',
    this.sessions = const [],
    this.sessionStartTime,
    this.linkedTodoId,
    this.initialMinutes = 25,
    this.initialCategory = 'Focus',
    this.initialTaskTitle = 'Focused Work Session',
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.sessionsBeforeLongBreak = 4,
    this.completedWorkSessions = 0,
    this.todayTotalFocusMinutes = 0,
    this.lastCompletedSessionId,
    this.isTaskSelectionStep = false,
    this.showSettings = false,
    this.distractionFreeMode = false,
    this.autoDndEnabled = false,
    this.autoDndAsked = false,
    this.selectedSound = 'None',
    this.isLockEnabled = false,
    this.lockPin,
  });

  bool get isBreak =>
      sessionType == SessionType.shortBreak ||
      sessionType == SessionType.longBreak;

  FocusState copyWith({
    FocusStatus? status,
    SessionType? sessionType,
    int? secondsRemaining,
    int? totalSeconds,
    String? currentTaskTitle,
    String? currentCategory,
    List<FocusSession>? sessions,
    DateTime? sessionStartTime,
    String? linkedTodoId,
    int? initialMinutes,
    String? initialCategory,
    String? initialTaskTitle,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? sessionsBeforeLongBreak,
    int? completedWorkSessions,
    int? todayTotalFocusMinutes,
    String? lastCompletedSessionId,
    bool? isTaskSelectionStep,
    bool? showSettings,
    bool? distractionFreeMode,
    bool? autoDndEnabled,
    bool? autoDndAsked,
    String? selectedSound,
    bool? isLockEnabled,
    String? lockPin,
  }) {
    return FocusState(
      status: status ?? this.status,
      sessionType: sessionType ?? this.sessionType,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      currentTaskTitle: currentTaskTitle ?? this.currentTaskTitle,
      currentCategory: currentCategory ?? this.currentCategory,
      sessions: sessions ?? this.sessions,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      linkedTodoId: linkedTodoId ?? this.linkedTodoId,
      initialMinutes: initialMinutes ?? this.initialMinutes,
      initialCategory: initialCategory ?? this.initialCategory,
      initialTaskTitle: initialTaskTitle ?? this.initialTaskTitle,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      sessionsBeforeLongBreak:
          sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
      completedWorkSessions:
          completedWorkSessions ?? this.completedWorkSessions,
      todayTotalFocusMinutes:
          todayTotalFocusMinutes ?? this.todayTotalFocusMinutes,
      lastCompletedSessionId:
          lastCompletedSessionId ?? this.lastCompletedSessionId,
      isTaskSelectionStep: isTaskSelectionStep ?? this.isTaskSelectionStep,
      showSettings: showSettings ?? this.showSettings,
      distractionFreeMode: distractionFreeMode ?? this.distractionFreeMode,
      autoDndEnabled: autoDndEnabled ?? this.autoDndEnabled,
      autoDndAsked: autoDndAsked ?? this.autoDndAsked,
      selectedSound: selectedSound ?? this.selectedSound,
      isLockEnabled: isLockEnabled ?? this.isLockEnabled,
      lockPin: lockPin ?? this.lockPin,
    );
  }

  @override
  List<Object?> get props => [
    status,
    sessionType,
    secondsRemaining,
    totalSeconds,
    currentTaskTitle,
    currentCategory,
    sessions,
    sessionStartTime,
    linkedTodoId,
    initialMinutes,
    initialCategory,
    initialTaskTitle,
    shortBreakMinutes,
    longBreakMinutes,
    sessionsBeforeLongBreak,
    completedWorkSessions,
    todayTotalFocusMinutes,
    lastCompletedSessionId,
    isTaskSelectionStep,
    showSettings,
    distractionFreeMode,
    autoDndEnabled,
    autoDndAsked,
    selectedSound,
    isLockEnabled,
    lockPin,
  ];
}

// Bloc
class FocusBloc extends Bloc<FocusEvent, FocusState> {
  final StatsRepository repository;
  Timer? _timer;
  static const _uuid = Uuid();
  static const DndMode _defaultDndMode = DndMode.totalSilence;
  static const String _lockEnabledKey = 'focus_lock_enabled';
  static const String _lockPinKey = 'focus_lock_pin';
  static const String _autoDndEnabledKey = 'focus_auto_dnd_enabled';
  static const String _autoDndAskedKey = 'focus_auto_dnd_asked';
  SharedPreferences? _prefs;

  FocusBloc({required this.repository}) : super(const FocusState()) {
    on<StartFocusSessionEvent>(_onStart);
    on<PauseFocusSessionEvent>(_onPause);
    on<ResumeFocusSessionEvent>(_onResume);
    on<StopFocusSessionEvent>(_onStop);
    on<SkipBreakEvent>(_onSkipBreak);
    on<StartBreakSessionEvent>((event, emit) => _startBreakSession(emit));
    on<TickFocusEvent>(_onTick);
    on<LoadFocusHistoryEvent>(_onLoadHistory);
    on<UpdateFocusSettingsEvent>(_onUpdateSettings);
    on<RateFocusSessionEvent>(_onRateSession);
    on<ToggleTaskSelectionEvent>(_onToggleTaskSelection);
    on<ToggleSettingsEvent>(_onToggleSettings);
    on<UpdateDistractionFreeModeEvent>(_onUpdateDistractionFreeMode);
    on<SetAutoDndPreferenceEvent>(_onSetAutoDndPreference);
    on<UpdateAmbientSoundEvent>(_onUpdateAmbientSound);
    on<SelectTaskEvent>(_onSelectTask);
    on<LoadFocusLockSettingsEvent>(_onLoadLockSettings);
    on<ToggleFocusLockEvent>(_onToggleLock);
    on<UpdateFocusLockPinEvent>(_onUpdateLockPin);
    on<LoadAutoDndPreferenceEvent>(_onLoadAutoDndPreference);
  }

  Future<void> _onRateSession(
    RateFocusSessionEvent event,
    Emitter<FocusState> emit,
  ) async {
    if (state.lastCompletedSessionId == null) return;

    final sessions = await repository.getFocusSessions();
    try {
      final session = sessions.firstWhere(
        (s) => s.id == state.lastCompletedSessionId,
      );
      final updatedSession = session.copyWith(rating: event.rating);
      await repository.saveFocusSession(updatedSession);
      add(const LoadFocusHistoryEvent());
    } catch (_) {
      // Session not found
    }
  }

  void _onUpdateSettings(
    UpdateFocusSettingsEvent event,
    Emitter<FocusState> emit,
  ) {
    if (state.status == FocusStatus.initial) {
      emit(
        state.copyWith(
          initialMinutes: event.minutes,
          initialCategory: event.category,
          initialTaskTitle: event.taskTitle,
          shortBreakMinutes: event.shortBreakMinutes,
          longBreakMinutes: event.longBreakMinutes,
          sessionsBeforeLongBreak: event.sessionsBeforeLongBreak,
          secondsRemaining: event.minutes != null ? event.minutes! * 60 : null,
          totalSeconds: event.minutes != null ? event.minutes! * 60 : null,
        ),
      );
    }
  }

  Future<void> _onStart(
    StartFocusSessionEvent event,
    Emitter<FocusState> emit,
  ) async {
    _timer?.cancel();
    final totalSeconds = event.minutes * 60;
    emit(
      state.copyWith(
        status: FocusStatus.active,
        sessionType: SessionType.work,
        totalSeconds: totalSeconds,
        secondsRemaining: totalSeconds,
        currentTaskTitle: event.taskTitle ?? state.initialTaskTitle,
        currentCategory: event.category,
        sessionStartTime: DateTime.now(),
        linkedTodoId: event.todoId,
      ),
    );

    await _enableDndIfNeeded();

    _startTimer();
  }

  Future<void> _onPause(
    PauseFocusSessionEvent event,
    Emitter<FocusState> emit,
  ) async {
    _timer?.cancel();
    emit(state.copyWith(status: FocusStatus.paused));
    await _disableDndIfNeeded();
  }

  Future<void> _onResume(
    ResumeFocusSessionEvent event,
    Emitter<FocusState> emit,
  ) async {
    emit(state.copyWith(status: FocusStatus.active));
    await _enableDndIfNeeded();
    _startTimer();
  }

  Future<void> _onSkipBreak(
    SkipBreakEvent event,
    Emitter<FocusState> emit,
  ) async {
    if (!state.isBreak) return;

    _timer?.cancel();
    _startWorkSession(emit);
    await _enableDndIfNeeded();
  }

  void _startTimer() {
    _timer?.cancel();
    // FIX F008: Use DateTime-based calculation instead of Timer.periodic
    // This ensures timer is accurate even when app is backgrounded
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.sessionStartTime == null) {
        timer.cancel();
        return;
      }

      // Calculate actual elapsed time from session start (handles backgrounding)
      final now = DateTime.now();
      final elapsedSeconds = now.difference(state.sessionStartTime!).inSeconds;
      final secondsRemaining = state.totalSeconds - elapsedSeconds;

      if (secondsRemaining <= 0) {
        // Session complete
        timer.cancel();
        add(const TickFocusEvent(0));
      } else {
        // Continue ticking with actual elapsed time
        add(TickFocusEvent(secondsRemaining));
      }
    });
  }

  void _startWorkSession(Emitter<FocusState> emit) {
    final totalSeconds = state.initialMinutes * 60;
    emit(
      state.copyWith(
        status: FocusStatus.active,
        sessionType: SessionType.work,
        totalSeconds: totalSeconds,
        secondsRemaining: totalSeconds,
        sessionStartTime: DateTime.now(),
      ),
    );
    _startTimer();
  }

  void _startBreakSession(Emitter<FocusState> emit) {
    final isLongBreak =
        state.completedWorkSessions >= state.sessionsBeforeLongBreak;
    final breakMinutes = isLongBreak
        ? state.longBreakMinutes
        : state.shortBreakMinutes;
    final totalSeconds = breakMinutes * 60;

    emit(
      state.copyWith(
        status: FocusStatus.active,
        sessionType: isLongBreak
            ? SessionType.longBreak
            : SessionType.shortBreak,
        totalSeconds: totalSeconds,
        secondsRemaining: totalSeconds,
        sessionStartTime: DateTime.now(),
        // Reset session count after long break
        completedWorkSessions: isLongBreak ? 0 : null,
      ),
    );
    _startTimer();
  }

  Future<void> _onTick(TickFocusEvent event, Emitter<FocusState> emit) async {
    if (event.secondsRemaining <= 0) {
      _timer?.cancel();

      if (state.sessionType == SessionType.work) {
        await _disableDndIfNeeded();
        // Work session completed - save to database
        final sessionId = _uuid.v4();
        final session = FocusSession(
          id: sessionId,
          startTime: state.sessionStartTime ?? DateTime.now(),
          endTime: DateTime.now(),
          durationSeconds: state.totalSeconds,
          taskTitle: state.currentTaskTitle,
          category: state.currentCategory,
          isCompleted: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repository.saveFocusSession(session);

        // Increment completed sessions
        final newCompletedSessions = state.completedWorkSessions + 1;
        final newTotalMinutes =
            state.todayTotalFocusMinutes + (state.totalSeconds ~/ 60);

        emit(
          state.copyWith(
            completedWorkSessions: newCompletedSessions,
            todayTotalFocusMinutes: newTotalMinutes,
            secondsRemaining: 0,
            lastCompletedSessionId: sessionId,
          ),
        );

        // Check for break
        _startBreakSession(emit);

        add(const LoadFocusHistoryEvent());
      } else {
        // Break completed
        // If it was a long break, we might want to end the session cycle
        if (state.sessionType == SessionType.longBreak) {
          emit(state.copyWith(status: FocusStatus.completed));
        } else {
          // Short break ended -> start next work session
          _startWorkSession(emit);
          await _enableDndIfNeeded();
        }
      }
    } else {
      emit(state.copyWith(secondsRemaining: event.secondsRemaining));
    }
  }

  Future<void> _onStop(
    StopFocusSessionEvent event,
    Emitter<FocusState> emit,
  ) async {
    _timer?.cancel();
    await _disableDndIfNeeded();

    // Only save if it was a work session (not break)
    if ((state.status == FocusStatus.active ||
            state.status == FocusStatus.paused) &&
        state.sessionType == SessionType.work) {
      final elapsedSeconds = state.totalSeconds - state.secondsRemaining;
      if (elapsedSeconds > 0) {
        final session = FocusSession(
          id: _uuid.v4(),
          startTime: state.sessionStartTime ?? DateTime.now(),
          endTime: DateTime.now(),
          durationSeconds: elapsedSeconds,
          taskTitle: state.currentTaskTitle,
          category: state.currentCategory,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repository.saveFocusSession(session);
      }
    }

    emit(
      state.copyWith(
        status: FocusStatus.initial,
        sessionType: SessionType.work,
        completedWorkSessions: 0,
      ),
    );
    add(const LoadFocusHistoryEvent());
  }

  Future<void> _onLoadHistory(
    LoadFocusHistoryEvent event,
    Emitter<FocusState> emit,
  ) async {
    final sessions = await repository.getFocusSessions();
    emit(state.copyWith(sessions: sessions));
  }

  void _onToggleTaskSelection(
    ToggleTaskSelectionEvent event,
    Emitter<FocusState> emit,
  ) {
    emit(state.copyWith(isTaskSelectionStep: event.isTaskSelection));
  }

  void _onToggleSettings(ToggleSettingsEvent event, Emitter<FocusState> emit) {
    emit(state.copyWith(showSettings: !state.showSettings));
  }

  void _onUpdateDistractionFreeMode(
    UpdateDistractionFreeModeEvent event,
    Emitter<FocusState> emit,
  ) {
    emit(state.copyWith(distractionFreeMode: event.enabled));
  }

  void _onUpdateAmbientSound(
    UpdateAmbientSoundEvent event,
    Emitter<FocusState> emit,
  ) {
    emit(state.copyWith(selectedSound: event.sound));
  }

  Future<void> _onLoadLockSettings(
    LoadFocusLockSettingsEvent event,
    Emitter<FocusState> emit,
  ) async {
    final prefs = await _getPrefs();
    final isEnabled = prefs.getBool(_lockEnabledKey) ?? false;
    final pin = prefs.getString(_lockPinKey);
    emit(state.copyWith(isLockEnabled: isEnabled, lockPin: pin));
  }

  Future<void> _onToggleLock(
    ToggleFocusLockEvent event,
    Emitter<FocusState> emit,
  ) async {
    emit(state.copyWith(isLockEnabled: event.enabled));
    final prefs = await _getPrefs();
    await prefs.setBool(_lockEnabledKey, event.enabled);
  }

  Future<void> _onUpdateLockPin(
    UpdateFocusLockPinEvent event,
    Emitter<FocusState> emit,
  ) async {
    final normalized = (event.pin ?? '').trim();
    final pinValue = normalized.isEmpty ? null : normalized;
    emit(state.copyWith(lockPin: pinValue));
    final prefs = await _getPrefs();
    if (pinValue == null) {
      await prefs.remove(_lockPinKey);
    } else {
      await prefs.setString(_lockPinKey, pinValue);
    }
  }

  Future<void> _onSetAutoDndPreference(
    SetAutoDndPreferenceEvent event,
    Emitter<FocusState> emit,
  ) async {
    emit(state.copyWith(autoDndEnabled: event.enabled, autoDndAsked: true));
    final prefs = await _getPrefs();
    await prefs.setBool(_autoDndEnabledKey, event.enabled);
    await prefs.setBool(_autoDndAskedKey, true);
  }

  Future<void> _onLoadAutoDndPreference(
    LoadAutoDndPreferenceEvent event,
    Emitter<FocusState> emit,
  ) async {
    final prefs = await _getPrefs();
    final autoDndEnabled = prefs.getBool(_autoDndEnabledKey) ?? false;
    final autoDndAsked = prefs.getBool(_autoDndAskedKey) ?? false;
    emit(
      state.copyWith(
        autoDndEnabled: autoDndEnabled,
        autoDndAsked: autoDndAsked,
      ),
    );
  }

  void _onSelectTask(SelectTaskEvent event, Emitter<FocusState> emit) {
    emit(
      state.copyWith(
        initialTaskTitle: event.title,
        linkedTodoId: event.todoId,
        isTaskSelectionStep: false,
      ),
    );
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await _disableDndIfNeeded();
    return super.close();
  }

  Future<void> _enableDndIfNeeded() async {
    if (!state.distractionFreeMode) return;
    if (state.sessionType != SessionType.work) return;
    // Only auto-enable DND if user has enabled it in preferences
    if (!state.autoDndEnabled) return;
    await DndService.enableDnd(mode: _defaultDndMode);
  }

  Future<void> _disableDndIfNeeded() async {
    if (!state.distractionFreeMode) return;
    await DndService.disableDnd();
  }

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }
}
