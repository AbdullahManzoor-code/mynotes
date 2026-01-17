/// Media compression and size constants
class MediaConstants {
  MediaConstants._();

  // Image compression
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  static const int imageCompressionQuality = 85;
  static const int thumbnailSize = 200;

  // Image compression targets
  static const int compressedImageQuality = 70;
  static const int compressedMinWidth = 1024;
  static const int compressedMinHeight = 1024;

  // Video settings
  static const int maxVideoDurationMinutes = 10;
  static const String videoResolution = '720p';
  static const int videoWidth = 1280;
  static const int videoHeight = 720;

  // Audio settings
  static const String audioFormat = 'm4a';
  static const String audioEncoder = 'aac';

  // File size limits (in MB)
  static const int maxImageSizeMB = 10;
  static const int maxVideoSizeMB = 100;
  static const int maxAudioSizeMB = 50;

  // Cache settings
  static const int maxCachedImages = 100;
  static const int cacheExpirationHours = 24;
}
