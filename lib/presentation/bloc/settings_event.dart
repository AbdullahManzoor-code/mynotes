part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {
  const LoadSettingsEvent();
}

class UpdateStorageSettingsEvent extends SettingsEvent {
  final String? storageLocation;
  final bool? autoBackupEnabled;
  final String? backupFrequency;

  const UpdateStorageSettingsEvent({
    this.storageLocation,
    this.autoBackupEnabled,
    this.backupFrequency,
  });

  @override
  List<Object?> get props => [storageLocation, autoBackupEnabled, backupFrequency];
}

class UpdateDefaultSettingsEvent extends SettingsEvent {
  final bool? darkModeEnabled;
  final int? fontSize;
  final String? fontFamily;
  final String? languageCode;

  const UpdateDefaultSettingsEvent({
    this.darkModeEnabled,
    this.fontSize,
    this.fontFamily,
    this.languageCode,
  });

  @override
  List<Object?> get props => [darkModeEnabled, fontSize, fontFamily, languageCode];
}

class UpdateAccessibilitySettingsEvent extends SettingsEvent {
  final bool? accessibilityEnabled;
  final int? fontSize;

  const UpdateAccessibilitySettingsEvent({
    this.accessibilityEnabled,
    this.fontSize,
  });

  @override
  List<Object?> get props => [accessibilityEnabled, fontSize];
}
