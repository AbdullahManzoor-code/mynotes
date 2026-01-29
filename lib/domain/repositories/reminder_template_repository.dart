import 'package:mynotes/domain/entities/reminder_template.dart';

/// Repository interface for reminder templates
abstract class ReminderTemplateRepository {
  /// Load all templates
  Future<List<ReminderTemplate>> loadTemplates();

  /// Get templates by category
  Future<List<ReminderTemplate>> getTemplatesByCategory(String category);

  /// Create a new template
  Future<String> createTemplate(ReminderTemplate template);

  /// Update an existing template
  Future<bool> updateTemplate(ReminderTemplate template);

  /// Delete a template
  Future<bool> deleteTemplate(String templateId);

  /// Get favorite templates
  Future<List<ReminderTemplate>> getFavoriteTemplates();

  /// Toggle template as favorite
  Future<bool> toggleFavorite(String templateId, bool isFavorite);

  /// Get all categories
  Future<List<String>> getCategories();

  /// Get template statistics
  Future<Map<String, dynamic>> getTemplateStats();

  /// Increment usage count
  Future<bool> incrementUsageCount(String templateId);

  /// Create reminder from template
  Future<String> createReminderFromTemplate(String templateId);
}
