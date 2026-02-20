import 'package:flutter/material.dart';

/// Centralized color constants to avoid duplication
/// Using Material Design 3 color system
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ==================== PRIMARY ====================
  static const Color primaryLight = Color(0xFF8DAA91);
  static const Color primaryDark = Color(0xFF9FBE9F);
  static const Color primaryContainer = Color(0xFFE8F0E8);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF2C4A2E);

  // ==================== SECONDARY ====================
  static const Color secondaryLight = Color(0xFF7A8A7F);
  static const Color secondaryDark = Color(0xFFABBCAF);
  static const Color secondaryContainer = Color(0xFFE5EBE6);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF303D32);

  // --- Dark-mode secondary containers (ADDED) ---
  static const Color secondaryDarkContainer = Color(0xFF3A4A3D);
  static const Color onSecondaryDark = Color(0xFFD6E3D8);

  // ==================== TERTIARY ====================
  static const Color tertiaryLight = Color(0xFFB8A194);
  static const Color tertiaryDark = Color(0xFFD4C4B8);
  static const Color tertiaryContainer = Color(0xFFF2EDE8);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF3E2E24);

  // --- Dark-mode tertiary containers (ADDED) ---
  static const Color tertiaryDarkContainer = Color(0xFF4A3B32);
  static const Color onTertiaryDark = Color(0xFFE8DDD6);

  // ==================== ERROR ====================
  static const Color errorLight = Color(0xFFD17B7B);
  static const Color errorDark = Color(0xFFE5A3A3);
  static const Color errorContainer = Color(0xFFFCE8E8);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF5C2424);

  // --- Dark-mode error containers (ADDED) ---
  static const Color errorDarkContainer = Color(0xFF5C2424);
  static const Color onErrorDark = Color(0xFFF2D0D0);

  // ==================== BACKGROUND & SURFACE ====================
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF1A1A1A);
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceVariantLight = Color(0xFFF0F0F0);
  static const Color surfaceVariantDark = Color(0xFF2A2A2A);

  // ==================== ON BACKGROUND & SURFACE ====================
  static const Color onBackgroundLight = Color(0xFF2A2A2A);
  static const Color onBackgroundDark = Color(0xFFF0F0F0);
  static const Color onSurfaceLight = Color(0xFF2A2A2A);
  static const Color onSurfaceDark = Color(0xFFF0F0F0);
  static const Color onSurfaceVariantLight = Color(0xFF5A5A5A);
  static const Color onSurfaceVariantDark = Color(0xFFCCCCCC);

  // ==================== OUTLINE ====================
  static const Color outlineLight = Color(0xFFD9D9D9);
  static const Color outlineDark = Color(0xFF3A3A3A);
  static const Color outlineVariantLight = Color(0xFFE8E8E8);
  static const Color outlineVariantDark = Color(0xFF2A2A2A);

  // ==================== SPECIAL PURPOSE ====================
  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);
  static const Color inverseSurfaceLight = Color(0xFF2A2A2A);
  static const Color inverseSurfaceDark = Color(0xFFF0F0F0);
  static const Color inverseOnSurfaceLight = Color(0xFFFAFAFA);
  static const Color inverseOnSurfaceDark = Color(0xFF2A2A2A);
  static const Color inversePrimaryLight = Color(0xFF9FBE9F);
  static const Color inversePrimaryDark = Color(0xFF8DAA91);

  // ==================== CONVENIENCE ALIASES ====================
  static const Color primaryColor = primaryLight;
  static const Color secondaryColor = secondaryLight;
  static const Color tertiaryColor = tertiaryLight;
  static const Color errorColor = errorLight;
  static const Color successColor = Color(0xFF8DAA91);
  static const Color warningColor = Color(0xFFD9B382);
  static const Color infoColor = Color(0xFF8FA3B8);
  static const Color accentColor = Color(0xFF8DAA91);
  static const Color primary = primaryColor;

  // ==================== MEDIA TYPE COLORS ====================
  static const Color imageColor = Color(0xFF4CAF50);
  static const Color audioColor = Color(0xFFFF9800);
  static const Color videoColor = Color(0xFF2196F3);
  static const Color documentColor = Color(0xFF9C27B0);

  // ==================== GREY SCALE ====================
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color greyDark = Color(0xFF424242);

  // ==================== OPACITY VARIANTS ====================
  static const Color whiteOpacity90 = Color(0xE6FFFFFF);
  static const Color whiteOpacity70 = Color(0xB3FFFFFF);
  static const Color whiteOpacity54 = Color(0x8AFFFFFF);
  static const Color whiteOpacity24 = Color(0x3DFFFFFF);
  static const Color whiteOpacity10 = Color(0x1AFFFFFF);
  static const Color blackOpacity87 = Color(0xDE000000);
  static const Color blackOpacity05 = Color(0x0DFFFFFF);
  static const Color blackOpacity20 = Color(0x33000000);

  // ==================== STATUS COLORS ====================
  static const Color successLight = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF81C784);
  static const Color warningLight = Color(0xFFFFA726);
  static const Color warningDark = Color(0xFFFFB74D);
  static const Color infoLight = Color(0xFF29B6F6);
  static const Color infoDark = Color(0xFF4FC3F7);

  // ==================== TODO STATUS ====================
  static const Color todoCompleted = Color(0xFF4CAF50);
  static const Color todoPending = Color(0xFFFF9800);
  static const Color todoOverdue = Color(0xFFF44336);

  // ==================== ALARM ====================
  static const Color alarmActive = Color(0xFFE91E63);
  static const Color alarmInactive = Color(0xFF9E9E9E);

  // ==================== GRADIENTS ====================
  static const List<Color> primaryGradient = [
    Color(0xFF6750A4),
    Color(0xFF7E57C2),
  ];
  static const List<Color> secondaryGradient = [
    Color(0xFF625B71),
    Color(0xFF7E57C2),
  ];

  // ==================== SHIMMER ====================
  static const Color shimmerBaseLight = Color(0xFFE0E0E0);
  static const Color shimmerHighlightLight = Color(0xFFF5F5F5);
  static const Color shimmerBaseDark = Color(0xFF2C2C2C);
  static const Color shimmerHighlightDark = Color(0xFF3C3C3C);

  // ==================== MODULE ALIASES ====================
  static const Color lightBackground = backgroundLight;
  static const Color darkBackground = backgroundDark;
  static const Color lightCardBackground = surfaceVariantLight;
  static const Color darkCardBackground = surfaceVariantDark;
  static const Color lightText = onBackgroundLight;
  static const Color darkText = onBackgroundDark;
  static const Color outlineColor = outlineLight;

  // ==================== FOCUS MODULE ====================
  static const Color focusDeepViolet = Color(0xFF1e1b4b);
  static const Color focusMidnightBlue = Color(0xFF0f172a);
  static const Color focusPurpleOrb = Color(0xFF4c1d95);
  static const Color focusVioletOrb = Color(0xFF5b21b6);
  static const Color focusBlueOrb = Color(0xFF1e3a8a);
  static const Color focusAccentGreen = Color(0xFFa7f3d0);
  static const Color focusIndigoLight = Color(0xFFA5B4FC);

  // ==================== ACCENT COLORS ====================
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentPurple = Color(0xFF8B5CF6);
}
