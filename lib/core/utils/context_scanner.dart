import '../../domain/entities/universal_item.dart';

enum SuggestionType { todo, reminder, linkedNote, template }

class ContextSuggestion {
  final String title;
  final String content;
  final SuggestionType type;
  final DateTime? date;
  final ItemPriority priority;

  ContextSuggestion({
    required this.title,
    this.content = '',
    required this.type,
    this.date,
    this.priority = ItemPriority.medium,
  });
}

class ContextScanner {
  /// Scans text for patterns that suggest it should be a Todo or Reminder.
  static List<ContextSuggestion> scan(String text) {
    List<ContextSuggestion> suggestions = [];
    final lines = text.split('\n');

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // 1. Detect task indicators
      if (_isTaskLike(trimmed)) {
        suggestions.add(
          ContextSuggestion(
            title: _cleanTitle(trimmed),
            type: SuggestionType.todo,
            priority: _detectPriority(trimmed),
          ),
        );
      }

      // 2. Detect date/time indicators
      final detectedDate = _detectDate(trimmed);
      if (detectedDate != null) {
        suggestions.add(
          ContextSuggestion(
            title: _cleanTitle(trimmed),
            type: SuggestionType.reminder,
            date: detectedDate,
          ),
        );
      }

      // 3. Detect Template intent
      final templateName = _detectTemplateIntent(trimmed);
      if (templateName != null) {
        suggestions.add(
          ContextSuggestion(title: templateName, type: SuggestionType.template),
        );
      }
    }

    // 4. PREMIUM: Detect mentions of other potential note titles (e.g. [[Project]])
    // or recurring keywords that might be related to other notes.
    final potentialLinks = extractPotentialKeywords(text);
    for (var link in potentialLinks) {
      if (link.length > 3) {
        suggestions.add(
          ContextSuggestion(
            title: 'Link to "$link"',
            content: link,
            type: SuggestionType.linkedNote,
          ),
        );
      }
    }

    return suggestions;
  }

  static String? _detectTemplateIntent(String text) {
    final lower = text.toLowerCase();
    if (lower == 'meeting' || lower == 'meeting notes') return 'Meeting Notes';
    if (lower == 'journal' || lower == 'diary') return 'Daily Journal';
    if (lower == 'recipe' || lower == 'food') return 'Recipe';
    if (lower == 'project' || lower == 'plan') return 'Project Plan';
    return null;
  }

  /// Extracts keywords that might represent links to other notes.
  static List<String> extractPotentialKeywords(String text) {
    // 1. Look for [[bracketed links]]
    final wikiRegex = RegExp(r'\[\[(.*?)\]\]');
    final wikiMatches = wikiRegex
        .allMatches(text)
        .map((m) => m.group(1)!)
        .toList();

    // 2. Look for #tags
    final tagRegex = RegExp(r'#(\w+)');
    final tagMatches = tagRegex
        .allMatches(text)
        .map((m) => m.group(1)!)
        .toList();

    // 3. Look for capitalized phrases (simple entity extraction)
    final entityRegex = RegExp(r'\b([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)\b');
    final entityMatches = entityRegex
        .allMatches(text)
        .map((m) => m.group(0)!)
        .where((e) => e.length > 3) // Ignore short words like "The", "A"
        .toList();

    return <String>{...wikiMatches, ...tagMatches, ...entityMatches}.toList();
  }

  static bool _isTaskLike(String text) {
    final lower = text.toLowerCase();
    final taskKeywords = [
      'todo',
      'task',
      'need to',
      'must',
      'buy',
      'call',
      'send',
    ];
    return taskKeywords.any((kw) => lower.contains(kw)) ||
        text.startsWith('- [ ]') ||
        text.startsWith('[]') ||
        text.startsWith('* ');
  }

  static ItemPriority _detectPriority(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('urgent') || lower.contains('asap')) {
      return ItemPriority.high;
    }
    if (lower.contains('later')) return ItemPriority.low;
    return ItemPriority.medium;
  }

  static DateTime? _detectDate(String text) {
    final lower = text.toLowerCase();
    final now = DateTime.now();

    if (lower.contains('tomorrow')) {
      return DateTime(now.year, now.month, now.day + 1, 9); // Default 9 AM
    }

    // Very basic day of week detection
    final days = {
      'monday': DateTime.monday,
      'tuesday': DateTime.tuesday,
      'wednesday': DateTime.wednesday,
      'thursday': DateTime.thursday,
      'friday': DateTime.friday,
      'saturday': DateTime.saturday,
      'sunday': DateTime.sunday,
    };

    for (var day in days.entries) {
      if (lower.contains(day.key)) {
        int daysUntil = (day.value - now.weekday + 7) % 7;
        if (daysUntil == 0) daysUntil = 7;
        return DateTime(now.year, now.month, now.day + daysUntil, 9);
      }
    }

    return null;
  }

  static String _cleanTitle(String text) {
    return text
        .replaceAll('- [ ]', '')
        .replaceAll('[]', '')
        .replaceAll('* ', '')
        .trim();
  }
}
