import 'package:mynotes/domain/entities/reminder_suggestion.dart';

/// Local data source for smart reminders - handles SQLite operations
abstract class SmartReminderLocalDataSource {
  /// Load all suggestions
  Future<List<ReminderSuggestion>> getSuggestions();

  /// Load all patterns
  Future<List<ReminderPattern>> getPatterns();

  /// Insert suggestion
  Future<int> insertSuggestion(ReminderSuggestion suggestion);

  /// Insert pattern
  Future<int> insertPattern(ReminderPattern pattern);

  /// Update suggestion
  Future<int> updateSuggestion(ReminderSuggestion suggestion);

  /// Update pattern
  Future<int> updatePattern(ReminderPattern pattern);

  /// Delete suggestion
  Future<int> deleteSuggestion(String id);

  /// Get suggestion by ID
  Future<ReminderSuggestion?> getSuggestionById(String id);

  /// Get pattern by ID
  Future<ReminderPattern?> getPatternById(String id);

  /// Save suggestion feedback
  Future<int> saveSuggestionFeedback(String suggestionId, bool isPositive);

  /// Get acceptance rate
  Future<double> getAverageCompletionRate();

  /// Get pattern completion rate
  Future<double> getPatternCompletionRate(String patternId);

  /// Get learning preferences
  Future<Map<String, bool>> getLearningPreferences();

  /// Save learning preference
  Future<int> saveLearningPreference(String key, bool isEnabled);

  /// Get model metadata
  Future<Map<String, dynamic>> getModelMetadata();

  /// Update model metadata
  Future<int> updateModelMetadata(Map<String, dynamic> metadata);

  /// Clear old suggestions
  Future<int> clearOldSuggestions(int daysOld);

  /// Clear all suggestions (for testing)
  Future<int> clearAllSuggestions();
}
