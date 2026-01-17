import 'package:flutter/material.dart';

/// Centralized color constants to avoid duplication
/// Using Material Design 3 color system
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Calm & Minimalist Design System - Sage Green Primary
  static const Color primaryLight = Color(0xFF8DAA91); // Muted Sage Green
  static const Color primaryDark = Color(
    0xFF9FBE9F,
  ); // Lighter Sage for dark mode
  static const Color primaryContainer = Color(0xFFE8F0E8);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF2C4A2E);

  // Secondary Colors - Soft Neutrals
  static const Color secondaryLight = Color(0xFF7A8A7F);
  static const Color secondaryDark = Color(0xFFABBCAF);
  static const Color secondaryContainer = Color(0xFFE5EBE6);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF303D32);

  // Tertiary Colors - Warm Accent
  static const Color tertiaryLight = Color(0xFFB8A194);
  static const Color tertiaryDark = Color(0xFFD4C4B8);
  static const Color tertiaryContainer = Color(0xFFF2EDE8);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF3E2E24);

  // Error Colors - Soft Red
  static const Color errorLight = Color(0xFFD17B7B);
  static const Color errorDark = Color(0xFFE5A3A3);
  static const Color errorContainer = Color(0xFFFCE8E8);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF5C2424);

  // Calm & Minimalist Background & Surface
  static const Color backgroundLight = Color(0xFFFAFAFA); // Soft off-white
  static const Color backgroundDark = Color(0xFF1A1A1A); // Deep charcoal
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceVariantLight = Color(0xFFF0F0F0);
  static const Color surfaceVariantDark = Color(0xFF2A2A2A);

  // On Background & Surface
  static const Color onBackgroundLight = Color(0xFF2A2A2A);
  static const Color onBackgroundDark = Color(0xFFF0F0F0);
  static const Color onSurfaceLight = Color(0xFF2A2A2A);
  static const Color onSurfaceDark = Color(0xFFF0F0F0);
  static const Color onSurfaceVariantLight = Color(0xFF5A5A5A);
  static const Color onSurfaceVariantDark = Color(0xFFCCCCCC);

  // Convenience getters for common usage
  static const Color primaryColor = primaryLight;
  static const Color secondaryColor = secondaryLight;
  static const Color tertiaryColor = tertiaryLight;
  static const Color errorColor = errorLight;
  static const Color successColor = Color(0xFF8DAA91); // Match sage green
  static const Color warningColor = Color(0xFFD9B382); // Warm muted orange
  static const Color infoColor = Color(0xFF8FA3B8); // Muted blue
  static const Color accentColor = Color(0xFF8DAA91); // Sage green accent

  // Outline - Subtle borders
  static const Color outlineLight = Color(0xFFD9D9D9); // Very light gray
  static const Color outlineDark = Color(0xFF3A3A3A); // Dark gray
  static const Color outlineVariantLight = Color(0xFFE8E8E8); // Extra light
  static const Color outlineVariantDark = Color(0xFF2A2A2A);

  // Special Purpose Colors
  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);
  static const Color inverseSurfaceLight = Color(0xFF2A2A2A);
  static const Color inverseSurfaceDark = Color(0xFFF0F0F0);
  static const Color inverseOnSurfaceLight = Color(0xFFFAFAFA);
  static const Color inverseOnSurfaceDark = Color(0xFF2A2A2A);
  static const Color inversePrimaryLight = Color(0xFF9FBE9F);
  static const Color inversePrimaryDark = Color(0xFF8DAA91);

  // Media Type Colors
  static const Color imageColor = Color(0xFF4CAF50);
  static const Color audioColor = Color(0xFFFF9800);
  static const Color videoColor = Color(0xFF2196F3);
  static const Color documentColor = Color(0xFF9C27B0);

  // Grey Colors (for UI elements)
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color greyDark = Color(0xFF424242);

  // White Opacity Variants
  static const Color whiteOpacity90 = Color(0xE6FFFFFF);
  static const Color whiteOpacity70 = Color(0xB3FFFFFF);
  static const Color whiteOpacity54 = Color(0x8AFFFFFF);
  static const Color whiteOpacity24 = Color(0x3DFFFFFF);
  static const Color whiteOpacity10 = Color(0x1AFFFFFF);

  // Black Opacity Variants
  static const Color blackOpacity87 = Color(0xDE000000);
  static const Color blackOpacity05 = Color(0x0DFFFFFF);
  static const Color blackOpacity20 = Color(0x33000000);

  // Status Colors
  static const Color successLight = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF81C784);
  static const Color warningLight = Color(0xFFFFA726);
  static const Color warningDark = Color(0xFFFFB74D);
  static const Color infoLight = Color(0xFF29B6F6);
  static const Color infoDark = Color(0xFF4FC3F7);

  // Todo Status Colors
  static const Color todoCompleted = Color(0xFF4CAF50);
  static const Color todoPending = Color(0xFFFF9800);
  static const Color todoOverdue = Color(0xFFF44336);

  // Alarm Colors
  static const Color alarmActive = Color(0xFFE91E63);
  static const Color alarmInactive = Color(0xFF9E9E9E);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF6750A4),
    Color(0xFF7E57C2),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF625B71),
    Color(0xFF7E57C2),
  ];

  // Shimmer Colors (for loading states)
  static const Color shimmerBaseLight = Color(0xFFE0E0E0);
  static const Color shimmerHighlightLight = Color(0xFFF5F5F5);
  static const Color shimmerBaseDark = Color(0xFF2C2C2C);
  static const Color shimmerHighlightDark = Color(0xFF3C3C3C);
}
