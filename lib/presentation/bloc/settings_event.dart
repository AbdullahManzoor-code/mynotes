part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {
  const LoadSettingsEvent();
}

class UpdateSettingsEvent extends SettingsEvent {
  final SettingsParams params;

  const UpdateSettingsEvent(this.params);

  factory UpdateSettingsEvent.toggleNotifications(SettingsParams params) {
    return UpdateSettingsEvent(params.toggleNotifications());
  }

  factory UpdateSettingsEvent.toggleSound(SettingsParams params) {
    return UpdateSettingsEvent(params.toggleSound());
  }

  factory UpdateSettingsEvent.toggleVibration(SettingsParams params) {
    return UpdateSettingsEvent(params.toggleVibration());
  }

  factory UpdateSettingsEvent.toggleDarkMode(SettingsParams params) {
    return UpdateSettingsEvent(params.toggleDarkMode());
  }

  factory UpdateSettingsEvent.toggleAutoSave(SettingsParams params) {
    return UpdateSettingsEvent(params.toggleAutoSave());
  }

  factory UpdateSettingsEvent.toggleCloudSync(SettingsParams params) {
    return UpdateSettingsEvent(params.toggleCloudSync());
  }

  @override
  List<Object?> get props => [params];
}

class UpdateLanguageEvent extends SettingsEvent {
  final SettingsParams params;

  const UpdateLanguageEvent(this.params);

  @override
  List<Object?> get props => [params];
}

class RefreshStatsEvent extends SettingsEvent {
  const RefreshStatsEvent();

  @override
  List<Object?> get props => [];
}

class ToggleBiometricEvent extends SettingsEvent {
  final bool enable;
  const ToggleBiometricEvent(this.enable);

  @override
  List<Object?> get props => [enable];
}
