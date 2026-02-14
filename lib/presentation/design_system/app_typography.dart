import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import '../../core/services/theme_customization_service.dart';

/// Design System Typography - Customizable Font System
/// Supports 6 font families with scaling options
/// Template Font Scale: 10px, 12px, 14px, 16px, 18px, 24px, 32px
/// Weights: 300 (light), 400 (regular), 500 (medium), 600 (semibold), 700 (bold)
class AppTypography {
  AppTypography._();

  // Cache for font settings to avoid repeated async calls
  static AppFontFamily? _cachedFontFamily;
  static double? _cachedFontScale;

  // Helper: resolve color when a BuildContext or Color is passed positionally
  static Color? _resolveColor(dynamic ctxOrColor, Color? explicitColor) {
    if (ctxOrColor is BuildContext) return AppColors.textPrimary(ctxOrColor);
    if (ctxOrColor is Color) return ctxOrColor;
    return explicitColor;
  }

  /// Initialize font settings cache
  static Future<void> initializeFontSettings() async {
    _cachedFontFamily = await ThemeCustomizationService.getFontFamily();
    _cachedFontScale = await ThemeCustomizationService.getFontScaleMultiplier();
  }

  /// Update cached font settings
  static void updateFontSettings(AppFontFamily fontFamily, double scale) {
    _cachedFontFamily = fontFamily;
    _cachedFontScale = scale;
  }

  static TextStyle _style({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    double letterSpacing = 0,
    dynamic context,
    Color? color,
    FontWeight? overrideFontWeight,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    AppFontFamily? customFontFamily,
    double? customScale,
  }) {
    final resolvedColor = _resolveColor(context, color);
    final fontFamily =
        customFontFamily ?? _cachedFontFamily ?? AppFontFamily.system;
    final scale = customScale ?? _cachedFontScale ?? 1.0;
    final scaledFontSize = fontSize * scale;

    return fontFamily
        .getTextStyle(
          fontSize: scaledFontSize,
          fontWeight: overrideFontWeight ?? fontWeight,
          color: resolvedColor,
          letterSpacing: letterSpacing,
          height: height,
        )
        .copyWith(fontFeatures: fontFeatures, decoration: decoration);
  }

  // ==================== Template Typography Scale ====================

  /// 32px Bold - Greeting headers
  static TextStyle displayLarge(
    dynamic context, [
    Color? color,
    FontWeight? fontWeight,
  ]) {
    return _style(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: -1.0,
      context: context,
      color: color,
      overrideFontWeight: fontWeight,
    );
  }

  /// 24px Bold - Screen titles
  static TextStyle displayMedium(
    dynamic context, [
    Color? color,
    FontWeight? fontWeight,
  ]) {
    return _style(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.3,
      letterSpacing: -0.5,
      context: context,
      color: color,
      overrideFontWeight: fontWeight,
    );
  }

  // ==================== Heading Text Styles ====================

  /// Heading 1 - 24px, Bold
  static TextStyle heading1([
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  ]) => _style(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.36,
    context: context,
    color: color,
    overrideFontWeight: fontWeight,
  );

  /// Heading 2 - 20px, Bold
  static TextStyle heading2([
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  ]) => _style(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.3,
    context: context,
    color: color,
    overrideFontWeight: fontWeight,
  );

  /// Heading 3 - 18px, Semibold
  static TextStyle heading3([
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  ]) => _style(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: -0.27,
    context: context,
    color: color,
    overrideFontWeight: fontWeight,
  );

  /// Heading 4 - 16px, Semibold
  static TextStyle heading4([
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  ]) => _style(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    context: context,
    color: color,
    overrideFontWeight: fontWeight,
  );

  // ==================== Legacy Aliases ====================
  static TextStyle titleLarge([
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  ]) => heading1(context, color, fontWeight);
  static TextStyle titleMedium([
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  ]) => heading2(context, color, fontWeight);
  static TextStyle displaySmall([
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  ]) => heading1(context, color, fontWeight);

  // ==================== Body Text Styles ====================

  /// Body Large - 16px, Medium
  static TextStyle bodyLarge([
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  ]) => _style(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    context: context,
    color: color,
    overrideFontWeight: fontWeight,
  );

  /// Body Medium - 14px, Regular
  static TextStyle bodyMedium([
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  ]) => _style(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    context: context,
    color: color,
    overrideFontWeight: fontWeight,
  );

  /// Body Small - 12px, Regular
  static TextStyle bodySmall([
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  ]) => _style(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    context: context,
    color: color,
    overrideFontWeight: fontWeight,
  );

  // ==================== Label Text Styles ====================

  /// Label Large - 14px, Semibold
  static TextStyle labelLarge([
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  ]) => _style(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    context: context,
    color: color,
    overrideFontWeight: fontWeight,
  );

  /// Label Medium - 12px, Semibold
  static TextStyle labelMedium([
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  ]) => _style(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
    context: context,
    color: color,
    overrideFontWeight: fontWeight,
  );

  /// Label Small - 10px, Bold, Uppercase
  static TextStyle labelSmall([
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  ]) => _style(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 1.2,
    context: context,
    color: color,
    overrideFontWeight: fontWeight,
    fontFeatures: [const FontFeature.enable('c2sc')],
  );

  // ==================== Caption Text Styles ====================

  /// Caption Large - 12px, Medium
  static TextStyle captionLarge([
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  ]) => _style(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    context: context,
    color: color,
    overrideFontWeight: fontWeight,
  );

  /// Caption Small - 10px, Medium
  static TextStyle captionSmall([
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  ]) => _style(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.2,
    context: context,
    color: color,
    overrideFontWeight: fontWeight,
  );

  // ==================== Special Text Styles ====================

  /// Button Text - 16px, Bold
  static TextStyle buttonLarge([dynamic context, Color? color]) => _style(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: 0.5,
    context: context,
    color: color,
  );

  /// Button Text - 14px, Semibold
  static TextStyle buttonMedium([dynamic context, Color? color]) => _style(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.5,
    context: context,
    color: color,
  );

  /// Overline - 10px, Bold, Uppercase
  static TextStyle overline([dynamic context, Color? color]) => _style(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.6,
    letterSpacing: 1.5,
    context: context,
    color: color,
  );

  /// Number Display - 28px, Bold
  static TextStyle numberLarge([dynamic context, Color? color]) => _style(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    context: context,
    color: color,
    fontFeatures: [const FontFeature.tabularFigures()],
  );

  /// Number Display - 20px, Bold
  static TextStyle numberMedium([dynamic context, Color? color]) => _style(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.3,
    context: context,
    color: color,
    fontFeatures: [const FontFeature.tabularFigures()],
  );

  // ==================== Interactive Text Styles ====================

  /// Link Text - 14px, Medium
  static TextStyle link([dynamic context, Color? color]) => _style(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
    decoration: TextDecoration.underline,
    context: context,
    color: color,
  );

  /// Link Text Small - 12px, Medium
  static TextStyle linkSmall([dynamic context, Color? color]) => _style(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    decoration: TextDecoration.underline,
    context: context,
    color: color,
  );

  // ==================== Input Text Styles ====================

  /// Input Label - 12px, Semibold
  static TextStyle inputLabel([dynamic context, Color? color]) => _style(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
    context: context,
    color: color,
  );

  /// Input Text - 16px, Regular
  static TextStyle inputText([dynamic context, Color? color]) => _style(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    context: context,
    color: color,
  );

  /// Input Placeholder - 16px, Regular
  static TextStyle inputPlaceholder([dynamic context, Color? color]) => _style(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    context: context,
    color: color?.withOpacity(0.5),
  );

  /// Input Helper - 12px, Regular
  static TextStyle inputHelper([dynamic context, Color? color]) => _style(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    context: context,
    color: color,
  );

  // ==================== Context-Specific Text Styles ====================

  /// Note Title - 16px, Bold
  static TextStyle noteTitle([dynamic context, Color? color]) => _style(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.4,
    context: context,
    color: color,
  );

  /// Note Content - 14px, Regular
  static TextStyle noteContent([dynamic context, Color? color]) => _style(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
    context: context,
    color: color,
  );

  /// Note Timestamp - 10px, Medium, Uppercase
  static TextStyle noteTimestamp([dynamic context, Color? color]) => _style(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.8,
    context: context,
    color: color,
  );

  /// Todo Text - 14px, Medium
  static TextStyle todoText([
    dynamic context,
    Color? color,
    bool isCompleted = false,
  ]) => _style(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    context: context,
    color: color,
    decoration: isCompleted ? TextDecoration.lineThrough : null,
  );

  /// Reminder Time - 12px, Medium
  static TextStyle reminderTime([dynamic context, Color? color]) => _style(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    context: context,
    color: color,
    fontFeatures: [const FontFeature.tabularFigures()],
  );

  /// Tag Text - 10px, Bold, Uppercase
  static TextStyle tagText([dynamic context, Color? color]) => _style(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.8,
    context: context,
    color: color,
  );

  // ==================== Text Theme Builder ====================

  /// Create a complete TextTheme for the app
  static TextTheme createTextTheme({required Brightness brightness}) {
    return TextTheme(
      displayLarge: displayLarge(null),
      displayMedium: heading1(null),
      displaySmall: heading2(null),
      headlineLarge: heading1(null),
      headlineMedium: heading2(null),
      headlineSmall: heading3(null),
      titleLarge: heading2(null),
      titleMedium: heading3(null),
      titleSmall: heading4(null),
      bodyLarge: bodyLarge(null),
      bodyMedium: bodyMedium(null),
      bodySmall: bodySmall(null),
      labelLarge: labelLarge(null),
      labelMedium: labelMedium(null),
      labelSmall: labelSmall(null),
    );
  }

  // ==================== Legacy compatibility wrappers ====================
  static TextStyle button([
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  ]) => buttonMedium(context, color);

  static TextStyle caption([
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  ]) => captionSmall(context, color, fontWeight);

  static TextStyle body1([
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  ]) => bodyLarge(context, color, fontWeight);

  static TextStyle body2([
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  ]) => bodyMedium(context, color, fontWeight);

  static TextStyle body3([
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  ]) => bodySmall(context, color, fontWeight);

  static TextStyle display1([
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  ]) => displayLarge(context, color, fontWeight);

  static TextStyle label([
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  ]) => labelLarge(context, color, fontWeight);

  static TextStyle todoTitle([
    dynamic context,
    Color? color,
    bool isCompleted = false,
  ]) => todoText(context, color, isCompleted);

  static TextStyle reminderTitle([dynamic context, Color? color]) =>
      reminderTime(context, color);

  // ==================== Utility Functions ====================

  /// Create text style with custom properties
  static TextStyle custom({
    required double fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w400,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      decoration: decoration,
    );
  }

  /// Apply responsive scaling to existing text style
  static TextStyle responsive(TextStyle style) {
    return style.copyWith(fontSize: style.fontSize!);
  }

  /// Create uppercase text style
  static TextStyle uppercase(TextStyle style) {
    return style.copyWith(
      fontFeatures: [const FontFeature.enable('c2sc')],
      letterSpacing: (style.letterSpacing ?? 0) + 1.0,
    );
  }
}

/// Extension on TextStyle for additional utilities
extension AppTypographyExtensions on TextStyle {
  /// Make text bold
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);

  /// Make text semibold
  TextStyle get semibold => copyWith(fontWeight: FontWeight.w600);

  /// Make text medium
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  /// Make text regular
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);

  /// Make text light
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);

  /// Make text italic
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);

  /// Add underline
  TextStyle get underline => copyWith(decoration: TextDecoration.underline);

  /// Add line-through
  TextStyle get lineThrough => copyWith(decoration: TextDecoration.lineThrough);

  /// Add color
  TextStyle withColor(Color color) => copyWith(color: color);

  /// Add opacity to text color
  TextStyle withOpacity(double opacity) {
    return copyWith(color: color?.withOpacity(opacity));
  }

  /// Scale font size
  TextStyle scale(double factor) {
    return copyWith(fontSize: (fontSize ?? 14) * factor);
  }

  /// Adjust letter spacing
  TextStyle spacing(double value) {
    return copyWith(letterSpacing: value);
  }

  /// Adjust line height
  TextStyle lineHeight(double value) {
    return copyWith(height: value);
  }
}
