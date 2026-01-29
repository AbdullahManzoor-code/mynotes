import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  static const String _storageLocationKey = 'storage_location';
  static const String _autoBackupKey = 'auto_backup_enabled';
  static const String _backupFrequencyKey = 'backup_frequency';
  static const String _darkModeKey = 'dark_mode_enabled';
  static const String _fontSizeKey = 'font_size';
  static const String _fontFamilyKey = 'font_family';
  static const String _languageKey = 'language_code';
  static const String _accessibilityKey = 'accessibility_enabled';

  SettingsBloc() : super(SettingsInitial()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<UpdateStorageSettingsEvent>(_onUpdateStorageSettings);
    on<UpdateDefaultSettingsEvent>(_onUpdateDefaultSettings);
    on<UpdateAccessibilitySettingsEvent>(_onUpdateAccessibilitySettings);
  }

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final prefs = await SharedPreferences.getInstance();

      emit(
        SettingsLoaded(
          storageLocation:
              prefs.getString(_storageLocationKey) ?? '/storage/notes',
          autoBackupEnabled: prefs.getBool(_autoBackupKey) ?? true,
          backupFrequency: prefs.getString(_backupFrequencyKey) ?? 'daily',
          darkModeEnabled: prefs.getBool(_darkModeKey) ?? false,
          fontSize: prefs.getDouble(_fontSizeKey) ?? 1.0,
          fontFamily: prefs.getString(_fontFamilyKey) ?? 'Roboto',
          languageCode: prefs.getString(_languageKey) ?? 'en',
          accessibilityEnabled: prefs.getBool(_accessibilityKey) ?? false,
        ),
      );
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateStorageSettings(
    UpdateStorageSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final current = state as SettingsLoaded;
      try {
        final prefs = await SharedPreferences.getInstance();

        final newLocation = event.storageLocation ?? current.storageLocation;
        final newAutoBackup =
            event.autoBackupEnabled ?? current.autoBackupEnabled;
        final newFrequency = event.backupFrequency ?? current.backupFrequency;

        await prefs.setString(_storageLocationKey, newLocation);
        await prefs.setBool(_autoBackupKey, newAutoBackup);
        await prefs.setString(_backupFrequencyKey, newFrequency);

        emit(
          SettingsLoaded(
            storageLocation: newLocation,
            autoBackupEnabled: newAutoBackup,
            backupFrequency: newFrequency,
            darkModeEnabled: current.darkModeEnabled,
            fontSize: current.fontSize,
            fontFamily: current.fontFamily,
            languageCode: current.languageCode,
            accessibilityEnabled: current.accessibilityEnabled,
          ),
        );
      } catch (e) {
        emit(SettingsError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateDefaultSettings(
    UpdateDefaultSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final current = state as SettingsLoaded;
      try {
        final prefs = await SharedPreferences.getInstance();

        final newDarkMode = event.darkModeEnabled ?? current.darkModeEnabled;
        final newFontSize = event.fontSize != null
            ? (event.fontSize!.toDouble())
            : current.fontSize;
        final newFontFamily = event.fontFamily ?? current.fontFamily;
        final newLanguage = event.languageCode ?? current.languageCode;

        await prefs.setBool(_darkModeKey, newDarkMode);
        await prefs.setDouble(_fontSizeKey, newFontSize);
        await prefs.setString(_fontFamilyKey, newFontFamily);
        await prefs.setString(_languageKey, newLanguage);

        emit(
          SettingsLoaded(
            storageLocation: current.storageLocation,
            autoBackupEnabled: current.autoBackupEnabled,
            backupFrequency: current.backupFrequency,
            darkModeEnabled: newDarkMode,
            fontSize: newFontSize,
            fontFamily: newFontFamily,
            languageCode: newLanguage,
            accessibilityEnabled: current.accessibilityEnabled,
          ),
        );
      } catch (e) {
        emit(SettingsError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateAccessibilitySettings(
    UpdateAccessibilitySettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final current = state as SettingsLoaded;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(
          _accessibilityKey,
          event.accessibilityEnabled ?? current.accessibilityEnabled,
        );
        final newFontSize = event.fontSize != null
            ? (event.fontSize!.toDouble())
            : current.fontSize;
        emit(
          SettingsLoaded(
            storageLocation: current.storageLocation,
            autoBackupEnabled: current.autoBackupEnabled,
            backupFrequency: current.backupFrequency,
            darkModeEnabled: current.darkModeEnabled,
            fontSize: newFontSize,
            fontFamily: current.fontFamily,
            languageCode: current.languageCode,
            accessibilityEnabled:
                event.accessibilityEnabled ?? current.accessibilityEnabled,
          ),
        );
      } catch (e) {
        emit(SettingsError(e.toString()));
      }
    }
  }
}
