part of 'accessibility_features_bloc.dart';

abstract class AccessibilityFeaturesState extends Equatable {
  const AccessibilityFeaturesState();

  @override
  List<Object?> get props => [];
}

class AccessibilityFeaturesInitial extends AccessibilityFeaturesState {
  const AccessibilityFeaturesInitial();
}

class AccessibilityFeaturesLoading extends AccessibilityFeaturesState {
  const AccessibilityFeaturesLoading();
}

class AccessibilitySettingsLoaded extends AccessibilityFeaturesState {
  final bool keyboardNavigationEnabled;
  final bool reduceMotionEnabled;
  final bool highContrastEnabled;
  final bool screenReaderEnabled;

  const AccessibilitySettingsLoaded({
    required this.keyboardNavigationEnabled,
    required this.reduceMotionEnabled,
    required this.highContrastEnabled,
    required this.screenReaderEnabled,
  });

  @override
  List<Object?> get props => [
    keyboardNavigationEnabled,
    reduceMotionEnabled,
    highContrastEnabled,
    screenReaderEnabled,
  ];
}

class KeyboardNavigationToggled extends AccessibilityFeaturesState {
  final bool enabled;

  const KeyboardNavigationToggled({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

class ReduceMotionToggled extends AccessibilityFeaturesState {
  final bool enabled;

  const ReduceMotionToggled({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

class HighContrastToggled extends AccessibilityFeaturesState {
  final bool enabled;

  const HighContrastToggled({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

class ScreenReaderToggled extends AccessibilityFeaturesState {
  final bool enabled;

  const ScreenReaderToggled({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

class AccessibilityFeaturesError extends AccessibilityFeaturesState {
  final String message;

  const AccessibilityFeaturesError(this.message);

  @override
  List<Object?> get props => [message];
}
