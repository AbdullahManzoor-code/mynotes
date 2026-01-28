import 'dart:math';

import 'package:mynotes/presentation/widgets/universal_item_card.dart';

/// Smart Voice Parser
/// Converts speech to appropriate item type (Note/Todo/Reminder)
/// with intelligent parsing and context detection
class SmartVoiceParser {
  // Keywords for different item types
  static const List<String> _todoKeywords = [
    'remind me to',
    'i need to',
    'don\'t forget to',
    'make sure to',
    'remember to',
    'have to',
    'need to do',
    'task',
    'complete',
    'finish',
    'do',
    'get',
    'buy',
    'call',
    'send',
    'write',
    'check',
  ];

  static const List<String> _reminderKeywords = [
    'remind me at',
    'remind me in',
    'alarm',
    'notification',
    'alert me',
    'wake me up',
    'meeting at',
    'appointment',
    'schedule',
    'calendar',
  ];

  static const Map<String, ItemPriority> _priorityKeywords = {
    'urgent': ItemPriority.high,
    'important': ItemPriority.high,
    'asap': ItemPriority.high,
    'critical': ItemPriority.high,
    'priority': ItemPriority.high,
    'later': ItemPriority.low,
    'sometime': ItemPriority.low,
    'eventually': ItemPriority.low,
    'when possible': ItemPriority.low,
  };

  static const Map<String, List<String>> _categoryKeywords = {
    'work': [
      'work',
      'office',
      'meeting',
      'project',
      'deadline',
      'boss',
      'colleague',
      'presentation',
    ],
    'personal': [
      'personal',
      'home',
      'family',
      'friend',
      'birthday',
      'anniversary',
    ],
    'health': [
      'doctor',
      'appointment',
      'medicine',
      'workout',
      'gym',
      'exercise',
      'health',
    ],
    'shopping': [
      'buy',
      'shop',
      'store',
      'mall',
      'grocery',
      'purchase',
      'order',
    ],
    'finance': ['pay', 'bill', 'bank', 'money', 'budget', 'insurance', 'tax'],
  };

  /// Parse speech text and create appropriate UniversalItem
  static UniversalItem parseVoiceInput(String speechText) {
    final cleanText = speechText.toLowerCase().trim();

    // Detect item type
    final ItemType itemType = _detectItemType(cleanText);

    // Extract components
    final String title = _extractTitle(cleanText, itemType);
    final String content = _extractContent(cleanText, title);
    final DateTime? reminderTime = _extractTime(cleanText);
    final ItemPriority? priority = _extractPriority(cleanText);
    final String category = _extractCategory(cleanText);

    // Create appropriate item
    switch (itemType) {
      case ItemType.todo:
        return UniversalItem.todo(
          id: _generateId(),
          title: title,
          content: content,
          reminderTime: reminderTime,
          priority: priority,
          category: category.isNotEmpty ? category : 'Todo',
          hasVoiceNote: true,
        );

      case ItemType.reminder:
        return UniversalItem.reminder(
          id: _generateId(),
          title: title,
          content: content,
          reminderTime:
              reminderTime ?? DateTime.now().add(const Duration(hours: 1)),
          priority: priority,
          category: category.isNotEmpty ? category : 'Reminder',
        );

      case ItemType.note:
        return UniversalItem(
          id: _generateId(),
          title: title.isNotEmpty ? title : 'Voice Note',
          content: content.isNotEmpty ? content : speechText,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          category: category.isNotEmpty ? category : 'Note',
          hasVoiceNote: true,
        );
    }
  }

  /// Detect the primary type of item from speech
  static ItemType _detectItemType(String text) {
    int todoScore = 0;
    int reminderScore = 0;

    // Check for todo keywords
    for (final keyword in _todoKeywords) {
      if (text.contains(keyword)) {
        todoScore += 2;
      }
    }

    // Check for reminder keywords
    for (final keyword in _reminderKeywords) {
      if (text.contains(keyword)) {
        reminderScore += 3; // Reminders get higher weight
      }
    }

    // Check for time indicators (strong reminder signal)
    if (_hasTimeIndicators(text)) {
      reminderScore += 5;
    }

    // Check for action words (todo signal)
    if (_hasActionWords(text)) {
      todoScore += 1;
    }

    if (reminderScore > todoScore) {
      return ItemType.reminder;
    } else if (todoScore > 0) {
      return ItemType.todo;
    } else {
      return ItemType.note;
    }
  }

  /// Extract title from speech text
  static String _extractTitle(String text, ItemType type) {
    String title = text;

    // Remove common prefixes
    final prefixesToRemove = [
      'remind me to ',
      'i need to ',
      'don\'t forget to ',
      'remember to ',
      'make sure to ',
      'remind me at ',
      'remind me in ',
      'note that ',
      'write down ',
    ];

    for (final prefix in prefixesToRemove) {
      if (title.startsWith(prefix)) {
        title = title.substring(prefix.length);
        break;
      }
    }

    // Extract until time indicator or limit length
    final timePattern = RegExp(r'\b(at|in|on|tomorrow|today|next|this)\b');
    final match = timePattern.firstMatch(title);
    if (match != null) {
      title = title.substring(0, match.start).trim();
    }

    // Capitalize first letter
    if (title.isNotEmpty) {
      title = title[0].toUpperCase() + title.substring(1);
    }

    // Limit title length
    if (title.length > 50) {
      title = title.substring(0, 50).trim() + '...';
    }

    return title;
  }

  /// Extract content/description from speech
  static String _extractContent(String text, String title) {
    if (text.length > title.length + 10) {
      return text; // Use full text as content
    }
    return '';
  }

  /// Extract time from speech using advanced parsing
  static DateTime? _extractTime(String text) {
    final now = DateTime.now();

    // Specific time patterns
    final timePatterns = [
      // Time with AM/PM
      RegExp(r'\b(\d{1,2}):?(\d{2})?\s*(am|pm)\b'),
      // "at 3" or "at 15"
      RegExp(r'\bat\s+(\d{1,2})\b'),
      // "in X minutes/hours"
      RegExp(r'\bin\s+(\d+)\s*(minute|hour)s?\b'),
    ];

    for (final pattern in timePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return _parseTimeMatch(match, now);
      }
    }

    // Day patterns
    if (text.contains('tomorrow')) {
      return DateTime(now.year, now.month, now.day + 1, 9, 0); // 9 AM tomorrow
    }

    if (text.contains('next week')) {
      return now.add(const Duration(days: 7));
    }

    if (text.contains('tonight')) {
      return DateTime(now.year, now.month, now.day, 20, 0); // 8 PM tonight
    }

    // Weekend detection
    if (text.contains('weekend') ||
        text.contains('saturday') ||
        text.contains('sunday')) {
      final daysUntilSaturday = (6 - now.weekday) % 7;
      return now
          .add(Duration(days: daysUntilSaturday == 0 ? 6 : daysUntilSaturday))
          .copyWith(hour: 10, minute: 0, second: 0, millisecond: 0);
    }

    return null;
  }

  /// Parse matched time pattern
  static DateTime _parseTimeMatch(Match match, DateTime now) {
    final hour = int.tryParse(match.group(1) ?? '') ?? 0;
    final minute = int.tryParse(match.group(2) ?? '0') ?? 0;
    final period = match.group(3)?.toLowerCase();

    int finalHour = hour;

    if (period == 'pm' && hour < 12) {
      finalHour += 12;
    } else if (period == 'am' && hour == 12) {
      finalHour = 0;
    }

    // If time has passed today, schedule for tomorrow
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      finalHour,
      minute,
    );
    if (scheduledTime.isBefore(now)) {
      return scheduledTime.add(const Duration(days: 1));
    }

    return scheduledTime;
  }

  /// Extract priority from speech
  static ItemPriority? _extractPriority(String text) {
    for (final entry in _priorityKeywords.entries) {
      if (text.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  /// Extract category from speech
  static String _extractCategory(String text) {
    for (final category in _categoryKeywords.entries) {
      for (final keyword in category.value) {
        if (text.contains(keyword)) {
          return category.key;
        }
      }
    }
    return '';
  }

  /// Check if text has time indicators
  static bool _hasTimeIndicators(String text) {
    final timeIndicators = [
      'at',
      'in',
      'on',
      'tomorrow',
      'today',
      'tonight',
      'morning',
      'evening',
      'afternoon',
      'pm',
      'am',
      'minute',
      'hour',
      'day',
      'week',
      'weekend',
    ];

    return timeIndicators.any((indicator) => text.contains(indicator));
  }

  /// Check if text has action words
  static bool _hasActionWords(String text) {
    final actionWords = [
      'buy',
      'call',
      'send',
      'write',
      'check',
      'complete',
      'finish',
      'do',
      'get',
      'take',
      'make',
      'clean',
    ];

    return actionWords.any((word) => text.contains(word));
  }

  /// Generate unique ID
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000).toString();
  }

  /// Advanced parsing for complex scenarios
  static Map<String, dynamic> parseComplexVoice(String speechText) {
    final item = parseVoiceInput(speechText);
    final confidence = _calculateConfidence(speechText);
    final suggestions = _generateSuggestions(speechText, item);

    return {
      'item': item,
      'confidence': confidence,
      'suggestions': suggestions,
      'rawText': speechText,
    };
  }

  /// Calculate parsing confidence
  static double _calculateConfidence(String text) {
    double confidence = 0.5; // Base confidence

    // Length factor
    if (text.length > 10) confidence += 0.2;

    // Keyword matches
    int keywordMatches = 0;
    for (final keyword in [..._todoKeywords, ..._reminderKeywords]) {
      if (text.contains(keyword)) keywordMatches++;
    }
    confidence += keywordMatches * 0.1;

    // Time presence
    if (_hasTimeIndicators(text)) confidence += 0.2;

    // Cap at 1.0
    return confidence.clamp(0.0, 1.0);
  }

  /// Generate alternative suggestions
  static List<UniversalItem> _generateSuggestions(
    String text,
    UniversalItem original,
  ) {
    final suggestions = <UniversalItem>[];

    // If parsed as note, suggest todo version
    if (original.isNote && _hasActionWords(text)) {
      suggestions.add(
        UniversalItem.todo(
          id: _generateId(),
          title: original.title,
          content: original.content,
          hasVoiceNote: true,
        ),
      );
    }

    // If parsed as todo, suggest reminder version if time detected
    if (original.isTodo && _hasTimeIndicators(text)) {
      final reminderTime =
          _extractTime(text) ?? DateTime.now().add(const Duration(hours: 1));
      suggestions.add(
        UniversalItem.reminder(
          id: _generateId(),
          title: original.title,
          content: original.content,
          reminderTime: reminderTime,
        ),
      );
    }

    return suggestions;
  }
}

enum ItemType { note, todo, reminder }

// Extension for DateTime
extension DateTimeExtensions on DateTime {
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }
}
