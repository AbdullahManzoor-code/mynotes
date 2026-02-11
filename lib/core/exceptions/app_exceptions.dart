// lib/core/exceptions/app_exceptions.dart

/// ============================================================================
/// 🚨 COMPREHENSIVE APPLICATION EXCEPTION HIERARCHY
/// ============================================================================
/// Covers all 19 flows: Launch, Notes, Reminders, Todos, Reflection,
/// Focus, Voice, Search, Settings, Backup, Calendar, Media, etc.
///
/// Usage:
/// ```dart
/// try {
///   await someOperation();
/// } on NoteNotFoundException catch (e) {
///   // Handle specific exception
/// } on NoteException catch (e) {
///   // Handle any note exception
/// } on AppException catch (e) {
///   // Handle any app exception
/// } catch (e) {
///   // Handle unknown errors
/// }
/// ```
/// ============================================================================

import 'package:flutter/foundation.dart';

/// ============================================================================
/// BASE EXCEPTION CLASS
/// ============================================================================

/// Base exception class for all app exceptions
/// Provides consistent error handling across the application
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  }) : timestamp = DateTime.now();

  /// Check if this exception is recoverable
  bool get isRecoverable => true;

  /// Check if this exception should be reported to analytics
  bool get shouldReport => true;

  /// Get user-friendly message
  String get userMessage => message;

  /// Get detailed debug info
  String get debugInfo {
    final buffer = StringBuffer();
    buffer.writeln('[$code] $message');
    buffer.writeln('Time: $timestamp');
    if (originalError != null) {
      buffer.writeln('Original Error: $originalError');
    }
    if (stackTrace != null) {
      buffer.writeln('Stack Trace: $stackTrace');
    }
    return buffer.toString();
  }

  /// Log the exception
  void log() {
    debugPrint('🚨 ${runtimeType}: $debugInfo');
  }

  @override
  String toString() => '${runtimeType}: $message (code: $code)';

  /// Convert to Map for serialization/logging
  Map<String, dynamic> toMap() {
    return {
      'type': runtimeType.toString(),
      'message': message,
      'code': code,
      'timestamp': timestamp.toIso8601String(),
      'originalError': originalError?.toString(),
      'isRecoverable': isRecoverable,
    };
  }
}

/// ============================================================================
/// INITIALIZATION & LAUNCH FLOW EXCEPTIONS
/// ============================================================================

/// Exception during app initialization
class AppInitializationException extends AppException {
  AppInitializationException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'INIT_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  bool get isRecoverable => false;

  @override
  String get userMessage => 'Failed to start the app. Please restart.';
}

/// Exception during database initialization
class DatabaseInitializationException extends AppException {
  DatabaseInitializationException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'DB_INIT_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  bool get isRecoverable => false;

  @override
  String get userMessage =>
      'Database initialization failed. Please reinstall the app.';
}

/// Exception when loading preferences
class PreferencesLoadException extends AppException {
  PreferencesLoadException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'PREF_LOAD_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Failed to load settings. Using defaults.';
}

/// ============================================================================
/// DATABASE EXCEPTIONS
/// ============================================================================

/// General database operation exception
class DatabaseException extends AppException {
  final String? operation; // 'insert', 'update', 'delete', 'query'
  final String? table;

  DatabaseException({
    required String message,
    this.operation,
    this.table,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'DATABASE_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Database operation failed. Please try again.';
}

/// Database migration exception
class DatabaseMigrationException extends DatabaseException {
  final int? fromVersion;
  final int? toVersion;

  DatabaseMigrationException({
    required String message,
    this.fromVersion,
    this.toVersion,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'DB_MIGRATION_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  bool get isRecoverable => false;
}

/// ============================================================================
/// AUTHENTICATION & SECURITY EXCEPTIONS
/// ============================================================================

/// Base biometric exception
class BiometricException extends AppException {
  BiometricException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'BIOMETRIC_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// Biometric not available on device
class BiometricNotAvailableException extends BiometricException {
  BiometricNotAvailableException({
    String message = 'Biometric authentication is not available on this device',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'BIOMETRIC_NOT_AVAILABLE',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage =>
      'Biometric authentication is not available. Please use PIN.';
}

/// Biometric authentication failed
class BiometricFailedException extends BiometricException {
  final int? attemptsRemaining;
  final bool isLocked;

  BiometricFailedException({
    required String message,
    this.attemptsRemaining,
    this.isLocked = false,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: isLocked ? 'BIOMETRIC_LOCKED' : 'BIOMETRIC_FAILED',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage {
    if (isLocked) {
      return 'Biometric locked. Please use PIN.';
    }
    if (attemptsRemaining != null && attemptsRemaining! > 0) {
      return 'Authentication failed. $attemptsRemaining attempts remaining.';
    }
    return 'Biometric authentication failed.';
  }
}

/// PIN related exception
class PINException extends AppException {
  final int? attemptsRemaining;
  final bool isLocked;
  final Duration? lockDuration;

  PINException({
    required String message,
    this.attemptsRemaining,
    this.isLocked = false,
    this.lockDuration,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? (isLocked ? 'PIN_LOCKED' : 'PIN_ERROR'),
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage {
    if (isLocked && lockDuration != null) {
      final minutes = lockDuration!.inMinutes;
      return 'Too many attempts. Try again in $minutes minutes.';
    }
    if (attemptsRemaining != null && attemptsRemaining! > 0) {
      return 'Incorrect PIN. $attemptsRemaining attempts remaining.';
    }
    return 'PIN verification failed.';
  }
}

/// PIN mismatch exception
class PINMismatchException extends PINException {
  PINMismatchException({
    String message = 'PINs do not match',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'PIN_MISMATCH',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'PINs do not match. Please try again.';
}

/// ============================================================================
/// NOTES MODULE EXCEPTIONS
/// ============================================================================

/// Base note exception
class NoteException extends AppException {
  final String? noteId;

  NoteException({
    required String message,
    this.noteId,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'NOTE_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// Note not found
class NoteNotFoundException extends NoteException {
  NoteNotFoundException({
    required String noteId,
    String? message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message ?? 'Note not found: $noteId',
         noteId: noteId,
         code: 'NOTE_NOT_FOUND',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Note not found. It may have been deleted.';
}

/// Note creation failed
class NoteCreationException extends NoteException {
  NoteCreationException({
    required String message,
    String? noteId,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         noteId: noteId,
         code: 'NOTE_CREATE_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Failed to create note. Please try again.';
}

/// Note auto-save failed
class NoteAutoSaveException extends NoteException {
  NoteAutoSaveException({
    required String message,
    String? noteId,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         noteId: noteId,
         code: 'NOTE_AUTOSAVE_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Auto-save failed. Your changes may not be saved.';
}

/// Note update failed
class NoteUpdateException extends NoteException {
  NoteUpdateException({
    required String message,
    String? noteId,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         noteId: noteId,
         code: 'NOTE_UPDATE_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Failed to save note. Please try again.';
}

/// Note deletion failed
class NoteDeletionException extends NoteException {
  NoteDeletionException({
    required String message,
    String? noteId,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         noteId: noteId,
         code: 'NOTE_DELETE_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Failed to delete note. Please try again.';
}

/// Max pinned notes exceeded
class MaxPinnedNotesExceededException extends NoteException {
  final int maxPinned;
  final int currentPinned;

  MaxPinnedNotesExceededException({
    this.maxPinned = 10,
    this.currentPinned = 10,
  }) : super(
         message: 'Maximum $maxPinned pinned notes allowed',
         code: 'MAX_PINNED_EXCEEDED',
       );

  @override
  String get userMessage =>
      'You can only pin up to $maxPinned notes. Unpin a note first.';
}

/// Note archive exception
class NoteArchiveException extends NoteException {
  NoteArchiveException({
    required String message,
    String? noteId,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         noteId: noteId,
         code: 'NOTE_ARCHIVE_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// ============================================================================
/// MEDIA EXCEPTIONS (Images, Videos, Audio, Documents)
/// ============================================================================

/// Base media exception
class MediaException extends AppException {
  final String? mediaType; // 'image', 'video', 'audio', 'document'
  final String? filePath;

  MediaException({
    required String message,
    this.mediaType,
    this.filePath,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'MEDIA_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// Media compression failed
class MediaCompressionException extends MediaException {
  MediaCompressionException({
    required String message,
    String? mediaType,
    String? filePath,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         mediaType: mediaType,
         filePath: filePath,
         code: 'MEDIA_COMPRESS_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage =>
      'Failed to compress media. Please try a smaller file.';
}

/// Image pick/capture failed
class ImagePickException extends MediaException {
  ImagePickException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         mediaType: 'image',
         code: 'IMAGE_PICK_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Failed to get image. Please try again.';
}

/// Video pick failed
class VideoPickException extends MediaException {
  final Duration? maxDuration;

  VideoPickException({
    required String message,
    this.maxDuration,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         mediaType: 'video',
         code: 'VIDEO_PICK_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage {
    if (maxDuration != null) {
      return 'Video must be under ${maxDuration!.inMinutes} minutes.';
    }
    return 'Failed to get video. Please try again.';
  }
}

/// Audio recording failed
class AudioRecordingException extends MediaException {
  AudioRecordingException({
    required String message,
    String? filePath,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         mediaType: 'audio',
         filePath: filePath,
         code: 'AUDIO_RECORD_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage =>
      'Recording failed. Please check microphone permissions.';
}

/// Audio playback failed
class AudioPlaybackException extends MediaException {
  AudioPlaybackException({
    required String message,
    String? filePath,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         mediaType: 'audio',
         filePath: filePath,
         code: 'AUDIO_PLAYBACK_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Cannot play audio. File may be corrupted.';
}

/// Document scan failed
class DocumentScanException extends MediaException {
  DocumentScanException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         mediaType: 'document',
         code: 'DOC_SCAN_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage =>
      'Scan failed. Please try again with better lighting.';
}

/// OCR extraction failed
class OCRException extends MediaException {
  OCRException({
    required String message,
    String? filePath,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         mediaType: 'document',
         filePath: filePath,
         code: 'OCR_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Text extraction failed. Image may be unclear.';
}

/// Media not found
class MediaNotFoundException extends MediaException {
  MediaNotFoundException({
    required String filePath,
    String? mediaType,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: 'Media not found: $filePath',
         mediaType: mediaType,
         filePath: filePath,
         code: 'MEDIA_NOT_FOUND',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Media file not found. It may have been deleted.';
}

/// ============================================================================
/// REMINDERS & ALARMS EXCEPTIONS
/// ============================================================================

/// Base reminder exception
class ReminderException extends AppException {
  final String? reminderId;

  ReminderException({
    required String message,
    this.reminderId,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'REMINDER_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// Reminder not found
class ReminderNotFoundException extends ReminderException {
  ReminderNotFoundException({
    required String reminderId,
    String? message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message ?? 'Reminder not found: $reminderId',
         reminderId: reminderId,
         code: 'REMINDER_NOT_FOUND',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Reminder not found. It may have been deleted.';
}

/// Invalid reminder date/time
class InvalidReminderDateException extends ReminderException {
  final DateTime? invalidDate;

  InvalidReminderDateException({
    required String message,
    this.invalidDate,
    String? reminderId,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         reminderId: reminderId,
         code: 'INVALID_REMINDER_DATE',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Please select a future date and time.';
}

/// Reminder scheduling failed
class ReminderSchedulingException extends ReminderException {
  ReminderSchedulingException({
    required String message,
    String? reminderId,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         reminderId: reminderId,
         code: 'REMINDER_SCHEDULE_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Failed to schedule reminder. Please try again.';
}

/// Reminder creation failed
class ReminderCreationException extends ReminderException {
  ReminderCreationException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'REMINDER_CREATE_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// Notification permission denied
class NotificationPermissionException extends AppException {
  NotificationPermissionException({
    String message = 'Notification permission denied',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'NOTIF_PERMISSION_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Please enable notifications to receive reminders.';
}

/// ============================================================================
/// TODOS MODULE EXCEPTIONS
/// ============================================================================

/// Base todo exception
class TodoException extends AppException {
  final String? todoId;

  TodoException({
    required String message,
    this.todoId,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'TODO_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// Todo not found
class TodoNotFoundException extends TodoException {
  TodoNotFoundException({
    required String todoId,
    String? message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message ?? 'Task not found: $todoId',
         todoId: todoId,
         code: 'TODO_NOT_FOUND',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Task not found. It may have been deleted.';
}

/// Todo creation failed
class TodoCreationException extends TodoException {
  TodoCreationException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'TODO_CREATE_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Failed to create task. Please try again.';
}

/// Subtask exception
class SubtaskException extends TodoException {
  final String? parentId;

  SubtaskException({
    required String message,
    this.parentId,
    String? todoId,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         todoId: todoId,
         code: 'SUBTASK_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Subtask operation failed. Please try again.';
}

/// Recurring task exception
class RecurringTaskException extends TodoException {
  RecurringTaskException({
    required String message,
    String? todoId,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         todoId: todoId,
         code: 'RECURRING_TASK_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Failed to set up recurring task.';
}

/// ============================================================================
/// FOCUS SESSION (POMODORO) EXCEPTIONS
/// ============================================================================

/// Base focus session exception
class FocusSessionException extends AppException {
  final String? sessionId;

  FocusSessionException({
    required String message,
    this.sessionId,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'FOCUS_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// Timer configuration invalid
class TimerConfigurationException extends FocusSessionException {
  TimerConfigurationException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'TIMER_CONFIG_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage =>
      'Invalid timer configuration. Please check settings.';
}

/// Background service failed
class BackgroundServiceException extends FocusSessionException {
  BackgroundServiceException({
    required String message,
    String? sessionId,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         sessionId: sessionId,
         code: 'BG_SERVICE_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Timer may not work in background. Keep app open.';
}

/// Session already active
class SessionAlreadyActiveException extends FocusSessionException {
  SessionAlreadyActiveException({String? sessionId})
    : super(
        message: 'A focus session is already active',
        sessionId: sessionId,
        code: 'SESSION_ALREADY_ACTIVE',
      );

  @override
  String get userMessage => 'A session is already running. Stop it first.';
}

/// ============================================================================
/// REFLECTION MODULE EXCEPTIONS
/// ============================================================================

/// Base reflection exception
class ReflectionException extends AppException {
  final String? reflectionId;

  ReflectionException({
    required String message,
    this.reflectionId,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'REFLECTION_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// Question not found
class QuestionNotFoundException extends ReflectionException {
  final String questionId;

  QuestionNotFoundException({
    required this.questionId,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: 'Question not found: $questionId',
         code: 'QUESTION_NOT_FOUND',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Question not found.';
}

/// Reflection save failed
class ReflectionSaveException extends ReflectionException {
  ReflectionSaveException({
    required String message,
    String? reflectionId,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         reflectionId: reflectionId,
         code: 'REFLECTION_SAVE_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Failed to save reflection. Please try again.';
}

/// Streak calculation failed
class StreakCalculationException extends ReflectionException {
  StreakCalculationException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'STREAK_CALC_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// ============================================================================
/// VOICE INPUT EXCEPTIONS
/// ============================================================================

/// Base voice exception
class VoiceException extends AppException {
  VoiceException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'VOICE_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// Speech recognition failed
class SpeechRecognitionException extends VoiceException {
  final String? language;

  SpeechRecognitionException({
    required String message,
    this.language,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'SPEECH_RECOGNITION_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Voice recognition failed. Please try again.';
}

/// Microphone permission denied
class MicrophonePermissionException extends VoiceException {
  MicrophonePermissionException({
    String message = 'Microphone permission denied',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'MIC_PERMISSION_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Please enable microphone access in settings.';
}

/// Speech recognition not available
class SpeechRecognitionNotAvailableException extends VoiceException {
  SpeechRecognitionNotAvailableException({
    String message = 'Speech recognition is not available',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'SPEECH_NOT_AVAILABLE',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Voice input is not available on this device.';
}

/// ============================================================================
/// SEARCH & FILTERING EXCEPTIONS
/// ============================================================================

/// Base search exception
class SearchException extends AppException {
  final String? query;

  SearchException({
    required String message,
    this.query,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'SEARCH_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// Full-text search failed
class FullTextSearchException extends SearchException {
  FullTextSearchException({
    required String message,
    String? query,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         query: query,
         code: 'FTS_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Search failed. Please try again.';
}

/// Search index exception
class SearchIndexException extends SearchException {
  SearchIndexException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'SEARCH_INDEX_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// ============================================================================
/// EXPORT & BACKUP EXCEPTIONS
/// ============================================================================

/// Export failed
class ExportException extends AppException {
  final String? format; // 'txt', 'md', 'html', 'pdf'
  final String? filePath;

  ExportException({
    required String message,
    this.format,
    this.filePath,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'EXPORT_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Export failed. Please try again.';
}

/// Backup failed
class BackupException extends AppException {
  final String? backupPath;

  BackupException({
    required String message,
    this.backupPath,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'BACKUP_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Backup failed. Please check storage space.';
}

/// Restore failed
class RestoreException extends AppException {
  final String? backupPath;
  final bool isCorrupted;

  RestoreException({
    required String message,
    this.backupPath,
    this.isCorrupted = false,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'RESTORE_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage {
    if (isCorrupted) {
      return 'Backup file is corrupted. Cannot restore.';
    }
    return 'Restore failed. Please check the backup file.';
  }
}

/// ============================================================================
/// CALENDAR & SYNC EXCEPTIONS
/// ============================================================================

/// Base calendar exception
class CalendarException extends AppException {
  CalendarException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'CALENDAR_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// Calendar sync failed
class CalendarSyncException extends CalendarException {
  CalendarSyncException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'CALENDAR_SYNC_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Calendar sync failed. Please try again.';
}

/// Calendar permission denied
class CalendarPermissionException extends CalendarException {
  CalendarPermissionException({
    String message = 'Calendar permission denied',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'CALENDAR_PERMISSION_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Please enable calendar access in settings.';
}

/// ============================================================================
/// SETTINGS & PREFERENCES EXCEPTIONS
/// ============================================================================

/// Base settings exception
class SettingsException extends AppException {
  final String? settingKey;

  SettingsException({
    required String message,
    this.settingKey,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'SETTINGS_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// Theme application failed
class ThemeApplicationException extends SettingsException {
  final String? themeName;

  ThemeApplicationException({
    required String message,
    this.themeName,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         settingKey: 'theme',
         code: 'THEME_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Failed to apply theme. Using default.';
}

/// Font application failed
class FontApplicationException extends SettingsException {
  final String? fontFamily;

  FontApplicationException({
    required String message,
    this.fontFamily,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         settingKey: 'font',
         code: 'FONT_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Failed to apply font. Using default.';
}

/// ============================================================================
/// PERMISSION EXCEPTIONS
/// ============================================================================

/// Base permission exception
class PermissionException extends AppException {
  final String permissionType;
  final bool isPermanentlyDenied;

  PermissionException({
    required String message,
    required this.permissionType,
    this.isPermanentlyDenied = false,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'PERMISSION_${permissionType.toUpperCase()}_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage {
    if (isPermanentlyDenied) {
      return 'Permission permanently denied. Please enable in device settings.';
    }
    return 'Permission required. Please grant access.';
  }
}

/// Camera permission denied
class CameraPermissionException extends PermissionException {
  CameraPermissionException({
    String message = 'Camera permission denied',
    bool isPermanentlyDenied = false,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         permissionType: 'camera',
         isPermanentlyDenied: isPermanentlyDenied,
         code: 'CAMERA_PERMISSION_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage =>
      'Camera access required. Please enable in settings.';
}

/// Storage permission denied
class StoragePermissionException extends PermissionException {
  StoragePermissionException({
    String message = 'Storage permission denied',
    bool isPermanentlyDenied = false,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         permissionType: 'storage',
         isPermanentlyDenied: isPermanentlyDenied,
         code: 'STORAGE_PERMISSION_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage =>
      'Storage access required. Please enable in settings.';
}

/// Location permission denied
class LocationPermissionException extends PermissionException {
  final bool isBackgroundPermission;

  LocationPermissionException({
    String message = 'Location permission denied',
    this.isBackgroundPermission = false,
    bool isPermanentlyDenied = false,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         permissionType: isBackgroundPermission
             ? 'background_location'
             : 'location',
         isPermanentlyDenied: isPermanentlyDenied,
         code: isBackgroundPermission
             ? 'BG_LOCATION_PERMISSION_ERROR'
             : 'LOCATION_PERMISSION_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage {
    if (isBackgroundPermission) {
      return 'Background location required for location reminders.';
    }
    return 'Location access required. Please enable in settings.';
  }
}

/// ============================================================================
/// NETWORK EXCEPTIONS
/// ============================================================================

/// Base network exception
class NetworkException extends AppException {
  final int? statusCode;
  final String? url;

  NetworkException({
    required String message,
    this.statusCode,
    this.url,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'NETWORK_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Network error. Please check your connection.';
}

/// No internet connection
class NoInternetException extends NetworkException {
  NoInternetException({
    String message = 'No internet connection',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'NO_INTERNET',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage =>
      'No internet connection. Please connect and try again.';
}

/// Request timeout
class TimeoutException extends AppException {
  final Duration? timeout;

  TimeoutException({
    required String message,
    this.timeout,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'TIMEOUT_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'Request timed out. Please try again.';
}

/// ============================================================================
/// VALIDATION EXCEPTIONS
/// ============================================================================

/// General validation exception
class ValidationException extends AppException {
  final String? field;
  final dynamic invalidValue;
  final String? validationRule;

  ValidationException({
    required String message,
    this.field,
    this.invalidValue,
    this.validationRule,
    String? code,
  }) : super(message: message, code: code ?? 'VALIDATION_ERROR');

  @override
  String get userMessage {
    if (field != null) {
      return 'Invalid $field. Please check and try again.';
    }
    return 'Invalid input. Please check and try again.';
  }
}

/// Required field missing
class RequiredFieldException extends ValidationException {
  RequiredFieldException({required String field})
    : super(
        message: '$field is required',
        field: field,
        validationRule: 'required',
        code: 'REQUIRED_FIELD',
      );

  @override
  String get userMessage => '$field is required.';
}

/// ============================================================================
/// GENERAL/UNKNOWN EXCEPTIONS
/// ============================================================================

/// Unknown/unexpected exception
class UnknownException extends AppException {
  UnknownException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'UNKNOWN_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  @override
  String get userMessage => 'An unexpected error occurred. Please try again.';
}

/// Feature not implemented
class NotImplementedException extends AppException {
  final String? featureName;

  NotImplementedException({String? message, this.featureName})
    : super(
        message: message ?? 'Feature not implemented: $featureName',
        code: 'NOT_IMPLEMENTED',
      );

  @override
  String get userMessage => 'This feature is coming soon!';

  @override
  bool get shouldReport => false;
}

/// ============================================================================
/// EXCEPTION HANDLER UTILITY
/// ============================================================================

/// Helper class to handle and convert exceptions
class ExceptionHandler {
  /// Convert any exception to AppException
  static AppException wrap(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppException) {
      return error;
    }

    if (error is FormatException) {
      return ValidationException(
        message: 'Invalid format: ${error.message}',
        code: 'FORMAT_ERROR',
      );
    }

    if (error is TypeError) {
      return ValidationException(
        message: 'Type error: ${error.toString()}',
        code: 'TYPE_ERROR',
      );
    }

    return UnknownException(
      message: error.toString(),
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Check if exception is recoverable
  static bool isRecoverable(dynamic error) {
    if (error is AppException) {
      return error.isRecoverable;
    }
    return true;
  }

  /// Get user-friendly message
  static String getUserMessage(dynamic error) {
    if (error is AppException) {
      return error.userMessage;
    }
    return 'An error occurred. Please try again.';
  }

  /// Log exception
  static void log(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppException) {
      error.log();
    } else {
      debugPrint('🚨 Error: $error\n$stackTrace');
    }
  }
}
