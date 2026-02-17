import 'package:flutter/material.dart';

/// Extension methods on BuildContext for convenient access to common properties
extension ContextExtensions on BuildContext {
  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Get device padding (notches, etc)
  EdgeInsets get devicePadding => MediaQuery.of(this).padding;

  /// Get device viewInsets (keyboard, etc)
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  /// Get theme data
  ThemeData get theme => Theme.of(this);

  /// Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get color scheme (Material 3)
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Check if dark mode is enabled
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Check if light mode is enabled
  bool get isLight => Theme.of(this).brightness == Brightness.light;

  /// Get primary color
  Color get primaryColor => colorScheme.primary;

  /// Get secondary color
  Color get secondaryColor => colorScheme.secondary;

  /// Get error color
  Color get errorColor => colorScheme.error;

  /// Get surface color
  Color get surfaceColor => colorScheme.surface;

  /// Get surface color with tint
  Color get surfaceTint => colorScheme.surfaceTint;

  /// Check if device is in landscape
  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;

  /// Check if device is in portrait
  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;

  /// Get keyboard height
  double get keyboardHeight => viewInsets.bottom;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => keyboardHeight > 0;

  /// Pop current page
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  /// Push named route
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) =>
      Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);

  /// Push named route and replace
  Future<T?> pushReplacementNamed<T>(String routeName, {Object? arguments}) =>
      Navigator.of(
        this,
      ).pushReplacementNamed<T, dynamic>(routeName, arguments: arguments);

  /// Pop until route name
  void popUntil(String routeName) =>
      Navigator.of(this).popUntil(ModalRoute.withName(routeName));

  /// Push and remove all
  Future<T?> pushNamedAndRemoveUntil<T>(
    String routeName, {
    Object? arguments,
    required bool Function(Route) predicate,
  }) => Navigator.of(
    this,
  ).pushNamedAndRemoveUntil<T>(routeName, predicate, arguments: arguments);

  /// Show snackbar with message
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    Color? textColor,
    SnackBarAction? action,
  }) {
    return ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: backgroundColor,
        action: action,
      ),
    );
  }

  /// Show error snackbar
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showErrorSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    return showSnackBar(
      message,
      duration: duration,
      backgroundColor: errorColor,
      textColor: Colors.white,
    );
  }

  /// Show success snackbar
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSuccessSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    return showSnackBar(
      message,
      duration: duration,
      backgroundColor: colorScheme.primary,
      textColor: Colors.white,
    );
  }

  /// Show simple dialog
  Future<T?> showSimpleDialog<T>({
    required String title,
    required String content,
    required List<SimpleDialogOption> options,
  }) {
    return showDialog<T>(
      context: this,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(content),
          ),
          const SizedBox(height: 16),
          ...options,
        ],
      ),
    );
  }

  /// Show alert dialog
  Future<bool?> showConfirmDialog({
    required String title,
    required String content,
    String confirmText = 'Yes',
    String cancelText = 'No',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmText,
              style: TextStyle(
                color: isDestructive ? errorColor : primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hide keyboard
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
}
