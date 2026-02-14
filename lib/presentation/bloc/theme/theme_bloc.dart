import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/params/theme_params.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _darkModeKey = 'dark_mode_enabled';
  static const String _fontSizeKey = 'font_size';

  ThemeBloc() : super(ThemeState(params: const ThemeParams())) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<UpdateThemeEvent>(_onUpdateTheme);
    on<ChangeThemeVariantEvent>(_onChangeThemeVariant);
  }

  Future<void> _onLoadTheme(
    LoadThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDarkMode = prefs.getBool(_darkModeKey) ?? false;
      final fontSizeMultiplier = prefs.getDouble(_fontSizeKey) ?? 1.0;

      final params = ThemeParams(
        isDarkMode: isDarkMode,
        fontSizeMultiplier: fontSizeMultiplier,
      );

      emit(ThemeState(params: params));
    } catch (e) {
      emit(ThemeState(params: const ThemeParams()));
    }
  }

  Future<void> _onUpdateTheme(
    UpdateThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final params = event.params;

      await prefs.setBool(_darkModeKey, params.isDarkMode);
      await prefs.setDouble(_fontSizeKey, params.fontSizeMultiplier);

      emit(ThemeState(params: params));
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _onChangeThemeVariant(
    ChangeThemeVariantEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final params = event.params;

      await prefs.setBool(_darkModeKey, params.isDarkMode);

      emit(ThemeState(params: params));
    } catch (e) {
      // Handle error silently
    }
  }
}
