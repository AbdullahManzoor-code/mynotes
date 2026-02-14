import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mynotes/injection_container.dart';
import 'package:mynotes/presentation/bloc/params/settings_params.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/biometric_auth_service.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/services/theme_customization_service.dart';
import '../../../domain/repositories/stats_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  static const String _notificationsKey = 'notifications_enabled';
  static const String _soundKey = 'sound_enabled';
  static const String _vibrationKey = 'vibration_enabled';
  static const String _darkModeKey = 'dark_mode_enabled';
  static const String _fontSizeKey = 'font_size_preference';
  static const String _languageKey = 'language_code';
  static const String _cloudSyncKey = 'cloud_sync_enabled';
  static const String _ledEnabledKey = 'led_enabled';
  static const String _quietHoursEnabledKey = 'quiet_hours_enabled';
  static const String _quietHoursStartKey = 'quiet_hours_start';
  static const String _quietHoursEndKey = 'quiet_hours_end';
  static const String _useCustomColorsKey = 'use_custom_colors';
  static const String _fontFamilyKey = 'font_family';
  static const String _fontScaleKey = 'font_scale';

  final BiometricAuthService _biometricService = BiometricAuthService();

  final SettingsService _settingsService = SettingsService();

  SettingsBloc() : super(const SettingsInitial()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<UpdateSettingsEvent>(_onUpdateSettings);
    on<UpdateLanguageEvent>(_onUpdateLanguage);
    on<RefreshStatsEvent>(_onRefreshStats);
    on<ToggleBiometricEvent>(_onToggleBiometric);
  }

  Future<void> _onToggleBiometric(
    ToggleBiometricEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentParams = (state as SettingsLoaded).params;
      try {
        if (event.enable) {
          final authenticated = await _biometricService.authenticate(
            reason: 'Verify your identity to enable biometric lock',
          );
          if (authenticated) {
            await _biometricService.enableBiometric();
            emit(
              SettingsLoaded(currentParams.copyWith(biometricEnabled: true)),
            );
          }
        } else {
          await _biometricService.disableBiometric();
          emit(SettingsLoaded(currentParams.copyWith(biometricEnabled: false)));
        }
      } catch (e) {
        // We could emit an error state, but usually a snackbar is enough
        // handled in UI via side-effects or here if we have a way
      }
    }
  }

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      final prefs = await SharedPreferences.getInstance();

      final biometricAvailable = await _biometricService.isBiometricAvailable();
      final biometricEnabled = await _biometricService.isBiometricEnabled();

      final counts = await getIt<StatsRepository>().getItemCounts();
      final stats = await BackupService.getBackupStats();

      final params = SettingsParams(
        notificationsEnabled: prefs.getBool(_notificationsKey) ?? true,
        soundEnabled: prefs.getBool(_soundKey) ?? true,
        vibrationEnabled: prefs.getBool(_vibrationKey) ?? true,
        darkModeEnabled: prefs.getBool(_darkModeKey) ?? false,
        fontSizePreference: prefs.getString(_fontSizeKey) ?? 'medium',
        language: prefs.getString(_languageKey) ?? 'en',
        cloudSyncEnabled: prefs.getBool(_cloudSyncKey) ?? false,
        ledEnabled: prefs.getBool(_ledEnabledKey) ?? true,
        quietHoursEnabled: prefs.getBool(_quietHoursEnabledKey) ?? false,
        quietHoursStart: prefs.getString(_quietHoursStartKey) ?? '22:00',
        quietHoursEnd: prefs.getString(_quietHoursEndKey) ?? '08:00',
        biometricEnabled: biometricEnabled,
        biometricAvailable: biometricAvailable,
        useCustomColors: prefs.getBool(_useCustomColorsKey) ?? false,
        storageUsed: (stats['totalSize'] ?? '0 MB') as String,
        mediaCount: counts['media'] ?? 0,
        noteCount: counts['notes'] ?? 0,
        fontFamily: prefs.getString(_fontFamilyKey) ?? 'System Default',
        fontScale: prefs.getDouble(_fontScaleKey) ?? 1.0,
      );

      emit(SettingsLoaded(params));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateSettings(
    UpdateSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final params = event.params;

      await prefs.setBool(_notificationsKey, params.notificationsEnabled);
      await prefs.setBool(_soundKey, params.soundEnabled);
      await prefs.setBool(_vibrationKey, params.vibrationEnabled);
      await prefs.setBool(_darkModeKey, params.darkModeEnabled);
      await prefs.setString(_fontSizeKey, params.fontSizePreference);
      await prefs.setBool(_cloudSyncKey, params.cloudSyncEnabled);
      await prefs.setBool(_ledEnabledKey, params.ledEnabled);
      await prefs.setBool(_quietHoursEnabledKey, params.quietHoursEnabled);
      await prefs.setString(_quietHoursStartKey, params.quietHoursStart);
      await prefs.setString(_quietHoursEndKey, params.quietHoursEnd);
      await prefs.setBool(_useCustomColorsKey, params.useCustomColors);
      await prefs.setString(_fontFamilyKey, params.fontFamily);
      await prefs.setDouble(_fontScaleKey, params.fontScale);

      if (params.biometricEnabled !=
          (state as SettingsLoaded).params.biometricEnabled) {
        if (params.biometricEnabled) {
          await _biometricService.enableBiometric();
        } else {
          await _biometricService.disableBiometric();
        }
      }

      emit(SettingsLoaded(params));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateLanguage(
    UpdateLanguageEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final params = event.params;

      await prefs.setString(_languageKey, params.language);

      emit(SettingsLoaded(params));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onRefreshStats(
    RefreshStatsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentParams = (state as SettingsLoaded).params;
      try {
        final counts = await getIt<StatsRepository>().getItemCounts();
        final stats = await BackupService.getBackupStats();

        final newParams = currentParams.copyWith(
          storageUsed: (stats['totalSize'] ?? '0 MB') as String,
          mediaCount: counts['media'] ?? 0,
          noteCount: counts['notes'] ?? 0,
        );
        emit(SettingsLoaded(newParams));
      } catch (e) {
        // Just log or ignore for now
      }
    }
  }
}
