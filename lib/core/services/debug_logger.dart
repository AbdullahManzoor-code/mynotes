import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'app_logger.dart';

/// Debug logger that captures all app events to a file for later analysis
class DebugLogger {
  static final DebugLogger _instance = DebugLogger._internal();
  static File? _logFile;
  static bool _initialized = false;

  factory DebugLogger() {
    return _instance;
  }

  DebugLogger._internal();

  /// Initialize debug logger (call in main.dart)
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final logDir = Directory('${appDir.path}/mynotes_logs');

      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toString().replaceAll(':', '-');
      _logFile = File('${logDir.path}/debug_$timestamp.log');

      await _log('=== MyNotes Debug Session Started ===');
      await _log('Device: ${Platform.operatingSystem}');
      await _log('Time: ${DateTime.now()}');

      _initialized = true;
      AppLogger.i('DebugLogger initialized: ${_logFile!.path}');
    } catch (e) {
      AppLogger.e('Failed to initialize DebugLogger', e, StackTrace.current);
    }
  }

  /// Log event (automatically called)
  static Future<void> log(String message, {String level = 'INFO'}) async {
    await _log('[$level] $message');
  }

  /// Log error
  static Future<void> logError(
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) async {
    await _log('[ERROR] $message');
    if (error != null) await _log('  Error: $error');
    if (stackTrace != null) await _log('  Stack: $stackTrace');
  }

  /// Log event
  static Future<void> _log(String message) async {
    if (!_initialized || _logFile == null) return;

    try {
      final timestamp = DateTime.now().toString();
      final fullMessage = '[$timestamp] $message\n';
      await _logFile!.writeAsString(fullMessage, mode: FileMode.append);
    } catch (e) {
      // Silent fail to prevent recursive errors
    }
  }

  /// Get log file path (for sharing/viewing)
  static String? getLogFilePath() => _logFile?.path;

  /// Clear old logs (older than 7 days)
  static Future<void> clearOldLogs() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final logDir = Directory('${appDir.path}/mynotes_logs');

      if (!await logDir.exists()) return;

      final files = logDir.listSync();
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          if (stat.modified.isBefore(sevenDaysAgo)) {
            await file.delete();
          }
        }
      }

      await _log('Cleared old logs');
    } catch (e) {
      AppLogger.e('Failed to clear old logs', e, StackTrace.current);
    }
  }

  /// Read current log file
  static Future<String> readCurrentLog() async {
    if (_logFile == null || !await _logFile!.exists()) {
      return 'No log file available';
    }

    try {
      return await _logFile!.readAsString();
    } catch (e) {
      return 'Failed to read log: $e';
    }
  }
}

/// Extension to AppLogger for automatic debug logging
extension DebugLogging on AppLogger {
  static void setupDebugLogging() {
    // Call this in main.dart after initializing AppLogger
  }
}
