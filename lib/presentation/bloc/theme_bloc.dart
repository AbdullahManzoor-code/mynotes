import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/themes/theme.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'theme_mode';
  static const String _themeVariantKey = 'theme_variant';
  static const String _fontSizeKey = 'font_size';

  ThemeBloc() : super(ThemeState(themeData: AppTheme.light)) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetThemeEvent>(_onSetTheme);
    on<ChangeThemeVariantEvent>(_onChangeThemeVariant);
    on<ChangeFontSizeEvent>(_onChangeFontSize);
  }

  Future<void> _onLoadTheme(
    LoadThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeVariantIndex = prefs.getInt(_themeVariantKey) ?? 0;
      final themeVariant = AppThemeType.values[themeVariantIndex];

      final systemIsDark =
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
      final themeData = AppTheme.getThemeData(themeVariant, systemIsDark);
      final isDark = themeData.brightness == Brightness.dark;

      emit(
        state.copyWith(
          currentTheme: themeVariant,
          themeData: themeData,
          isDarkMode: isDark,
          themeMode: _getThemeMode(themeVariant, systemIsDark),
        ),
      );
    } catch (e) {
      // Default to system theme if error
      emit(
        state.copyWith(
          currentTheme: AppThemeType.system,
          themeData: AppTheme.light,
          isDarkMode: false,
          themeMode: ThemeMode.system,
        ),
      );
    }
  }

  Future<void> _onToggleTheme(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final newTheme = state.isDarkMode ? AppThemeType.light : AppThemeType.dark;
    add(ChangeThemeVariantEvent(newTheme));
  }

  Future<void> _onSetTheme(
    SetThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final newTheme = event.isDarkMode ? AppThemeType.dark : AppThemeType.light;
    add(ChangeThemeVariantEvent(newTheme));
  }

  Future<void> _onChangeThemeVariant(
    ChangeThemeVariantEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final systemIsDark =
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
      final themeData = AppTheme.getThemeData(event.themeType, systemIsDark);
      final isDark = themeData.brightness == Brightness.dark;

      await _saveThemePreference(event.themeType);

      emit(
        state.copyWith(
          currentTheme: event.themeType,
          themeData: themeData,
          isDarkMode: isDark,
          themeMode: _getThemeMode(event.themeType, systemIsDark),
        ),
      );
    } catch (e) {
      // Handle error silently
    }
  }

  ThemeMode _getThemeMode(AppThemeType themeType, bool systemIsDark) {
    switch (themeType) {
      case AppThemeType.system:
        return ThemeMode.system;
      case AppThemeType.light:
        return ThemeMode.light;
      case AppThemeType.dark:
      case AppThemeType.ocean:
      case AppThemeType.forest:
      case AppThemeType.sunset:
      case AppThemeType.midnight:
        return ThemeMode.dark;
    }
  }

  Future<void> _saveThemePreference(AppThemeType themeType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeVariantKey, themeType.index);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _onChangeFontSize(
    ChangeFontSizeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_fontSizeKey, event.fontSize);
      emit(state.copyWith(fontSize: event.fontSize));
    } catch (e) {
      // Handle error silently
    }
  }
}
