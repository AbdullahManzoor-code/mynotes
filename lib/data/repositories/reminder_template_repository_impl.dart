import 'package:mynotes/data/datasources/local/reminder_template_local_datasource.dart';
import 'package:mynotes/domain/entities/reminder_template.dart';
import 'package:mynotes/domain/repositories/reminder_template_repository.dart';

/// Implementation of ReminderTemplateRepository
class ReminderTemplateRepositoryImpl implements ReminderTemplateRepository {
  final ReminderTemplateLocalDataSource localDataSource;

  ReminderTemplateRepositoryImpl({required this.localDataSource});

  @override
  Future<List<ReminderTemplate>> loadTemplates() async {
    return await localDataSource.getAllTemplates();
  }

  @override
  Future<ReminderTemplate?> getTemplateById(String id) async {
    return await localDataSource.getTemplateById(id);
  }

  @override
  Future<List<ReminderTemplate>> getTemplatesByCategory(String category) async {
    return await localDataSource.getTemplatesByCategory(category);
  }

  @override
  Future<List<ReminderTemplate>> getFavoriteTemplates() async {
    return await localDataSource.getFavoriteTemplates();
  }

  @override
  Future<String> createTemplate(ReminderTemplate template) async {
    final result = await localDataSource.insertTemplate(template);
    return result > 0 ? template.id : '';
  }

  @override
  Future<bool> updateTemplate(ReminderTemplate template) async {
    final result = await localDataSource.updateTemplate(template);
    return result > 0;
  }

  @override
  Future<bool> deleteTemplate(String id) async {
    final result = await localDataSource.deleteTemplate(id);
    return result > 0;
  }

  @override
  Future<bool> toggleFavorite(String id, bool isFavorite) async {
    final result = await localDataSource.toggleFavorite(id, isFavorite);
    return result > 0;
  }

  @override
  Future<List<String>> getCategories() async {
    return await localDataSource.getAvailableCategories();
  }

  @override
  Future<String> createReminderFromTemplate(String templateId) async {
    final template = await localDataSource.getTemplateById(templateId);
    if (template != null) {
      await localDataSource.incrementUsageCount(templateId);
      // This would create an actual reminder from the template
      // For now, just return the template ID
      return templateId;
    }
    return '';
  }

  @override
  Future<Map<String, dynamic>> getTemplateStats() async {
    return await localDataSource.getTemplateStats();
  }

  @override
  Future<List<ReminderTemplate>> searchTemplates(String query) async {
    return await localDataSource.searchTemplates(query);
  }

  @override
  Future<List<ReminderTemplate>> getMostUsedTemplates({int limit = 10}) async {
    return await localDataSource.getMostUsedTemplates(limit);
  }

  @override
  Future<bool> incrementUsageCount(String id) async {
    final result = await localDataSource.incrementUsageCount(id);
    return result > 0;
  }
}
