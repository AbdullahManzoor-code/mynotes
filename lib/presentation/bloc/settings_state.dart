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
  final String storageLocation;
  final bool autoBackupEnabled;
  final String backupFrequency;
  final bool darkModeEnabled;
  final double fontSize;
  final String fontFamily;
  final String languageCode;
  final bool accessibilityEnabled;

  const SettingsLoaded({
    required this.storageLocation,
    required this.autoBackupEnabled,
    required this.backupFrequency,
    required this.darkModeEnabled,
    required this.fontSize,
    required this.fontFamily,
    required this.languageCode,
    required this.accessibilityEnabled,
  });

  @override
  List<Object?> get props => [
    storageLocation,
    autoBackupEnabled,
    backupFrequency,
    darkModeEnabled,
    fontSize,
    fontFamily,
    languageCode,
    accessibilityEnabled,
  ];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
