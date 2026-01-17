import 'package:intl/intl.dart' as intl;
import '../constants/app_constants.dart';

/// Utility class for date and time operations
class AppDateUtils {
  AppDateUtils._(); // Private constructor

  /// Format date to string
  static String formatDate(DateTime date) {
    return intl.DateFormat(AppConstants.dateFormat).format(date);
  }

  /// Format time to string
  static String formatTime(DateTime date) {
    return intl.DateFormat(AppConstants.timeFormat).format(date);
  }

  /// Format date and time to string
  static String formatDateTime(DateTime date) {
    return intl.DateFormat(AppConstants.dateTimeFormat).format(date);
  }

  /// Format to full date time
  static String formatFullDateTime(DateTime date) {
    return intl.DateFormat(AppConstants.fullDateTimeFormat).format(date);
  }

  /// Get relative time string (e.g., "2 hours ago")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Get smart date string
  static String getSmartDateString(DateTime date) {
    if (isToday(date)) {
      return 'Today ${formatTime(date)}';
    } else if (isYesterday(date)) {
      return 'Yesterday ${formatTime(date)}';
    } else if (isTomorrow(date)) {
      return 'Tomorrow ${formatTime(date)}';
    } else {
      return formatDateTime(date);
    }
  }

  /// Format duration (e.g., for audio/video)
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Parse string to DateTime
  static DateTime? parseDateTime(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// Check if date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  /// Get days until date
  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    return difference.inDays;
  }

  /// Get hours until date
  static int hoursUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    return difference.inHours;
  }
}
