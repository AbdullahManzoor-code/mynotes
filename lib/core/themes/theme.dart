import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    primarySwatch: Colors.indigo,
    brightness: Brightness.light,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static final ThemeData dark = ThemeData(
    primarySwatch: Colors.indigo,
    brightness: Brightness.dark,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static final ThemeData current = light;
}

extension ThemeExtensions on ThemeData {
  // Helpers for consistent typography or shadows can be added here
}
