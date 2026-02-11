import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mynotes/core/routes/app_router.dart';

/// Global UI Service for context-less interactions
/// Handles Snackbars, Dialogs, Loaders, and Haptics
class GlobalUiService {
  final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // Use the existing navigator key from AppRouter to avoid duplicates
  GlobalKey<NavigatorState> get navigatorKey => AppRouter.navigatorKey;

  // Loader state
  final ValueNotifier<bool> _loadingNotifier = ValueNotifier<bool>(false);
  ValueListenable<bool> get loadingListenable => _loadingNotifier;

  void showLoader() => _loadingNotifier.value = true;
  void hideLoader() => _loadingNotifier.value = false;

  // --- Snackbars ---

  void showSuccess(
    String message, {
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    _showSnackbar(
      message,
      backgroundColor: Colors.green.shade800,
      icon: Icons.check_circle_outline,
      action: (actionLabel != null && onActionPressed != null)
          ? SnackBarAction(label: actionLabel, onPressed: onActionPressed)
          : null,
    );
    vibrate(HapticType.success);
  }

  void showError(
    String message, {
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    _showSnackbar(
      message,
      backgroundColor: Colors.red.shade800,
      icon: Icons.error_outline,
      duration: const Duration(seconds: 4),
      action: (actionLabel != null && onActionPressed != null)
          ? SnackBarAction(label: actionLabel, onPressed: onActionPressed)
          : null,
    );
    vibrate(HapticType.error);
  }

  void showWarning(
    String message, {
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    _showSnackbar(
      message,
      backgroundColor: Colors.orange.shade900,
      icon: Icons.warning_amber_outlined,
      action: (actionLabel != null && onActionPressed != null)
          ? SnackBarAction(label: actionLabel, onPressed: onActionPressed)
          : null,
    );
    vibrate(HapticType.warning);
  }

  void showInfo(
    String message, {
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    _showSnackbar(
      message,
      backgroundColor: Colors.blueGrey.shade800,
      icon: Icons.info_outline,
      action: (actionLabel != null && onActionPressed != null)
          ? SnackBarAction(label: actionLabel, onPressed: onActionPressed)
          : null,
    );
  }

  void _showSnackbar(
    String message, {
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    messengerKey.currentState?.hideCurrentSnackBar();
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(12),
        action: action,
      ),
    );
  }

  // --- Dialogs & Bottom Sheets ---

  Future<T?> showCustomDialog<T>({
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) return Future.value(null);

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }

  Future<T?> showCustomModal<T>({
    required Widget Function(BuildContext) builder,
    bool isScrollControlled = true,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) return Future.value(null);

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: builder,
    );
  }

  // --- Haptics ---

  void vibrate(HapticType type) {
    switch (type) {
      case HapticType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticType.success:
        HapticFeedback.mediumImpact(); // fallback for generic success
        break;
      case HapticType.warning:
        HapticFeedback.vibrate();
        break;
      case HapticType.error:
        HapticFeedback.vibrate();
        break;
      case HapticType.selection:
        HapticFeedback.selectionClick();
        break;
    }
  }

  void hapticFeedback([HapticType type = HapticType.medium]) {
    vibrate(type);
  }
}

enum HapticType { light, medium, heavy, success, warning, error, selection }
