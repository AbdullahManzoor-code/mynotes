import '../entities/focus_session.dart';

abstract class StatsRepository {
  // Focus Sessions
  Future<void> saveFocusSession(FocusSession session);
  Future<List<FocusSession>> getFocusSessions();
  Future<List<FocusSession>> getFocusSessionsByDateRange(
    DateTime start,
    DateTime end,
  );

  // Aggregate Metrics
  Future<Map<String, int>> getItemCounts();
  Future<Map<String, double>> getWeeklyActivity();
  Future<List<Map<String, dynamic>>> getCategoryBreakdown();
  Future<Map<String, dynamic>> getProductivityInsights();
  Future<int> getCurrentStreak();
  Future<List<Map<String, dynamic>>> getRecentItems({int limit = 5});
  Future<List<Map<String, dynamic>>> getOverdueReminders();
  Future<List<String>> getDailyHighlights();
}
