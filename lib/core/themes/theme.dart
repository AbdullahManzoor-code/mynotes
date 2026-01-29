import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AppThemeType { system, light, dark, ocean, forest, sunset, midnight }

class AppTheme {
  static const Map<AppThemeType, String> themeNames = {
    AppThemeType.system: 'System',
    AppThemeType.light: 'Light',
    AppThemeType.dark: 'Dark',
    AppThemeType.ocean: 'Ocean',
    AppThemeType.forest: 'Forest',
    AppThemeType.sunset: 'Sunset',
    AppThemeType.midnight: 'Midnight',
  };

  static final ThemeData light = _buildLightTheme();
  static final ThemeData dark = _buildDarkTheme();
  static final ThemeData ocean = _buildOceanTheme();
  static final ThemeData forest = _buildForestTheme();
  static final ThemeData sunset = _buildSunsetTheme();
  static final ThemeData midnight = _buildMidnightTheme();

  static ThemeData getThemeData(AppThemeType themeType, bool systemIsDark) {
    switch (themeType) {
      case AppThemeType.system:
        return systemIsDark ? dark : light;
      case AppThemeType.light:
        return light;
      case AppThemeType.dark:
        return dark;
      case AppThemeType.ocean:
        return ocean;
      case AppThemeType.forest:
        return forest;
      case AppThemeType.sunset:
        return sunset;
      case AppThemeType.midnight:
        return midnight;
    }
  }

  static ThemeData _buildLightTheme() {
    const primaryColor = Color(0xFF6366F1); // Indigo
    const backgroundColor = Color(0xFFFAFAFA);
    const surfaceColor = Color(0xFFFFFFFF);
    const onSurfaceColor = Color(0xFF1F2937);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: onSurfaceColor,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: const CardThemeData(color: surfaceColor, elevation: 2),
    );
  }

  static ThemeData _buildDarkTheme() {
    const primaryColor = Color(0xFF818CF8); // Light Indigo
    const backgroundColor = Color(0xFF0F172A);
    const surfaceColor = Color(0xFF1E293B);
    const onSurfaceColor = Color(0xFFF1F5F9);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: onSurfaceColor,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: const CardThemeData(color: surfaceColor, elevation: 2),
    );
  }

  static ThemeData _buildOceanTheme() {
    const primaryColor = Color(0xFF0EA5E9); // Sky Blue
    const backgroundColor = Color(0xFF0C4A6E);
    const surfaceColor = Color(0xFF075985);
    const onSurfaceColor = Color(0xFFE0F2FE);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: onSurfaceColor,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: const CardThemeData(color: surfaceColor, elevation: 2),
    );
  }

  static ThemeData _buildForestTheme() {
    const primaryColor = Color(0xFF22C55E); // Green
    const backgroundColor = Color(0xFF14532D);
    const surfaceColor = Color(0xFF166534);
    const onSurfaceColor = Color(0xFFDCFCE7);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: onSurfaceColor,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: const CardThemeData(color: surfaceColor, elevation: 2),
    );
  }

  static ThemeData _buildSunsetTheme() {
    const primaryColor = Color(0xFFF59E0B); // Amber
    const backgroundColor = Color(0xFF92400E);
    const surfaceColor = Color(0xFFA16207);
    const onSurfaceColor = Color(0xFFFEF3C7);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: onSurfaceColor,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: const CardThemeData(color: surfaceColor, elevation: 2),
    );
  }

  static ThemeData _buildMidnightTheme() {
    const primaryColor = Color(0xFF8B5CF6); // Violet
    const backgroundColor = Color(0xFF000000);
    const surfaceColor = Color(0xFF1C1C1E);
    const onSurfaceColor = Color(0xFFF2F2F7);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: onSurfaceColor,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: const CardThemeData(color: surfaceColor, elevation: 2),
    );
  }
}

extension ThemeExtensions on ThemeData {
  bool get isDark => brightness == Brightness.dark;

  Color get primaryContainer => colorScheme.primaryContainer;
  Color get onPrimaryContainer => colorScheme.onPrimaryContainer;
  Color get secondaryContainer => colorScheme.secondaryContainer;
  Color get onSecondaryContainer => colorScheme.onSecondaryContainer;
}
