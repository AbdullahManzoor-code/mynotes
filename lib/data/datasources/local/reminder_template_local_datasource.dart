import 'package:mynotes/domain/entities/reminder_template.dart';

/// Local data source for reminder templates - handles SQLite operations
abstract class ReminderTemplateLocalDataSource {
  /// Load all templates
  Future<List<ReminderTemplate>> getAllTemplates();

  /// Insert new template
  Future<int> insertTemplate(ReminderTemplate template);

  /// Update template
  Future<int> updateTemplate(ReminderTemplate template);

  /// Delete template
  Future<int> deleteTemplate(String id);

  /// Get template by ID
  Future<ReminderTemplate?> getTemplateById(String id);

  /// Get templates by category
  Future<List<ReminderTemplate>> getTemplatesByCategory(String category);

  /// Get favorite templates
  Future<List<ReminderTemplate>> getFavoriteTemplates();

  /// Toggle favorite status
  Future<int> toggleFavorite(String id, bool isFavorite);

  /// Get available categories
  Future<List<String>> getAvailableCategories();

  /// Search templates by name
  Future<List<ReminderTemplate>> searchTemplates(String query);

  /// Get most used templates
  Future<List<ReminderTemplate>> getMostUsedTemplates(int limit);

  /// Increment usage count
  Future<int> incrementUsageCount(String id);

  /// Get template statistics
  Future<Map<String, dynamic>> getTemplateStats();

  /// Get built-in templates
  Future<List<ReminderTemplate>> getBuiltInTemplates();

  /// Get custom templates
  Future<List<ReminderTemplate>> getCustomTemplates();

  /// Clear all templates (for testing)
  Future<int> clearAllTemplates();
}
