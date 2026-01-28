import 'dart:async';
import 'package:mynotes/presentation/widgets/universal_item_card.dart';
import 'package:sqflite/sqflite.dart';

/// Unified Repository
/// Single source of truth for Notes, Todos, and Reminders
/// Handles all CRUD operations and cross-feature integration
class UnifiedRepository {
  static UnifiedRepository? _instance;
  static UnifiedRepository get instance => _instance ??= UnifiedRepository._();
  UnifiedRepository._();

  Database? _database;
  final StreamController<List<UniversalItem>> _itemsController =
      StreamController<List<UniversalItem>>.broadcast();
  final StreamController<List<UniversalItem>> _todosController =
      StreamController<List<UniversalItem>>.broadcast();
  final StreamController<List<UniversalItem>> _remindersController =
      StreamController<List<UniversalItem>>.broadcast();

  // Streams for reactive UI
  Stream<List<UniversalItem>> get allItemsStream => _itemsController.stream;
  Stream<List<UniversalItem>> get todosStream => _todosController.stream;
  Stream<List<UniversalItem>> get remindersStream =>
      _remindersController.stream;

  Stream<List<UniversalItem>> get notesStream => allItemsStream.map(
    (items) => items.where((item) => item.isNote).toList(),
  );

  // Initialize database
  Future<void> initialize() async {
    if (_database != null) return;

    _database = await openDatabase(
      'unified_mynotes.db',
      version: 1,
      onCreate: _createTables,
    );

    // Load initial data
    await _refreshStreams();
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE unified_items (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT DEFAULT '',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_todo INTEGER DEFAULT 0,
        is_completed INTEGER DEFAULT 0,
        reminder_time INTEGER,
        priority TEXT,
        category TEXT DEFAULT '',
        has_voice_note INTEGER DEFAULT 0,
        has_images INTEGER DEFAULT 0,
        tags TEXT,
        is_archived INTEGER DEFAULT 0,
        is_deleted INTEGER DEFAULT 0,
        metadata TEXT DEFAULT '{}'
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_is_todo ON unified_items(is_todo)');
    await db.execute(
      'CREATE INDEX idx_reminder_time ON unified_items(reminder_time)',
    );
    await db.execute('CREATE INDEX idx_category ON unified_items(category)');
    await db.execute(
      'CREATE INDEX idx_updated_at ON unified_items(updated_at)',
    );
  }

  // CRUD Operations

  /// Create a new item
  Future<String> createItem(UniversalItem item) async {
    await _ensureInitialized();

    await _database!.insert('unified_items', _itemToMap(item));
    await _refreshStreams();

    return item.id;
  }

  /// Get item by ID
  Future<UniversalItem?> getItem(String id) async {
    await _ensureInitialized();

    final maps = await _database!.query(
      'unified_items',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );

    return maps.isNotEmpty ? _mapToItem(maps.first) : null;
  }

  /// Update existing item
  Future<void> updateItem(UniversalItem item) async {
    await _ensureInitialized();

    await _database!.update(
      'unified_items',
      _itemToMap(item),
      where: 'id = ?',
      whereArgs: [item.id],
    );

    await _refreshStreams();
  }

  /// Delete item (soft delete)
  Future<void> deleteItem(String id) async {
    await _ensureInitialized();

    await _database!.update(
      'unified_items',
      {'is_deleted': 1, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );

    await _refreshStreams();
  }

  /// Archive item
  Future<void> archiveItem(String id) async {
    await _ensureInitialized();

    await _database!.update(
      'unified_items',
      {'is_archived': 1, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );

    await _refreshStreams();
  }

  // Specialized operations

  /// Toggle todo completion
  Future<void> toggleTodoCompletion(String id) async {
    final item = await getItem(id);
    if (item != null && item.isTodo) {
      final updatedItem = item.copyWith(isCompleted: !item.isCompleted);
      await updateItem(updatedItem);
    }
  }

  /// Add reminder to existing item
  Future<void> addReminderToItem(String id, DateTime reminderTime) async {
    final item = await getItem(id);
    if (item != null) {
      final updatedItem = item.copyWith(reminderTime: reminderTime);
      await updateItem(updatedItem);
    }
  }

  /// Convert note to todo
  Future<void> convertNoteToTodo(String id) async {
    final item = await getItem(id);
    if (item != null && !item.isTodo) {
      final updatedItem = item.copyWith(isTodo: true);
      await updateItem(updatedItem);
    }
  }

  // Query operations

  /// Get all active items
  Future<List<UniversalItem>> getAllItems() async {
    await _ensureInitialized();

    final maps = await _database!.query(
      'unified_items',
      where: 'is_deleted = 0 AND is_archived = 0',
      orderBy: 'updated_at DESC',
    );

    return maps.map(_mapToItem).toList();
  }

  /// Get todos only
  Future<List<UniversalItem>> getTodos() async {
    await _ensureInitialized();

    final maps = await _database!.query(
      'unified_items',
      where: 'is_todo = 1 AND is_deleted = 0 AND is_archived = 0',
      orderBy: 'created_at DESC',
    );

    return maps.map(_mapToItem).toList();
  }

  /// Get notes only
  Future<List<UniversalItem>> getNotes() async {
    await _ensureInitialized();

    final maps = await _database!.query(
      'unified_items',
      where:
          'is_todo = 0 AND reminder_time IS NULL AND is_deleted = 0 AND is_archived = 0',
      orderBy: 'updated_at DESC',
    );

    return maps.map(_mapToItem).toList();
  }

  /// Get reminders only
  Future<List<UniversalItem>> getReminders() async {
    await _ensureInitialized();

    final maps = await _database!.query(
      'unified_items',
      where: 'reminder_time IS NOT NULL AND is_deleted = 0 AND is_archived = 0',
      orderBy: 'reminder_time ASC',
    );

    return maps.map(_mapToItem).toList();
  }

  /// Get overdue reminders
  Future<List<UniversalItem>> getOverdueReminders() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _ensureInitialized();

    final maps = await _database!.query(
      'unified_items',
      where:
          'reminder_time IS NOT NULL AND reminder_time < ? AND is_deleted = 0 AND is_archived = 0',
      whereArgs: [now],
      orderBy: 'reminder_time ASC',
    );

    return maps.map(_mapToItem).toList();
  }

  /// Search across all items
  Future<List<UniversalItem>> searchItems(String query) async {
    await _ensureInitialized();

    final searchQuery = '%${query.toLowerCase()}%';
    final maps = await _database!.query(
      'unified_items',
      where: '''
        (LOWER(title) LIKE ? OR LOWER(content) LIKE ? OR LOWER(category) LIKE ?)
        AND is_deleted = 0 AND is_archived = 0
      ''',
      whereArgs: [searchQuery, searchQuery, searchQuery],
      orderBy: 'updated_at DESC',
    );

    return maps.map(_mapToItem).toList();
  }

  /// Get items by category
  Future<List<UniversalItem>> getItemsByCategory(String category) async {
    await _ensureInitialized();

    final maps = await _database!.query(
      'unified_items',
      where: 'LOWER(category) = ? AND is_deleted = 0 AND is_archived = 0',
      whereArgs: [category.toLowerCase()],
      orderBy: 'updated_at DESC',
    );

    return maps.map(_mapToItem).toList();
  }

  /// Get items by priority
  Future<List<UniversalItem>> getItemsByPriority(ItemPriority priority) async {
    await _ensureInitialized();

    final maps = await _database!.query(
      'unified_items',
      where: 'priority = ? AND is_deleted = 0 AND is_archived = 0',
      whereArgs: [priority.toString().split('.').last],
      orderBy: 'updated_at DESC',
    );

    return maps.map(_mapToItem).toList();
  }

  // Analytics and insights

  /// Get item counts by type
  Future<Map<String, int>> getItemCounts() async {
    await _ensureInitialized();

    final result = await _database!.rawQuery('''
      SELECT 
        SUM(CASE WHEN is_todo = 0 AND reminder_time IS NULL THEN 1 ELSE 0 END) as notes_count,
        SUM(CASE WHEN is_todo = 1 THEN 1 ELSE 0 END) as todos_count,
        SUM(CASE WHEN reminder_time IS NOT NULL THEN 1 ELSE 0 END) as reminders_count,
        SUM(CASE WHEN is_todo = 1 AND is_completed = 1 THEN 1 ELSE 0 END) as completed_todos_count
      FROM unified_items 
      WHERE is_deleted = 0 AND is_archived = 0
    ''');

    final row = result.first;
    return {
      'notes': (row['notes_count'] as int?) ?? 0,
      'todos': (row['todos_count'] as int?) ?? 0,
      'reminders': (row['reminders_count'] as int?) ?? 0,
      'completed_todos': (row['completed_todos_count'] as int?) ?? 0,
    };
  }

  /// Get productivity insights
  Future<Map<String, dynamic>> getProductivityInsights() async {
    final counts = await getItemCounts();
    final overdueReminders = await getOverdueReminders();

    final completionRate = counts['todos']! > 0
        ? (counts['completed_todos']! / counts['todos']!) * 100
        : 0.0;

    return {
      'total_items': counts.values.reduce((a, b) => a + b),
      'completion_rate': completionRate.round(),
      'overdue_reminders': overdueReminders.length,
      'most_productive_hour': await _getMostProductiveHour(),
      'top_category': await _getTopCategory(),
    };
  }

  // Helper methods

  Map<String, dynamic> _itemToMap(UniversalItem item) {
    return {
      'id': item.id,
      'title': item.title,
      'content': item.content,
      'created_at': item.createdAt.millisecondsSinceEpoch,
      'updated_at': item.updatedAt.millisecondsSinceEpoch,
      'is_todo': item.isTodo ? 1 : 0,
      'is_completed': item.isCompleted ? 1 : 0,
      'reminder_time': item.reminderTime?.millisecondsSinceEpoch,
      'priority': item.priority?.toString().split('.').last,
      'category': item.category,
      'has_voice_note': item.hasVoiceNote ? 1 : 0,
      'has_images': item.hasImages ? 1 : 0,
      'tags': item.tags?.join(','),
      'is_archived': 0,
      'is_deleted': 0,
      'metadata': '{}',
    };
  }

  UniversalItem _mapToItem(Map<String, dynamic> map) {
    return UniversalItem(
      id: map['id'],
      title: map['title'],
      content: map['content'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      isTodo: map['is_todo'] == 1,
      isCompleted: map['is_completed'] == 1,
      reminderTime: map['reminder_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['reminder_time'])
          : null,
      priority: map['priority'] != null
          ? ItemPriority.values.firstWhere(
              (e) => e.toString().split('.').last == map['priority'],
              orElse: () => ItemPriority.medium,
            )
          : null,
      category: map['category'] ?? '',
      hasVoiceNote: map['has_voice_note'] == 1,
      hasImages: map['has_images'] == 1,
      tags: map['tags']?.isNotEmpty == true ? map['tags'].split(',') : null,
    );
  }

  Future<void> _ensureInitialized() async {
    if (_database == null) {
      await initialize();
    }
  }

  Future<void> _refreshStreams() async {
    final allItems = await getAllItems();
    final todos = allItems.where((item) => item.isTodo).toList();
    final reminders = allItems.where((item) => item.isReminder).toList();

    _itemsController.add(allItems);
    _todosController.add(todos);
    _remindersController.add(reminders);
  }

  Future<int> _getMostProductiveHour() async {
    await _ensureInitialized();

    final result = await _database!.rawQuery(
      '''
      SELECT strftime('%H', datetime(created_at/1000, 'unixepoch', 'localtime')) as hour,
             COUNT(*) as count
      FROM unified_items 
      WHERE is_deleted = 0 AND created_at > ?
      GROUP BY hour 
      ORDER BY count DESC 
      LIMIT 1
    ''',
      [
        DateTime.now()
            .subtract(const Duration(days: 30))
            .millisecondsSinceEpoch,
      ],
    );

    return result.isNotEmpty ? int.parse(result.first['hour'] as String) : 9;
  }

  Future<String> _getTopCategory() async {
    await _ensureInitialized();

    final result = await _database!.rawQuery('''
      SELECT category, COUNT(*) as count
      FROM unified_items 
      WHERE is_deleted = 0 AND category != ''
      GROUP BY category 
      ORDER BY count DESC 
      LIMIT 1
    ''');

    return result.isNotEmpty ? result.first['category'] as String : 'General';
  }

  // Cleanup
  void dispose() {
    _itemsController.close();
    _todosController.close();
    _remindersController.close();
    _database?.close();
  }
}
