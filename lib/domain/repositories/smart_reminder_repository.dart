import 'package:mynotes/domain/entities/reminder_suggestion.dart';

/// Repository interface for smart reminders
abstract class SmartReminderRepository {
  /// Generate suggestions
  Future<List<ReminderSuggestion>> generateSuggestions();

  /// Detect patterns
  Future<List<ReminderPattern>> detectPatterns();

  /// Accept a suggestion and create reminder
  Future<String> acceptSuggestion(String suggestionId);

  /// Reject a suggestion for learning
  Future<bool> rejectSuggestion(String suggestionId);

  /// Get all suggestions
  Future<List<ReminderSuggestion>> getAllSuggestions();

  /// Get suggestion by ID
  Future<ReminderSuggestion?> getSuggestionById(String id);

  /// Get all patterns
  Future<List<ReminderPattern>> getAllPatterns();

  /// Get average completion rate
  Future<double> getAverageCompletionRate();

  /// Get pattern completion rate
  Future<double> getPatternCompletionRate(String patternId);

  /// Toggle learning setting
  Future<bool> toggleLearning(String settingKey, bool isEnabled);

  /// Get learning preference
  Future<bool> getLearningPreference(String settingKey);

  /// Get all learning preferences
  Future<Map<String, bool>> getLearningPreferences();

  /// Save feedback on a suggestion
  Future<bool> saveFeedback(String suggestionId, bool isPositive);

  /// Refresh suggestions
  Future<bool> refreshSuggestions();

  /// Get AI model information
  Future<Map<String, dynamic>> getModelInfo();

  /// Predict best time for reminder
  Future<String> predictBestTime(String reminderTitle);

  /// Save pattern analytics
  Future<bool> savePatterAnalytics(Map<String, dynamic> analytics);
}
