// Removed unused imports

/// AI-powered reminder suggestion engine
class AISuggestionEngine {
  static final AISuggestionEngine _instance = AISuggestionEngine._internal();

  factory AISuggestionEngine() {
    return _instance;
  }

  AISuggestionEngine._internal();

  /// Generate smart suggestions based on user history and patterns
  Future<List<Map<String, dynamic>>> generateSuggestions({
    required List<dynamic> reminderHistory,
    required List<dynamic> mediaItems,
    int maxSuggestions = 5,
  }) async {
    try {
      final suggestions = <Map<String, dynamic>>[];

      // 1. Detect time-based patterns
      final timePatterns = detectTimePatterns(reminderHistory);
      suggestions.addAll(_createTimingBasedSuggestions(timePatterns));

      // 2. Detect content patterns
      final contentPatterns = detectContentPatterns(reminderHistory);
      suggestions.addAll(_createContentBasedSuggestions(contentPatterns));

      // 3. Detect media-based patterns
      suggestions.addAll(
        _createMediaBasedSuggestions(mediaItems, reminderHistory),
      );

      // 4. Detect frequency patterns
      final frequencyPatterns = detectFrequencyPatterns(reminderHistory);
      suggestions.addAll(_createFrequencyBasedSuggestions(frequencyPatterns));

      // Score and rank suggestions
      final scored = _scoreAndRankSuggestions(suggestions);

      // Limit to max suggestions
      return scored.take(maxSuggestions).toList();
    } catch (e) {
      throw Exception('Suggestion generation failed: ${e.toString()}');
    }
  }

  /// Detect recurring time patterns in reminder history
  Map<String, int> detectTimePatterns(List<dynamic> reminderHistory) {
    final timePatterns = <String, int>{};

    for (final reminder in reminderHistory) {
      try {
        final createdAt = DateTime.tryParse(reminder.createdAt ?? '');
        if (createdAt == null) continue;

        // Hour pattern (e.g., "09:00")
        final hour = '${createdAt.hour.toString().padLeft(2, '0')}:00';
        timePatterns[hour] = (timePatterns[hour] ?? 0) + 1;

        // Day of week pattern
        final dayName = _getDayName(createdAt.weekday);
        timePatterns[dayName] = (timePatterns[dayName] ?? 0) + 1;

        // Time of day pattern
        final timeOfDay = _getTimeOfDay(createdAt.hour);
        timePatterns[timeOfDay] = (timePatterns[timeOfDay] ?? 0) + 1;
      } catch (e) {
        // Skip invalid entries
      }
    }

    return timePatterns;
  }

  /// Detect content-related patterns
  Map<String, int> detectContentPatterns(List<dynamic> reminderHistory) {
    final patterns = <String, int>{};

    for (final reminder in reminderHistory) {
      try {
        final description = (reminder.description ?? '').toLowerCase();
        if (description.isEmpty) continue;

        // Extract keywords (words > 3 chars)
        final words = description
            .split(RegExp(r'[^a-z0-9]+'))
            .where((w) => w.length > 3)
            .toList();

        for (final word in words) {
          patterns[word] = (patterns[word] ?? 0) + 1;
        }
      } catch (e) {
        // Skip
      }
    }

    return patterns;
  }

  /// Detect frequency patterns (how often reminders are created)
  Map<String, dynamic> detectFrequencyPatterns(List<dynamic> reminderHistory) {
    if (reminderHistory.isEmpty) {
      return {'avgPerDay': 0, 'avgPerWeek': 0, 'trend': 'stable'};
    }

    try {
      // Parse dates
      final dates = reminderHistory
          .map((r) => DateTime.tryParse(r.createdAt ?? ''))
          .whereType<DateTime>()
          .toList();

      if (dates.length < 2) {
        return {'avgPerDay': 0, 'avgPerWeek': 0, 'trend': 'stable'};
      }

      // Calculate average frequency
      dates.sort();
      final daysDiff = dates.last.difference(dates.first).inDays + 1;
      final avgPerDay = reminderHistory.length / daysDiff;
      final avgPerWeek = avgPerDay * 7;

      // Detect trend (increasing/decreasing)
      final midpoint = dates.length ~/ 2;
      final firstHalf = dates.sublist(0, midpoint);
      final secondHalf = dates.sublist(midpoint);

      final trend = secondHalf.length > firstHalf.length * 0.8
          ? 'increasing'
          : 'stable';

      return {
        'avgPerDay': avgPerDay,
        'avgPerWeek': avgPerWeek,
        'trend': trend,
        'totalReminders': reminderHistory.length,
        'daysTracked': daysDiff,
      };
    } catch (e) {
      return {'avgPerDay': 0, 'avgPerWeek': 0, 'trend': 'stable'};
    }
  }

  /// Create time-based suggestions
  List<Map<String, dynamic>> _createTimingBasedSuggestions(
    Map<String, int> timePatterns,
  ) {
    final suggestions = <Map<String, dynamic>>[];

    // Sort patterns by frequency
    final sorted = timePatterns.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final pattern in sorted.take(3)) {
      final key = pattern.key;
      final count = pattern.value;

      if (count >= 3) {
        // Pattern is recurring
        suggestions.add({
          'type': 'timing',
          'description': 'You often create reminders at $key',
          'recommendation': 'Set a recurring reminder for $key',
          'confidence': (count / sorted.first.value * 100).toInt(),
          'data': {'time': key, 'frequency': count},
        });
      }
    }

    return suggestions;
  }

  /// Create content-based suggestions
  List<Map<String, dynamic>> _createContentBasedSuggestions(
    Map<String, int> contentPatterns,
  ) {
    final suggestions = <Map<String, dynamic>>[];

    // Sort patterns by frequency
    final sorted = contentPatterns.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final pattern in sorted.take(3)) {
      final word = pattern.key;
      final count = pattern.value;

      if (count >= 3) {
        suggestions.add({
          'type': 'content',
          'description': 'You mention "$word" frequently in reminders',
          'recommendation':
              'Create a template or collection for "$word"-related reminders',
          'confidence': (count / sorted.first.value * 100).toInt(),
          'data': {'keyword': word, 'frequency': count},
        });
      }
    }

    return suggestions;
  }

  /// Create frequency-based suggestions
  List<Map<String, dynamic>> _createFrequencyBasedSuggestions(
    Map<String, dynamic> frequencyPatterns,
  ) {
    final suggestions = <Map<String, dynamic>>[];

    final avgPerDay = frequencyPatterns['avgPerDay'] as double? ?? 0;
    final trend = frequencyPatterns['trend'] as String? ?? 'stable';

    if (avgPerDay > 0) {
      suggestions.add({
        'type': 'frequency',
        'description':
            'You create ${avgPerDay.toStringAsFixed(1)} reminders per day',
        'recommendation':
            'Your reminder activity is ${trend == 'increasing' ? 'increasing' : 'stable'}',
        'confidence': 75,
        'data': frequencyPatterns,
      });
    }

    if (avgPerDay < 1 &&
        (frequencyPatterns['totalReminders'] as int? ?? 0) > 0) {
      suggestions.add({
        'type': 'engagement',
        'description': 'You have low reminder creation frequency',
        'recommendation': 'Try setting automatic reminders for daily tasks',
        'confidence': 60,
        'data': frequencyPatterns,
      });
    }

    return suggestions;
  }

  /// Create media-based suggestions
  List<Map<String, dynamic>> _createMediaBasedSuggestions(
    List<dynamic> mediaItems,
    List<dynamic> reminderHistory,
  ) {
    final suggestions = <Map<String, dynamic>>[];

    // Detect if user has a lot of media but few reminders
    final mediaCount = mediaItems.length;
    final reminderCount = reminderHistory.length;

    if (mediaCount > 10 && reminderCount < mediaCount ~/ 2) {
      suggestions.add({
        'type': 'media',
        'description':
            'You have $mediaCount media items but only $reminderCount reminders',
        'recommendation': 'Create reminders to organize or review your media',
        'confidence': 65,
        'data': {'mediaCount': mediaCount, 'reminderCount': reminderCount},
      });
    }

    // Suggest reviewing unorganized media
    if (mediaCount > 20) {
      suggestions.add({
        'type': 'media_organization',
        'description': 'Large media collection ($mediaCount items) detected',
        'recommendation': 'Create reminders to organize and tag your media',
        'confidence': 55,
        'data': {'mediaCount': mediaCount},
      });
    }

    return suggestions;
  }

  /// Score and rank suggestions
  List<Map<String, dynamic>> _scoreAndRankSuggestions(
    List<Map<String, dynamic>> suggestions,
  ) {
    // Deduplicate by type
    final seen = <String>{};
    final deduped = <Map<String, dynamic>>[];

    for (final suggestion in suggestions) {
      final type = suggestion['type'] as String;
      if (!seen.contains(type)) {
        deduped.add(suggestion);
        seen.add(type);
      }
    }

    // Sort by confidence (descending)
    deduped.sort((a, b) {
      final confA = (a['confidence'] as int?) ?? 0;
      final confB = (b['confidence'] as int?) ?? 0;
      return confB.compareTo(confA);
    });

    return deduped;
  }

  /// Get personalized recommendation strength
  Future<Map<String, dynamic>> getPersonalizedRecommendationStrength({
    required List<dynamic> reminderHistory,
  }) async {
    try {
      final patterns = detectFrequencyPatterns(reminderHistory);
      final avgPerDay = patterns['avgPerDay'] as double? ?? 0;

      String strength = 'low';
      if (avgPerDay >= 5) {
        strength = 'very_high';
      } else if (avgPerDay >= 3) {
        strength = 'high';
      } else if (avgPerDay >= 1) {
        strength = 'medium';
      } else if (avgPerDay > 0) {
        strength = 'low';
      }

      return {
        'strength': strength,
        'score': (avgPerDay * 20).clamp(0, 100).toInt(),
        'description': 'Recommendation strength based on reminder activity',
        'patterns': patterns,
      };
    } catch (e) {
      return {
        'strength': 'low',
        'score': 0,
        'description': 'Unable to calculate recommendation strength',
      };
    }
  }

  /// Helper: Get day name from weekday number
  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  /// Helper: Get time of day category
  String _getTimeOfDay(int hour) {
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }
}
