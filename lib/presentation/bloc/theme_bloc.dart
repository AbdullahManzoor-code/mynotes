import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'theme_mode';

  ThemeBloc() : super(const ThemeState()) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetThemeEvent>(_onSetTheme);
  }

  Future<void> _onLoadTheme(
    LoadThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey) ?? false;
      emit(
        state.copyWith(
          isDarkMode: isDark,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        ),
      );
    } catch (e) {
      // If there's an error loading theme, default to light mode
      emit(state.copyWith(isDarkMode: false, themeMode: ThemeMode.light));
    }
  }

  Future<void> _onToggleTheme(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final newIsDark = !state.isDarkMode;
    await _saveThemePreference(newIsDark);
    emit(
      state.copyWith(
        isDarkMode: newIsDark,
        themeMode: newIsDark ? ThemeMode.dark : ThemeMode.light,
      ),
    );
  }

  Future<void> _onSetTheme(
    SetThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    await _saveThemePreference(event.isDarkMode);
    emit(
      state.copyWith(
        isDarkMode: event.isDarkMode,
        themeMode: event.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      ),
    );
  }

  Future<void> _saveThemePreference(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, isDark);
    } catch (e) {
      // Handle error silently
    }
  }
}
