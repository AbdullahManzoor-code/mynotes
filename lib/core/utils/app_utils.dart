import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

/// Utility class for file operations
class FileUtils {
  FileUtils._(); // Private constructor

  /// Get file size in human-readable format
  static String getFileSizeString(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  /// Get file extension
  static String getFileExtension(String filePath) {
    if (!filePath.contains('.')) return '';
    return filePath.split('.').last.toLowerCase();
  }

  /// Get file name from path
  static String getFileName(String filePath) {
    return filePath.split('/').last;
  }

  /// Get file name without extension
  static String getFileNameWithoutExtension(String filePath) {
    final fileName = getFileName(filePath);
    if (!fileName.contains('.')) return fileName;
    return fileName.substring(0, fileName.lastIndexOf('.'));
  }

  /// Check if file is image
  static bool isImageFile(String filePath) {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return imageExtensions.contains(getFileExtension(filePath));
  }

  /// Check if file is video
  static bool isVideoFile(String filePath) {
    const videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp'];
    return videoExtensions.contains(getFileExtension(filePath));
  }

  /// Check if file is audio
  static bool isAudioFile(String filePath) {
    const audioExtensions = ['mp3', 'wav', 'aac', 'm4a', 'ogg', 'flac'];
    return audioExtensions.contains(getFileExtension(filePath));
  }

  /// Check if file size is within limit
  static bool isFileSizeValid(int bytes, int maxBytes) {
    return bytes <= maxBytes;
  }

  /// Validate image file
  static bool validateImageFile(String filePath, int fileSize) {
    return isImageFile(filePath) &&
        isFileSizeValid(fileSize, AppConstants.maxImageSizeBytes);
  }

  /// Validate video file
  static bool validateVideoFile(String filePath, int fileSize) {
    return isVideoFile(filePath) &&
        isFileSizeValid(fileSize, AppConstants.maxVideoSizeBytes);
  }

  /// Validate audio file
  static bool validateAudioFile(String filePath, int fileSize) {
    return isAudioFile(filePath) &&
        isFileSizeValid(fileSize, AppConstants.maxAudioSizeBytes);
  }

  /// Generate unique file name
  static String generateUniqueFileName(String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${timestamp}_${DateTime.now().microsecond}.$extension';
  }

  /// Sanitize file name
  static String sanitizeFileName(String fileName) {
    // Remove invalid characters
    final sanitized = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    // Limit length
    if (sanitized.length > 255) {
      return sanitized.substring(0, 255);
    }
    return sanitized;
  }
}

/// Utility class for haptic feedback
class HapticUtils {
  HapticUtils._(); // Private constructor

  /// Light haptic feedback
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium haptic feedback
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy haptic feedback
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection haptic feedback
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Vibrate
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }
}

/// Utility class for validation
class ValidationUtils {
  ValidationUtils._(); // Private constructor

  /// Validate note title
  static String? validateNoteTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title cannot be empty';
    }
    if (value.trim().length < AppConstants.minNoteTitleLength) {
      return 'Title is too short';
    }
    if (value.length > AppConstants.maxNoteTitleLength) {
      return 'Title is too long (max ${AppConstants.maxNoteTitleLength} characters)';
    }
    return null;
  }

  /// Validate note content
  static String? validateNoteContent(String? value) {
    if (value != null && value.length > AppConstants.maxNoteContentLength) {
      return 'Content is too long (max ${AppConstants.maxNoteContentLength} characters)';
    }
    return null;
  }

  /// Validate todo title
  static String? validateTodoTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Todo cannot be empty';
    }
    if (value.trim().length < AppConstants.minTodoTitleLength) {
      return 'Todo is too short';
    }
    if (value.length > AppConstants.maxTodoTitleLength) {
      return 'Todo is too long (max ${AppConstants.maxTodoTitleLength} characters)';
    }
    return null;
  }

  /// Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email cannot be empty';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email address';
    }
    return null;
  }

  /// Check if string is empty or whitespace
  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }
}
