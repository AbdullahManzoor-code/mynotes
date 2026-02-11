// lib/presentation/bloc/alarm_event.dart

import 'package:equatable/equatable.dart';
import 'params/alarm_params.dart';

/// Base class for all alarm events
abstract class AlarmEvent extends Equatable {
  const AlarmEvent();

  @override
  List<Object?> get props => [];
}

/// 📥 Load all alarms
class LoadAlarmsEvent extends AlarmEvent {
  final String? noteId;
  final bool includeDisabled;

  const LoadAlarmsEvent({this.noteId, this.includeDisabled = true});

  @override
  List<Object?> get props => [noteId, includeDisabled];
}

/// ➕ Add new alarm
class AddAlarmEvent extends AlarmEvent {
  final AlarmParams params;

  const AddAlarmEvent(this.params);

  /// Factory to create from Alarm entity
  factory AddAlarmEvent.fromAlarm(dynamic alarm) {
    return AddAlarmEvent(AlarmParams.fromAlarm(alarm));
  }

  /// Factory to create quick alarm (now + duration)
  factory AddAlarmEvent.quickAlarm({
    required Duration fromNow,
    required String title,
    String description = '',
    String? noteId,
  }) {
    return AddAlarmEvent(
      AlarmParams(
        alarmTime: DateTime.now().add(fromNow),
        title: title,
        description: description,
        noteId: noteId,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  List<Object?> get props => [params];
}

/// ✏️ Update existing alarm
class UpdateAlarmEvent extends AlarmEvent {
  final AlarmParams params;

  const UpdateAlarmEvent(this.params);

  /// Factory to create from Alarm entity
  factory UpdateAlarmEvent.fromAlarm(dynamic alarm) {
    return UpdateAlarmEvent(AlarmParams.fromAlarm(alarm));
  }

  /// Factory to toggle enabled status
  factory UpdateAlarmEvent.toggleEnabled(AlarmParams params) {
    return UpdateAlarmEvent(params.toggleEnabled());
  }

  /// Factory to update time only
  factory UpdateAlarmEvent.updateTime(AlarmParams params, DateTime newTime) {
    return UpdateAlarmEvent(params.withAlarmTime(newTime));
  }

  /// Factory to update description only
  factory UpdateAlarmEvent.updateDescription(
    AlarmParams params,
    String newDescription,
  ) {
    return UpdateAlarmEvent(params.withDescription(newDescription));
  }

  @override
  List<Object?> get props => [params];
}

/// 🗑️ Delete alarm
class DeleteAlarmEvent extends AlarmEvent {
  final String alarmId;
  final String? noteId;

  const DeleteAlarmEvent({required this.alarmId, this.noteId});

  @override
  List<Object?> get props => [alarmId, noteId];
}

/// 🔔 Snooze alarm
class SnoozeAlarmEvent extends AlarmEvent {
  final String alarmId;
  final int snoozeMinutes;

  const SnoozeAlarmEvent({required this.alarmId, this.snoozeMinutes = 5});

  @override
  List<Object?> get props => [alarmId, snoozeMinutes];
}

/// ✅ Mark alarm as triggered/completed
class CompleteAlarmEvent extends AlarmEvent {
  final String alarmId;

  const CompleteAlarmEvent({required this.alarmId});

  @override
  List<Object?> get props => [alarmId];
}

/// 🔄 Toggle alarm enabled status
class ToggleAlarmEvent extends AlarmEvent {
  final String alarmId;
  final bool? isEnabled;

  const ToggleAlarmEvent({required this.alarmId, this.isEnabled});

  @override
  List<Object?> get props => [alarmId, isEnabled];
}

/// 🗑️ Delete all alarms for a note
class DeleteAlarmsForNoteEvent extends AlarmEvent {
  final String noteId;

  const DeleteAlarmsForNoteEvent({required this.noteId});

  @override
  List<Object?> get props => [noteId];
}

/// 🔄 Refresh alarms (force reload)
class RefreshAlarmsEvent extends AlarmEvent {
  const RefreshAlarmsEvent();
}

/// 🔍 Search alarms
class SearchAlarmsEvent extends AlarmEvent {
  final String query;

  const SearchAlarmsEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

/// 📅 Filter alarms by date range
class FilterAlarmsByDateEvent extends AlarmEvent {
  final DateTime startDate;
  final DateTime endDate;

  const FilterAlarmsByDateEvent({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}
