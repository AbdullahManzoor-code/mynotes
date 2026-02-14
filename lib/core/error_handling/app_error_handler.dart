/// Global Error Handler & Recovery Manager
/// Handles all exceptions across app flows with recovery strategies
library;

import 'package:flutter/material.dart';
import 'package:mynotes/core/exceptions/app_exceptions.dart';
import 'package:mynotes/core/services/global_ui_service.dart';
import 'package:mynotes/injection_container.dart';
import 'package:mynotes/core/services/app_logger.dart';

typedef ErrorCallback = Function(AppException error);
typedef RecoveryCallback = Function();

class AppErrorHandler {
  static final AppErrorHandler _instance = AppErrorHandler._internal();

  factory AppErrorHandler() => _instance;

  AppErrorHandler._internal();

  final List<ErrorCallback> _errorListeners = [];
  final Map<Type, RecoveryCallback> _recoveryStrategies = {};

  void registerErrorListener(ErrorCallback listener) {
    if (!_errorListeners.contains(listener)) {
      _errorListeners.add(listener);
    }
  }

  void removeErrorListener(ErrorCallback listener) {
    _errorListeners.remove(listener);
  }

  void registerRecoveryStrategy<T extends AppException>(
    RecoveryCallback callback,
  ) {
    _recoveryStrategies[T] = callback;
  }

  /// Main error handling method
  Future<void> handleError(
    AppException error, {
    String? userMessage,
    bool shouldRecover = true,
  }) async {
    // Log error using professional logger
    _logError(error);

    // Notify listeners (analytics, etc.)
    _notifyListeners(error);

    // Attempt recovery if applicable
    if (shouldRecover) {
      await _attemptRecovery(error);
    }

    // Show user-friendly message via Global UI Service
    final message = userMessage ?? _getUserMessage(error);
    getIt<GlobalUiService>().showError(message);
  }

  void _logError(AppException error) {
    AppLogger.e(
      '${error.code}: ${error.message}',
      error.originalError,
      error.stackTrace,
    );
  }

  void _notifyListeners(AppException error) {
    for (final listener in _errorListeners) {
      try {
        listener(error);
      } catch (e) {
        debugPrint('[ERROR] Listener notification failed: $e');
      }
    }
  }

  Future<void> _attemptRecovery(AppException error) async {
    final strategy = _recoveryStrategies[error.runtimeType];
    if (strategy != null) {
      try {
        await Future(() => strategy());
        debugPrint('[RECOVERY] Recovered from ${error.code}');
      } catch (e) {
        debugPrint('[RECOVERY] Recovery failed: $e');
      }
    }
  }

  String _getUserMessage(AppException error) {
    // User-friendly messages for different error types
    if (error is BiometricFailedException) {
      final attempts = error.attemptsRemaining;
      if (attempts != null && attempts > 0) {
        return 'Authentication failed. $attempts ${attempts == 1 ? 'attempt' : 'attempts'} remaining. Try again or use PIN.';
      }
      return 'Biometric authentication failed. Please use PIN instead.';
    }

    if (error is PINException) {
      final attempts = error.attemptsRemaining;
      if (attempts != null && attempts > 0) {
        return 'Incorrect PIN. $attempts ${attempts == 1 ? 'attempt' : 'attempts'} remaining.';
      }
      return 'Too many failed PIN attempts. Please try again later.';
    }

    if (error is InvalidReminderDateException) {
      return 'Invalid reminder date. Please select a future date and time.';
    }

    if (error is MaxPinnedNotesExceededException) {
      return 'You can only pin up to 10 notes. Unpin a note to pin another.';
    }

    if (error is NoteAutoSaveException) {
      return 'Failed to auto-save note. Please try again or your changes may be lost.';
    }

    if (error is CameraPermissionException) {
      return 'Camera access is required to capture images. Please enable it in settings.';
    }

    if (error is MicrophonePermissionException) {
      return 'Microphone access is required for voice input. Please enable it in settings.';
    }

    if (error is NotificationPermissionException) {
      return 'Notification permission is required for reminders. Please enable it in settings.';
    }

    if (error is MediaCompressionException) {
      return 'Failed to process image. Please try another image or check available storage.';
    }

    if (error is ReminderSchedulingException) {
      return 'Failed to schedule reminder. Please check date/time and try again.';
    }

    if (error is TodoCreationException) {
      return 'Failed to create task. Please check your input and try again.';
    }

    if (error is ReflectionSaveException) {
      return 'Failed to save reflection. Your answer may not be lost. Please try again.';
    }

    if (error is BackupException) {
      return 'Failed to create backup. Please check available storage and try again.';
    }

    if (error is RestoreException) {
      return 'Failed to restore backup. Please ensure the backup file is valid and try again.';
    }

    if (error is DatabaseInitializationException) {
      return 'Failed to initialize database. Please restart the app.';
    }

    // Generic message
    return error.message;
  }

  void _showUserMessage(String message) {
    debugPrint('[USER MESSAGE] $message');
    // This will be intercepted by UI layer via listener
  }

  /// Show snackbar via BuildContext
  static void showErrorSnackbar(
    BuildContext context,
    AppException error, {
    Duration duration = const Duration(seconds: 4),
  }) {
    final handler = AppErrorHandler();
    final message = handler._getUserMessage(error);

    getIt<GlobalUiService>().showError(message);
  }

  /// Show recovery dialog
  static Future<bool> showErrorDialog(
    BuildContext context,
    AppException error, {
    VoidCallback? onRetry,
  }) async {
    final handler = AppErrorHandler();
    final message = handler._getUserMessage(error);

    return await getIt<GlobalUiService>().showCustomDialog<bool>(
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(
              _getErrorTitle(error),
              style: const TextStyle(color: Colors.red),
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              if (onRetry != null)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                    onRetry();
                  },
                  child: const Text('Retry'),
                ),
            ],
          ),
        ) ??
        false;
  }

  static String _getErrorTitle(AppException error) {
    if (error is BiometricException) return 'Authentication Error';
    if (error is PermissionException) return 'Permission Denied';
    if (error is NoteException) return 'Note Error';
    if (error is ReminderException) return 'Reminder Error';
    if (error is TodoException) return 'Task Error';
    if (error is MediaException) return 'Media Error';
    if (error is VoiceException) return 'Voice Error';
    if (error is ReflectionException) return 'Reflection Error';
    if (error is BackupException) return 'Backup Error';
    if (error is DatabaseInitializationException) return 'Database Error';
    return 'Error';
  }

  /// Clear all listeners and strategies
  void clear() {
    _errorListeners.clear();
    _recoveryStrategies.clear();
  }
}

/// Error Boundary Widget for catching and displaying errors
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(AppException error)? errorBuilder;
  final VoidCallback? onError;

  const ErrorBoundary({
    required this.child,
    this.errorBuilder,
    this.onError,
    super.key,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  AppException? _error;

  @override
  void initState() {
    super.initState();
    AppErrorHandler().registerErrorListener(_handleError);
  }

  @override
  void dispose() {
    AppErrorHandler().removeErrorListener(_handleError);
    super.dispose();
  }

  void _handleError(AppException error) {
    setState(() {
      _error = error;
    });
    widget.onError?.call();
  }

  void _clearError() {
    setState(() {
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ??
          _buildDefaultErrorWidget(context, _error!);
    }

    return widget.child;
  }

  Widget _buildDefaultErrorWidget(BuildContext context, AppException error) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Colors.red.shade700,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                error.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _clearError,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
