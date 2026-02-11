import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

/// Professional Logging Service
/// Centralizes app logs with severity levels
class AppLogger {
  static void i(String message, [Object? error, StackTrace? stackTrace]) {
    _log('INFO', message, error, stackTrace);
  }

  static void w(String message, [Object? error, StackTrace? stackTrace]) {
    _log('WARNING', message, error, stackTrace);
  }

  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', message, error, stackTrace);
  }

  static void c(String message, [Object? error, StackTrace? stackTrace]) {
    _log('CRITICAL', message, error, stackTrace);
  }

  static void _log(
    String level,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    if (!kDebugMode && level != 'CRITICAL' && level != 'ERROR') return;

    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [$level] $message';

    if (error != null) {
      dev.log(
        logMessage,
        error: error,
        stackTrace: stackTrace,
        name: 'AppLogger',
      );
    } else {
      dev.log(logMessage, name: 'AppLogger');
    }

    // In a real production app, we would send errors/critical logs to Sentry/Crashlytics here
  }
}
