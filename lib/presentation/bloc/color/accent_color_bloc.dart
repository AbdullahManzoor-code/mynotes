import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'accent_color_event.dart';
part 'accent_color_state.dart';

/// Accent Color Picker BLoC for custom theme color selection
class AccentColorBloc extends Bloc<AccentColorEvent, AccentColorState> {
  static const String _accentColorKey = 'accent_color';
  static const int _defaultAccentColor = 0xFF2196F3; // Material Blue

  static final Map<int, String> _colorNames = {
    0xFFFF6B6B: 'Red',
    0xFFFF8B94: 'Pink',
    0xFFC06C84: 'Rose',
    0xFF6C5B7B: 'Purple',
    0xFF355C7D: 'Navy',
    0xFF2196F3: 'Blue',
    0xFF00BCD4: 'Cyan',
    0xFF4CAF50: 'Green',
    0xFF8BC34A: 'Light Green',
    0xFFCDDC39: 'Lime',
    0xFFFFC107: 'Amber',
    0xFFFF9800: 'Orange',
    0xFFFF5722: 'Deep Orange',
  };

  AccentColorBloc() : super(const AccentColorInitial()) {
    on<LoadAccentColorEvent>(_onLoadAccentColor);
    on<ChangeAccentColorEvent>(_onChangeAccentColor);
    on<ResetAccentColorEvent>(_onResetAccentColor);
  }

  Future<void> _onLoadAccentColor(
    LoadAccentColorEvent event,
    Emitter<AccentColorState> emit,
  ) async {
    try {
      emit(const AccentColorLoading());

      final prefs = await SharedPreferences.getInstance();
      final colorValue = prefs.getInt(_accentColorKey) ?? _defaultAccentColor;
      final colorName = _colorNames[colorValue] ?? 'Blue';

      emit(AccentColorLoaded(colorValue: colorValue, colorName: colorName));
    } catch (e) {
      emit(AccentColorError(e.toString()));
    }
  }

  Future<void> _onChangeAccentColor(
    ChangeAccentColorEvent event,
    Emitter<AccentColorState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_accentColorKey, event.colorValue);

      final colorName = _colorNames[event.colorValue] ?? 'Custom';

      emit(
        AccentColorChanged(colorValue: event.colorValue, colorName: colorName),
      );
    } catch (e) {
      emit(AccentColorError(e.toString()));
    }
  }

  Future<void> _onResetAccentColor(
    ResetAccentColorEvent event,
    Emitter<AccentColorState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accentColorKey);

      const colorName = 'Blue';

      emit(
        const AccentColorLoaded(
          colorValue: _defaultAccentColor,
          colorName: colorName,
        ),
      );
    } catch (e) {
      emit(AccentColorError(e.toString()));
    }
  }

  static List<int> getAvailableColors() => _colorNames.keys.toList();
  static String getColorName(int colorValue) =>
      _colorNames[colorValue] ?? 'Custom';
}
