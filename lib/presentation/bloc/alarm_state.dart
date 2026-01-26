import 'package:equatable/equatable.dart';

abstract class AlarmState extends Equatable {
  const AlarmState();

  @override
  List<Object?> get props => [];
}

class AlarmInitial extends AlarmState {
  const AlarmInitial();
}

class AlarmLoading extends AlarmState {
  const AlarmLoading();
}

class AlarmSuccess extends AlarmState {
  final String message;

  const AlarmSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AlarmError extends AlarmState {
  final String message;

  const AlarmError(this.message);

  @override
  List<Object?> get props => [message];
}
