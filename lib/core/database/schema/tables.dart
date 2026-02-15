import 'package:sqflite/sqflite.dart';

/// All database table creation logic organized by concern
class DatabaseSchema {
  // Table names as constants
  static const String notesTable = 'notes';
  static const String todosTable = 'todos';
  static const String remindersTable = 'reminders';
  static const String mediaTable = 'media';
  static const String reflectionsTable = 'reflections';
  static const String reflectionAnswersTable = 'reflection_answers';
  static const String reflectionDraftsTable = 'reflection_drafts';
  static const String reflectionQuestionsTable = 'reflection_questions';
  static const String activityTagsTable = 'activity_tags';
  static const String moodEntriesTable = 'mood_entries';
  static const String userSettingsTable = 'user_settings';
  static const String locationRemindersTable = 'location_reminders';
  static const String savedLocationsTable = 'saved_locations';
  static const String focusSessionsTable = 'focus_sessions';
  static const String smartCollectionsTable = 'smart_collections';
  static const String collectionRulesTable = 'collection_rules';
  static const String reminderTemplatesTable = 'reminder_templates';
  static const String noteLinksTable = 'note_links';
  static const String notesFtsTable = 'notes_fts';

  /// Create all tables at once
  static Future<void> createAll(Database db) async {
    await _createNoteTable(db);
    await _createTodoTable(db);
    await _createRemindersTable(db);
    await _createMediaTable(db);
    await _createReflectionsTable(db);
    await _createReflectionAnswersTable(db);
    await _createReflectionDraftsTable(db);
    await _createReflectionQuestionsTable(db);
    await _createActivityTagsTable(db);
    await _createMoodEntriesTable(db);
    await _createUserSettingsTable(db);
    await _createLocationRemindersTable(db);
    await _createSavedLocationsTable(db);
    await _createFocusSessionsTable(db);
    await _createSmartCollectionsTable(db);
    await _createCollectionRulesTable(db);
    await _createReminderTemplatesTable(db);
    await _createNoteLinksTable(db);
  }

  static Future<void> _createNoteTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $notesTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        color INTEGER NOT NULL DEFAULT 0,
        category TEXT NOT NULL DEFAULT 'General',
        isPinned INTEGER NOT NULL DEFAULT 0,
        isArchived INTEGER NOT NULL DEFAULT 0,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        tags TEXT,
        priority INTEGER DEFAULT 1,
        linkedReflectionId TEXT,
        linkedTodoId TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createTodoTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $todosTable (
        id TEXT PRIMARY KEY,
        noteId TEXT,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL DEFAULT 'Personal',
        priority INTEGER NOT NULL DEFAULT 2,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        isImportant INTEGER NOT NULL DEFAULT 0,
        hasReminder INTEGER NOT NULL DEFAULT 0,
        reminderId TEXT,
        dueDate TEXT,
        completedAt TEXT,
        subtasksJson TEXT,
        attachmentsJson TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (noteId) REFERENCES $notesTable(id)
      )
    ''');
  }

  static Future<void> _createRemindersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $remindersTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        scheduledTime TEXT NOT NULL,
        recurrence TEXT,
        snoozeCount INTEGER DEFAULT 0,
        isActive INTEGER NOT NULL DEFAULT 1,
        hasVibration INTEGER NOT NULL DEFAULT 1,
        hasSound INTEGER NOT NULL DEFAULT 1,
        label TEXT,
        linkedNoteId TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createMediaTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $mediaTable (
        id TEXT PRIMARY KEY,
        noteId TEXT NOT NULL,
        type TEXT NOT NULL,
        name TEXT NOT NULL,
        size INTEGER,
        filePath TEXT NOT NULL,
        thumbnailPath TEXT,
        durationMs INTEGER DEFAULT 0,
        metadata TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (noteId) REFERENCES $notesTable(id)
      )
    ''');
  }

  static Future<void> _createReflectionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $reflectionsTable (
        id TEXT PRIMARY KEY,
        questionId TEXT,
        answerText TEXT NOT NULL,
        mood TEXT,
        moodValue INTEGER,
        energyLevel INTEGER,
        activityTags TEXT,
        reflectionDate TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (questionId) REFERENCES $reflectionQuestionsTable(id)
      )
    ''');
  }

  static Future<void> _createReflectionAnswersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $reflectionAnswersTable (
        id TEXT PRIMARY KEY,
        reflectionId TEXT NOT NULL,
        questionId TEXT,
        answerText TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (reflectionId) REFERENCES $reflectionsTable(id),
        FOREIGN KEY (questionId) REFERENCES $reflectionQuestionsTable(id)
      )
    ''');
  }

  static Future<void> _createReflectionDraftsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $reflectionDraftsTable (
        id TEXT PRIMARY KEY,
        questionId TEXT,
        answerText TEXT,
        lastEditedAt TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (questionId) REFERENCES $reflectionQuestionsTable(id)
      )
    ''');
  }

  static Future<void> _createReflectionQuestionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $reflectionQuestionsTable (
        id TEXT PRIMARY KEY,
        question TEXT NOT NULL,
        category TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createActivityTagsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $activityTagsTable (
        id TEXT PRIMARY KEY,
        tagName TEXT NOT NULL UNIQUE,
        colorHex TEXT,
        frequency INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createMoodEntriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $moodEntriesTable (
        id TEXT PRIMARY KEY,
        reflectionId TEXT,
        mood TEXT NOT NULL,
        moodValue INTEGER NOT NULL,
        recordedAt TEXT NOT NULL,
        FOREIGN KEY (reflectionId) REFERENCES $reflectionsTable(id)
      )
    ''');
  }

  static Future<void> _createUserSettingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $userSettingsTable (
        id TEXT PRIMARY KEY,
        settingKey TEXT NOT NULL UNIQUE,
        settingValue TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createLocationRemindersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $locationRemindersTable (
        id TEXT PRIMARY KEY,
        message TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        radius REAL NOT NULL DEFAULT 100.0,
        trigger_type TEXT NOT NULL,
        place_name TEXT,
        place_address TEXT,
        linked_note_id TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createSavedLocationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $savedLocationsTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        address TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createFocusSessionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $focusSessionsTable (
        id TEXT PRIMARY KEY,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        durationSeconds INTEGER NOT NULL,
        taskTitle TEXT,
        category TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        rating INTEGER,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createSmartCollectionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $smartCollectionsTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        itemCount INTEGER DEFAULT 0,
        lastUpdated TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        logic TEXT NOT NULL DEFAULT 'AND'
      )
    ''');
  }

  static Future<void> _createCollectionRulesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $collectionRulesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        collectionId TEXT NOT NULL,
        type TEXT NOT NULL,
        operator TEXT NOT NULL,
        value TEXT NOT NULL,
        FOREIGN KEY (collectionId) REFERENCES $smartCollectionsTable(id)
      )
    ''');
  }

  static Future<void> _createReminderTemplatesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $reminderTemplatesTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        cronExpression TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createNoteLinksTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $noteLinksTable (
        sourceId TEXT NOT NULL,
        targetId TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'manual',
        createdAt TEXT NOT NULL,
        PRIMARY KEY (sourceId, targetId),
        FOREIGN KEY (sourceId) REFERENCES $notesTable(id),
        FOREIGN KEY (targetId) REFERENCES $notesTable(id)
      )
    ''');
  }
}
