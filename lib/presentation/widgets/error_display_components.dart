import 'package:flutter/material.dart';
import 'package:mynotes/core/exceptions/app_exceptions.dart';
import 'package:mynotes/presentation/design_system/app_typography.dart';
import 'package:mynotes/injection_container.dart' show getIt;
import 'package:mynotes/core/services/global_ui_service.dart';

/// Global error display component utilities
/// Provides reusable error snackbars, dialogs, and inline feedback

class ErrorDisplay {
  /// Show error snackbar with optional retry button
  static void showErrorSnackbar(
    BuildContext context, {
    required String message,
    String? code,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    getIt<GlobalUiService>().showError(
      code != null ? '$message (Error: $code)' : message,
    );
  }

  /// Show warning snackbar
  static void showWarningSnackbar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    getIt<GlobalUiService>().showWarning(message);
  }

  /// Show success snackbar
  static void showSuccessSnackbar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    getIt<GlobalUiService>().showSuccess(message);
  }

  /// Show error dialog for critical errors
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? code,
    dynamic originalError,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTypography.heading1(
                  context,
                ).copyWith(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, style: AppTypography.body1(context)),
              if (code != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Error Code: $code',
                          style: AppTypography.caption(context).copyWith(
                            fontFamily: 'monospace',
                            color: Colors.red.shade700,
                          ),
                        ),
                        if (originalError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Details: ${originalError.toString()}',
                              style: AppTypography.caption(
                                context,
                              ).copyWith(color: Colors.grey.shade700),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: onDismiss ?? () => Navigator.pop(context),
            child: const Text('DISMISS'),
          ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
              ),
              child: const Text('RETRY'),
            ),
        ],
      ),
    );
  }

  /// Show validation error inline (for forms)
  static Widget buildValidationErrorWidget(
    BuildContext context,
    String message, {
    String? fieldName,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (fieldName != null)
                  Text(
                    fieldName,
                    style: AppTypography.bodySmall(context).copyWith(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                Text(
                  message,
                  style: AppTypography.bodySmall(
                    context,
                  ).copyWith(color: Colors.red.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build error banner for app-wide errors
  static Widget buildErrorBanner(
    BuildContext context,
    String message, {
    VoidCallback? onDismiss,
    String? code,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border(bottom: BorderSide(color: Colors.red.shade300)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: AppTypography.body1(
                    context,
                  ).copyWith(color: Colors.red.shade700),
                ),
                if (code != null)
                  Text(
                    'Code: $code',
                    style: AppTypography.caption(
                      context,
                    ).copyWith(color: Colors.red.shade600),
                  ),
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close),
              color: Colors.red.shade700,
              onPressed: onDismiss,
            ),
        ],
      ),
    );
  }

  /// Get user-friendly message from exception
  static String getUserMessage(AppException exception) {
    if (exception is BiometricFailedException) {
      return 'Authentication failed. Please try again.';
    }
    if (exception is BiometricNotAvailableException) {
      return 'Biometric authentication is not available on this device.';
    }
    if (exception is DatabaseException) {
      return 'Database error. Your changes may not be saved.';
    }
    if (exception is NetworkException) {
      return 'Network error. Please check your connection.';
    }
    if (exception is PermissionException) {
      return 'Permission denied. Please enable it in settings.';
    }
    if (exception is ReminderSchedulingException) {
      return 'Failed to schedule reminder. Please try again.';
    }
    if (exception is InvalidReminderDateException) {
      return 'Invalid reminder date. Please try again.';
    }
    if (exception is MediaException) {
      return 'Media operation failed. Please try again.';
    }

    // Default message
    return exception.message;
  }
}

/// Error state builder widget - for displaying errors in BLoC states
class ErrorStateBuilder extends StatelessWidget {
  final String errorMessage;
  final String? errorCode;
  final VoidCallback? onRetry;
  final IconData icon;
  final String title;

  const ErrorStateBuilder({
    super.key,
    required this.errorMessage,
    this.errorCode,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.title = 'Error',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.red.shade700),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.titleLarge(
                context,
              ).copyWith(color: Colors.red.shade700),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: AppTypography.body1(context),
            ),
            if (errorCode != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Error Code: $errorCode',
                  style: AppTypography.caption(
                    context,
                  ).copyWith(color: Colors.grey.shade600),
                ),
              ),
            const SizedBox(height: 24),
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('RETRY'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
