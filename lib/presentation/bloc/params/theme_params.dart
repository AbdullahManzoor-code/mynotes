import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Complete Param Model for Theme Operations
/// 📦 Container for all theme-related data
class ThemeParams extends Equatable {
  final Color primaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final bool isDarkMode;
  final double fontSizeMultiplier;
  final String fontFamily;
  final double borderRadius;

  const ThemeParams({
    this.primaryColor = const Color(0xFF6200EE),
    this.accentColor = const Color(0xFF03DAC6),
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.isDarkMode = false,
    this.fontSizeMultiplier = 1.0,
    this.fontFamily = 'Roboto',
    this.borderRadius = 12.0,
  });

  ThemeParams copyWith({
    Color? primaryColor,
    Color? accentColor,
    Color? backgroundColor,
    bool? isDarkMode,
    double? fontSizeMultiplier,
    String? fontFamily,
    double? borderRadius,
  }) {
    return ThemeParams(
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      fontSizeMultiplier: fontSizeMultiplier ?? this.fontSizeMultiplier,
      fontFamily: fontFamily ?? this.fontFamily,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  ThemeParams toggleDarkMode() => copyWith(isDarkMode: !isDarkMode);
  ThemeParams increaseFontSize() =>
      copyWith(fontSizeMultiplier: fontSizeMultiplier + 0.1);
  ThemeParams decreaseFontSize() =>
      copyWith(fontSizeMultiplier: (fontSizeMultiplier - 0.1).clamp(0.8, 1.5));

  /// Calculate actual font size based on multiplier
  double get fontSize => 14.0 * fontSizeMultiplier;

  @override
  List<Object?> get props => [
    primaryColor,
    accentColor,
    backgroundColor,
    isDarkMode,
    fontSizeMultiplier,
    fontFamily,
    borderRadius,
  ];
}
