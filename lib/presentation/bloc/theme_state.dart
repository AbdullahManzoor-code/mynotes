import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../core/themes/theme.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final bool isDarkMode;
  final AppThemeType currentTheme;
  final ThemeData themeData;
  final double fontSize;

  const ThemeState({
    this.themeMode = ThemeMode.light,
    this.isDarkMode = false,
    this.currentTheme = AppThemeType.system,
    required this.themeData,
    this.fontSize = 1.0,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? isDarkMode,
    AppThemeType? currentTheme,
    ThemeData? themeData,
    double? fontSize,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currentTheme: currentTheme ?? this.currentTheme,
      themeData: themeData ?? this.themeData,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  @override
  List<Object?> get props => [
    themeMode,
    isDarkMode,
    currentTheme,
    themeData,
    fontSize,
  ];
}
