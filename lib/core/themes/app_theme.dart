import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Centralized theme configuration
/// Prevents code duplication and ensures consistent UI
class AppTheme {
  AppTheme._(); // Private constructor

  // ==================== LIGHT THEME WITH CUSTOM PRIMARY COLOR ====================
  static ThemeData buildLightTheme(Color customPrimaryColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: GoogleFonts.interTextTheme(),
      colorScheme: ColorScheme.light(
        primary: customPrimaryColor,
        onPrimary: Colors.white,
        primaryContainer: customPrimaryColor.withOpacity(0.1),
        onPrimaryContainer: customPrimaryColor,
        secondary: AppColors.secondaryLight,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiaryLight,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.errorLight,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.onSurfaceLight,
        surfaceContainerHighest: AppColors.surfaceVariantLight,
        onSurfaceVariant: AppColors.onSurfaceVariantLight,
        outline: AppColors.outlineLight,
        outlineVariant: AppColors.outlineVariantLight,
        shadow: AppColors.shadow,
        scrim: AppColors.scrim,
        inverseSurface: AppColors.inverseSurfaceLight,
        onInverseSurface: AppColors.inverseOnSurfaceLight,
        inversePrimary: customPrimaryColor,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: customPrimaryColor,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: customPrimaryColor),
        titleTextStyle: TextStyle(
          color: customPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0.5,
        shadowColor: AppColors.shadow.withOpacity(0.05),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: customPrimaryColor.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.all(16),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        backgroundColor: customPrimaryColor,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: customPrimaryColor.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: customPrimaryColor.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: customPrimaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorLight, width: 0.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        labelStyle: TextStyle(color: customPrimaryColor),
        hintStyle: const TextStyle(color: AppColors.onSurfaceVariantLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: customPrimaryColor,
          foregroundColor: Colors.white,
          side: BorderSide(color: customPrimaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: customPrimaryColor,
          side: BorderSide(color: customPrimaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: customPrimaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariantLight,
        selectedColor: AppColors.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariantLight,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? customPrimaryColor
              : Colors.grey.shade400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? customPrimaryColor.withOpacity(0.5)
              : Colors.grey.shade400.withOpacity(0.3);
        }),
      ),
    );
  }

  // ==================== DARK THEME WITH CUSTOM PRIMARY COLOR ====================
  static ThemeData buildDarkTheme(Color customPrimaryColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      colorScheme: ColorScheme.dark(
        primary: customPrimaryColor,
        onPrimary: Colors.black,
        primaryContainer: customPrimaryColor.withOpacity(0.2),
        onPrimaryContainer: customPrimaryColor.withOpacity(0.9),
        secondary: AppColors.secondaryDark,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryDarkContainer,
        onSecondaryContainer: AppColors.onSecondaryDark,
        tertiary: AppColors.tertiaryDark,
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.tertiaryDarkContainer,
        onTertiaryContainer: AppColors.onTertiaryDark,
        error: AppColors.errorDark,
        onError: Colors.black,
        errorContainer: AppColors.errorDarkContainer,
        onErrorContainer: AppColors.onErrorDark,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.onSurfaceDark,
        surfaceContainerHighest: AppColors.surfaceVariantDark,
        onSurfaceVariant: AppColors.onSurfaceVariantDark,
        outline: AppColors.outlineDark,
        outlineVariant: AppColors.outlineVariantDark,
        shadow: AppColors.shadow,
        scrim: AppColors.scrim,
        inverseSurface: AppColors.inverseSurfaceDark,
        onInverseSurface: AppColors.inverseOnSurfaceDark,
        inversePrimary: customPrimaryColor,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: customPrimaryColor,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: customPrimaryColor),
        titleTextStyle: TextStyle(
          color: customPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0.5,
        shadowColor: AppColors.shadow.withOpacity(0.15),
        color: const Color(0xFF222222),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: customPrimaryColor.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.all(16),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        backgroundColor: customPrimaryColor,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF222222),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: customPrimaryColor.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.outlineVariantDark,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: customPrimaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorDark, width: 0.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        labelStyle: TextStyle(color: customPrimaryColor),
        hintStyle: const TextStyle(color: AppColors.onSurfaceVariantDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: customPrimaryColor,
          foregroundColor: Colors.black,
          side: BorderSide(color: customPrimaryColor),
          elevation: 0.5,
          shadowColor: AppColors.shadow.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: customPrimaryColor,
          side: BorderSide(color: customPrimaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: customPrimaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariantDark,
        selectedColor: AppColors.onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariantDark,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? customPrimaryColor
              : Colors.grey.shade600;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? customPrimaryColor.withOpacity(0.5)
              : Colors.grey.shade600.withOpacity(0.3);
        }),
      ),
    );
  }

  // ==================== DEFAULT THEME GETTERS ====================

  /// Light Theme - Calm & Minimalist Design
  static ThemeData get lightTheme => buildLightTheme(AppColors.primaryLight);

  /// Dark Theme - Calm & Minimalist Design
  static ThemeData get darkTheme => buildDarkTheme(AppColors.primaryDark);

  // ==================== HIGH CONTRAST THEMES ====================

  /// High Contrast Light Theme
  static ThemeData get highContrastLightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: GoogleFonts.interTextTheme(),
      colorScheme: const ColorScheme.light(
        primary: Colors.black,
        onPrimary: Colors.white,
        primaryContainer: Colors.black87,
        onPrimaryContainer: Colors.white,
        secondary: Colors.black,
        onSecondary: Colors.white,
        secondaryContainer: Colors.black87,
        onSecondaryContainer: Colors.white,
        tertiary: Colors.black,
        onTertiary: Colors.white,
        tertiaryContainer: Colors.black87,
        onTertiaryContainer: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        errorContainer: Colors.red,
        onErrorContainer: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
        surfaceContainerHighest: Colors.black26,
        onSurfaceVariant: Colors.black87,
        outline: Colors.black,
        outlineVariant: Colors.black45,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: Colors.black,
        onInverseSurface: Colors.white,
        inversePrimary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 2,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
      ),
      scaffoldBackgroundColor: Colors.white,
    );
  }

  /// High Contrast Dark Theme
  static ThemeData get highContrastDarkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        onPrimary: Colors.black,
        primaryContainer: Colors.white70,
        onPrimaryContainer: Colors.black,
        secondary: Colors.white,
        onSecondary: Colors.black,
        secondaryContainer: Colors.white70,
        onSecondaryContainer: Colors.black,
        tertiary: Colors.white,
        onTertiary: Colors.black,
        tertiaryContainer: Colors.white70,
        onTertiaryContainer: Colors.black,
        error: Colors.yellow,
        onError: Colors.black,
        errorContainer: Colors.yellow,
        onErrorContainer: Colors.black,
        surface: Colors.black,
        onSurface: Colors.white,
        surfaceContainerHighest: Colors.white24,
        onSurfaceVariant: Colors.white70,
        outline: Colors.white,
        outlineVariant: Colors.white30,
        shadow: Colors.white,
        scrim: Colors.white,
        inverseSurface: Colors.white,
        onInverseSurface: Colors.black,
        inversePrimary: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
      scaffoldBackgroundColor: Colors.black,
    );
  }
}
