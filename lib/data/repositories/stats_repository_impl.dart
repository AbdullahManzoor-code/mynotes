import 'package:sqflite/sqflite.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/repositories/stats_repository.dart';
import '../datasources/local_database.dart';

class StatsRepositoryImpl implements StatsRepository {
  final NotesDatabase _db;

  StatsRepositoryImpl(this._db);

  @override
  Future<void> saveFocusSession(FocusSession session) async {
    final db = await _db.database;
    await db.insert(
      NotesDatabase.focusSessionsTable,
      _focusSessionToMap(session),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<FocusSession>> getFocusSessions() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      NotesDatabase.focusSessionsTable,
      orderBy: 'startTime DESC',
    );
    return maps.map(_mapToFocusSession).toList();
  }

  @override
  Future<List<FocusSession>> getFocusSessionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      NotesDatabase.focusSessionsTable,
      where: 'startTime >= ? AND startTime <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'startTime DESC',
    );
    return maps.map(_mapToFocusSession).toList();
  }

  @override
  Future<Map<String, int>> getItemCounts() async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT 
        (SELECT COUNT(*) FROM ${NotesDatabase.notesTable} WHERE isDeleted = 0 AND isArchived = 0) as notes_count,
        (SELECT COUNT(*) FROM ${NotesDatabase.todosTable} WHERE isDeleted = 0) as todos_count,
        (SELECT COUNT(*) FROM ${NotesDatabase.todosTable} WHERE isDeleted = 0 AND isCompleted = 1) as completed_todos_count,
        (SELECT COUNT(*) FROM ${NotesDatabase.remindersTable} WHERE isDeleted = 0) as reminders_count,
        (SELECT COUNT(*) FROM ${NotesDatabase.focusSessionsTable} WHERE isCompleted = 1) as focus_sessions_count
    ''');

    if (result.isEmpty)
      return {
        'notes': 0,
        'todos': 0,
        'reminders': 0,
        'completed_todos': 0,
        'focus_sessions': 0,
      };

    final row = result.first;
    return {
      'notes': (row['notes_count'] as int?) ?? 0,
      'todos': (row['todos_count'] as int?) ?? 0,
      'completed_todos': (row['completed_todos_count'] as int?) ?? 0,
      'reminders': (row['reminders_count'] as int?) ?? 0,
      'focus_sessions': (row['focus_sessions_count'] as int?) ?? 0,
    };
  }

  @override
  Future<Map<String, double>> getWeeklyActivity() async {
    final db = await _db.database;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    // We'll aggregate counts from notes, todos, and reflections
    // For simplicity, we'll use a Dart-based aggregation after fetching recent items
    final weekAgoStr = weekAgo.toIso8601String();

    final notes = await db.query(
      NotesDatabase.notesTable,
      columns: ['createdAt'],
      where: 'createdAt >= ? AND isDeleted = 0',
      whereArgs: [weekAgoStr],
    );

    final todos = await db.query(
      NotesDatabase.todosTable,
      columns: ['createdAt'],
      where: 'createdAt >= ? AND isDeleted = 0',
      whereArgs: [weekAgoStr],
    );

    final reflections = await db.query(
      NotesDatabase.reflectionsTable,
      columns: ['createdAt'],
      where: 'createdAt >= ? AND isDeleted = 0',
      whereArgs: [weekAgoStr],
    );

    final focusSessions = await db.query(
      NotesDatabase.focusSessionsTable,
      columns: ['startTime'],
      where: 'startTime >= ? AND isCompleted = 1',
      whereArgs: [weekAgoStr],
    );

    final activityMap = <String, double>{};
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      final dayName = weekdays[date.weekday - 1];
      activityMap[dayName] = 0.0;

      final dateStr = date.toIso8601String().split('T')[0];

      activityMap[dayName] =
          (activityMap[dayName] ?? 0.0) +
          notes
              .where((n) => (n['createdAt'] as String).startsWith(dateStr))
              .length
              .toDouble();
      activityMap[dayName] =
          (activityMap[dayName] ?? 0.0) +
          todos
              .where((t) => (t['createdAt'] as String).startsWith(dateStr))
              .length
              .toDouble();
      activityMap[dayName] =
          (activityMap[dayName] ?? 0.0) +
          reflections
              .where((r) => (r['createdAt'] as String).startsWith(dateStr))
              .length
              .toDouble();
      activityMap[dayName] =
          (activityMap[dayName] ?? 0.0) +
          focusSessions
              .where((s) => (s['startTime'] as String).startsWith(dateStr))
              .length
              .toDouble();
    }

    return activityMap;
  }

  @override
  Future<List<Map<String, dynamic>>> getCategoryBreakdown() async {
    final db = await _db.database;

    final result = await db.rawQuery('''
      SELECT category, COUNT(*) as count 
      FROM (
        SELECT category FROM ${NotesDatabase.notesTable} WHERE isDeleted = 0
        UNION ALL
        SELECT category FROM ${NotesDatabase.todosTable} WHERE isDeleted = 0
      )
      WHERE category IS NOT NULL AND category != ''
      GROUP BY category
      ORDER BY count DESC
    ''');

    final totalResult = await db.rawQuery('''
      SELECT COUNT(*) as total FROM (
        SELECT id FROM ${NotesDatabase.notesTable} WHERE isDeleted = 0
        UNION ALL
        SELECT id FROM ${NotesDatabase.todosTable} WHERE isDeleted = 0
      )
    ''');

    final total = (totalResult.first['total'] as int?) ?? 1;
    if (total == 0) return [];

    return result.map((row) {
      final count = row['count'] as int;
      return {
        'name': row['category'] as String,
        'count': count,
        'percentage': (count / total) * 100,
      };
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> getProductivityInsights() async {
    final counts = await getItemCounts();
    final totalTodos = counts['todos'] ?? 0;
    final completedTodos = counts['completed_todos'] ?? 0;

    final completionRate = totalTodos > 0
        ? (completedTodos / totalTodos * 100).round()
        : 0;

    final db = await _db.database;
    final focusResult = await db.rawQuery('''
      SELECT SUM(durationSeconds) as total_seconds
      FROM ${NotesDatabase.focusSessionsTable}
      WHERE isCompleted = 1
    ''');

    final focusSeconds = (focusResult.first['total_seconds'] as int?) ?? 0;
    final focusMinutes = (focusSeconds / 60).round();

    return {
      'total_items':
          counts['notes']! +
          counts['todos']! +
          counts['reminders']! +
          counts['focus_sessions']!,
      'completion_rate': completionRate,
      'most_productive_hour': await _getMostProductiveHour(),
      'top_category': await _getTopCategory(),
      'focus_minutes': focusMinutes,
    };
  }

  @override
  Future<int> getCurrentStreak() async {
    final db = await _db.database;
    // Streak based on having at least one note, todo, or reflection per day
    final result = await db.rawQuery('''
      SELECT DISTINCT date(createdAt) as day
      FROM (
        SELECT createdAt FROM ${NotesDatabase.notesTable} WHERE isDeleted = 0
        UNION ALL
        SELECT createdAt FROM ${NotesDatabase.todosTable} WHERE isDeleted = 0
        UNION ALL
        SELECT createdAt FROM ${NotesDatabase.reflectionsTable} WHERE isDeleted = 0
      )
      ORDER BY day DESC
    ''');

    if (result.isEmpty) return 0;

    int streak = 0;
    DateTime today = DateTime.now();
    DateTime checkDate = DateTime(today.year, today.month, today.day);

    for (var row in result) {
      String? dayStr = row['day'] as String?;
      if (dayStr == null) continue;

      DateTime day = DateTime.parse(dayStr);
      if (day == checkDate) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (day.isBefore(checkDate)) {
        // Check if they skipped today but did something yesterday
        if (streak == 0 && day == checkDate.subtract(const Duration(days: 1))) {
          // If they haven't done anything today yet, the streak continues from yesterday
          streak = 1;
          checkDate = day.subtract(const Duration(days: 1));
          continue;
        }
        break; // Streak broken
      }
    }

    return streak;
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentItems({int limit = 5}) async {
    final db = await _db.database;
    // We return maps that can be converted to UniversalItem or used directly
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT 'note' as item_type, id, title, content, createdAt, updatedAt, 0 as isTodo, 0 as isCompleted, NULL as reminderTime, category
      FROM ${NotesDatabase.notesTable} 
      WHERE isDeleted = 0
      UNION ALL
      SELECT 'todo' as item_type, id, title, description as content, createdAt, updatedAt, 1 as isTodo, isCompleted, reminderTime, category
      FROM ${NotesDatabase.todosTable} 
      WHERE isDeleted = 0
      ORDER BY updatedAt DESC
      LIMIT ?
    ''',
      [limit],
    );
    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> getOverdueReminders() async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT 'reminder' as item_type, id, title, message as content, createdAt, updatedAt, 0 as isTodo, isCompleted, scheduledTime as reminderTime, 'Reminder' as category
      FROM ${NotesDatabase.remindersTable}
      WHERE scheduledTime < ? AND isCompleted = 0 AND isDeleted = 0
      ORDER BY scheduledTime ASC
    ''',
      [now],
    );

    return result;
  }

  @override
  Future<List<String>> getDailyHighlights() async {
    final db = await _db.database;
    final today = DateTime.now().toIso8601String().split('T')[0];

    // Get top 3 activities: Completed todos first, then new notes
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT title FROM ${NotesDatabase.todosTable} 
      WHERE isCompleted = 1 AND isDeleted = 0 AND (updatedAt LIKE ? OR createdAt LIKE ?)
      UNION ALL
      SELECT title FROM ${NotesDatabase.notesTable} 
      WHERE isDeleted = 0 AND createdAt LIKE ?
      LIMIT 3
    ''',
      ['$today%', '$today%', '$today%'],
    );

    final highlights = result.map((row) => row['title'] as String).toList();

    // Fallback if no activity today
    if (highlights.isEmpty) {
      return [
        'Organized workspace and set priorities for tomorrow',
        'Stayed focused on key tasks today',
        'Took time for mindful reflection',
      ];
    }

    return highlights;
  }

  Future<int> _getMostProductiveHour() async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT strftime('%H', createdAt) as hour, COUNT(*) as count
      FROM (
        SELECT createdAt FROM ${NotesDatabase.notesTable} WHERE isDeleted = 0
        UNION ALL
        SELECT createdAt FROM ${NotesDatabase.todosTable} WHERE isDeleted = 0
      )
      GROUP BY hour
      ORDER BY count DESC
      LIMIT 1
    ''');

    if (result.isEmpty) return 9;
    return int.parse(result.first['hour'] as String);
  }

  Future<String> _getTopCategory() async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT category, COUNT(*) as count
      FROM (
        SELECT category FROM ${NotesDatabase.notesTable} WHERE isDeleted = 0
        UNION ALL
        SELECT category FROM ${NotesDatabase.todosTable} WHERE isDeleted = 0
      )
      WHERE category IS NOT NULL AND category != ''
      GROUP BY category
      ORDER BY count DESC
      LIMIT 1
    ''');

    if (result.isEmpty) return 'General';
    return result.first['category'] as String;
  }

  Map<String, dynamic> _focusSessionToMap(FocusSession session) {
    return {
      'id': session.id,
      'startTime': session.startTime.toIso8601String(),
      'endTime': session.endTime?.toIso8601String(),
      'durationSeconds': session.durationSeconds,
      'taskTitle': session.taskTitle,
      'category': session.category,
      'isCompleted': session.isCompleted ? 1 : 0,
      'rating': session.rating,
      'createdAt': session.createdAt.toIso8601String(),
      'updatedAt': session.updatedAt.toIso8601String(),
    };
  }

  FocusSession _mapToFocusSession(Map<String, dynamic> map) {
    return FocusSession(
      id: map['id'] as String,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: map['endTime'] != null
          ? DateTime.parse(map['endTime'] as String)
          : null,
      durationSeconds: map['durationSeconds'] as int,
      taskTitle: map['taskTitle'] as String?,
      category: map['category'] as String? ?? 'Focus',
      isCompleted: (map['isCompleted'] as int) == 1,
      rating: map['rating'] as int?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
