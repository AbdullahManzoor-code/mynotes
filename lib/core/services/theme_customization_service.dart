import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

/// Font families supported by the app
enum AppFontFamily {
  system('System Default', ''),
  roboto('Roboto', 'Roboto'),
  openSans('Open Sans', 'OpenSans'),
  lato('Lato', 'Lato'),
  montserrat('Montserrat', 'Montserrat'),
  poppins('Poppins', 'Poppins');

  const AppFontFamily(this.displayName, this.fontFamily);

  final String displayName;
  final String fontFamily;

  /// Get TextStyle for this font family
  TextStyle getTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    switch (this) {
      case AppFontFamily.roboto:
        return GoogleFonts.roboto(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
      case AppFontFamily.openSans:
        return GoogleFonts.openSans(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
      case AppFontFamily.lato:
        return GoogleFonts.lato(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
      case AppFontFamily.montserrat:
        return GoogleFonts.montserrat(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
      case AppFontFamily.poppins:
        return GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
      default:
        return TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
    }
  }
}

/// Font size scaling options
enum FontSizeScale {
  extraSmall('Extra Small', 0.8),
  small('Small', 0.9),
  normal('Normal', 1.0),
  large('Large', 1.1),
  extraLarge('Extra Large', 1.2),
  huge('Huge', 1.5);

  const FontSizeScale(this.displayName, this.scale);

  final String displayName;
  final double scale;
}

/// Service for managing theme and font customization
class ThemeCustomizationService {
  static const String _fontFamilyKey = 'font_family';
  static const String _fontScaleKey = 'font_scale';

  // Cache for font settings to avoid repeated async calls
  static AppFontFamily? _cachedFontFamily;
  static FontSizeScale? _cachedFontScale;

  /// Get current font family (with cache)
  static Future<AppFontFamily> getCurrentFontFamily() async {
    if (_cachedFontFamily != null) return _cachedFontFamily!;

    final prefs = await SharedPreferences.getInstance();
    final fontIndex = prefs.getInt(_fontFamilyKey) ?? 0;
    _cachedFontFamily = AppFontFamily.values[fontIndex];
    return _cachedFontFamily!;
  }

  /// Backward compatibility method
  static Future<AppFontFamily> getFontFamily() async {
    return getCurrentFontFamily();
  }

  /// Set font family
  static Future<void> setFontFamily(AppFontFamily fontFamily) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_fontFamilyKey, fontFamily.index);
    _cachedFontFamily = fontFamily;
  }

  /// Get current font scale (with cache)
  static Future<FontSizeScale> getCurrentFontScale() async {
    if (_cachedFontScale != null) return _cachedFontScale!;

    final prefs = await SharedPreferences.getInstance();
    final scaleIndex = prefs.getInt(_fontScaleKey) ?? 2; // Default to normal
    _cachedFontScale = FontSizeScale.values[scaleIndex];
    return _cachedFontScale!;
  }

  /// Backward compatibility method
  static Future<FontSizeScale> getFontSizeScale() async {
    return getCurrentFontScale();
  }

  /// Get font scale multiplier
  static Future<double> getFontScaleMultiplier() async {
    final scale = await getCurrentFontScale();
    return scale.scale;
  }

  /// Set font scale
  static Future<void> setFontScale(FontSizeScale scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_fontScaleKey, scale.index);
    _cachedFontScale = scale;
  }

  /// Backward compatibility method
  static Future<void> setFontSizeScale(FontSizeScale scale) async {
    return setFontScale(scale);
  }

  /// Clear cache (useful when initializing the app)
  static void clearCache() {
    _cachedFontFamily = null;
    _cachedFontScale = null;
  }

  /// Get TextTheme with current font family
  static Future<TextTheme> getCustomTextTheme() async {
    final fontFamily = await getCurrentFontFamily();
    final fontScale = await getCurrentFontScale();

    switch (fontFamily) {
      case AppFontFamily.roboto:
        return GoogleFonts.robotoTextTheme().apply(
          fontSizeFactor: fontScale.scale,
        );
      case AppFontFamily.openSans:
        return GoogleFonts.openSansTextTheme().apply(
          fontSizeFactor: fontScale.scale,
        );
      case AppFontFamily.lato:
        return GoogleFonts.latoTextTheme().apply(
          fontSizeFactor: fontScale.scale,
        );
      case AppFontFamily.montserrat:
        return GoogleFonts.montserratTextTheme().apply(
          fontSizeFactor: fontScale.scale,
        );
      case AppFontFamily.poppins:
        return GoogleFonts.poppinsTextTheme().apply(
          fontSizeFactor: fontScale.scale,
        );
      default:
        return ThemeData().textTheme.apply(fontSizeFactor: fontScale.scale);
    }
  }
}
