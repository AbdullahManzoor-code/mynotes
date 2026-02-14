import 'package:flutter/material.dart';
import 'package:mynotes/core/error_handling/app_error_handler.dart';
import 'package:mynotes/core/exceptions/app_exceptions.dart';
import 'package:mynotes/presentation/widgets/error_display_components.dart';

/// Global Error Handler Listener
/// Integrates app error handler with UI error display
class GlobalErrorHandlerListener extends StatefulWidget {
  final Widget child;

  const GlobalErrorHandlerListener({super.key, required this.child});

  @override
  State<GlobalErrorHandlerListener> createState() =>
      _GlobalErrorHandlerListenerState();
}

class _GlobalErrorHandlerListenerState
    extends State<GlobalErrorHandlerListener> {
  final AppErrorHandler _errorHandler = AppErrorHandler();

  @override
  void initState() {
    super.initState();
    _setupErrorHandling();
  }

  void _setupErrorHandling() {
    // Only register recovery strategies here
    // UI display is now handled globally by AppErrorHandler using GlobalUiService
    _setupRecoveryStrategies();
  }

  void _setupRecoveryStrategies() {
    // Database errors - attempt to recreate connection
    _errorHandler.registerRecoveryStrategy<DatabaseException>(() {
      debugPrint('[GlobalErrorHandler] Attempting database recovery...');
      // Recovery logic here
    });

    // Network errors - retry the operation
    _errorHandler.registerRecoveryStrategy<NetworkException>(() {
      debugPrint('[GlobalErrorHandler] Network error recovery triggered');
      // Recovery logic here
    });

    // Permission errors - prompt user to enable
    _errorHandler.registerRecoveryStrategy<PermissionException>(() {
      debugPrint('[GlobalErrorHandler] Permission recovery triggered');
      // Recovery logic here
    });

    // Biometric errors - fallback to PIN
    _errorHandler.registerRecoveryStrategy<BiometricFailedException>(() {
      debugPrint('[GlobalErrorHandler] Biometric fallback to PIN');
      // Recovery logic here
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Error State Wrapper for BLoCs
/// Simplifies error handling in BLoC states
class ErrorStateWrapper extends StatelessWidget {
  final String? errorMessage;
  final String? errorCode;
  final VoidCallback? onRetry;
  final Widget? child;
  final String errorTitle;

  const ErrorStateWrapper({
    super.key,
    this.errorMessage,
    this.errorCode,
    this.onRetry,
    this.child,
    this.errorTitle = 'Operation Failed',
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return ErrorStateBuilder(
        title: errorTitle,
        errorMessage: errorMessage!,
        errorCode: errorCode,
        onRetry: onRetry,
      );
    }

    return child ?? const SizedBox.shrink();
  }
}
