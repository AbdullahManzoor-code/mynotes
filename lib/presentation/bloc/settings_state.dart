part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final SettingsParams params;

  const SettingsLoaded(this.params);

  // Backup settings accessors
  bool get autoBackupEnabled => params.cloudSyncEnabled;
  String get backupFrequency => 'weekly'; // Default frequency

  // Default settings accessors
  String get fontFamily => 'Roboto';
  String get languageCode => params.language;
  bool get darkModeEnabled => params.darkModeEnabled;

  // Accessibility settings accessors
  bool get accessibilityEnabled => params.notificationsEnabled;
  double get fontSize => 14.0; // Default size

  @override
  List<Object?> get props => [params];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
