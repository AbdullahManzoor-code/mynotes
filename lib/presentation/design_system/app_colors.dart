import 'package:flutter/material.dart';
import '../../domain/entities/note.dart';

/// Design System Colors extracted from HTML templates
/// Primary color: #13b6ec (Cyan Blue)
/// Design follows Material 3 principles with custom brand colors
class AppColors {
  AppColors._();

  // ==================== Primary Brand Colors ====================

  /// Main app accent color - Cyan Blue (#13b6ec)
  static const Color primaryColor = Color(0xFF13B6EC);
  static const Color primaryColorLight = Color(0xFF4CBFE6);
  static const Color primaryColorDark = Color(0xFF0EA5E9);

  /// Primary color with opacity variants (for backgrounds, overlays)
  static const Color primary10 = Color(0x1A13B6EC); // 10% opacity
  static const Color primary20 = Color(0x3313B6EC); // 20% opacity
  static const Color primary30 = Color(0x4D13B6EC); // 30% opacity
  static const Color primary40 = Color(0x6613B6EC); // 40% opacity

  // ==================== Background Colors ====================

  /// Light mode background - Off white (#f6f8f8)
  static const Color lightBackground = Color(0xFFF6F8F8);

  /// Light mode surface - Pure white
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Light mode card background - Pure white with shadow
  static const Color lightCardBackground = Color(0xFFFFFFFF);

  /// Dark mode background - Dark charcoal (#101d22)
  static const Color darkBackground = Color(0xFF101D22);

  /// Dark mode surface - Slightly lighter charcoal (#1a2b32)
  static const Color darkSurface = Color(0xFF1A2B32);

  /// Dark mode card background (#1a282e, #1c2a2f variations)
  static const Color darkCardBackground = Color(0xFF1A282E);
  static const Color darkCardBackgroundAlt = Color(0xFF1C2A2F);

  // ==================== Text Colors ====================

  /// Primary text color (dark mode) - Near white
  static const Color lightText = Color(0xFFFFFFFF);

  /// Primary text color (light mode) - Near black (#111618)
  static const Color darkText = Color(0xFF111618);

  /// Secondary text color - Medium gray (#617f89)
  static const Color secondaryText = Color(0xFF617F89);
  static const Color secondaryTextDark = Color(0xFF92BBC9);

  /// Tertiary text color - Light gray (#9db2b9, #9eb1b7)
  static const Color tertiaryText = Color(0xFF9DB2B9);
  static const Color tertiaryTextAlt = Color(0xFF9EB1B7);

  /// Disabled/Placeholder text
  static const Color disabledText = Color(0xFFBDBDBD);

  // ==================== Accent Colors ====================

  /// Blue accent variations
  static const Color accentBlue = Color(0xFF38BDF8);
  static const Color accentBlueDark = Color(0xFF0EA5E9);

  /// Purple accent
  static const Color accentPurple = Color(0xFFC084FC);

  /// Green accent
  static const Color accentGreen = Color(0xFF4ADE80);
  static const Color accentGreenDark = Color(0xFF10B981);

  /// Orange accent
  static const Color accentOrange = Color(0xFFF57C00);

  /// Emerald accent
  static const Color accentEmerald = Color(0xFF10B981);

  /// Pink accent
  static const Color accentPink = Color(0xFFEC4899);

  /// Yellow accent
  static const Color accentYellow = Color(0xFFFBBF24);

  // ==================== Semantic Colors ====================

  /// Success states
  static const Color successColor = Color(0xFF078836);
  static const Color successLight = Color(0xFF4ADE80);
  static const Color successDark = Color(0xFF065F46);

  /// Error states
  static const Color errorColor = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  /// Warning states
  static const Color warningColor = Color(0xFFFBBF24);
  static const Color warningLight = Color(0xFFFCD34D);
  static const Color warningDark = Color(0xFFF59E0B);

  /// Info states
  static const Color infoColor = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);

  // ==================== Border & Divider Colors ====================

  /// Light mode border
  static const Color lightBorder = Color(0xFFE5E7EB); // gray-200
  static const Color lightBorderAlt = Color(0xFFF3F4F6); // gray-100

  /// Dark mode border
  static const Color darkBorder = Color(0xFF374151); // gray-700
  static const Color darkBorderSubtle = Color(0x0DFFFFFF); // white/5%

  /// Divider colors
  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0x14FFFFFF); // white/8%

  // ==================== Overlay & Shadow Colors ====================

  /// Black overlay with opacity
  static const Color overlayBlack = Color(0x99000000); // 60% opacity
  static const Color overlayBlackLight = Color(0x33000000); // 20% opacity

  /// White overlay with opacity
  static const Color overlayWhite = Color(0x0DFFFFFF); // 5% opacity
  static const Color overlayWhite10 = Color(0x1AFFFFFF); // 10% opacity

  /// Shadow colors
  static const Color shadowLight = Color(0x1A000000); // 10% black
  static const Color shadowMedium = Color(0x33000000); // 20% black
  static const Color shadowDark = Color(0x4D000000); // 30% black

  // ==================== Note Color Variants (from existing NoteColor enum) ====================

  /// Note color palette - optimized for both light and dark modes
  static const Color noteRed = Color(0xFFFFCDD2);
  static const Color noteRedDark = Color(0xFFB71C1C);

  static const Color notePink = Color(0xFFF8BBD0);
  static const Color notePinkDark = Color(0xFFC2185B);

  static const Color notePurple = Color(0xFFE1BEE7);
  static const Color notePurpleDark = Color(0xFF7B1FA2);

  static const Color noteBlue = Color(0xFFBBDEFB);
  static const Color noteBlueDark = Color(0xFF1976D2);

  static const Color noteGreen = Color(0xFFC8E6C9);
  static const Color noteGreenDark = Color(0xFF388E3C);

  static const Color noteYellow = Color(0xFFFFF9C4);
  static const Color noteYellowDark = Color(0xFFFBC02D);

  static const Color noteOrange = Color(0xFFFFE0B2);
  static const Color noteOrangeDark = Color(0xFFF57C00);

  // ==================== Chart & Visualization Colors ====================

  /// Chart color palette for analytics
  static const List<Color> chartColors = [
    Color(0xFF13B6EC), // primary
    Color(0xFFC084FC), // purple
    Color(0xFF4ADE80), // green
    Color(0xFFFBBF24), // yellow
    Color(0xFFEC4899), // pink
    Color(0xFF38BDF8), // blue
    Color(0xFFF57C00), // orange
    Color(0xFF10B981), // emerald
  ];

  // ==================== Gradient Definitions ====================

  /// Primary gradient (used in FAB, buttons)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF13B6EC), Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Success gradient
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF4ADE80), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Card gradient (subtle background)
  static const LinearGradient cardGradientLight = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF9FAFB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradientDark = LinearGradient(
    colors: [Color(0xFF1A2B32), Color(0xFF12232A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ==================== Tag & Category Colors ====================

  /// Category colors with light/dark variants
  static const Map<String, Color> categoryColors = {
    'work': Color(0xFF13B6EC),
    'personal': Color(0xFFF57C00),
    'shopping': Color(0xFFFBBF24),
    'health': Color(0xFF4ADE80),
    'finance': Color(0xFF10B981),
    'education': Color(0xFFC084FC),
    'home': Color(0xFFEC4899),
    'travel': Color(0xFF13B6EC),
    'journal': Color(0xFF10B981),
  };

  /// Tag background colors (10% opacity versions)
  static Color getCategoryLightColor(String category) {
    final color = categoryColors[category.toLowerCase()] ?? primaryColor;
    return color.withOpacity(0.1);
  }

  /// Tag border colors (20% opacity versions)
  static Color getCategoryBorderColor(String category) {
    final color = categoryColors[category.toLowerCase()] ?? primaryColor;
    return color.withOpacity(0.2);
  }

  // ==================== Mood Colors (for reflection module) ====================

  static const Color moodVeryHappy = Color(0xFFFCD34D);
  static const Color moodHappy = Color(0xFF4ADE80);
  static const Color moodNeutral = Color(0xFF94A3B8);
  static const Color moodSad = Color(0xFF60A5FA);
  static const Color moodVerySad = Color(0xFF818CF8);
  static const Color moodExcited = Color(0xFFEC4899);
  static const Color moodStressed = Color(0xFFF87171);
  static const Color moodCalm = Color(0xFF6EE7B7);
  static const Color moodAnxious = Color(0xFFFBBF24);
  static const Color moodGrateful = Color(0xFFC084FC);

  // ==================== Utility Functions ====================

  /// Get color based on theme brightness
  static Color getTextColor(Brightness brightness) {
    return brightness == Brightness.light ? darkText : lightText;
  }

  static Color getSecondaryTextColor(Brightness brightness) {
    return brightness == Brightness.light ? secondaryText : secondaryTextDark;
  }

  static Color getBackgroundColor(Brightness brightness) {
    return brightness == Brightness.light ? lightBackground : darkBackground;
  }

  static Color getSurfaceColor(Brightness brightness) {
    return brightness == Brightness.light ? lightSurface : darkSurface;
  }

  static Color getCardColor(Brightness brightness) {
    return brightness == Brightness.light
        ? lightCardBackground
        : darkCardBackground;
  }

  static Color getBorderColor(Brightness brightness) {
    return brightness == Brightness.light ? lightBorder : darkBorder;
  }

  // ==================== Legacy compatibility aliases ====================
  // Many components still reference older API names; provide aliases
  static Color get primary => primaryColor;
  static Color get success => successColor;
  static Color get error => errorColor;
  static Color get warning => warningColor;
  static Color get info => infoColor;
  static Color get accentColor => accentBlue;

  /// Returns primary text color for given BuildContext
  static Color textPrimary(BuildContext context) =>
      getTextColor(Theme.of(context).brightness);

  /// Returns secondary text color for given BuildContext
  static Color textSecondary(BuildContext context) =>
      getSecondaryTextColor(Theme.of(context).brightness);

  /// Returns surface color for given BuildContext
  static Color surface(BuildContext context) =>
      getSurfaceColor(Theme.of(context).brightness);

  /// Returns card color for given BuildContext
  static Color card(BuildContext context) =>
      getCardColor(Theme.of(context).brightness);

  /// Returns border color for given BuildContext
  static Color border(BuildContext context) =>
      getBorderColor(Theme.of(context).brightness);

  /// On-error color (used for icons on error backgrounds)
  static const Color onError = Color(0xFFFFFFFF);

  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity.clamp(0.0, 1.0));
  }

  /// Get the appropriate color for a NoteColor enum based on current theme
  /// Get the appropriate color for a NoteColor enum.
  /// Accepts either `(BuildContext, NoteColor)` or `(NoteColor, BuildContext)` for
  /// backward compatibility with older call sites.
  static Color getNoteColor(dynamic a, [dynamic b]) {
    BuildContext? ctx;
    NoteColor? noteColor;
    if (a is BuildContext && b is NoteColor) {
      ctx = a;
      noteColor = b;
    } else if (a is NoteColor && b is BuildContext) {
      noteColor = a;
      ctx = b;
    } else if (a is NoteColor && b == null) {
      noteColor = a;
    }

    final isDark = ctx != null
        ? Theme.of(ctx).brightness == Brightness.dark
        : false; // default to light when no context

    if (noteColor == null) return primaryColor;
    return Color(isDark ? noteColor.darkColor : noteColor.lightColor);
  }

  /// Returns background color for given BuildContext
  static Color background(BuildContext context) =>
      getBackgroundColor(Theme.of(context).brightness);

  /// Legacy gradient getters
  static LinearGradient get darkGradient => cardGradientDark;
  static LinearGradient get lightGradient => cardGradientLight;

  /// Create color from hex string
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Get contrasting text color for any background
  static Color getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? darkText : lightText;
  }
}

/// Extension on Color for additional utilities
extension AppColorExtensions on Color {
  /// Get 10% opacity version of this color
  Color get opacity10 => withOpacity(0.1);

  /// Get 20% opacity version of this color
  Color get opacity20 => withOpacity(0.2);

  /// Get 30% opacity version of this color
  Color get opacity30 => withOpacity(0.3);

  /// Get 40% opacity version of this color
  Color get opacity40 => withOpacity(0.4);

  /// Get 50% opacity version of this color
  Color get opacity50 => withOpacity(0.5);

  /// Get 60% opacity version of this color
  Color get opacity60 => withOpacity(0.6);

  /// Get 70% opacity version of this color
  Color get opacity70 => withOpacity(0.7);

  /// Get 80% opacity version of this color
  Color get opacity80 => withOpacity(0.8);

  /// Get 90% opacity version of this color
  Color get opacity90 => withOpacity(0.9);

  /// Convert color to hex string
  String toHex() {
    return '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}

