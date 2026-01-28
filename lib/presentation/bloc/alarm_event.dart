import 'package:equatable/equatable.dart';
import '../../domain/entities/alarm.dart';

abstract class AlarmEvent extends Equatable {
  const AlarmEvent();

  @override
  List<Object?> get props => [];
}

class AddAlarmEvent extends AlarmEvent {
  final Alarm alarm;

  const AddAlarmEvent(this.alarm);

  @override
  List<Object?> get props => [alarm];
}

class UpdateAlarmEvent extends AlarmEvent {
  final Alarm alarm;

  const UpdateAlarmEvent(this.alarm);

  @override
  List<Object?> get props => [alarm];
}

class DeleteAlarmEvent extends AlarmEvent {
  final String noteId;
  final String alarmId;

  const DeleteAlarmEvent({required this.noteId, required this.alarmId});

  @override
  List<Object?> get props => [noteId, alarmId];
}

