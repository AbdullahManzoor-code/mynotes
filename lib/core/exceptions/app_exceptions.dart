/// Comprehensive Application Exception Hierarchy
/// Covers all flows: Launch, Notes, Reminders, Todos, Reflection, Focus, Voice, Search, Settings

/// Base exception class for all app errors
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

/// ============================================================================
/// INITIALIZATION & LAUNCH FLOW EXCEPTIONS
/// ============================================================================

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
}

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
}

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
}

/// ============================================================================
/// AUTHENTICATION & SECURITY EXCEPTIONS
/// ============================================================================

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

class BiometricNotAvailableException extends BiometricException {
  BiometricNotAvailableException({
    String message = 'Biometric authentication is not available',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'BIOMETRIC_NOT_AVAILABLE',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class BiometricFailedException extends BiometricException {
  final int? attemptsRemaining;

  BiometricFailedException({
    required String message,
    this.attemptsRemaining,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'BIOMETRIC_FAILED',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class PINException extends AppException {
  final int? attemptsRemaining;

  PINException({
    required String message,
    this.attemptsRemaining,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'PIN_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// ============================================================================
/// NOTES MODULE EXCEPTIONS
/// ============================================================================

class NoteException extends AppException {
  NoteException({
    required String message,
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

class NoteNotFound extends NoteException {
  NoteNotFound({
    required String noteId,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: 'Note not found: $noteId',
         code: 'NOTE_NOT_FOUND',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class NoteCreationException extends NoteException {
  NoteCreationException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'NOTE_CREATE_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class NoteAutoSaveException extends NoteException {
  NoteAutoSaveException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'NOTE_AUTOSAVE_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class NoteDeletionException extends NoteException {
  NoteDeletionException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'NOTE_DELETE_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class MaxPinnedNotesExceededException extends NoteException {
  MaxPinnedNotesExceededException()
    : super(
        message: 'Maximum 10 pinned notes allowed',
        code: 'MAX_PINNED_EXCEEDED',
      );
}

/// ============================================================================
/// MEDIA EXCEPTIONS (Images, Videos, Audio)
/// ============================================================================

class MediaException extends AppException {
  MediaException({
    required String message,
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

class MediaCompressionException extends MediaException {
  MediaCompressionException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'MEDIA_COMPRESS_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class AudioRecordingException extends MediaException {
  AudioRecordingException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'AUDIO_RECORD_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class VideoPickException extends MediaException {
  VideoPickException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'VIDEO_PICK_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class DocumentScanException extends MediaException {
  DocumentScanException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'DOC_SCAN_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class OCRException extends MediaException {
  OCRException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'OCR_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// ============================================================================
/// REMINDERS & NOTIFICATIONS EXCEPTIONS
/// ============================================================================

class ReminderException extends AppException {
  ReminderException({
    required String message,
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

class ReminderNotFound extends ReminderException {
  ReminderNotFound({
    required String reminderId,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: 'Reminder not found: $reminderId',
         code: 'REMINDER_NOT_FOUND',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class ReminderSchedulingException extends ReminderException {
  ReminderSchedulingException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'REMINDER_SCHEDULE_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class InvalidReminderDateException extends ReminderException {
  InvalidReminderDateException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'INVALID_REMINDER_DATE',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

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
}

/// ============================================================================
/// TODOS MODULE EXCEPTIONS
/// ============================================================================

class TodoException extends AppException {
  TodoException({
    required String message,
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

class TodoNotFound extends TodoException {
  TodoNotFound({
    required String todoId,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: 'Task not found: $todoId',
         code: 'TODO_NOT_FOUND',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

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
}

class SubtaskException extends TodoException {
  SubtaskException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'SUBTASK_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class RecurringTaskException extends TodoException {
  RecurringTaskException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'RECURRING_TASK_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// ============================================================================
/// FOCUS SESSION (POMODORO) EXCEPTIONS
/// ============================================================================

class FocusSessionException extends AppException {
  FocusSessionException({
    required String message,
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
}

class BackgroundServiceException extends FocusSessionException {
  BackgroundServiceException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'BG_SERVICE_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// ============================================================================
/// REFLECTION MODULE EXCEPTIONS
/// ============================================================================

class ReflectionException extends AppException {
  ReflectionException({
    required String message,
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

class QuestionNotFoundException extends ReflectionException {
  QuestionNotFoundException({
    required String questionId,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: 'Question not found: $questionId',
         code: 'QUESTION_NOT_FOUND',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class ReflectionSaveException extends ReflectionException {
  ReflectionSaveException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'REFLECTION_SAVE_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

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

class SpeechRecognitionException extends VoiceException {
  SpeechRecognitionException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'SPEECH_RECOGNITION_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

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
}

class AudioPlaybackException extends VoiceException {
  AudioPlaybackException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'AUDIO_PLAYBACK_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// ============================================================================
/// SEARCH & FILTERING EXCEPTIONS
/// ============================================================================

class SearchException extends AppException {
  SearchException({
    required String message,
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

class FullTextSearchException extends SearchException {
  FullTextSearchException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'FTS_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// ============================================================================
/// EXPORT & BACKUP EXCEPTIONS
/// ============================================================================

class ExportException extends AppException {
  ExportException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'EXPORT_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class BackupException extends AppException {
  BackupException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'BACKUP_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class RestoreException extends AppException {
  RestoreException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'RESTORE_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// ============================================================================
/// CALENDAR & SYNC EXCEPTIONS
/// ============================================================================

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
}

/// ============================================================================
/// SETTINGS & PREFERENCES EXCEPTIONS
/// ============================================================================

class SettingsException extends AppException {
  SettingsException({
    required String message,
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

class ThemeApplicationException extends SettingsException {
  ThemeApplicationException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: 'THEME_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// ============================================================================
/// PERMISSION EXCEPTIONS
/// ============================================================================

class PermissionException extends AppException {
  final String permissionType; // 'camera', 'microphone', 'storage', etc.

  PermissionException({
    required String message,
    required this.permissionType,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'PERMISSION_${permissionType.toUpperCase()}_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class CameraPermissionException extends PermissionException {
  CameraPermissionException({
    String message = 'Camera permission denied',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         permissionType: 'camera',
         code: 'CAMERA_PERMISSION_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class StoragePermissionException extends PermissionException {
  StoragePermissionException({
    String message = 'Storage permission denied',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         permissionType: 'storage',
         code: 'STORAGE_PERMISSION_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

/// ============================================================================
/// GENERAL/NETWORK EXCEPTIONS
/// ============================================================================

class NetworkException extends AppException {
  NetworkException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'NETWORK_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class TimeoutException extends AppException {
  TimeoutException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'TIMEOUT_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

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
}
