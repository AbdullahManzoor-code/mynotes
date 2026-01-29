import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/alarm.dart';
import '../../core/services/alarm_service.dart';

// Events
abstract class AlarmsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAlarms extends AlarmsEvent {}

class AddAlarm extends AlarmsEvent {
  final Alarm alarm;

  AddAlarm(this.alarm);

  @override
  List<Object> get props => [alarm];
}

class UpdateAlarm extends AlarmsEvent {
  final Alarm alarm;

  UpdateAlarm(this.alarm);

  @override
  List<Object> get props => [alarm];
}

class ToggleAlarm extends AlarmsEvent {
  final String alarmId;

  ToggleAlarm(this.alarmId);

  @override
  List<Object> get props => [alarmId];
}

class DeleteAlarm extends AlarmsEvent {
  final String alarmId;

  DeleteAlarm(this.alarmId);

  @override
  List<Object> get props => [alarmId];
}

class SnoozeAlarm extends AlarmsEvent {
  final String alarmId;
  final SnoozePreset preset;

  SnoozeAlarm(this.alarmId, this.preset);

  @override
  List<Object> get props => [alarmId, preset];
}

class RescheduleAlarm extends AlarmsEvent {
  final String alarmId;
  final DateTime newTime;

  RescheduleAlarm(this.alarmId, this.newTime);

  @override
  List<Object> get props => [alarmId, newTime];
}

class MarkAlarmTriggered extends AlarmsEvent {
  final String alarmId;

  MarkAlarmTriggered(this.alarmId);

  @override
  List<Object> get props => [alarmId];
}

class MarkAlarmCompleted extends AlarmsEvent {
  final String alarmId;

  MarkAlarmCompleted(this.alarmId);

  @override
  List<Object> get props => [alarmId];
}

class FilterAlarms extends AlarmsEvent {
  final AlarmFilter filter;

  FilterAlarms(this.filter);

  @override
  List<Object> get props => [filter];
}

class ClearCompletedAlarms extends AlarmsEvent {}

class UndoDeleteAlarm extends AlarmsEvent {
  final Alarm alarm;

  UndoDeleteAlarm(this.alarm);

  @override
  List<Object> get props => [alarm];
}

// Filter options (ALM-004)
enum AlarmFilter { all, overdue, dueSoon, future, completed }

// States
abstract class AlarmsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AlarmsInitial extends AlarmsState {}

class AlarmsLoading extends AlarmsState {}

class AlarmsLoaded extends AlarmsState {
  final List<Alarm> alarms;
  final List<Alarm> filteredAlarms;
  final AlarmFilter currentFilter;
  final AlarmStats stats;

  AlarmsLoaded({
    required this.alarms,
    required this.filteredAlarms,
    this.currentFilter = AlarmFilter.all,
    required this.stats,
  });

  @override
  List<Object> get props => [alarms, filteredAlarms, currentFilter, stats];
}

class AlarmsError extends AlarmsState {
  final String message;

  AlarmsError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class AlarmsBloc extends Bloc<AlarmsEvent, AlarmsState> {
  final AlarmService _alarmService;
  Alarm? _lastDeletedAlarm;

  AlarmsBloc({required AlarmService alarmService})
    : _alarmService = alarmService,
      super(AlarmsInitial()) {
    on<LoadAlarms>(_onLoadAlarms);
    on<AddAlarm>(_onAddAlarm);
    on<UpdateAlarm>(_onUpdateAlarm);
    on<ToggleAlarm>(_onToggleAlarm);
    on<DeleteAlarm>(_onDeleteAlarm);
    on<SnoozeAlarm>(_onSnoozeAlarm);
    on<RescheduleAlarm>(_onRescheduleAlarm);
    on<MarkAlarmTriggered>(_onMarkTriggered);
    on<MarkAlarmCompleted>(_onMarkCompleted);
    on<FilterAlarms>(_onFilterAlarms);
    on<ClearCompletedAlarms>(_onClearCompleted);
    on<UndoDeleteAlarm>(_onUndoDelete);
  }

  Future<void> _onLoadAlarms(
    LoadAlarms event,
    Emitter<AlarmsState> emit,
  ) async {
    try {
      emit(AlarmsLoading());

      final alarms = await _alarmService.loadAlarms();
      final stats = await _alarmService.getStats();

      // Sort by scheduled time
      final sortedAlarms = _alarmService.sortByTime(alarms);

      emit(
        AlarmsLoaded(
          alarms: sortedAlarms,
          filteredAlarms: sortedAlarms,
          stats: stats,
        ),
      );
    } catch (e) {
      emit(AlarmsError(e.toString()));
    }
  }

  Future<void> _onAddAlarm(AddAlarm event, Emitter<AlarmsState> emit) async {
    try {
      final currentState = state;
      if (currentState is! AlarmsLoaded) return;

      final addedAlarm = await _alarmService.addAlarm(event.alarm);
      if (addedAlarm == null) {
        emit(AlarmsError('Failed to add alarm'));
        return;
      }

      // Reload to get updated state
      add(LoadAlarms());
    } catch (e) {
      emit(AlarmsError(e.toString()));
    }
  }

  Future<void> _onUpdateAlarm(
    UpdateAlarm event,
    Emitter<AlarmsState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! AlarmsLoaded) return;

      final success = await _alarmService.updateAlarm(event.alarm);
      if (!success) {
        emit(AlarmsError('Failed to update alarm'));
        return;
      }

      add(LoadAlarms());
    } catch (e) {
      emit(AlarmsError(e.toString()));
    }
  }

  Future<void> _onToggleAlarm(
    ToggleAlarm event,
    Emitter<AlarmsState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! AlarmsLoaded) return;

      final success = await _alarmService.toggleAlarm(event.alarmId);
      if (!success) {
        emit(AlarmsError('Failed to toggle alarm'));
        return;
      }

      add(LoadAlarms());
    } catch (e) {
      emit(AlarmsError(e.toString()));
    }
  }

  Future<void> _onDeleteAlarm(
    DeleteAlarm event,
    Emitter<AlarmsState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! AlarmsLoaded) return;

      // Store for undo
      _lastDeletedAlarm = currentState.alarms.firstWhere(
        (alarm) => alarm.id == event.alarmId,
      );

      final success = await _alarmService.deleteAlarm(event.alarmId);
      if (!success) {
        emit(AlarmsError('Failed to delete alarm'));
        return;
      }

      add(LoadAlarms());
    } catch (e) {
      emit(AlarmsError(e.toString()));
    }
  }

  Future<void> _onSnoozeAlarm(
    SnoozeAlarm event,
    Emitter<AlarmsState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! AlarmsLoaded) return;

      final success = await _alarmService.quickSnooze(
        event.alarmId,
        event.preset,
      );
      if (!success) {
        emit(AlarmsError('Failed to snooze alarm'));
        return;
      }

      add(LoadAlarms());
    } catch (e) {
      emit(AlarmsError(e.toString()));
    }
  }

  Future<void> _onRescheduleAlarm(
    RescheduleAlarm event,
    Emitter<AlarmsState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! AlarmsLoaded) return;

      final success = await _alarmService.rescheduleAlarm(
        event.alarmId,
        event.newTime,
      );
      if (!success) {
        emit(AlarmsError('Failed to reschedule alarm'));
        return;
      }

      add(LoadAlarms());
    } catch (e) {
      emit(AlarmsError(e.toString()));
    }
  }

  Future<void> _onMarkTriggered(
    MarkAlarmTriggered event,
    Emitter<AlarmsState> emit,
  ) async {
    try {
      await _alarmService.markTriggered(event.alarmId);
      add(LoadAlarms());
    } catch (e) {
      emit(AlarmsError(e.toString()));
    }
  }

  Future<void> _onMarkCompleted(
    MarkAlarmCompleted event,
    Emitter<AlarmsState> emit,
  ) async {
    try {
      await _alarmService.markCompleted(event.alarmId);
      add(LoadAlarms());
    } catch (e) {
      emit(AlarmsError(e.toString()));
    }
  }

  Future<void> _onFilterAlarms(
    FilterAlarms event,
    Emitter<AlarmsState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! AlarmsLoaded) return;

      List<Alarm> filtered;
      switch (event.filter) {
        case AlarmFilter.all:
          filtered = currentState.alarms;
          break;
        case AlarmFilter.overdue:
          filtered = currentState.alarms.where((a) => a.isOverdue).toList();
          break;
        case AlarmFilter.dueSoon:
          filtered = currentState.alarms.where((a) => a.isDueSoon).toList();
          break;
        case AlarmFilter.future:
          filtered = currentState.alarms.where((a) {
            return a.isActive &&
                !a.isOverdue &&
                !a.isDueSoon &&
                a.status != AlarmStatus.completed;
          }).toList();
          break;
        case AlarmFilter.completed:
          filtered = currentState.alarms
              .where((a) => a.status == AlarmStatus.completed)
              .toList();
          break;
      }

      emit(
        AlarmsLoaded(
          alarms: currentState.alarms,
          filteredAlarms: filtered,
          currentFilter: event.filter,
          stats: currentState.stats,
        ),
      );
    } catch (e) {
      emit(AlarmsError(e.toString()));
    }
  }

  Future<void> _onClearCompleted(
    ClearCompletedAlarms event,
    Emitter<AlarmsState> emit,
  ) async {
    try {
      await _alarmService.clearCompleted();
      add(LoadAlarms());
    } catch (e) {
      emit(AlarmsError(e.toString()));
    }
  }

  Future<void> _onUndoDelete(
    UndoDeleteAlarm event,
    Emitter<AlarmsState> emit,
  ) async {
    try {
      if (_lastDeletedAlarm == null) return;

      await _alarmService.addAlarm(_lastDeletedAlarm!);
      _lastDeletedAlarm = null;
      add(LoadAlarms());
    } catch (e) {
      emit(AlarmsError(e.toString()));
    }
  }
}
