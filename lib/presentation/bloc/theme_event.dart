import 'package:equatable/equatable.dart';
import '../../core/themes/theme.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ToggleThemeEvent extends ThemeEvent {
  const ToggleThemeEvent();
}

class SetThemeEvent extends ThemeEvent {
  final bool isDarkMode;

  const SetThemeEvent(this.isDarkMode);

  @override
  List<Object?> get props => [isDarkMode];
}

class LoadThemeEvent extends ThemeEvent {
  const LoadThemeEvent();
}

class ChangeThemeVariantEvent extends ThemeEvent {
  final AppThemeType themeType;

  const ChangeThemeVariantEvent(this.themeType);

  @override
  List<Object?> get props => [themeType];
}

class ChangeFontSizeEvent extends ThemeEvent {
  final double fontSize;

  const ChangeFontSizeEvent(this.fontSize);

  @override
  List<Object?> get props => [fontSize];
}
