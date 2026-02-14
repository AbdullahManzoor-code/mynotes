import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/presentation/bloc/params/theme_params.dart';
import '../../../core/themes/theme.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class LoadThemeEvent extends ThemeEvent {
  const LoadThemeEvent();
}

class UpdateThemeEvent extends ThemeEvent {
  final ThemeParams params;

  const UpdateThemeEvent(this.params);

  factory UpdateThemeEvent.toggleDarkMode(ThemeParams params) {
    return UpdateThemeEvent(params.toggleDarkMode());
  }

  factory UpdateThemeEvent.setDarkMode(ThemeParams params, bool isDarkMode) {
    return UpdateThemeEvent(params.copyWith(isDarkMode: isDarkMode));
  }

  factory UpdateThemeEvent.increaseFontSize(ThemeParams params) {
    return UpdateThemeEvent(params.increaseFontSize());
  }

  factory UpdateThemeEvent.decreaseFontSize(ThemeParams params) {
    return UpdateThemeEvent(params.decreaseFontSize());
  }

  factory UpdateThemeEvent.changeColor(ThemeParams params, Color color) {
    return UpdateThemeEvent(params.copyWith(primaryColor: color));
  }

  @override
  List<Object?> get props => [params];
}

class ChangeThemeVariantEvent extends ThemeEvent {
  final ThemeParams params;
  final AppThemeType themeType;

  const ChangeThemeVariantEvent(this.params, this.themeType);

  @override
  List<Object?> get props => [params, themeType];
}
