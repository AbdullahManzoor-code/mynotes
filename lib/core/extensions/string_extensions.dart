/// Extension methods on String for validation and manipulation
extension StringExtensions on String {
  /// Capitalize first letter
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Convert to title case
  String get toTitleCase => split(' ').map((word) => word.capitalize).join(' ');

  /// Convert to sentence case (first letter uppercase, rest lowercase)
  String get toSentenceCase =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  /// Check if string is a valid email
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Check if string is a valid URL
  bool get isValidUrl {
    final uri = Uri.tryParse(this);
    return uri != null && (startsWith('http://') || startsWith('https://'));
  }

  /// Check if string is a valid phone number (basic validation)
  bool get isValidPhone {
    final phoneRegex = RegExp(r'^[+]?[\d\s\-()]{10,}$');
    return phoneRegex.hasMatch(this);
  }

  /// Check if string is a valid number
  bool get isNumeric {
    if (isEmpty) return false;
    return double.tryParse(this) != null;
  }

  /// Check if string is alphanumeric only
  bool get isAlphaNumeric {
    final regex = RegExp(r'^[a-zA-Z0-9]+$');
    return regex.hasMatch(this);
  }

  /// Check if string contains only whitespace
  bool get isBlankString => trim().isEmpty;

  /// Remove all whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Truncate string to max length with ellipsis
  String truncate({required int maxLength, String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Reverse string
  String get reversed => split('').reversed.join('');

  /// Check if string has only digits
  bool get isDigitsOnly => RegExp(r'^\d+$').hasMatch(this);

  /// Get initials from string (e.g., "John Doe" → "JD")
  String getInitials({int maxInitials = 2}) {
    final words = split(' ').where((word) => word.isNotEmpty).toList();
    return words.take(maxInitials).map((word) => word[0].toUpperCase()).join();
  }

  /// Remove leading zeros
  String get removeLeadingZeros => replaceFirst(RegExp(r'^0+'), '');

  /// Add line breaks every n characters
  String breakAt({required int length}) {
    if (isEmpty) return this;
    final buffer = StringBuffer();
    for (int i = 0; i < this.length; i += length) {
      buffer.writeln(
        substring(i, i + length > this.length ? this.length : i + length),
      );
    }
    return buffer.toString().trim();
  }

  /// Check if string matches regex pattern
  bool matches(String pattern) => RegExp(pattern).hasMatch(this);

  /// Replace first occurrence (not all)
  String replaceFirstOccurrence(String from, String to) {
    final index = indexOf(from);
    if (index == -1) return this;
    return replaceRange(index, index + from.length, to);
  }

  /// Encode to Base64 string
  String toBase64() {
    return Uri.encodeComponent(this);
  }

  /// Decode from Base64 string
  String fromBase64() {
    return Uri.decodeFull(this);
  }

  /// Convert to slug (kebab-case URL friendly)
  String toSlug() {
    return toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[-\s]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  /// Pluralize string if count != 1
  String pluralize({required int count, String? plural}) {
    String p = plural ?? '${this}s';
    return count == 1 ? this : p;
  }

  /// Check if string contains any emoji
  bool get hasEmoji {
    final emojiPattern = RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\uddff])',
    );
    return emojiPattern.hasMatch(this);
  }

  /// Split string into words
  List<String> splitIntoWords() {
    return split(RegExp(r'\s+'));
  }

  /// Count word occurrences
  int countWords() {
    return split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }
}
