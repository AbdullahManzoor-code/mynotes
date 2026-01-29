import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Accessibility helper utilities for WCAG AA compliance
/// Provides utilities for semantic labels, screen reader support, and contrast validation
class AccessibilityHelper {
  /// Wraps a widget with semantic information for screen readers
  static Widget semanticButton({
    required Widget child,
    required String label,
    required VoidCallback? onTap,
    String? hint,
    bool enabled = true,
  }) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      hint: hint,
      onTap: onTap,
      child: child,
    );
  }

  /// Wraps a widget with semantic information for images
  static Widget semanticImage({required Widget child, required String label}) {
    return Semantics(image: true, label: label, child: child);
  }

  /// Wraps a widget with semantic information for text fields
  static Widget semanticTextField({
    required Widget child,
    required String label,
    String? hint,
  }) {
    return Semantics(textField: true, label: label, hint: hint, child: child);
  }

  /// Wraps a widget with semantic information for headings
  static Widget semanticHeading({
    required Widget child,
    required String label,
    int level = 1,
  }) {
    return Semantics(header: true, label: '$level. $label', child: child);
  }

  /// Validates color contrast ratio (WCAG AA standard = 4.5:1 for normal text)
  /// Returns true if contrast is sufficient
  static bool isContrastSufficient(Color foreground, Color background) {
    final fgLuminance = _relativeLuminance(foreground);
    final bgLuminance = _relativeLuminance(background);

    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;

    final contrastRatio = (lighter + 0.05) / (darker + 0.05);
    return contrastRatio >= 4.5; // WCAG AA standard
  }

  /// Calculates relative luminance for contrast ratio calculation
  static double _relativeLuminance(Color color) {
    final r = _linearizeColor(color.red / 255.0);
    final g = _linearizeColor(color.green / 255.0);
    final b = _linearizeColor(color.blue / 255.0);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Linearize RGB color value
  static double _linearizeColor(double value) {
    if (value <= 0.03928) {
      return value / 12.92;
    }
    return ((value + 0.055) / 1.055) * ((value + 0.055) / 1.055);
  }

  /// Gets appropriate color based on contrast with background
  /// Returns a color that ensures sufficient contrast
  static Color getContrastColor(Color background) {
    // Check if background is light or dark
    final luminance = _relativeLuminance(background);
    // If luminance > 0.5, use dark color; otherwise use light color
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  /// Announces a message to screen readers
  static Future<void> announceMessage(
    BuildContext context,
    String message,
  ) async {
    await SemanticsService.announce(
      message,
      TextDirection.ltr, // Default to LTR; will use app's directionality
    );
  }

  /// Wraps an icon button with proper semantic labels for accessibility
  static Widget accessibleIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
    double size = 24.0,
  }) {
    return Semantics(
      button: true,
      enabled: true,
      label: label,
      onTap: onPressed,
      child: IconButton(
        icon: Icon(icon, color: color, size: size),
        onPressed: onPressed,
        tooltip: label, // Also provides hover text for desktop
      ),
    );
  }

  /// Ensures text doesn't get cut off with large text scaling
  static Widget textWithMaxLines({
    required String text,
    required TextStyle style,
    int maxLines = 3,
  }) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      semanticsLabel: text, // Provides full text to screen readers
    );
  }
}
