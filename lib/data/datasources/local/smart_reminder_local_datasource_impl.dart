import 'package:sqflite/sqflite.dart';
import 'package:mynotes/data/datasources/local/smart_reminder_local_datasource.dart';
import 'package:mynotes/domain/entities/reminder_suggestion.dart';

/// Implementation of SmartReminderLocalDataSource using SQLite
class SmartReminderLocalDataSourceImpl implements SmartReminderLocalDataSource {
  final Database database;

  SmartReminderLocalDataSourceImpl({required this.database});

  static const String tableSuggestions = 'reminder_suggestions';
  static const String tablePatterns = 'reminder_patterns';
  static const String tableFeedback = 'suggestion_feedback';
  static const String tablePreferences = 'learning_preferences';

  @override
  Future<List<ReminderSuggestion>> getSuggestions() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        tableSuggestions,
      );
      return List<ReminderSuggestion>.from(
        maps.map((x) => ReminderSuggestion.fromJson(x)),
      );
    } catch (e) {
      throw Exception('Failed to load suggestions: $e');
    }
  }

  @override
  Future<List<ReminderPattern>> getPatterns() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        tablePatterns,
      );
      return List<ReminderPattern>.from(
        maps.map((x) => ReminderPattern.fromJson(x)),
      );
    } catch (e) {
      throw Exception('Failed to load patterns: $e');
    }
  }

  @override
  Future<int> insertSuggestion(ReminderSuggestion suggestion) async {
    try {
      return await database.insert(tableSuggestions, suggestion.toJson());
    } catch (e) {
      throw Exception('Failed to insert suggestion: $e');
    }
  }

  @override
  Future<int> insertPattern(ReminderPattern pattern) async {
    try {
      return await database.insert(tablePatterns, pattern.toJson());
    } catch (e) {
      throw Exception('Failed to insert pattern: $e');
    }
  }

  @override
  Future<int> updateSuggestion(ReminderSuggestion suggestion) async {
    try {
      return await database.update(
        tableSuggestions,
        suggestion.toJson(),
        where: 'id = ?',
        whereArgs: [suggestion.id],
      );
    } catch (e) {
      throw Exception('Failed to update suggestion: $e');
    }
  }

  @override
  Future<int> updatePattern(ReminderPattern pattern) async {
    try {
      return await database.update(
        tablePatterns,
        pattern.toJson(),
        where: 'id = ?',
        whereArgs: [pattern.id],
      );
    } catch (e) {
      throw Exception('Failed to update pattern: $e');
    }
  }

  @override
  Future<int> deleteSuggestion(String id) async {
    try {
      await database.delete(
        tableFeedback,
        where: 'suggestionId = ?',
        whereArgs: [id],
      );
      return await database.delete(
        tableSuggestions,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete suggestion: $e');
    }
  }

  @override
  Future<ReminderSuggestion?> getSuggestionById(String id) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        tableSuggestions,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return ReminderSuggestion.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get suggestion: $e');
    }
  }

  @override
  Future<ReminderPattern?> getPatternById(String id) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        tablePatterns,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return ReminderPattern.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get pattern: $e');
    }
  }

  @override
  Future<int> saveSuggestionFeedback(
    String suggestionId,
    bool isPositive,
  ) async {
    try {
      return await database.insert(tableFeedback, {
        'suggestionId': suggestionId,
        'isPositive': isPositive ? 1 : 0,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to save feedback: $e');
    }
  }

  @override
  Future<double> getAverageCompletionRate() async {
    try {
      final result = await database.rawQuery(
        'SELECT AVG(completionRate) as avg FROM $tablePatterns',
      );
      if (result.isNotEmpty && result.first['avg'] != null) {
        return (result.first['avg'] as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      throw Exception('Failed to get average completion rate: $e');
    }
  }

  @override
  Future<double> getPatternCompletionRate(String patternId) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        tablePatterns,
        where: 'id = ?',
        whereArgs: [patternId],
      );
      if (maps.isNotEmpty) {
        final pattern = ReminderPattern.fromJson(maps.first);
        return pattern.completionRate;
      }
      return 0.0;
    } catch (e) {
      throw Exception('Failed to get pattern completion rate: $e');
    }
  }

  @override
  Future<Map<String, bool>> getLearningPreferences() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        tablePreferences,
      );
      final preferences = <String, bool>{};
      for (final map in maps) {
        preferences[map['key']] = map['value'] == 1;
      }
      return preferences;
    } catch (e) {
      throw Exception('Failed to get learning preferences: $e');
    }
  }

  @override
  Future<int> saveLearningPreference(String key, bool isEnabled) async {
    try {
      return await database.insert(tablePreferences, {
        'key': key,
        'value': isEnabled ? 1 : 0,
        'timestamp': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw Exception('Failed to save learning preference: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getModelMetadata() async {
    try {
      final result = await database.rawQuery(
        'SELECT COUNT(*) as suggestionCount, COUNT(DISTINCT id) as patternCount FROM $tablePatterns',
      );
      if (result.isNotEmpty) {
        return {
          'version': '1.0',
          'lastUpdated': DateTime.now().toIso8601String(),
          'suggestionCount': result.first['suggestionCount'] ?? 0,
          'patternCount': result.first['patternCount'] ?? 0,
        };
      }
      return {};
    } catch (e) {
      throw Exception('Failed to get model metadata: $e');
    }
  }

  @override
  Future<int> updateModelMetadata(Map<String, dynamic> metadata) async {
    try {
      // Store in preferences table
      return await database.insert(tablePreferences, {
        'key': 'modelMetadata',
        'value': 1,
        'timestamp': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw Exception('Failed to update model metadata: $e');
    }
  }

  @override
  Future<int> clearOldSuggestions(int daysOld) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      return await database.delete(
        tableSuggestions,
        where: 'createdAt < ?',
        whereArgs: [cutoffDate.toIso8601String()],
      );
    } catch (e) {
      throw Exception('Failed to clear old suggestions: $e');
    }
  }

  @override
  Future<int> clearAllSuggestions() async {
    try {
      await database.delete(tableFeedback);
      return await database.delete(tableSuggestions);
    } catch (e) {
      throw Exception('Failed to clear suggestions: $e');
    }
  }
}
