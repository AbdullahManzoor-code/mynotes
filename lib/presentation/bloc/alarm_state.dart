import 'package:equatable/equatable.dart';
import '../../core/exceptions/app_exceptions.dart';

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
  final dynamic result;

  const AlarmSuccess(this.message, {this.result});

  @override
  List<Object?> get props => [message, result];
}

class AlarmError extends AlarmState {
  final String message;
  final String? code;
  final AppException? exception;

  const AlarmError(this.message, {this.code, this.exception});

  @override
  List<Object?> get props => [message, code, exception];
}

class AlarmValidationError extends AlarmState {
  final String message;
  final String field;

  const AlarmValidationError(this.message, {required this.field});

  @override
  List<Object?> get props => [message, field];
}
