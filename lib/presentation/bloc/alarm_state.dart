// lib/presentation/bloc/alarm_state.dart

import 'package:equatable/equatable.dart';
import 'params/alarm_params.dart';

/// Base class for all alarm states
abstract class AlarmState extends Equatable {
  const AlarmState();

  @override
  List<Object?> get props => [];
}

/// 🏁 Initial state before any action
class AlarmInitial extends AlarmState {
  const AlarmInitial();
}

/// ⏳ Loading state during async operations
class AlarmLoading extends AlarmState {
  final String? message;

  const AlarmLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// ✅ Success state after successful operation
class AlarmSuccess extends AlarmState {
  final String message;
  final dynamic result; // Can be AlarmParams or List<AlarmParams>

  const AlarmSuccess(this.message, {this.result});

  @override
  List<Object?> get props => [message, result];
}

/// 📋 State with loaded alarms list
class AlarmsLoaded extends AlarmState {
  final List<AlarmParams> alarms;
  final List<AlarmParams> activeAlarms;
  final List<AlarmParams> upcomingAlarms;
  final int totalCount;

  const AlarmsLoaded({
    required this.alarms,
    List<AlarmParams>? activeAlarms,
    List<AlarmParams>? upcomingAlarms,
  }) : activeAlarms = activeAlarms ?? const [],
       upcomingAlarms = upcomingAlarms ?? const [],
       totalCount = alarms.length;

  /// Get alarms for today
  List<AlarmParams> get todayAlarms {
    final now = DateTime.now();
    return alarms.where((alarm) {
      return alarm.alarmTime.year == now.year &&
          alarm.alarmTime.month == now.month &&
          alarm.alarmTime.day == now.day;
    }).toList();
  }

  /// Get enabled alarms only
  List<AlarmParams> get enabledAlarms {
    return alarms.where((alarm) => alarm.isEnabled).toList();
  }

  /// Get disabled alarms only
  List<AlarmParams> get disabledAlarms {
    return alarms.where((alarm) => !alarm.isEnabled).toList();
  }

  /// Get recurring alarms only
  List<AlarmParams> get recurringAlarms {
    return alarms.where((alarm) => alarm.isRecurring).toList();
  }

  /// Create copy with updated alarm
  AlarmsLoaded withUpdatedAlarm(AlarmParams updatedAlarm) {
    final updatedList = alarms.map((alarm) {
      return alarm.alarmId == updatedAlarm.alarmId ? updatedAlarm : alarm;
    }).toList();

    return AlarmsLoaded(
      alarms: updatedList,
      activeAlarms: updatedList.where((a) => a.isEnabled).toList(),
      upcomingAlarms:
          updatedList.where((a) => a.isEnabled && !a.isPast).toList()
            ..sort((a, b) => a.alarmTime.compareTo(b.alarmTime)),
    );
  }

  /// Create copy with added alarm
  AlarmsLoaded withAddedAlarm(AlarmParams newAlarm) {
    final updatedList = [...alarms, newAlarm];

    return AlarmsLoaded(
      alarms: updatedList,
      activeAlarms: updatedList.where((a) => a.isEnabled).toList(),
      upcomingAlarms:
          updatedList.where((a) => a.isEnabled && !a.isPast).toList()
            ..sort((a, b) => a.alarmTime.compareTo(b.alarmTime)),
    );
  }

  /// Create copy with removed alarm
  AlarmsLoaded withRemovedAlarm(String alarmId) {
    final updatedList = alarms.where((a) => a.alarmId != alarmId).toList();

    return AlarmsLoaded(
      alarms: updatedList,
      activeAlarms: updatedList.where((a) => a.isEnabled).toList(),
      upcomingAlarms:
          updatedList.where((a) => a.isEnabled && !a.isPast).toList()
            ..sort((a, b) => a.alarmTime.compareTo(b.alarmTime)),
    );
  }

  @override
  List<Object?> get props => [alarms, activeAlarms, upcomingAlarms, totalCount];
}

/// ❌ Error state for failures
class AlarmError extends AlarmState {
  final String message;
  final String? code;
  final dynamic exception;
  final bool canRetry;

  const AlarmError(
    this.message, {
    this.code,
    this.exception,
    this.canRetry = true,
  });

  @override
  List<Object?> get props => [message, code, exception, canRetry];
}

/// ⚠️ Validation error state
class AlarmValidationError extends AlarmState {
  final String message;
  final String? field;
  final dynamic invalidValue;

  const AlarmValidationError(this.message, {this.field, this.invalidValue});

  @override
  List<Object?> get props => [message, field, invalidValue];
}

/// 🔔 Alarm triggered state
class AlarmTriggered extends AlarmState {
  final AlarmParams alarm;
  final DateTime triggeredAt;

  AlarmTriggered({required this.alarm, DateTime? triggeredAt})
    : triggeredAt = triggeredAt ?? DateTime.now();

  @override
  List<Object?> get props => [alarm, triggeredAt];
}

/// ⏰ Alarm snoozed state
class AlarmSnoozed extends AlarmState {
  final AlarmParams alarm;
  final DateTime snoozeUntil;
  final int snoozeMinutes;

  const AlarmSnoozed({
    required this.alarm,
    required this.snoozeUntil,
    required this.snoozeMinutes,
  });

  @override
  List<Object?> get props => [alarm, snoozeUntil, snoozeMinutes];
}

/// 🗑️ Alarm deleted state
class AlarmDeleted extends AlarmState {
  final String alarmId;
  final AlarmParams? deletedAlarm; // For undo functionality

  const AlarmDeleted({required this.alarmId, this.deletedAlarm});

  @override
  List<Object?> get props => [alarmId, deletedAlarm];
}
