import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'accessibility_features_event.dart';
part 'accessibility_features_state.dart';

/// Accessibility Features BLoC
/// Manages keyboard navigation and reduce motion settings
class AccessibilityFeaturesBloc
    extends Bloc<AccessibilityFeaturesEvent, AccessibilityFeaturesState> {
  static const String _keyboardNavKey = 'a11y_keyboard_nav';
  static const String _reduceMotionKey = 'a11y_reduce_motion';
  static const String _highContrastKey = 'a11y_high_contrast';
  static const String _screenReaderKey = 'a11y_screen_reader';

  AccessibilityFeaturesBloc() : super(const AccessibilityFeaturesInitial()) {
    on<LoadAccessibilitySettingsEvent>(_onLoadSettings);
    on<ToggleKeyboardNavigationEvent>(_onToggleKeyboardNav);
    on<ToggleReduceMotionEvent>(_onToggleReduceMotion);
    on<ToggleHighContrastEvent>(_onToggleHighContrast);
    on<ToggleScreenReaderEvent>(_onToggleScreenReader);
  }

  Future<void> _onLoadSettings(
    LoadAccessibilitySettingsEvent event,
    Emitter<AccessibilityFeaturesState> emit,
  ) async {
    try {
      emit(const AccessibilityFeaturesLoading());

      final prefs = await SharedPreferences.getInstance();

      final keyboardNavEnabled = prefs.getBool(_keyboardNavKey) ?? false;
      final reduceMotionEnabled = prefs.getBool(_reduceMotionKey) ?? false;
      final highContrastEnabled = prefs.getBool(_highContrastKey) ?? false;
      final screenReaderEnabled = prefs.getBool(_screenReaderKey) ?? false;

      emit(
        AccessibilitySettingsLoaded(
          keyboardNavigationEnabled: keyboardNavEnabled,
          reduceMotionEnabled: reduceMotionEnabled,
          highContrastEnabled: highContrastEnabled,
          screenReaderEnabled: screenReaderEnabled,
        ),
      );
    } catch (e) {
      emit(AccessibilityFeaturesError(e.toString()));
    }
  }

  Future<void> _onToggleKeyboardNav(
    ToggleKeyboardNavigationEvent event,
    Emitter<AccessibilityFeaturesState> emit,
  ) async {
    try {
      emit(const AccessibilityFeaturesLoading());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyboardNavKey, event.enabled);

      emit(KeyboardNavigationToggled(enabled: event.enabled));
    } catch (e) {
      emit(AccessibilityFeaturesError(e.toString()));
    }
  }

  Future<void> _onToggleReduceMotion(
    ToggleReduceMotionEvent event,
    Emitter<AccessibilityFeaturesState> emit,
  ) async {
    try {
      emit(const AccessibilityFeaturesLoading());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_reduceMotionKey, event.enabled);

      emit(ReduceMotionToggled(enabled: event.enabled));
    } catch (e) {
      emit(AccessibilityFeaturesError(e.toString()));
    }
  }

  Future<void> _onToggleHighContrast(
    ToggleHighContrastEvent event,
    Emitter<AccessibilityFeaturesState> emit,
  ) async {
    try {
      emit(const AccessibilityFeaturesLoading());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_highContrastKey, event.enabled);

      emit(HighContrastToggled(enabled: event.enabled));
    } catch (e) {
      emit(AccessibilityFeaturesError(e.toString()));
    }
  }

  Future<void> _onToggleScreenReader(
    ToggleScreenReaderEvent event,
    Emitter<AccessibilityFeaturesState> emit,
  ) async {
    try {
      emit(const AccessibilityFeaturesLoading());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_screenReaderKey, event.enabled);

      emit(ScreenReaderToggled(enabled: event.enabled));
    } catch (e) {
      emit(AccessibilityFeaturesError(e.toString()));
    }
  }
}
