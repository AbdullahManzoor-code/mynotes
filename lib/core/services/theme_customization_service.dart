import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Custom App Themes
enum AppThemeType {
  system,
  light,
  dark,
  ocean,
  forest,
  sunset,
  midnight;

  String get displayName {
    switch (this) {
      case AppThemeType.system:
        return 'System Default';
      case AppThemeType.light:
        return 'Light';
      case AppThemeType.dark:
        return 'Dark';
      case AppThemeType.ocean:
        return 'Ocean Blue';
      case AppThemeType.forest:
        return 'Forest Green';
      case AppThemeType.sunset:
        return 'Sunset Orange';
      case AppThemeType.midnight:
        return 'Midnight Purple';
    }
  }

  String get icon {
    switch (this) {
      case AppThemeType.system:
        return '⚙️';
      case AppThemeType.light:
        return '☀️';
      case AppThemeType.dark:
        return '🌙';
      case AppThemeType.ocean:
        return '🌊';
      case AppThemeType.forest:
        return '🌲';
      case AppThemeType.sunset:
        return '🌅';
      case AppThemeType.midnight:
        return '🌌';
    }
  }
}

/// App Font
enum AppFont {
  system,
  roboto,
  openSans,
  lato,
  montserrat,
  poppins;

  String get displayName {
    switch (this) {
      case AppFont.system:
        return 'System Default';
      case AppFont.roboto:
        return 'Roboto';
      case AppFont.openSans:
        return 'Open Sans';
      case AppFont.lato:
        return 'Lato';
      case AppFont.montserrat:
        return 'Montserrat';
      case AppFont.poppins:
        return 'Poppins';
    }
  }

  String? get fontFamily {
    switch (this) {
      case AppFont.system:
        return null;
      case AppFont.roboto:
        return 'Roboto';
      case AppFont.openSans:
        return 'OpenSans';
      case AppFont.lato:
        return 'Lato';
      case AppFont.montserrat:
        return 'Montserrat';
      case AppFont.poppins:
        return 'Poppins';
    }
  }
}

/// Theme Customization Service
class ThemeCustomizationService {
  static const String _themeKey = 'app_theme_type';
  static const String _fontKey = 'app_font';
  static const String _fontSizeKey = 'app_font_size';

  /// Get current theme type
  Future<AppThemeType> getThemeType() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    return AppThemeType.values[themeIndex];
  }

  /// Set theme type
  Future<void> setThemeType(AppThemeType theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);
  }

  /// Get current font
  Future<AppFont> getFont() async {
    final prefs = await SharedPreferences.getInstance();
    final fontIndex = prefs.getInt(_fontKey) ?? 0;
    return AppFont.values[fontIndex];
  }

  /// Set font
  Future<void> setFont(AppFont font) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_fontKey, font.index);
  }

  /// Get font size multiplier
  Future<double> getFontSizeMultiplier() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontSizeKey) ?? 1.0;
  }

  /// Set font size multiplier
  Future<void> setFontSizeMultiplier(double multiplier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, multiplier);
  }

  /// Get theme data based on type
  ThemeData getThemeData(AppThemeType themeType, AppFont font) {
    switch (themeType) {
      case AppThemeType.light:
        return _lightTheme(font);
      case AppThemeType.dark:
        return _darkTheme(font);
      case AppThemeType.ocean:
        return _oceanTheme(font);
      case AppThemeType.forest:
        return _forestTheme(font);
      case AppThemeType.sunset:
        return _sunsetTheme(font);
      case AppThemeType.midnight:
        return _midnightTheme(font);
      default:
        return _lightTheme(font);
    }
  }

  ThemeData _lightTheme(AppFont font) {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.grey[50],
      fontFamily: font.fontFamily,
      cardTheme: const CardThemeData(elevation: 2),
    );
  }

  ThemeData _darkTheme(AppFont font) {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFF121212),
      fontFamily: font.fontFamily,
      cardTheme: const CardThemeData(elevation: 4),
    );
  }

  ThemeData _oceanTheme(AppFont font) {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.cyan,
      primaryColor: const Color(0xFF006994),
      scaffoldBackgroundColor: const Color(0xFFE0F7FA),
      fontFamily: font.fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF006994),
        foregroundColor: Colors.white,
      ),
    );
  }

  ThemeData _forestTheme(AppFont font) {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.green,
      primaryColor: const Color(0xFF2E7D32),
      scaffoldBackgroundColor: const Color(0xFFE8F5E9),
      fontFamily: font.fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
    );
  }

  ThemeData _sunsetTheme(AppFont font) {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.orange,
      primaryColor: const Color(0xFFE65100),
      scaffoldBackgroundColor: const Color(0xFFFFF3E0),
      fontFamily: font.fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFE65100),
        foregroundColor: Colors.white,
      ),
    );
  }

  ThemeData _midnightTheme(AppFont font) {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.deepPurple,
      primaryColor: const Color(0xFF4A148C),
      scaffoldBackgroundColor: const Color(0xFF1A0033),
      fontFamily: font.fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF4A148C),
        foregroundColor: Colors.white,
      ),
    );
  }
}
