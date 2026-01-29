import 'package:mynotes/data/datasources/local/smart_reminder_local_datasource.dart';
import 'package:mynotes/domain/entities/reminder_suggestion.dart';
import 'package:mynotes/domain/repositories/smart_reminder_repository.dart';

/// Implementation of SmartReminderRepository
class SmartReminderRepositoryImpl implements SmartReminderRepository {
  final SmartReminderLocalDataSource localDataSource;

  SmartReminderRepositoryImpl({required this.localDataSource});

  @override
  Future<List<ReminderSuggestion>> getAllSuggestions() async {
    return await localDataSource.getSuggestions();
  }

  @override
  Future<List<ReminderPattern>> getAllPatterns() async {
    return await localDataSource.getPatterns();
  }

  @override
  Future<ReminderSuggestion?> getSuggestionById(String id) async {
    return await localDataSource.getSuggestionById(id);
  }

  @override
  Future<String> acceptSuggestion(String suggestionId) async {
    await localDataSource.saveSuggestionFeedback(suggestionId, true);
    await localDataSource.deleteSuggestion(suggestionId);
    return suggestionId;
  }

  @override
  Future<bool> rejectSuggestion(String suggestionId) async {
    await localDataSource.saveSuggestionFeedback(suggestionId, false);
    await localDataSource.deleteSuggestion(suggestionId);
    return true;
  }

  @override
  Future<double> getAverageCompletionRate() async {
    return await localDataSource.getAverageCompletionRate();
  }

  @override
  Future<double> getPatternCompletionRate(String patternId) async {
    return await localDataSource.getPatternCompletionRate(patternId);
  }

  @override
  Future<bool> toggleLearning(String settingKey, bool isEnabled) async {
    final result = await localDataSource.saveLearningPreference(
      settingKey,
      isEnabled,
    );
    return result > 0;
  }

  @override
  Future<Map<String, bool>> getLearningPreferences() async {
    return await localDataSource.getLearningPreferences();
  }

  @override
  Future<Map<String, dynamic>> getModelInfo() async {
    return await localDataSource.getModelMetadata();
  }

  @override
  Future<String> predictBestTime(String reminderTitle) async {
    // AI prediction logic would go here
    // For now, return a default time
    return '2:00 PM';
  }

  @override
  Future<bool> saveFeedback(String suggestionId, bool isPositive) async {
    final result = await localDataSource.saveSuggestionFeedback(
      suggestionId,
      isPositive,
    );
    return result > 0;
  }

  @override
  Future<bool> refreshSuggestions() async {
    // This would trigger AI model to regenerate suggestions
    return true;
  }

  @override
  Future<List<ReminderSuggestion>> generateSuggestions() async {
    return await localDataSource.getSuggestions();
  }

  @override
  Future<List<ReminderPattern>> detectPatterns() async {
    return await localDataSource.getPatterns();
  }

  @override
  Future<bool> getLearningPreference(String settingKey) async {
    final prefs = await localDataSource.getLearningPreferences();
    return prefs[settingKey] ?? false;
  }

  @override
  Future<bool> savePatterAnalytics(Map<String, dynamic> analytics) async {
    final result = await localDataSource.updateModelMetadata(analytics);
    return result > 0;
  }
}
