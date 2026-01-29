import 'package:sqflite/sqflite.dart';
import 'package:mynotes/data/datasources/local/reminder_template_local_datasource.dart';
import 'package:mynotes/domain/entities/reminder_template.dart';

/// Implementation of ReminderTemplateLocalDataSource using SQLite
class ReminderTemplateLocalDataSourceImpl
    implements ReminderTemplateLocalDataSource {
  final Database database;

  ReminderTemplateLocalDataSourceImpl({required this.database});

  static const String tableName = 'reminder_templates';

  @override
  Future<List<ReminderTemplate>> getAllTemplates() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(tableName);
      return List<ReminderTemplate>.from(
        maps.map((x) => ReminderTemplate.fromJson(x)),
      );
    } catch (e) {
      throw Exception('Failed to load templates: $e');
    }
  }

  @override
  Future<int> insertTemplate(ReminderTemplate template) async {
    try {
      return await database.insert(tableName, template.toJson());
    } catch (e) {
      throw Exception('Failed to insert template: $e');
    }
  }

  @override
  Future<int> updateTemplate(ReminderTemplate template) async {
    try {
      return await database.update(
        tableName,
        template.toJson(),
        where: 'id = ?',
        whereArgs: [template.id],
      );
    } catch (e) {
      throw Exception('Failed to update template: $e');
    }
  }

  @override
  Future<int> deleteTemplate(String id) async {
    try {
      return await database.delete(tableName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Failed to delete template: $e');
    }
  }

  @override
  Future<ReminderTemplate?> getTemplateById(String id) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return ReminderTemplate.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get template: $e');
    }
  }

  @override
  Future<List<ReminderTemplate>> getTemplatesByCategory(String category) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        tableName,
        where: 'category = ?',
        whereArgs: [category],
      );
      return List<ReminderTemplate>.from(
        maps.map((x) => ReminderTemplate.fromJson(x)),
      );
    } catch (e) {
      throw Exception('Failed to get templates by category: $e');
    }
  }

  @override
  Future<List<ReminderTemplate>> getFavoriteTemplates() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        tableName,
        where: 'isFavorite = ?',
        whereArgs: [1],
      );
      return List<ReminderTemplate>.from(
        maps.map((x) => ReminderTemplate.fromJson(x)),
      );
    } catch (e) {
      throw Exception('Failed to get favorite templates: $e');
    }
  }

  @override
  Future<int> toggleFavorite(String id, bool isFavorite) async {
    try {
      return await database.update(
        tableName,
        {'isFavorite': isFavorite ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  @override
  Future<List<String>> getAvailableCategories() async {
    try {
      final result = await database.rawQuery(
        'SELECT DISTINCT category FROM $tableName ORDER BY category',
      );
      return List<String>.from(result.map((x) => x['category']));
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  @override
  Future<List<ReminderTemplate>> searchTemplates(String query) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        tableName,
        where: 'name LIKE ? OR description LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
      );
      return List<ReminderTemplate>.from(
        maps.map((x) => ReminderTemplate.fromJson(x)),
      );
    } catch (e) {
      throw Exception('Failed to search templates: $e');
    }
  }

  @override
  Future<List<ReminderTemplate>> getMostUsedTemplates(int limit) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        tableName,
        orderBy: 'usageCount DESC',
        limit: limit,
      );
      return List<ReminderTemplate>.from(
        maps.map((x) => ReminderTemplate.fromJson(x)),
      );
    } catch (e) {
      throw Exception('Failed to get most used templates: $e');
    }
  }

  @override
  Future<int> incrementUsageCount(String id) async {
    try {
      return await database.rawUpdate(
        'UPDATE $tableName SET usageCount = usageCount + 1 WHERE id = ?',
        [id],
      );
    } catch (e) {
      throw Exception('Failed to increment usage count: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getTemplateStats() async {
    try {
      final countResult = await database.rawQuery(
        'SELECT COUNT(*) as total FROM $tableName',
      );
      final favoriteResult = await database.rawQuery(
        'SELECT COUNT(*) as favorites FROM $tableName WHERE isFavorite = 1',
      );
      final usageResult = await database.rawQuery(
        'SELECT SUM(usageCount) as totalUsage FROM $tableName',
      );

      return {
        'total': countResult.first['total'] ?? 0,
        'favorites': favoriteResult.first['favorites'] ?? 0,
        'totalUsage': usageResult.first['totalUsage'] ?? 0,
        'categories': await getAvailableCategories(),
      };
    } catch (e) {
      throw Exception('Failed to get template stats: $e');
    }
  }

  @override
  Future<List<ReminderTemplate>> getBuiltInTemplates() async {
    try {
      // Assuming built-in templates are marked or have specific IDs
      return getAllTemplates();
    } catch (e) {
      throw Exception('Failed to get built-in templates: $e');
    }
  }

  @override
  Future<List<ReminderTemplate>> getCustomTemplates() async {
    try {
      // Assuming custom templates are those not built-in
      return getAllTemplates();
    } catch (e) {
      throw Exception('Failed to get custom templates: $e');
    }
  }

  @override
  Future<int> clearAllTemplates() async {
    try {
      return await database.delete(tableName);
    } catch (e) {
      throw Exception('Failed to clear templates: $e');
    }
  }
}
