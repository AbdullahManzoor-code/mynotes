import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Design System Typography extracted from HTML templates
/// Font Family: Inter (sans-serif)
/// Weights: 300 (light), 400 (regular), 500 (medium), 600 (semibold), 700 (bold)
class AppTypography {
  AppTypography._();

  // Helper: resolve color when a BuildContext or Color is passed positionally
  static Color? _resolveColor(dynamic ctxOrColor, Color? explicitColor) {
    if (ctxOrColor is BuildContext) return AppColors.textPrimary(ctxOrColor);
    if (ctxOrColor is Color) return ctxOrColor;
    return explicitColor;
  }
  // ==================== Font Family ====================

  static const String primaryFontFamily = 'Inter';

  /// Get the base text style with Inter font
  static TextStyle get baseTextStyle => GoogleFonts.inter();

  // ==================== Display Text Styles (32px+) ====================

  /// Display Large - 32px, Bold, Tight tracking
  /// Usage: Onboarding headlines, major section titles
  static TextStyle displayLarge({
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  }) {
    final resolvedColor = _resolveColor(context, color);
    return GoogleFonts.inter(
      fontSize: 32.sp,
      fontWeight: fontWeight ?? FontWeight.w700,
      height: 1.2,
      letterSpacing: -0.48, // -0.015em * 32
      color: resolvedColor,
    );
  }

  // ==================== Heading Text Styles ====================

  /// Heading 1 - 24px, Bold, Tight tracking
  /// Usage: Screen titles, main headings
  static TextStyle heading1({
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  }) {
    final resolvedColor = _resolveColor(context, color);
    return GoogleFonts.inter(
      fontSize: 24.sp,
      fontWeight: fontWeight ?? FontWeight.w700,
      height: 1.25,
      letterSpacing: -0.36, // -0.015em * 24
      color: resolvedColor,
    );
  }

  /// Heading 2 - 20px, Bold, Tight tracking
  /// Usage: Card titles, dialog headers
  static TextStyle heading2({
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  }) {
    final resolvedColor = _resolveColor(context, color);
    return GoogleFonts.inter(
      fontSize: 20.sp,
      fontWeight: fontWeight ?? FontWeight.w700,
      height: 1.3,
      letterSpacing: -0.3, // -0.015em * 20
      color: resolvedColor,
    );
  }

  /// Heading 3 - 18px, Semibold
  /// Usage: Section headers, subheadings
  static TextStyle heading3({
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  }) {
    final resolvedColor = _resolveColor(context, color);
    return GoogleFonts.inter(
      fontSize: 18.sp,
      fontWeight: fontWeight ?? FontWeight.w600,
      height: 1.33,
      letterSpacing: -0.27, // -0.015em * 18
      color: resolvedColor,
    );
  }

  /// Heading 4 - 16px, Semibold
  /// Usage: List section headers
  static TextStyle heading4({
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  }) {
    final resolvedColor = _resolveColor(context, color);
    return GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: fontWeight ?? FontWeight.w600,
      height: 1.4,
      color: resolvedColor,
    );
  }

  // ==================== Body Text Styles ====================

  /// Body Large - 16px, Medium
  /// Usage: Important body text, emphasized content
  static TextStyle bodyLarge({
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  }) {
    final resolvedColor = _resolveColor(context, color);
    return GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: fontWeight ?? FontWeight.w500,
      height: 1.5,
      color: resolvedColor,
    );
  }

  /// Body Medium - 14px, Regular
  /// Usage: Default body text, descriptions
  static TextStyle bodyMedium({
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  }) {
    final resolvedColor = _resolveColor(context, color);
    return GoogleFonts.inter(
      fontSize: 14.sp,
      fontWeight: fontWeight ?? FontWeight.w400,
      height: 1.5,
      color: resolvedColor,
    );
  }

  /// Body Small - 12px, Regular
  /// Usage: Secondary information, helper text
  static TextStyle bodySmall({
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  }) {
    final resolvedColor = _resolveColor(context, color);
    return GoogleFonts.inter(
      fontSize: 12.sp,
      fontWeight: fontWeight ?? FontWeight.w400,
      height: 1.4,
      color: resolvedColor,
    );
  }

  // ==================== Label Text Styles ====================

  /// Label Large - 14px, Semibold
  /// Usage: Button labels, tab labels
  static TextStyle labelLarge({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      fontSize: 14.sp,
      fontWeight: fontWeight ?? FontWeight.w600,
      height: 1.4,
      color: color,
    );
  }

  /// Label Medium - 12px, Semibold
  /// Usage: Small buttons, chips, tags
  static TextStyle labelMedium({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      fontSize: 12.sp,
      fontWeight: fontWeight ?? FontWeight.w600,
      height: 1.3,
      color: color,
    );
  }

  /// Label Small - 10px, Bold, Uppercase, Wide tracking
  /// Usage: Section headers, category labels, timestamps
  static TextStyle labelSmall({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      fontSize: 10.sp,
      fontWeight: fontWeight ?? FontWeight.w700,
      height: 1.2,
      letterSpacing: 1.2, // Wide tracking
      color: color,
    ).copyWith(
      // Force uppercase
      fontFeatures: [const FontFeature.enable('c2sc')],
    );
  }

  // ==================== Caption Text Styles ====================

  /// Caption Large - 12px, Medium
  /// Usage: Timestamps, metadata
  static TextStyle captionLarge({
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  }) {
    final resolvedColor = _resolveColor(context, color);
    return GoogleFonts.inter(
      fontSize: 12.sp,
      fontWeight: fontWeight ?? FontWeight.w500,
      height: 1.3,
      color: resolvedColor,
    );
  }

  /// Caption Small - 10px, Medium
  /// Usage: Very small metadata, badges
  static TextStyle captionSmall({
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  }) {
    final resolvedColor = _resolveColor(context, color);
    return GoogleFonts.inter(
      fontSize: 10.sp,
      fontWeight: fontWeight ?? FontWeight.w500,
      height: 1.2,
      color: resolvedColor,
    );
  }

  // ==================== Special Text Styles ====================

  /// Button Text - 16px, Bold
  /// Usage: Primary button labels
  static TextStyle buttonLarge({dynamic context, Color? color}) {
    final resolvedColor = _resolveColor(context, color);
    return GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
      height: 1.25,
      letterSpacing: 0.5,
      color: resolvedColor,
    );
  }

  /// Button Text - 14px, Semibold
  /// Usage: Secondary button labels
  static TextStyle buttonMedium({dynamic context, Color? color}) {
    final resolvedColor = _resolveColor(context, color);
    return GoogleFonts.inter(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 0.5,
      color: resolvedColor,
    );
  }

  /// Overline - 10px, Bold, Uppercase, Wide tracking
  /// Usage: Section labels, category headers
  static TextStyle overline({dynamic context, Color? color}) {
    final resolvedColor = _resolveColor(context, color);
    return GoogleFonts.inter(
      fontSize: 10.sp,
      fontWeight: FontWeight.w700,
      height: 1.6,
      letterSpacing: 1.5,
      color: resolvedColor,
    );
  }

  /// Number Display - 28px, Bold
  /// Usage: Stats, metrics, large numbers
  static TextStyle numberLarge({dynamic context, Color? color}) {
    final resolvedColor = _resolveColor(context, color);
    return GoogleFonts.inter(
      fontSize: 28.sp,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: -0.5,
      color: resolvedColor,
      fontFeatures: [const FontFeature.tabularFigures()],
    );
  }

  /// Number Display - 20px, Bold
  /// Usage: Medium numbers, counts
  static TextStyle numberMedium({dynamic context, Color? color}) {
    final resolvedColor = _resolveColor(context, color);
    return GoogleFonts.inter(
      fontSize: 20.sp,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: -0.3,
      color: resolvedColor,
      fontFeatures: [const FontFeature.tabularFigures()],
    );
  }

  // ==================== Interactive Text Styles ====================

  /// Link Text - 14px, Medium
  /// Usage: Hyperlinks, clickable text
  static TextStyle link({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      height: 1.5,
      decoration: TextDecoration.underline,
      color: color,
    );
  }

  /// Link Text Small - 12px, Medium
  /// Usage: Small hyperlinks
  static TextStyle linkSmall({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      height: 1.4,
      decoration: TextDecoration.underline,
      color: color,
    );
  }

  // ==================== Input Text Styles ====================

  /// Input Label - 12px, Semibold
  /// Usage: Text field labels
  static TextStyle inputLabel({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: color,
    );
  }

  /// Input Text - 16px, Regular
  /// Usage: Text field input
  static TextStyle inputText({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: color,
    );
  }

  /// Input Placeholder - 16px, Regular
  /// Usage: Text field placeholder
  static TextStyle inputPlaceholder({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: color?.withOpacity(0.5),
    );
  }

  /// Input Helper - 12px, Regular
  /// Usage: Helper text, error text
  static TextStyle inputHelper({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      height: 1.3,
      color: color,
    );
  }

  // ==================== Context-Specific Text Styles ====================

  /// Note Title - 16px, Bold
  /// Usage: Note card titles
  static TextStyle noteTitle({dynamic context, Color? color}) {
    final resolvedColor = _resolveColor(context, color);
    return GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
      height: 1.4,
      color: resolvedColor,
    );
  }

  /// Note Content - 14px, Regular, Relaxed line height
  /// Usage: Note preview text
  static TextStyle noteContent({dynamic context, Color? color}) {
    final resolvedColor = _resolveColor(context, color);
    return GoogleFonts.inter(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      height: 1.6, // Relaxed for readability
      color: resolvedColor,
    );
  }

  /// Note Timestamp - 10px, Medium, Uppercase
  /// Usage: Note creation/update time
  static TextStyle noteTimestamp({dynamic context, Color? color}) {
    final resolvedColor = _resolveColor(context, color);
    return GoogleFonts.inter(
      fontSize: 10.sp,
      fontWeight: FontWeight.w500,
      height: 1.2,
      letterSpacing: 0.8,
      color: resolvedColor,
    );
  }

  /// Todo Text - 14px, Medium
  /// Usage: Todo item text
  static TextStyle todoText({
    dynamic context,
    Color? color,
    bool isCompleted = false,
  }) {
    final resolvedColor = _resolveColor(context, color);
    return GoogleFonts.inter(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      height: 1.4,
      decoration: isCompleted ? TextDecoration.lineThrough : null,
      color: resolvedColor,
    );
  }

  /// Reminder Time - 12px, Medium
  /// Usage: Reminder time display
  static TextStyle reminderTime({dynamic context, Color? color}) {
    final resolvedColor = _resolveColor(context, color);
    return GoogleFonts.inter(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      height: 1.3,
      fontFeatures: [const FontFeature.tabularFigures()],
      color: resolvedColor,
    );
  }

  /// Tag Text - 10px, Bold, Uppercase
  /// Usage: Category tags, chips
  static TextStyle tagText({dynamic context, Color? color}) {
    final resolvedColor = _resolveColor(context, color);
    return GoogleFonts.inter(
      fontSize: 10.sp,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: 0.8,
      color: resolvedColor,
    );
  }

  // ==================== Text Theme Builder ====================

  /// Create a complete TextTheme for the app
  static TextTheme createTextTheme({required Brightness brightness}) {
    return TextTheme(
      // Display styles
      displayLarge: displayLarge(),
      displayMedium: heading1(),
      displaySmall: heading2(),

      // Headline styles
      headlineLarge: heading1(),
      headlineMedium: heading2(),
      headlineSmall: heading3(),

      // Title styles
      titleLarge: heading2(),
      titleMedium: heading3(),
      titleSmall: heading4(),

      // Body styles
      bodyLarge: bodyLarge(),
      bodyMedium: bodyMedium(),
      bodySmall: bodySmall(),

      // Label styles
      labelLarge: labelLarge(),
      labelMedium: labelMedium(),
      labelSmall: labelSmall(),
    );
  }

  // ==================== Legacy compatibility wrappers ====================
  // Provide old method names expected by components to maintain compatibility.
  static TextStyle button({
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  }) => buttonMedium(context: context, color: color);

  static TextStyle caption({
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  }) => captionSmall(context: context, color: color);

  static TextStyle body1({
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  }) => bodyLarge(context: context, color: color, fontWeight: fontWeight);

  static TextStyle body2({
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  }) => bodyMedium(context: context, color: color, fontWeight: fontWeight);

  static TextStyle display1({
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  }) => displayLarge(context: context, color: color, fontWeight: fontWeight);

  static TextStyle label({
    dynamic context,
    Color? color,
    FontWeight? fontWeight,
  }) => labelLarge(color: color, fontWeight: fontWeight);

  static TextStyle todoTitle({
    dynamic context,
    Color? color,
    bool isCompleted = false,
  }) => todoText(context: context, color: color, isCompleted: isCompleted);

  static TextStyle reminderTitle({dynamic context, Color? color}) =>
      reminderTime(context: context, color: color);

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
      fontSize: fontSize.sp,
      fontWeight: fontWeight ?? FontWeight.w400,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      decoration: decoration,
    );
  }

  /// Apply responsive scaling to existing text style
  static TextStyle responsive(TextStyle style) {
    return style.copyWith(fontSize: style.fontSize! * 1.sp);
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
    return copyWith(color: this.color?.withOpacity(opacity));
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

