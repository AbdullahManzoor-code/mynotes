// lib/presentation/bloc/alarm_event.dart

import 'package:equatable/equatable.dart';
import 'package:mynotes/presentation/bloc/params/alarm_params.dart';

/// Base class for all alarm events
abstract class AlarmEvent extends Equatable {
  const AlarmEvent();

  @override
  List<Object?> get props => [];
}

/// 📥 Load all alarms
class LoadAlarms extends LoadAlarmsEvent {
  const LoadAlarms({super.noteId, super.includeDisabled});
}

class LoadAlarmsEvent extends AlarmEvent {
  final String? noteId;
  final bool includeDisabled;

  const LoadAlarmsEvent({this.noteId, this.includeDisabled = true});

  @override
  List<Object?> get props => [noteId, includeDisabled];
}

/// ➕ Add new alarm
class AddAlarm extends AddAlarmEvent {
  AddAlarm(dynamic alarm) : super(AlarmParams.fromAlarm(alarm));
}

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

/// 📝 Update draft alarm (for form state)
class UpdateAlarmDraftEvent extends AlarmEvent {
  final AlarmParams? params;
  final bool clear;

  const UpdateAlarmDraftEvent({this.params, this.clear = false});

  @override
  List<Object?> get props => [params, clear];
}

class UpdateAlarmUiConfigEvent extends AlarmEvent {
  final String? searchQuery;
  final bool? showFab;

  const UpdateAlarmUiConfigEvent({this.searchQuery, this.showFab});

  @override
  List<Object?> get props => [searchQuery, showFab];
}

class StartPeriodicRefreshEvent extends AlarmEvent {
  const StartPeriodicRefreshEvent();
}

class StopPeriodicRefreshEvent extends AlarmEvent {
  const StopPeriodicRefreshEvent();
}

/// ✏️ Update existing alarm
class UpdateAlarm extends UpdateAlarmEvent {
  UpdateAlarm(dynamic alarm) : super(AlarmParams.fromAlarm(alarm));
}

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
class DeleteAlarm extends DeleteAlarmEvent {
  const DeleteAlarm(String id, {required super.alarmId});
}

class DeleteAlarmEvent extends AlarmEvent {
  final String alarmId;
  final String? noteId;

  const DeleteAlarmEvent({required this.alarmId, this.noteId});

  @override
  List<Object?> get props => [alarmId, noteId];
}

/// 🔔 Snooze alarm
class SnoozeAlarm extends SnoozeAlarmEvent {
  const SnoozeAlarm({required super.alarmId, super.snoozeMinutes});
}

class SnoozeAlarmEvent extends AlarmEvent {
  final String alarmId;
  final int snoozeMinutes;

  const SnoozeAlarmEvent({required this.alarmId, this.snoozeMinutes = 5});

  @override
  List<Object?> get props => [alarmId, snoozeMinutes];
}

/// ✅ Mark alarm as triggered/completed
class CompleteAlarm extends CompleteAlarmEvent {
  const CompleteAlarm({required super.alarmId});
}

class MarkAlarmCompleted extends CompleteAlarmEvent {
  const MarkAlarmCompleted(String alarmId) : super(alarmId: alarmId);
}

class CompleteAlarmEvent extends AlarmEvent {
  final String alarmId;

  const CompleteAlarmEvent({required this.alarmId});

  @override
  List<Object?> get props => [alarmId];
}

/// 🔄 Toggle alarm enabled status
class ToggleAlarm extends ToggleAlarmEvent {
  const ToggleAlarm({required super.alarmId, super.isEnabled});
}

class ToggleAlarmEvent extends AlarmEvent {
  final String alarmId;
  final bool? isEnabled;

  const ToggleAlarmEvent({required this.alarmId, this.isEnabled});

  @override
  List<Object?> get props => [alarmId, isEnabled];
}

/// 🗑️ Delete all alarms for a note
class DeleteAlarmsForNote extends DeleteAlarmsForNoteEvent {
  const DeleteAlarmsForNote({required super.noteId});
}

class DeleteAlarmsForNoteEvent extends AlarmEvent {
  final String noteId;

  const DeleteAlarmsForNoteEvent({required this.noteId});

  @override
  List<Object?> get props => [noteId];
}

/// 🔄 Refresh alarms (force reload)
class RefreshAlarms extends RefreshAlarmsEvent {
  const RefreshAlarms();
}

class RefreshAlarmsEvent extends AlarmEvent {
  const RefreshAlarmsEvent();
}

/// 🔍 Search alarms
class SearchAlarms extends SearchAlarmsEvent {
  const SearchAlarms({required super.query});
}

class SearchAlarmsEvent extends AlarmEvent {
  final String query;

  const SearchAlarmsEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

/// 📅 Filter alarms by date range
class FilterAlarms extends AlarmEvent {
  final String filter;
  const FilterAlarms(this.filter);
}

/// 🧹 Clear all completed alarms
class ClearCompletedAlarms extends ClearCompletedAlarmsEvent {}

class ClearCompletedAlarmsEvent extends AlarmEvent {}

/// 📅 Reschedule alarm
class RescheduleAlarm extends RescheduleAlarmEvent {
  const RescheduleAlarm({required super.alarmId, required super.newTime});
}

class RescheduleAlarmEvent extends AlarmEvent {
  final String alarmId;
  final DateTime newTime;
  const RescheduleAlarmEvent({required this.alarmId, required this.newTime});

  @override
  List<Object?> get props => [alarmId, newTime];
}

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

/// 🔇 Dismiss/Stop alarm (stop sound and vibration)
class DismissAlarmEvent extends AlarmEvent {
  final String alarmId;

  const DismissAlarmEvent({required this.alarmId});

  @override
  List<Object?> get props => [alarmId];
}
