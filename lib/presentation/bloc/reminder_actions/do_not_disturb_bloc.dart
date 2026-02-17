import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/domain/models/do_not_disturb_settings.dart';

abstract class DoNotDisturbEvent extends Equatable {
  const DoNotDisturbEvent();

  @override
  List<Object?> get props => [];
}

class InitializeDoNotDisturb extends DoNotDisturbEvent {
  final DoNotDisturbSettings settings;

  const InitializeDoNotDisturb(this.settings);

  @override
  List<Object?> get props => [settings];
}

class ToggleDoNotDisturbEnabled extends DoNotDisturbEvent {
  final bool enabled;

  const ToggleDoNotDisturbEnabled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateDoNotDisturbStartTime extends DoNotDisturbEvent {
  final TimeOfDay time;

  const UpdateDoNotDisturbStartTime(this.time);

  @override
  List<Object?> get props => [time];
}

class UpdateDoNotDisturbEndTime extends DoNotDisturbEvent {
  final TimeOfDay time;

  const UpdateDoNotDisturbEndTime(this.time);

  @override
  List<Object?> get props => [time];
}

class ToggleDoNotDisturbUrgent extends DoNotDisturbEvent {
  final bool allowUrgent;

  const ToggleDoNotDisturbUrgent(this.allowUrgent);

  @override
  List<Object?> get props => [allowUrgent];
}

class DoNotDisturbBloc extends Bloc<DoNotDisturbEvent, DoNotDisturbSettings> {
  DoNotDisturbBloc(super.settings) {
    on<InitializeDoNotDisturb>(_onInitialize);
    on<ToggleDoNotDisturbEnabled>(_onToggleEnabled);
    on<UpdateDoNotDisturbStartTime>(_onUpdateStartTime);
    on<UpdateDoNotDisturbEndTime>(_onUpdateEndTime);
    on<ToggleDoNotDisturbUrgent>(_onToggleUrgent);
  }

  void _onInitialize(
    InitializeDoNotDisturb event,
    Emitter<DoNotDisturbSettings> emit,
  ) {
    emit(event.settings);
  }

  void _onToggleEnabled(
    ToggleDoNotDisturbEnabled event,
    Emitter<DoNotDisturbSettings> emit,
  ) {
    emit(state.copyWith(enabled: event.enabled));
  }

  void _onUpdateStartTime(
    UpdateDoNotDisturbStartTime event,
    Emitter<DoNotDisturbSettings> emit,
  ) {
    emit(state.copyWith(startTime: event.time));
  }

  void _onUpdateEndTime(
    UpdateDoNotDisturbEndTime event,
    Emitter<DoNotDisturbSettings> emit,
  ) {
    emit(state.copyWith(endTime: event.time));
  }

  void _onToggleUrgent(
    ToggleDoNotDisturbUrgent event,
    Emitter<DoNotDisturbSettings> emit,
  ) {
    emit(state.copyWith(allowUrgent: event.allowUrgent));
  }
}
