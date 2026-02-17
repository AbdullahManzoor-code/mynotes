/// Reminder Templates service for managing and using reminder templates
class ReminderTemplatesService {
  static final ReminderTemplatesService _instance =
      ReminderTemplatesService._internal();

  factory ReminderTemplatesService() {
    return _instance;
  }

  ReminderTemplatesService._internal();

  /// Load all available templates
  Future<List<Map<String, dynamic>>> loadTemplates() async {
    try {
      // Implementation would load from database
      return [
        {
          'id': '1',
          'name': 'Daily Standup',
          'description': 'Quick team sync meeting',
          'time': '10:00 AM',
          'frequency': 'Weekdays',
          'duration': '15 min',
          'category': 'Work',
          'isFavorite': false,
        },
        {
          'id': '2',
          'name': 'Lunch Break',
          'description': 'Take a break and eat',
          'time': '12:30 PM',
          'frequency': 'Daily',
          'duration': '60 min',
          'category': 'Personal',
          'isFavorite': false,
        },
        {
          'id': '3',
          'name': 'Medication Reminder',
          'description': 'Take your daily medications',
          'time': '8:00 AM, 8:00 PM',
          'frequency': 'Daily',
          'duration': '5 min',
          'category': 'Health',
          'isFavorite': false,
        },
      ];
    } catch (e) {
      throw Exception('Failed to load templates: $e');
    }
  }

  /// Get templates by category
  Future<List<Map<String, dynamic>>> getTemplatesByCategory(
    String category,
  ) async {
    try {
      final all = await loadTemplates();
      return all.where((t) => t['category'] == category).toList();
    } catch (e) {
      throw Exception('Failed to get templates by category: $e');
    }
  }

  /// Create reminder from template
  Future<String> createReminderFromTemplate(String templateId) async {
    try {
      final templates = await loadTemplates();
      templates.firstWhere((t) => t['id'] == templateId);

      // Implementation would create actual reminder
      return '${templateId}_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      throw Exception('Failed to create reminder from template: $e');
    }
  }

  /// Toggle template as favorite
  Future<bool> toggleFavorite(String templateId) async {
    try {
      // Implementation would store preference
      return true;
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  /// Get favorite templates
  Future<List<Map<String, dynamic>>> getFavoriteTemplates() async {
    try {
      final all = await loadTemplates();
      return all.where((t) => t['isFavorite'] as bool).toList();
    } catch (e) {
      throw Exception('Failed to get favorite templates: $e');
    }
  }

  /// Get available categories
  Future<List<String>> getCategories() async {
    try {
      final templates = await loadTemplates();
      final categories = <String>{'All'};
      for (var template in templates) {
        categories.add(template['category'] as String);
      }
      return categories.toList();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  /// Create custom template
  Future<String> createCustomTemplate({
    required String name,
    required String description,
    required String time,
    required String frequency,
    required String duration,
    required String category,
  }) async {
    try {
      // Implementation would save to database
      return DateTime.now().millisecondsSinceEpoch.toString();
    } catch (e) {
      throw Exception('Failed to create custom template: $e');
    }
  }

  /// Delete template
  Future<bool> deleteTemplate(String templateId) async {
    try {
      // Implementation would delete from database
      return true;
    } catch (e) {
      throw Exception('Failed to delete template: $e');
    }
  }

  /// Get template statistics
  Future<Map<String, dynamic>> getTemplateStats() async {
    try {
      final templates = await loadTemplates();
      final favorites = templates.where((t) => t['isFavorite'] as bool).length;

      return {
        'total': templates.length,
        'favorites': favorites,
        'categories': <String>{'Work', 'Personal', 'Health'}.length,
        'mostUsed': 'Daily Standup',
      };
    } catch (e) {
      throw Exception('Failed to get template stats: $e');
    }
  }
}
