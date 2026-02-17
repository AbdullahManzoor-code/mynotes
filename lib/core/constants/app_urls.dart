/// API endpoints and service URLs
/// Centralized for easy configuration per environment
class AppUrls {
  AppUrls._();

  // ═════════════════════════════════════════════════════════════════════════
  // BASE URLs
  // ═════════════════════════════════════════════════════════════════════════

  /// Base URL for all API calls (update per environment: dev, staging, prod)
  static const String baseUrl = 'https://api.mynotes-app.com/v1';

  /// Development base URL
  static const String devUrl = 'http://localhost:8000/v1';

  /// Staging base URL
  static const String stagingUrl = 'https://staging-api.mynotes-app.com/v1';

  /// Production base URL
  static const String prodUrl = 'https://api.mynotes-app.com/v1';

  /// WebSocket base URL (for real-time updates)
  static const String wsBaseUrl = 'wss://ws.mynotes-app.com';

  /// CDN base URL (for media storage)
  static const String cdnUrl = 'https://cdn.mynotes-app.com';

  // ═════════════════════════════════════════════════════════════════════════
  // AUTHENTICATION ENDPOINTS
  // ═════════════════════════════════════════════════════════════════════════

  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String verifyEmailEndpoint = '/auth/verify-email';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String resetPasswordEndpoint = '/auth/reset-password';
  static const String changePasswordEndpoint = '/auth/change-password';
  static const String biometricAuthEndpoint = '/auth/biometric';

  // ═════════════════════════════════════════════════════════════════════════
  // NOTES ENDPOINTS
  // ═════════════════════════════════════════════════════════════════════════

  static const String notesEndpoint = '/notes';
  static const String createNoteEndpoint = '/notes';
  static const String getNoteEndpoint = '/notes/{id}';
  static const String updateNoteEndpoint = '/notes/{id}';
  static const String deleteNoteEndpoint = '/notes/{id}';
  static const String archiveNoteEndpoint = '/notes/{id}/archive';
  static const String unarchiveNoteEndpoint = '/notes/{id}/unarchive';
  static const String pinNoteEndpoint = '/notes/{id}/pin';
  static const String unpinNoteEndpoint = '/notes/{id}/unpin';
  static const String searchNotesEndpoint = '/notes/search';
  static const String getNotesByTagEndpoint = '/notes/tags/{tag}';
  static const String exportNotesEndpoint = '/notes/export';

  // ═════════════════════════════════════════════════════════════════════════
  // TODOS ENDPOINTS
  // ═════════════════════════════════════════════════════════════════════════

  static const String todosEndpoint = '/todos';
  static const String createTodoEndpoint = '/todos';
  static const String getTodoEndpoint = '/todos/{id}';
  static const String updateTodoEndpoint = '/todos/{id}';
  static const String deleteTodoEndpoint = '/todos/{id}';
  static const String completeTodoEndpoint = '/todos/{id}/complete';
  static const String uncompleteTodoEndpoint = '/todos/{id}/uncomplete';
  static const String searchTodosEndpoint = '/todos/search';

  // ═════════════════════════════════════════════════════════════════════════
  // ALARMS & REMINDERS ENDPOINTS
  // ═════════════════════════════════════════════════════════════════════════

  static const String alarmsEndpoint = '/alarms';
  static const String createAlarmEndpoint = '/alarms';
  static const String getAlarmEndpoint = '/alarms/{id}';
  static const String updateAlarmEndpoint = '/alarms/{id}';
  static const String deleteAlarmEndpoint = '/alarms/{id}';
  static const String triggerAlarmEndpoint = '/alarms/{id}/trigger';
  static const String snoozeAlarmEndpoint = '/alarms/{id}/snooze';

  // ═════════════════════════════════════════════════════════════════════════
  // MEDIA ENDPOINTS
  // ═════════════════════════════════════════════════════════════════════════

  static const String uploadMediaEndpoint = '/media/upload';
  static const String deleteMediaEndpoint = '/media/{id}';
  static const String getMediaEndpoint = '/media/{id}';
  static const String generateThumbnailEndpoint = '/media/{id}/thumbnail';

  // ═════════════════════════════════════════════════════════════════════════
  // USER ENDPOINTS
  // ═════════════════════════════════════════════════════════════════════════

  static const String getUserProfileEndpoint = '/users/profile';
  static const String updateProfileEndpoint = '/users/profile';
  static const String uploadAvatarEndpoint = '/users/avatar';
  static const String getUserSettingsEndpoint = '/users/settings';
  static const String updateSettingsEndpoint = '/users/settings';

  // ═════════════════════════════════════════════════════════════════════════
  // BACKUP & SYNC ENDPOINTS
  // ═════════════════════════════════════════════════════════════════════════

  static const String createBackupEndpoint = '/backup/create';
  static const String restoreBackupEndpoint = '/backup/restore';
  static const String syncDataEndpoint = '/sync';
  static const String exportDataEndpoint = '/export';
  static const String importDataEndpoint = '/import';

  // ═════════════════════════════════════════════════════════════════════════
  // HEALTH CHECK
  // ═════════════════════════════════════════════════════════════════════════

  static const String healthCheckEndpoint = '/health';
  static const String statusEndpoint = '/status';

  // ═════════════════════════════════════════════════════════════════════════
  // EXTERNAL SERVICES
  // ═════════════════════════════════════════════════════════════════════════

  /// Google Maps API
  static const String googleMapsApiUrl = 'https://maps.googleapis.com/maps/api';

  /// OpenWeather API
  static const String weatherApiUrl = 'https://api.openweathermap.org/data/2.5';

  /// Sentry (Error Tracking)
  static const String sentryUrl = 'https://sentry.io';

  /// Firebase
  static const String firebaseUrl = 'https://firebase.googleapis.com';

  // ═════════════════════════════════════════════════════════════════════════
  // TIMEOUT CONSTANTS
  // ═════════════════════════════════════════════════════════════════════════

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
