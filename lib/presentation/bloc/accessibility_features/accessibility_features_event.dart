part of 'accessibility_features_bloc.dart';

abstract class AccessibilityFeaturesEvent extends Equatable {
  const AccessibilityFeaturesEvent();

  @override
  List<Object?> get props => [];
}

class LoadAccessibilitySettingsEvent extends AccessibilityFeaturesEvent {
  const LoadAccessibilitySettingsEvent();
}

class ToggleKeyboardNavigationEvent extends AccessibilityFeaturesEvent {
  final bool enabled;

  const ToggleKeyboardNavigationEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ToggleReduceMotionEvent extends AccessibilityFeaturesEvent {
  final bool enabled;

  const ToggleReduceMotionEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ToggleHighContrastEvent extends AccessibilityFeaturesEvent {
  final bool enabled;

  const ToggleHighContrastEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ToggleScreenReaderEvent extends AccessibilityFeaturesEvent {
  final bool enabled;

  const ToggleScreenReaderEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}
