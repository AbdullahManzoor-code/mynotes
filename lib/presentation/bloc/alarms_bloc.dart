import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/alarm.dart';
import '../../domain/repositories/alarm_repository.dart';
import '../../core/notifications/alarm_service.dart' as notifications;
import 'dart:convert';

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

// NEW: Algorithm 4 Events
class ToggleAlarmEnabled extends AlarmsEvent {
  final String alarmId;

  ToggleAlarmEnabled(this.alarmId);

  @override
  List<Object> get props => [alarmId];
}

class LinkAlarmToNote extends AlarmsEvent {
  final String alarmId;
  final String noteId;

  LinkAlarmToNote(this.alarmId, this.noteId);

  @override
  List<Object> get props => [alarmId, noteId];
}

class LinkAlarmToTodo extends AlarmsEvent {
  final String alarmId;
  final String todoId;

  LinkAlarmToTodo(this.alarmId, this.todoId);

  @override
  List<Object> get props => [alarmId, todoId];
}

class UnlinkAlarm extends AlarmsEvent {
  final String alarmId;

  UnlinkAlarm(this.alarmId);

  @override
  List<Object> get props => [alarmId];
}

class SearchAlarms extends AlarmsEvent {
  final String query;

  SearchAlarms(this.query);

  @override
  List<Object> get props => [query];
}

// Filter options (ALM-004) - Updated for Algorithm 4
enum AlarmFilter {
  all,
  today, // NEW: Due today
  upcoming, // NEW: Future alarms
  overdue,
  snoozed, // NEW: Snoozed alarms
  completed,
}

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
  final AlarmRepository _alarmRepository;
  final notifications.AlarmService _notificationService;
  Alarm? _lastDeletedAlarm;

  AlarmsBloc({
    required AlarmRepository alarmRepository,
    notifications.AlarmService? notificationService,
  }) : _alarmRepository = alarmRepository,
       _notificationService =
           notificationService ?? notifications.AlarmService(),
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
    on<ToggleAlarmEnabled>(_onToggleAlarmEnabled);
    on<LinkAlarmToNote>(_onLinkAlarmToNote);
    on<LinkAlarmToTodo>(_onLinkAlarmToTodo);
    on<UnlinkAlarm>(_onUnlinkAlarm);
    on<SearchAlarms>(_onSearchAlarms);
  }

  Future<void> _onLoadAlarms(
    LoadAlarms event,
    Emitter<AlarmsState> emit,
  ) async {
    await _loadAlarmsInternal(emit);
  }

  Future<void> _loadAlarmsInternal(Emitter<AlarmsState> emit) async {
    try {
      emit(AlarmsLoading());

      final alarms = await _alarmRepository.getAlarms();
      final stats = alarms.stats;

      // Sort by scheduled time
      final sortedAlarms = alarms.sortByTime();

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

      await _alarmRepository.createAlarm(event.alarm);
      final addedAlarm = event.alarm;

      // Schedule notification
      // Schedule notification
      await _notificationService.scheduleAlarm(
        dateTime: addedAlarm.scheduledTime,
        id: addedAlarm.id,
        title: addedAlarm.message, // Use message as title
        payload: jsonEncode({'type': 'alarm', 'id': addedAlarm.id}),
        recurrence: addedAlarm.recurrence,
      );

      // Reload to get updated state
      await _loadAlarmsInternal(emit);
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

      await _alarmRepository.updateAlarm(event.alarm);

      // Reschedule notification
      if (event.alarm.isEnabled) {
        await _notificationService.scheduleAlarm(
          dateTime: event.alarm.scheduledTime,
          id: event.alarm.id,
          title: event.alarm.message,
          payload: jsonEncode({'type': 'alarm', 'id': event.alarm.id}),
        );
      } else {
        await _notificationService.cancelAlarm(event.alarm.id);
      }

      await _loadAlarmsInternal(emit);
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

      await _alarmRepository.toggleAlarm(event.alarmId);

      // Update notification state
      final alarm = await _alarmRepository.getAlarmById(event.alarmId);
      if (alarm != null) {
        if (alarm.isEnabled) {
          await _notificationService.scheduleAlarm(
            dateTime: alarm.scheduledTime,
            id: alarm.id,
            title: alarm.message,
            payload: jsonEncode({'type': 'alarm', 'id': alarm.id}),
          );
        } else {
          await _notificationService.cancelAlarm(alarm.id);
        }
      }

      await _loadAlarmsInternal(emit);
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

      await _alarmRepository.deleteAlarm(event.alarmId);

      // Cancel notification
      await _notificationService.cancelAlarm(event.alarmId);

      await _loadAlarmsInternal(emit);
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

      await _alarmRepository.quickSnooze(event.alarmId, event.preset);

      final updatedAlarm = await _alarmRepository.getAlarmById(event.alarmId);
      if (updatedAlarm != null && updatedAlarm.snoozedUntil != null) {
        await _notificationService.scheduleAlarm(
          dateTime: updatedAlarm.snoozedUntil!,
          id: updatedAlarm.id,
          title: updatedAlarm.message,
          payload: jsonEncode({'type': 'alarm', 'id': updatedAlarm.id}),
        );
      }

      await _loadAlarmsInternal(emit);
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

      await _alarmRepository.rescheduleAlarm(event.alarmId, event.newTime);

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
      await _alarmRepository.markTriggered(event.alarmId);
      await _loadAlarmsInternal(emit);
    } catch (e) {
      emit(AlarmsError(e.toString()));
    }
  }

  Future<void> _onMarkCompleted(
    MarkAlarmCompleted event,
    Emitter<AlarmsState> emit,
  ) async {
    try {
      await _alarmRepository.markCompleted(event.alarmId);
      await _notificationService.cancelAlarm(event.alarmId);
      await _loadAlarmsInternal(emit);
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
        case AlarmFilter.today:
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final tomorrow = today.add(const Duration(days: 1));
          filtered = currentState.alarms.where((a) {
            final effectiveTime = a.snoozedUntil ?? a.scheduledTime;
            return effectiveTime.isAfter(today) &&
                effectiveTime.isBefore(tomorrow);
          }).toList();
          break;
        case AlarmFilter.upcoming:
          final now = DateTime.now();
          filtered = currentState.alarms.where((a) {
            final effectiveTime = a.snoozedUntil ?? a.scheduledTime;
            return effectiveTime.isAfter(now) &&
                !a.isOverdue &&
                a.status != AlarmStatus.completed;
          }).toList();
          break;
        case AlarmFilter.overdue:
          filtered = currentState.alarms.where((a) => a.isOverdue).toList();
          break;
        case AlarmFilter.snoozed:
          filtered = currentState.alarms.where((a) => a.isSnoozed).toList();
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
      await _alarmRepository.clearCompleted();
      await _loadAlarmsInternal(emit);
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

      await _alarmRepository.createAlarm(_lastDeletedAlarm!);
      _lastDeletedAlarm = null;
      await _loadAlarmsInternal(emit);
    } catch (e) {
      emit(AlarmsError(e.toString()));
    }
  }

  Future<void> _onToggleAlarmEnabled(
    ToggleAlarmEnabled event,
    Emitter<AlarmsState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! AlarmsLoaded) return;

      final alarm = await _alarmRepository.getAlarmById(event.alarmId);
      if (alarm != null) {
        final updatedAlarm = alarm.copyWith(isEnabled: !alarm.isEnabled);
        await _alarmRepository.updateAlarm(updatedAlarm);
        await _loadAlarmsInternal(emit);
      }
    } catch (e) {
      emit(AlarmsError(e.toString()));
    }
  }

  Future<void> _onLinkAlarmToNote(
    LinkAlarmToNote event,
    Emitter<AlarmsState> emit,
  ) async {
    try {
      final alarm = await _alarmRepository.getAlarmById(event.alarmId);
      if (alarm != null) {
        final updatedAlarm = alarm.copyWith(linkedNoteId: event.noteId);
        await _alarmRepository.updateAlarm(updatedAlarm);
        // Note updates are handled by NoteBloc listening to stream or service
        await _loadAlarmsInternal(emit);
      }
    } catch (e) {
      emit(AlarmsError(e.toString()));
    }
  }

  Future<void> _onLinkAlarmToTodo(
    LinkAlarmToTodo event,
    Emitter<AlarmsState> emit,
  ) async {
    try {
      final alarm = await _alarmRepository.getAlarmById(event.alarmId);
      if (alarm != null) {
        final updatedAlarm = alarm.copyWith(linkedTodoId: event.todoId);
        await _alarmRepository.updateAlarm(updatedAlarm);
        await _loadAlarmsInternal(emit);
      }
    } catch (e) {
      emit(AlarmsError(e.toString()));
    }
  }

  Future<void> _onUnlinkAlarm(
    UnlinkAlarm event,
    Emitter<AlarmsState> emit,
  ) async {
    try {
      final alarm = await _alarmRepository.getAlarmById(event.alarmId);
      if (alarm != null) {
        final updatedAlarm = alarm.copyWith(
          clearLinkedNote: true,
          clearLinkedTodo: true,
        );
        await _alarmRepository.updateAlarm(updatedAlarm);
        await _loadAlarmsInternal(emit);
      }
    } catch (e) {
      emit(AlarmsError(e.toString()));
    }
  }

  Future<void> _onSearchAlarms(
    SearchAlarms event,
    Emitter<AlarmsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AlarmsLoaded) return;

    final query = event.query.toLowerCase();
    final filtered = currentState.alarms.where((a) {
      return a.message.toLowerCase().contains(query);
    }).toList();

    emit(
      AlarmsLoaded(
        alarms: currentState.alarms,
        filteredAlarms: filtered,
        currentFilter: currentState.currentFilter,
        stats: currentState.stats,
      ),
    );
  }
}
