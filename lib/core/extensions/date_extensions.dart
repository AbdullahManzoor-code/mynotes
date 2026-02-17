/// Extension methods on DateTime for convenient formatting and comparison
extension DateTimeExtensions on DateTime {
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is in the future
  bool get isFuture => isAfter(DateTime.now());

  /// Check if date is in the past
  bool get isPast => isBefore(DateTime.now());

  /// Check if date is current year
  bool get isCurrentYear => year == DateTime.now().year;

  /// Check if date is current month
  bool get isCurrentMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Check if date is this week (using Monday as week start)
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek) &&
        isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Format as "MMM dd, yyyy" (Jan 15, 2024)
  String formatDate() {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[month - 1]} ${day.toString().padLeft(2, '0')}, $year';
  }

  /// Format as "hh:mm AM/PM"
  String formatTime() {
    final hour = this.hour;
    final minute = this.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Format as "MMM dd, yyyy hh:mm AM/PM"
  String formatDateTime() => '${formatDate()} ${formatTime()}';

  /// Format as "Today", "Tomorrow", "Yesterday", or "MMM dd, yyyy"
  String formatRelative() {
    if (isToday) return 'Today';
    if (isTomorrow) return 'Tomorrow';
    if (isYesterday) return 'Yesterday';
    return formatDate();
  }

  /// Format as "hh:mm AM/PM" or "Yesterday hh:mm" etc
  String formatTimeRelative() {
    if (isToday) return formatTime();
    if (isTomorrow) return 'Tomorrow ${formatTime()}';
    if (isYesterday) return 'Yesterday ${formatTime()}';
    return formatDateTime();
  }

  /// Get human-readable time difference (e.g., "2 hours ago")
  String timeAgo() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) return 'just now';
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    }
    if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }

    final years = (difference.inDays / 365).floor();
    return '$years year${years > 1 ? 's' : ''} ago';
  }

  /// Get countdown duration (e.g., "2 hours from now")
  String countdown() {
    final now = DateTime.now();
    final difference = this.difference(now);

    if (difference.isNegative) return timeAgo();

    if (difference.inSeconds < 60) return 'in a moment';
    if (difference.inMinutes < 60) {
      return 'in ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    }
    if (difference.inHours < 24) {
      return 'in ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    }
    if (difference.inDays < 7) {
      return 'in ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    }

    return formatDate();
  }

  /// Get day of week name (Monday, Tuesday, etc.)
  String getDayOfWeekName() {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  /// Get day of week short name (Mon, Tue, etc.)
  String getDayOfWeekShort() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  /// Get month name (January, February, etc.)
  String getMonthName() {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  /// Get month short name (Jan, Feb, etc.)
  String getMonthShort() {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  /// Get age in years from this date
  int getAge() {
    final now = DateTime.now();
    var age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  /// Get start of day (00:00:00)
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day (23:59:59)
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  /// Get start of week (Monday)
  DateTime get startOfWeek {
    final diff = weekday - 1;
    return subtract(Duration(days: diff)).startOfDay;
  }

  /// Get end of week (Sunday)
  DateTime get endOfWeek => startOfWeek.add(const Duration(days: 6)).endOfDay;

  /// Get start of month
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Get end of month
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59);

  /// Get start of year
  DateTime get startOfYear => DateTime(year, 1, 1);

  /// Get end of year
  DateTime get endOfYear => DateTime(year, 12, 31, 23, 59, 59);

  /// Check if date is in the same day as another date
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Get days difference from now
  int daysFromNow() {
    final now = DateTime.now();
    return difference(now).inDays;
  }

  /// Check if date is leap year
  bool get isLeapYear {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }
}
