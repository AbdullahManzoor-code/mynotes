/// Application-wide constants
/// Centralized to avoid duplication and magic numbers
class AppConstants {
  AppConstants._(); // Private constructor

  // App Info
  static const String appName = 'MyNotes';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'mynotes.db';
  static const int databaseVersion = 1;

  // Storage
  static const String notesDirectory = 'notes';
  static const String mediaDirectory = 'media';
  static const String imagesDirectory = 'images';
  static const String audioDirectory = 'audio';
  static const String videoDirectory = 'videos';
  static const String thumbnailsDirectory = 'thumbnails';
  static const String pdfsDirectory = 'pdfs';

  // Media Limits
  static const int maxImageSizeBytes = 10 * 1024 * 1024; // 10 MB
  static const int maxVideoSizeBytes = 50 * 1024 * 1024; // 50 MB
  static const int maxAudioSizeBytes = 20 * 1024 * 1024; // 20 MB
  static const int maxVideoDurationSeconds = 60; // 60 seconds
  static const int maxMediaPerNote = 20;

  // Image Compression
  static const int imageMaxWidth = 1080;
  static const int imageMaxHeight = 1920;
  static const int imageQuality = 65; // 0-100
  static const int thumbnailSize = 200;

  // Video Compression
  static const int videoMaxWidth = 1280;
  static const int videoMaxHeight = 720;
  static const int videoFrameRate = 30;
  static const String videoFormat = 'mp4';
  static const String videoCodec = 'h264';
  static const String audioCodec = 'aac';

  // Audio Recording
  static const int audioSampleRate = 44100;
  static const int audioBitRate = 128000;
  static const String audioFormat = 'aac';
  static const int maxAudioDurationSeconds = 600; // 10 minutes

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  static const double defaultRadius = 12.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 16.0;

  static const double defaultElevation = 2.0;
  static const double mediumElevation = 4.0;
  static const double highElevation = 8.0;

  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeExtraLarge = 48.0;

  // Animation Durations
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;

  // Grid Layout
  static const int gridCrossAxisCount = 2;
  static const double gridAspectRatio = 0.75;
  static const double gridSpacing = 12.0;

  // List Layout
  static const double listItemHeight = 120.0;
  static const double listItemSpacing = 8.0;

  // Notification
  static const String notificationChannelId = 'mynotes_channel';
  static const String notificationChannelName = 'MyNotes Notifications';
  static const String notificationChannelDescription =
      'Notifications for notes, alarms, and reminders';
  static const String alarmChannelId = 'alarm_channel';
  static const String alarmChannelName = 'Alarms';
  static const String alarmChannelDescription = 'Alarm notifications for notes';

  // PDF Export
  static const String pdfAuthor = 'MyNotes App';
  static const String pdfCreator = 'MyNotes';
  static const double pdfPageMargin = 40.0;
  static const double pdfImageMaxWidth = 500.0;
  static const double pdfImageMaxHeight = 400.0;

  // Date Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'MMM dd, yyyy hh:mm a';
  static const String fullDateTimeFormat = 'EEEE, MMMM dd, yyyy hh:mm a';

  // Search
  static const int searchDebounceMilliseconds = 500;
  static const int searchMinLength = 2;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache
  static const int maxCacheSize = 100;
  static const int cacheExpirationMinutes = 30;

  // Validation
  static const int minNoteTitleLength = 1;
  static const int maxNoteTitleLength = 100;
  static const int minNoteContentLength = 0;
  static const int maxNoteContentLength = 50000;
  static const int minTodoTitleLength = 1;
  static const int maxTodoTitleLength = 200;

  // Haptic Feedback Intensity (0.0 - 1.0)
  static const double hapticLightIntensity = 0.3;
  static const double hapticMediumIntensity = 0.6;
  static const double hapticHeavyIntensity = 1.0;

  // Auto-save
  static const int autoSaveDelaySeconds = 3;

  // Backup
  static const String backupFileExtension = 'backup';
  static const int maxBackupFiles = 5;

  // Error Messages
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
  static const String networkErrorMessage =
      'Network error. Please check your connection.';
  static const String storageErrorMessage =
      'Storage error. Please check available space.';
  static const String permissionErrorMessage =
      'Permission denied. Please grant necessary permissions.';
}

