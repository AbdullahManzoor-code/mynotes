import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/todo_item.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/entities/alarm.dart';
import '../../core/services/app_logger.dart';

/// Local SQLite database for notes storage
class NotesDatabase {
  static const String _databaseName = 'notes.db';
  // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
  /// Database version for schema migrations
  /// Current version: 16
  static const int _databaseVersion = 16;

  // P0 Tables
  static const String notesTable = 'notes';
  static const String todosTable = 'todos';
  static const String remindersTable = 'reminders';
  static const String mediaTable = 'media';

  // P1 Tables (Phase 2A)
  static const String reflectionsTable = 'reflections';
  static const String reflectionAnswersTable = 'reflection_answers';
  static const String reflectionQuestionsTable = 'reflection_questions';
  static const String reflectionDraftsTable = 'reflection_drafts';
  static const String activityTagsTable = 'activity_tags';
  static const String moodEntriesTable = 'mood_entries';
  static const String userSettingsTable = 'user_settings';

  // Location-based Reminders (Phase 2B)
  static const String locationRemindersTable = 'location_reminders';
  static const String savedLocationsTable = 'saved_locations';
  static const String focusSessionsTable = 'focus_sessions';

  // Batch 5 & 7 Tables
  static const String smartCollectionsTable = 'smart_collections';
  static const String collectionRulesTable = 'collection_rules';
  static const String reminderTemplatesTable = 'reminder_templates';

  // Full-text search
  static const String notesFtsTable = 'notes_fts';

  // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
  static const String noteLinksTable = 'note_links';

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    AppLogger.i('Database requested, initializing...');
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    AppLogger.i('Initializing database at path: $path');

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        AppLogger.i('Creating database version $version...');
        await _createTables(db, version);
        AppLogger.i('Database version $version created successfully.');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        AppLogger.i('Upgrading database from $oldVersion to $newVersion...');
        await _onUpgrade(db, oldVersion, newVersion);
        AppLogger.i('Database upgrade to $newVersion complete.');
      },
    );
  }

  Future<void> _createTables(Database db, int version) async {
    AppLogger.i('Adding core tables (Notes, Todos, Reminders)...');
    // Notes table (extended)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $notesTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        contentPreview TEXT,
        color INTEGER NOT NULL DEFAULT 0,
        category TEXT DEFAULT 'General',
        tags TEXT,
        isPinned INTEGER NOT NULL DEFAULT 0,
        isArchived INTEGER NOT NULL DEFAULT 0,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        wordCount INTEGER DEFAULT 0,
        characterCount INTEGER DEFAULT 0,
        readingTimeMinutes INTEGER DEFAULT 0,
        linkedReflectionId TEXT,
        linkedTodoId TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        lastAccessedAt TEXT,
        syncStatus TEXT DEFAULT 'pending',
        lastSyncedAt TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        priority INTEGER DEFAULT 1,
        FOREIGN KEY (linkedReflectionId) REFERENCES $reflectionsTable(id),
        FOREIGN KEY (linkedTodoId) REFERENCES $todosTable(id)
      )
    ''');

    // Todos table (enhanced)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $todosTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        noteId TEXT,
        parentTodoId TEXT,
        category TEXT NOT NULL DEFAULT 'Personal',
        priority INTEGER NOT NULL DEFAULT 2,
        isImportant INTEGER DEFAULT 0,
        hasReminder INTEGER DEFAULT 0,
        reminderId TEXT,
        dueDate TEXT,
        dueTime TEXT,
        completedAt TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        todo_order INTEGER,
        recurPattern TEXT,
        recurDays TEXT,
        recurEndDate TEXT,
        recurEndType TEXT,
        recurEndValue INTEGER,
        reminderTime TEXT,
        estimatedMinutes INTEGER,
        actualMinutes INTEGER,
        subtaskCount INTEGER DEFAULT 0,
        completedSubtasks INTEGER DEFAULT 0,
        subtasksJson TEXT,
        attachmentsJson TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (noteId) REFERENCES $notesTable(id) ON DELETE SET NULL,
        FOREIGN KEY (parentTodoId) REFERENCES $todosTable(id) ON DELETE CASCADE
      )
    ''');

    // Reminders table (enhanced, renamed from 'alarm')
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $remindersTable (
        id TEXT PRIMARY KEY,
        message TEXT,
        title TEXT,
        linkedNoteId TEXT,
        linkedTodoId TEXT,
        scheduledTime TEXT NOT NULL,
        timezone TEXT DEFAULT 'local',
        recurrence TEXT DEFAULT 'once',
        recurPattern TEXT,
        recurDays TEXT,
        recurEndDate TEXT,
        recurEndType TEXT,
        recurEndValue INTEGER,
        isActive INTEGER NOT NULL DEFAULT 1,
        isEnabled INTEGER NOT NULL DEFAULT 1,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        status TEXT DEFAULT 'pending',
        snoozedUntil TEXT,
        snoozeCount INTEGER DEFAULT 0,
        notificationId INTEGER,
        soundUri TEXT,
        hasVibration INTEGER DEFAULT 1,
        hasLED INTEGER DEFAULT 1,
        lastTriggered TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (linkedNoteId) REFERENCES $notesTable(id) ON DELETE SET NULL,
        FOREIGN KEY (linkedTodoId) REFERENCES $todosTable(id) ON DELETE SET NULL
      )
    ''');

    // Media table (enhanced)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $mediaTable (
        id TEXT PRIMARY KEY,
        noteId TEXT NOT NULL,
        type TEXT NOT NULL,
        name TEXT,
        size INTEGER,
        filePath TEXT NOT NULL,
        originalPath TEXT,
        thumbnailPath TEXT,
        isCompressed INTEGER DEFAULT 1,
        originalSize INTEGER,
        compressedSize INTEGER,
        compressionRatio REAL,
        width INTEGER,
        height INTEGER,
        aspectRatio REAL,
        durationMs INTEGER,
        mimeType TEXT,
        caption TEXT,
        media_order INTEGER,
        ocrText TEXT,
        ocrConfidence REAL,
        metadata TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (noteId) REFERENCES $notesTable(id) ON DELETE CASCADE
      )
    ''');

    // Reflections table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $reflectionsTable (
        id TEXT PRIMARY KEY,
        questionId TEXT NOT NULL,
        answerText TEXT NOT NULL,
        mood TEXT,
        moodValue INTEGER,
        energyLevel INTEGER,
        sleepQuality INTEGER,
        activityTags TEXT,
        isPrivate INTEGER DEFAULT 0,
        linkedNoteId TEXT,
        linkedTodoId TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        reflectionDate TEXT NOT NULL,
        draft TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (questionId) REFERENCES $reflectionQuestionsTable(id),
        FOREIGN KEY (linkedNoteId) REFERENCES $notesTable(id) ON DELETE SET NULL,
        FOREIGN KEY (linkedTodoId) REFERENCES $todosTable(id) ON DELETE SET NULL
      )
    ''');

    // Reflection Questions table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $reflectionQuestionsTable (
        id TEXT PRIMARY KEY,
        questionText TEXT NOT NULL,
        category TEXT NOT NULL,
        isDefault INTEGER DEFAULT 1,
        isCustom INTEGER DEFAULT 0,
        frequency TEXT DEFAULT 'daily',
        usageCount INTEGER DEFAULT 0,
        lastUsedAt TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        question_order INTEGER,
        isPinned INTEGER DEFAULT 0,
        isDeleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Activity Tags table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $activityTagsTable (
        id TEXT PRIMARY KEY,
        tagName TEXT NOT NULL,
        color TEXT,
        icon TEXT,
        usageCount INTEGER DEFAULT 0,
        lastUsedAt TEXT,
        createdAt TEXT NOT NULL,
        tag_order INTEGER,
        isDeleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Mood Entries table (Analytics)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $moodEntriesTable (
        id TEXT PRIMARY KEY,
        reflectionId TEXT NOT NULL,
        mood TEXT NOT NULL,
        moodValue INTEGER NOT NULL,
        energyLevel INTEGER,
        sleepQuality INTEGER,
        recordedAt TEXT NOT NULL,
        FOREIGN KEY (reflectionId) REFERENCES $reflectionsTable(id) ON DELETE CASCADE
      )
    ''');

    // User Settings table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $userSettingsTable (
        id TEXT PRIMARY KEY,
        theme TEXT DEFAULT 'system',
        fontFamily TEXT DEFAULT 'roboto',
        fontSize REAL DEFAULT 1.0,
        biometricEnabled INTEGER DEFAULT 0,
        pinRequired INTEGER DEFAULT 0,
        autoLockMinutes INTEGER DEFAULT 5,
        notificationsEnabled INTEGER DEFAULT 1,
        soundEnabled INTEGER DEFAULT 1,
        vibrationEnabled INTEGER DEFAULT 1,
        quietHoursStart TEXT,
        quietHoursEnd TEXT,
        voiceLanguage TEXT DEFAULT 'en-US',
        voiceCommandsEnabled INTEGER DEFAULT 1,
        audioFeedbackEnabled INTEGER DEFAULT 1,
        voiceConfidenceThreshold REAL DEFAULT 0.8,
        defaultNoteColor INTEGER DEFAULT 0,
        defaultTodoCategory TEXT DEFAULT 'Personal',
        defaultTodoPriority INTEGER DEFAULT 2,
        autoBackupEnabled INTEGER DEFAULT 0,
        cloudSyncEnabled INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Location Reminders table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $locationRemindersTable (
        id TEXT PRIMARY KEY,
        message TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        radius REAL DEFAULT 100.0,
        trigger_type TEXT DEFAULT 'arrive',
        place_name TEXT,
        place_address TEXT,
        linked_note_id TEXT,
        is_active INTEGER DEFAULT 1,
        last_triggered TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Saved Locations table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $savedLocationsTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        address TEXT,
        icon TEXT DEFAULT 'location_on',
        created_at TEXT NOT NULL
      )
    ''');

    // Focus Sessions table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $focusSessionsTable (
        id TEXT PRIMARY KEY,
        startTime TEXT NOT NULL,
        endTime TEXT,
        durationSeconds INTEGER,
        taskTitle TEXT,
        category TEXT DEFAULT 'Focus',
        isCompleted INTEGER DEFAULT 0,
        rating INTEGER,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Create Batch 5 & 7 tables
    await _migrateToV6(db);
    await _migrateToV7(db);
    await _migrateToV11(db);

    // Create FTS5 virtual table for full-text search
    try {
      await db.execute('''
        CREATE VIRTUAL TABLE IF NOT EXISTS $notesFtsTable USING fts5(
          noteId UNINDEXED,
          title,
          content,
          tags,
          category,
          content=notes,
          content_rowid=id,
          tokenize = 'porter'
        )
      ''');
    } catch (e) {
      // FTS5 may not be available on all devices/environments
      debugPrint(
        'Database: FTS5 not available on this device. Search fallback to standard SQL. Error: $e',
      );
    }

    // Create indexes for performance (P0 tables)
    await _createIndexes(db);
  }

  Future<void> _createIndexes(Database db) async {
    // Notes indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_notes_created ON $notesTable(createdAt DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_notes_pinned ON $notesTable(isPinned)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_notes_archived ON $notesTable(isArchived)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_notes_color ON $notesTable(color)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_notes_category ON $notesTable(category)',
    );

    // Todos indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_todos_noteId ON $todosTable(noteId)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_todos_parentId ON $todosTable(parentTodoId)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_todos_dueDate ON $todosTable(dueDate)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_todos_completed ON $todosTable(isCompleted)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_todos_category ON $todosTable(category)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_todos_priority ON $todosTable(priority)',
    );

    // Reminders indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_reminders_scheduledTime ON $remindersTable(scheduledTime)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_reminders_isActive ON $remindersTable(isActive)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_reminders_status ON $remindersTable(status)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_reminders_linkedNoteId ON $remindersTable(linkedNoteId)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_reminders_linkedTodoId ON $remindersTable(linkedTodoId)',
    );

    // Media indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_media_noteId ON $mediaTable(noteId)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_media_type ON $mediaTable(type)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_media_createdAt ON $mediaTable(createdAt DESC)',
    );

    // Reflections indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_reflections_createdAt ON $reflectionsTable(createdAt DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_reflections_reflectionDate ON $reflectionsTable(reflectionDate)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_reflections_mood ON $reflectionsTable(mood)',
    );

    // Questions indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_questions_category ON $reflectionQuestionsTable(category)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_questions_isDefault ON $reflectionQuestionsTable(isDefault)',
    );

    // Activity Tags indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_activity_tags_name ON $activityTagsTable(tagName)',
    );

    // Mood Entries indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_mood_entries_recordedAt ON $moodEntriesTable(recordedAt DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_mood_entries_mood ON $moodEntriesTable(mood)',
    );

    // Focus Sessions indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_focus_sessions_start ON $focusSessionsTable(startTime DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_focus_sessions_category ON $focusSessionsTable(category)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    AppLogger.i(
      'Upgrading database from version $oldVersion to $newVersion...',
    );
    // v1 → v2: Upgrade alarms table
    if (oldVersion < 2) {
      AppLogger.i('Migration: v1 to v2 (Regenerating reminders table)');
      await db.execute('DROP TABLE IF EXISTS $remindersTable');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $remindersTable (
          id TEXT PRIMARY KEY,
          linkedNoteId TEXT,
          scheduledTime TEXT NOT NULL,
          timezone TEXT DEFAULT 'local',
          recurPattern TEXT,
          isActive INTEGER NOT NULL DEFAULT 1,
          isCompleted INTEGER NOT NULL DEFAULT 0,
          status TEXT DEFAULT 'pending',
          createdAt TEXT NOT NULL,
          updatedAt TEXT,
          FOREIGN KEY (linkedNoteId) REFERENCES $notesTable(id) ON DELETE CASCADE
        )
      ''');
    }

    // v2 → v3: Extend existing tables with new columns
    if (oldVersion < 3) {
      AppLogger.i('Migration: v2 to v3');
      await _migrateToV3(db);
    }

    // v3 → v4: Create new tables for Phase 2A
    if (oldVersion < 4) {
      AppLogger.i('Migration: v3 to v4');
      await _migrateToV4(db);
    }

    // v4 → v5: Create focus_sessions table
    if (oldVersion < 5) {
      AppLogger.i('Migration: v4 to v5');
      await _migrateToV5(db);
    }

    // v5 → v6: Create Batch 5 & 7 tables
    if (oldVersion < 6) {
      AppLogger.i('Migration: v5 to v6');
      await _migrateToV6(db);
    }

    // v6 → v7: Create reflection_answers and reflection_drafts tables
    if (oldVersion < 7) {
      AppLogger.i('Migration: v6 to v7');
      await _migrateToV7(db);
    }

    // v7 → v8: Add isPinned to reflection_questions
    if (oldVersion < 8) {
      AppLogger.i('Migration: v7 to v8');
      await _migrateToV8(db);
    }

    // v8 → v9: Add rating to focus_sessions
    if (oldVersion < 9) {
      AppLogger.i('Migration: v8 to v9');
      await _migrateToV9(db);
    }

    // v9 → v10: Add metadata to media table
    if (oldVersion < 10) {
      AppLogger.i('Migration: v9 to v10');
      await _migrateToV10(db);
    }
    // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
    if (oldVersion < 11) {
      AppLogger.i('Migration: v10 to v11');
      await _migrateToV11(db);
    }

    // SAFETY MIGRATION: Ensure note_links exists if v11 failed
    if (oldVersion < 12) {
      AppLogger.i('Migration: v11 to v12 (Safety Check)');
      await _migrateToV11(db);
    }

    // v12 → v13: Add frequency to reflection_questions
    if (oldVersion < 13) {
      AppLogger.i('Migration: v12 to v13');
      await _migrateToV13(db);
    }

    // v13 → v14: Add recurrence to reminders and draft to reflections
    if (oldVersion < 14) {
      AppLogger.i('Migration: v13 to v14');
      await _migrateToV14(db);
    }

    // v14 → v15: Sync entity fields (isImportant, hasReminder, etc)
    if (oldVersion < 15) {
      AppLogger.i('Migration: v14 to v15');
      await _migrateToV15(db);
    }

    // v15 → v16: Align notes priority and todo extra fields
    if (oldVersion < 16) {
      AppLogger.i('Migration: v15 to v16');
      await _migrateToV16(db);
    }
    AppLogger.i('Migration process completed.');
  }

  Future<void> _migrateToV16(Database db) async {
    try {
      await db.execute(
        'ALTER TABLE $notesTable ADD COLUMN priority INTEGER DEFAULT 1',
      );
    } catch (e) {}
    try {
      await db.execute('ALTER TABLE $todosTable ADD COLUMN subtasksJson TEXT');
    } catch (e) {}
    try {
      await db.execute(
        'ALTER TABLE $todosTable ADD COLUMN attachmentsJson TEXT',
      );
    } catch (e) {}
    try {
      await db.execute(
        'ALTER TABLE $remindersTable ADD COLUMN lastTriggered TEXT',
      );
    } catch (e) {}
    try {
      await db.execute(
        'ALTER TABLE $remindersTable ADD COLUMN isEnabled INTEGER DEFAULT 1',
      );
    } catch (e) {}
  }

  Future<void> _migrateToV15(Database db) async {
    try {
      await db.execute(
        'ALTER TABLE $todosTable ADD COLUMN isImportant INTEGER DEFAULT 0',
      );
    } catch (e) {}
    try {
      await db.execute(
        'ALTER TABLE $todosTable ADD COLUMN hasReminder INTEGER DEFAULT 0',
      );
    } catch (e) {}
    try {
      await db.execute('ALTER TABLE $todosTable ADD COLUMN reminderId TEXT');
    } catch (e) {}
  }

  Future<void> _migrateToV13(Database db) async {
    try {
      await db.execute(
        'ALTER TABLE $reflectionQuestionsTable ADD COLUMN frequency TEXT DEFAULT "daily"',
      );
    } catch (e) {
      // Column may already exist
    }
  }

  Future<void> _migrateToV14(Database db) async {
    try {
      // Add recurrence column to reminders table
      await db.execute(
        'ALTER TABLE $remindersTable ADD COLUMN recurrence TEXT DEFAULT "once"',
      );
    } catch (e) {
      // Column may already exist
    }

    try {
      // Add draft column to reflections table
      await db.execute('ALTER TABLE $reflectionsTable ADD COLUMN draft TEXT');
    } catch (e) {
      // Column may already exist
    }
  }

  Future<void> _migrateToV10(Database db) async {
    try {
      await db.execute('ALTER TABLE $mediaTable ADD COLUMN metadata TEXT');
      await db.execute('ALTER TABLE $mediaTable ADD COLUMN name TEXT');
      await db.execute('ALTER TABLE $mediaTable ADD COLUMN size INTEGER');
    } catch (e) {
      // Columns may already exist
    }
  }

  // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
  Future<void> _migrateToV11(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $noteLinksTable (
        sourceId TEXT NOT NULL,
        targetId TEXT NOT NULL,
        type TEXT DEFAULT 'manual',
        createdAt TEXT NOT NULL,
        PRIMARY KEY (sourceId, targetId),
        FOREIGN KEY (sourceId) REFERENCES $notesTable(id) ON DELETE CASCADE,
        FOREIGN KEY (targetId) REFERENCES $notesTable(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _migrateToV9(Database db) async {
    try {
      await db.execute(
        'ALTER TABLE $focusSessionsTable ADD COLUMN rating INTEGER',
      );
    } catch (e) {
      // Column may already exist
    }
  }

  Future<void> _migrateToV8(Database db) async {
    try {
      await db.execute(
        'ALTER TABLE $reflectionQuestionsTable ADD COLUMN isPinned INTEGER DEFAULT 0',
      );
    } catch (e) {
      // Column may already exist
    }
  }

  Future<void> _migrateToV3(Database db) async {
    // Add new columns to notes table
    try {
      await db.execute(
        'ALTER TABLE $notesTable ADD COLUMN contentPreview TEXT',
      );
      await db.execute(
        'ALTER TABLE $notesTable ADD COLUMN category TEXT DEFAULT "General"',
      );
      await db.execute(
        'ALTER TABLE $notesTable ADD COLUMN isFavorite INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $notesTable ADD COLUMN wordCount INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $notesTable ADD COLUMN characterCount INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $notesTable ADD COLUMN readingTimeMinutes INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $notesTable ADD COLUMN linkedReflectionId TEXT',
      );
      await db.execute('ALTER TABLE $notesTable ADD COLUMN linkedTodoId TEXT');
      await db.execute(
        'ALTER TABLE $notesTable ADD COLUMN lastAccessedAt TEXT',
      );
      await db.execute(
        'ALTER TABLE $notesTable ADD COLUMN syncStatus TEXT DEFAULT "pending"',
      );
      await db.execute('ALTER TABLE $notesTable ADD COLUMN lastSyncedAt TEXT');
      await db.execute(
        'ALTER TABLE $notesTable ADD COLUMN isDeleted INTEGER NOT NULL DEFAULT 0',
      );
    } catch (e) {
      // Columns may already exist
    }

    // Enhance todos table
    try {
      await db.execute('ALTER TABLE $todosTable ADD COLUMN title TEXT');
      await db.execute('ALTER TABLE $todosTable ADD COLUMN description TEXT');
      await db.execute('ALTER TABLE $todosTable ADD COLUMN parentTodoId TEXT');
      await db.execute(
        'ALTER TABLE $todosTable ADD COLUMN category TEXT DEFAULT "Personal"',
      );
      await db.execute(
        'ALTER TABLE $todosTable ADD COLUMN priority INTEGER DEFAULT 2',
      );
      await db.execute('ALTER TABLE $todosTable ADD COLUMN dueTime TEXT');
      await db.execute('ALTER TABLE $todosTable ADD COLUMN completedAt TEXT');
      await db.execute('ALTER TABLE $todosTable ADD COLUMN todo_order INTEGER');
      await db.execute('ALTER TABLE $todosTable ADD COLUMN recurPattern TEXT');
      await db.execute('ALTER TABLE $todosTable ADD COLUMN recurDays TEXT');
      await db.execute('ALTER TABLE $todosTable ADD COLUMN recurEndDate TEXT');
      await db.execute('ALTER TABLE $todosTable ADD COLUMN recurEndType TEXT');
      await db.execute(
        'ALTER TABLE $todosTable ADD COLUMN recurEndValue INTEGER',
      );
      await db.execute('ALTER TABLE $todosTable ADD COLUMN reminderTime TEXT');
      await db.execute(
        'ALTER TABLE $todosTable ADD COLUMN hasReminder INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $todosTable ADD COLUMN estimatedMinutes INTEGER',
      );
      await db.execute(
        'ALTER TABLE $todosTable ADD COLUMN actualMinutes INTEGER',
      );
      await db.execute(
        'ALTER TABLE $todosTable ADD COLUMN subtaskCount INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $todosTable ADD COLUMN completedSubtasks INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $todosTable ADD COLUMN updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP',
      );
      await db.execute(
        'ALTER TABLE $todosTable ADD COLUMN isDeleted INTEGER NOT NULL DEFAULT 0',
      );
    } catch (e) {
      // Columns may already exist
    }

    // Enhance media table
    try {
      await db.execute('ALTER TABLE $mediaTable ADD COLUMN originalPath TEXT');
      await db.execute(
        'ALTER TABLE $mediaTable ADD COLUMN isCompressed INTEGER DEFAULT 1',
      );
      await db.execute(
        'ALTER TABLE $mediaTable ADD COLUMN originalSize INTEGER',
      );
      await db.execute(
        'ALTER TABLE $mediaTable ADD COLUMN compressedSize INTEGER',
      );
      await db.execute(
        'ALTER TABLE $mediaTable ADD COLUMN compressionRatio REAL',
      );
      await db.execute('ALTER TABLE $mediaTable ADD COLUMN width INTEGER');
      await db.execute('ALTER TABLE $mediaTable ADD COLUMN height INTEGER');
      await db.execute('ALTER TABLE $mediaTable ADD COLUMN aspectRatio REAL');
      await db.execute('ALTER TABLE $mediaTable ADD COLUMN mimeType TEXT');
      await db.execute('ALTER TABLE $mediaTable ADD COLUMN caption TEXT');
      await db.execute(
        'ALTER TABLE $mediaTable ADD COLUMN media_order INTEGER',
      );
      await db.execute('ALTER TABLE $mediaTable ADD COLUMN ocrText TEXT');
      await db.execute('ALTER TABLE $mediaTable ADD COLUMN ocrConfidence REAL');
      await db.execute(
        'ALTER TABLE $mediaTable ADD COLUMN updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP',
      );
      await db.execute(
        'ALTER TABLE $mediaTable ADD COLUMN isDeleted INTEGER NOT NULL DEFAULT 0',
      );
    } catch (e) {
      // Columns may already exist
    }

    // Enhance reminders table
    try {
      await db.execute('ALTER TABLE $remindersTable ADD COLUMN message TEXT');
      await db.execute('ALTER TABLE $remindersTable ADD COLUMN title TEXT');
      await db.execute(
        'ALTER TABLE $remindersTable ADD COLUMN linkedTodoId TEXT',
      );
      await db.execute('ALTER TABLE $remindersTable ADD COLUMN recurDays TEXT');
      await db.execute(
        'ALTER TABLE $remindersTable ADD COLUMN recurEndDate TEXT',
      );
      await db.execute(
        'ALTER TABLE $remindersTable ADD COLUMN recurEndType TEXT',
      );
      await db.execute(
        'ALTER TABLE $remindersTable ADD COLUMN recurEndValue INTEGER',
      );
      await db.execute(
        'ALTER TABLE $remindersTable ADD COLUMN snoozedUntil TEXT',
      );
      await db.execute(
        'ALTER TABLE $remindersTable ADD COLUMN snoozeCount INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $remindersTable ADD COLUMN notificationId INTEGER',
      );
      await db.execute('ALTER TABLE $remindersTable ADD COLUMN soundUri TEXT');
      await db.execute(
        'ALTER TABLE $remindersTable ADD COLUMN hasVibration INTEGER DEFAULT 1',
      );
      await db.execute(
        'ALTER TABLE $remindersTable ADD COLUMN hasLED INTEGER DEFAULT 1',
      );
      await db.execute(
        'ALTER TABLE $remindersTable ADD COLUMN isDeleted INTEGER NOT NULL DEFAULT 0',
      );
    } catch (e) {
      // Columns may already exist
    }

    // Create indexes for v3
    await _createIndexes(db);
  }

  Future<void> _migrateToV4(Database db) async {
    // Create new tables for reflections and settings
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $reflectionsTable (
          id TEXT PRIMARY KEY,
          questionId TEXT NOT NULL,
          answerText TEXT NOT NULL,
          mood TEXT,
          moodValue INTEGER,
          energyLevel INTEGER,
          sleepQuality INTEGER,
          activityTags TEXT,
          isPrivate INTEGER DEFAULT 0,
          linkedNoteId TEXT,
          linkedTodoId TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          reflectionDate TEXT NOT NULL,
          isDeleted INTEGER NOT NULL DEFAULT 0
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS $reflectionQuestionsTable (
          id TEXT PRIMARY KEY,
          questionText TEXT NOT NULL,
          category TEXT NOT NULL,
          isDefault INTEGER DEFAULT 1,
          isCustom INTEGER DEFAULT 0,
          usageCount INTEGER DEFAULT 0,
          lastUsedAt TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT,
          question_order INTEGER,
          isDeleted INTEGER NOT NULL DEFAULT 0
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS $activityTagsTable (
          id TEXT PRIMARY KEY,
          tagName TEXT NOT NULL,
          color TEXT,
          icon TEXT,
          usageCount INTEGER DEFAULT 0,
          lastUsedAt TEXT,
          createdAt TEXT NOT NULL,
          tag_order INTEGER,
          isDeleted INTEGER NOT NULL DEFAULT 0
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS $moodEntriesTable (
          id TEXT PRIMARY KEY,
          reflectionId TEXT NOT NULL,
          mood TEXT NOT NULL,
          moodValue INTEGER NOT NULL,
          energyLevel INTEGER,
          sleepQuality INTEGER,
          recordedAt TEXT NOT NULL,
          FOREIGN KEY (reflectionId) REFERENCES $reflectionsTable(id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS $userSettingsTable (
          id TEXT PRIMARY KEY,
          theme TEXT DEFAULT 'system',
          fontFamily TEXT DEFAULT 'roboto',
          fontSize REAL DEFAULT 1.0,
          biometricEnabled INTEGER DEFAULT 0,
          pinRequired INTEGER DEFAULT 0,
          autoLockMinutes INTEGER DEFAULT 5,
          notificationsEnabled INTEGER DEFAULT 1,
          soundEnabled INTEGER DEFAULT 1,
          vibrationEnabled INTEGER DEFAULT 1,
          quietHoursStart TEXT,
          quietHoursEnd TEXT,
          voiceLanguage TEXT DEFAULT 'en-US',
          voiceCommandsEnabled INTEGER DEFAULT 1,
          audioFeedbackEnabled INTEGER DEFAULT 1,
          voiceConfidenceThreshold REAL DEFAULT 0.8,
          defaultNoteColor INTEGER DEFAULT 0,
          defaultTodoCategory TEXT DEFAULT 'Personal',
          defaultTodoPriority INTEGER DEFAULT 2,
          autoBackupEnabled INTEGER DEFAULT 0,
          cloudSyncEnabled INTEGER DEFAULT 0,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');

      // Location Reminders table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $locationRemindersTable (
          id TEXT PRIMARY KEY,
          message TEXT NOT NULL,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          radius REAL DEFAULT 100.0,
          trigger_type TEXT DEFAULT 'arrive',
          place_name TEXT,
          place_address TEXT,
          linked_note_id TEXT,
          is_active INTEGER DEFAULT 1,
          last_triggered TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      // Saved Locations table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $savedLocationsTable (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          address TEXT,
          icon TEXT DEFAULT 'location_on',
          created_at TEXT NOT NULL
        )
      ''');

      // Create FTS5 virtual table
      try {
        await db.execute('''
          CREATE VIRTUAL TABLE IF NOT EXISTS $notesFtsTable USING fts5(
            noteId UNINDEXED,
            title,
            content,
            tags,
            category,
            content=notes,
            content_rowid=id,
            tokenize = 'porter'
          )
        ''');

        // Populate FTS table from existing notes
        final notes = await db.query(notesTable);
        for (final note in notes) {
          await db.insert(notesFtsTable, {
            'rowid': note['id'],
            'noteId': note['id'],
            'title': note['title'],
            'content': note['content'],
            'tags': note['tags'],
            'category': note['category'],
          });
        }
      } catch (e) {
        // FTS5 may not be available on all Android devices
        print('Warning: FTS5 not available during migration. Error: $e');
      }
    } catch (e) {
      // Tables may already exist
    }

    // Create FTS triggers
    await _createFTSTriggers(db);
  }

  Future<void> _migrateToV5(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $focusSessionsTable (
          id TEXT PRIMARY KEY,
          startTime TEXT NOT NULL,
          endTime TEXT,
          durationSeconds INTEGER,
          taskTitle TEXT,
          category TEXT DEFAULT 'Focus',
          isCompleted INTEGER DEFAULT 0,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_focus_sessions_start ON $focusSessionsTable(startTime DESC)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_focus_sessions_category ON $focusSessionsTable(category)',
      );
    } catch (e) {
      print('Warning: Migration to V5 failed. Error: $e');
    }
  }

  Future<void> _migrateToV6(Database db) async {
    try {
      // Smart Collections Table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $smartCollectionsTable (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          itemCount INTEGER DEFAULT 0,
          lastUpdated TEXT NOT NULL,
          isActive INTEGER DEFAULT 1,
          logic TEXT DEFAULT 'AND'
        )
      ''');

      // Collection Rules Table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $collectionRulesTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          collectionId TEXT NOT NULL,
          type TEXT NOT NULL,
          operator TEXT NOT NULL,
          value TEXT NOT NULL,
          FOREIGN KEY (collectionId) REFERENCES $smartCollectionsTable(id) ON DELETE CASCADE
        )
      ''');

      // Reminder Templates Table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $reminderTemplatesTable (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          time TEXT,
          frequency TEXT,
          duration TEXT,
          category TEXT,
          isFavorite INTEGER DEFAULT 0,
          usageCount INTEGER DEFAULT 0,
          createdAt TEXT NOT NULL
        )
      ''');

      // Create indexes
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_smart_collections_active ON $smartCollectionsTable(isActive)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_collection_rules_cid ON $collectionRulesTable(collectionId)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_reminder_templates_fav ON $reminderTemplatesTable(isFavorite)',
      );
    } catch (e) {
      print('Warning: Migration to V6 failed. Error: $e');
    }
  }

  Future<void> _migrateToV7(Database db) async {
    try {
      // Reflection Answers Table
      // This table stores the actual submitted responses
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $reflectionAnswersTable (
          id TEXT PRIMARY KEY,
          questionId TEXT NOT NULL,
          answerText TEXT NOT NULL,
          mood TEXT,
          createdAt TEXT NOT NULL,
          draft TEXT,
          isDeleted INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (questionId) REFERENCES $reflectionQuestionsTable(id) ON DELETE CASCADE
        )
      ''');

      // Reflection Drafts Table
      // This table stores in-progress reflections
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $reflectionDraftsTable (
          id TEXT PRIMARY KEY,
          questionId TEXT NOT NULL,
          draftText TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          FOREIGN KEY (questionId) REFERENCES $reflectionQuestionsTable(id) ON DELETE CASCADE
        )
      ''');

      // Create indexes for the new tables
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_reflection_answers_qid ON $reflectionAnswersTable(questionId)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_reflection_answers_date ON $reflectionAnswersTable(createdAt DESC)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_reflection_drafts_qid ON $reflectionDraftsTable(questionId)',
      );
    } catch (e) {
      print('Warning: Migration to V7 failed. Error: $e');
    }
  }

  Future<void> _createFTSTriggers(Database db) async {
    try {
      try {
        await db.execute('''
          CREATE TRIGGER IF NOT EXISTS notes_ai AFTER INSERT ON $notesTable BEGIN
            INSERT INTO $notesFtsTable(rowid, noteId, title, content, tags, category)
            VALUES (new.id, new.id, new.title, new.content, new.tags, new.category);
          END
        ''');

        await db.execute('''
          CREATE TRIGGER IF NOT EXISTS notes_ad AFTER DELETE ON $notesTable BEGIN
            DELETE FROM $notesFtsTable WHERE rowid = old.id;
          END
        ''');

        await db.execute('''
          CREATE TRIGGER IF NOT EXISTS notes_au AFTER UPDATE ON $notesTable BEGIN
            DELETE FROM $notesFtsTable WHERE rowid = old.id;
            INSERT INTO $notesFtsTable(rowid, noteId, title, content, tags, category)
            VALUES (new.id, new.id, new.title, new.content, new.tags, new.category);
          END
        ''');
      } catch (e) {
        // FTS5 triggers may not be available
        print('Warning: FTS5 triggers not available. Error: $e');
      }
    } catch (e) {
      // Triggers may already exist
    }
  }

  /// Create a new note
  Future<void> createNote(Note note) async {
    AppLogger.i('Creating note: ${note.id}');
    final db = await database;
    await db.insert(
      notesTable,
      _noteToMap(note),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    AppLogger.i('Note created successfully: ${note.id}');
  }

  /// Get all notes
  Future<List<Note>> getAllNotes() async {
    AppLogger.i('Fetching all notes...');
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(notesTable);

    if (maps.isEmpty) {
      AppLogger.i('No notes found in database.');
      return [];
    }

    AppLogger.i('Fetched ${maps.length} notes.');
    return List.generate(maps.length, (i) => _noteFromMap(maps[i]));
  }

  /// Get note by ID
  Future<Note?> getNoteById(String id) async {
    AppLogger.i('Fetching note by ID: $id');
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      AppLogger.i('Note not found: $id');
      return null;
    }

    AppLogger.i('Note found: $id');
    return _noteFromMap(maps[0]);
  }

  /// Update note
  Future<void> updateNote(Note note) async {
    AppLogger.i('Updating note: ${note.id}');
    final db = await database;
    await db.update(
      notesTable,
      _noteToMap(note),
      where: 'id = ?',
      whereArgs: [note.id],
    );
    AppLogger.i('Note updated successfully: ${note.id}');
  }

  /// Delete note
  Future<void> deleteNote(String id) async {
    AppLogger.i('Deleting note: $id');
    final db = await database;
    await db.delete(notesTable, where: 'id = ?', whereArgs: [id]);
    AppLogger.i('Note deleted successfully: $id');
  }

  /// Get all notes (archived or not)
  Future<List<Note>> getNotes({bool archived = false}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      notesTable,
      where: 'isArchived = ?',
      whereArgs: [archived ? 1 : 0],
    );

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (i) => _noteFromMap(maps[i]));
  }

  /// Get pinned notes
  Future<List<Note>> getPinnedNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      notesTable,
      where: 'isPinned = ? AND isArchived = ?',
      whereArgs: [1, 0],
    );

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (i) => _noteFromMap(maps[i]));
  }

  /// Search notes by title or content
  Future<List<Note>> searchNotes(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      notesTable,
      where: '(title LIKE ? OR content LIKE ?) AND isArchived = ?',
      whereArgs: ['%$query%', '%$query%', 0],
    );

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (i) => _noteFromMap(maps[i]));
  }

  /// Search todos by title or description
  Future<List<TodoItem>> searchTodos(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      todosTable,
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((map) => _todoFromMap(map)).toList();
  }

  /// Search alarms by title
  Future<List<Alarm>> searchAlarms(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      remindersTable,
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
    );
    return maps.map((map) => _alarmFromMap(map)).toList();
  }

  /// Add todos to note
  Future<void> addTodos(String noteId, List<TodoItem> todos) async {
    final db = await database;
    // Clear existing todos for this note to ensure sync
    await db.delete(todosTable, where: 'noteId = ?', whereArgs: [noteId]);

    for (final todo in todos) {
      await db.insert(
        todosTable,
        _todoToMap(todo, noteId),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Get todos for note
  Future<List<TodoItem>> getTodos(String noteId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      todosTable,
      where: 'noteId = ?',
      whereArgs: [noteId],
    );

    return List.generate(maps.length, (i) => _todoFromMap(maps[i]));
  }

  /// Get all todos (standalone or linked)
  Future<List<TodoItem>> getAllTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      todosTable,
      where: 'isDeleted = 0',
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) => _todoFromMap(maps[i]));
  }

  /// Get todo by ID
  Future<TodoItem?> getTodoById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      todosTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _todoFromMap(maps.first);
  }

  /// Create a standalone todo
  Future<void> createTodo(TodoItem todo) async {
    final db = await database;
    await db.insert(
      todosTable,
      _todoToMap(todo),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update existing todo
  Future<void> updateTodo(TodoItem todo) async {
    final db = await database;
    await db.update(
      todosTable,
      _todoToMap(todo),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  /// Delete todo
  Future<void> deleteTodo(String id) async {
    final db = await database;
    await db.delete(todosTable, where: 'id = ?', whereArgs: [id]);
  }

  /// Add alarms to note
  Future<void> updateAlarms(String noteId, List<Alarm> alarms) async {
    final db = await database;
    // Clear existing alarms for this note
    await db.delete(
      remindersTable,
      where: 'linkedNoteId = ?',
      whereArgs: [noteId],
    );

    for (final alarm in alarms) {
      await db.insert(
        remindersTable,
        _alarmToMap(alarm, noteId),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Get alarms for note
  Future<List<Alarm>> getAlarms(String noteId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      remindersTable,
      where: 'linkedNoteId = ?',
      whereArgs: [noteId],
    );

    return List.generate(maps.length, (i) => _alarmFromMap(maps[i]));
  }

  /// Get all alarms
  Future<List<Alarm>> getAllAlarms() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      remindersTable,
      where: 'isDeleted = 0',
      orderBy: 'scheduledTime ASC',
    );

    return List.generate(maps.length, (i) => _alarmFromMap(maps[i]));
  }

  /// Get alarm by ID
  Future<Alarm?> getAlarmById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      remindersTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _alarmFromMap(maps.first);
  }

  /// Create standalone alarm
  Future<void> createAlarm(Alarm alarm) async {
    final db = await database;
    await db.insert(
      remindersTable,
      _alarmToMap(alarm),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update alarm
  Future<void> updateAlarm(Alarm alarm) async {
    final db = await database;
    await db.update(
      remindersTable,
      _alarmToMap(alarm),
      where: 'id = ?',
      whereArgs: [alarm.id],
    );
  }

  /// Delete alarm
  Future<void> deleteAlarm(String id) async {
    final db = await database;
    await db.delete(remindersTable, where: 'id = ?', whereArgs: [id]);
  }

  // TodoPriority _parseTodoPriority(int level) {
  //   switch (level) {
  //     case 1:
  //       return TodoPriority.low;
  //     case 2:
  //       return TodoPriority.medium;
  //     case 3:
  //       return TodoPriority.high;
  //     case 4:
  //       return TodoPriority.urgent;
  //     default:
  //       return TodoPriority.medium;
  //   }
  // }

  // TodoCategory _parseTodoCategory(String category) {
  //   return TodoCategory.values.firstWhere(
  //     (c) => c.displayName == category,
  //     orElse: () => TodoCategory.personal,
  //   );
  // }

  Map<String, dynamic> _alarmToMap(Alarm alarm, [String? noteId]) {
    return {
      'id': alarm.id,
      'message': alarm.message,
      'title': alarm.message, // Use message as title
      'linkedNoteId': noteId ?? alarm.linkedNoteId,
      'linkedTodoId': alarm.linkedTodoId,
      'scheduledTime': alarm.scheduledTime.toIso8601String(),
      'timezone': 'local',
      'recurrence': alarm.recurrence.name,
      'recurPattern': null,
      'recurDays': alarm.weekDays?.join(','),
      'recurEndDate': null,
      'recurEndType': null,
      'recurEndValue': null,
      'isActive': alarm.isActive ? 1 : 0,
      'isCompleted': alarm.completedAt != null ? 1 : 0,
      'status': alarm.status.name,
      'snoozedUntil': alarm.snoozedUntil?.toIso8601String(),
      'snoozeCount': alarm.snoozeCount,
      'notificationId': null,
      'soundUri': alarm.soundPath,
      'hasVibration': alarm.vibrate ? 1 : 0,
      'hasLED': 1,
      'isEnabled': alarm.isEnabled ? 1 : 0,
      'lastTriggered': alarm.lastTriggered?.toIso8601String(),
      'createdAt': alarm.createdAt.toIso8601String(),
      'updatedAt': alarm.updatedAt.toIso8601String(),
      'isDeleted': 0,
    };
  }

  Alarm _alarmFromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id'],
      message: map['message'] ?? '',
      linkedNoteId: map['linkedNoteId'],
      linkedTodoId: map['linkedTodoId'],
      scheduledTime: DateTime.parse(map['scheduledTime']),
      recurrence: AlarmRecurrence.values.firstWhere(
        (e) => e.name == (map['recurrence'] ?? 'none'),
        orElse: () => AlarmRecurrence.none,
      ),
      status: AlarmStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'scheduled'),
        orElse: () => AlarmStatus.scheduled,
      ),
      isActive: map['isActive'] == 1,
      vibrate: (map['hasVibration'] ?? 1) == 1,
      isEnabled: (map['isEnabled'] ?? 1) == 1,
      lastTriggered: map['lastTriggered'] != null
          ? DateTime.parse(map['lastTriggered'])
          : null,
      snoozeCount: map['snoozeCount'] ?? 0,
      completedAt: map['isCompleted'] == 1 ? DateTime.now() : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      snoozedUntil: map['snoozedUntil'] != null
          ? DateTime.parse(map['snoozedUntil'])
          : null,
      soundPath: map['soundUri'],
      weekDays:
          map['recurDays'] != null && (map['recurDays'] as String).isNotEmpty
          ? (map['recurDays'] as String)
                .split(',')
                .map((e) => int.parse(e))
                .toList()
          : null,
    );
  }

  /// Seed dummy data for testing
  Future<void> seedDummyData() async {
    final db = await database;
    final now = DateTime.now();
    final isoNow = now.toIso8601String();

    // 1. Clear existing data
    await clearAll();

    // 2. Insert Default Reflection Questions
    final questions = [
      {
        'id': 'q_1',
        'questionText': 'What are you grateful for today?',
        'category': 'Gratitude',
        'createdAt': isoNow,
      },
      {
        'id': 'q_2',
        'questionText': 'What was the highlight of your day?',
        'category': 'Daily',
        'createdAt': isoNow,
      },
      {
        'id': 'q_3',
        'questionText': 'What is one thing you would change about today?',
        'category': 'Growth',
        'createdAt': isoNow,
      },
    ];
    for (var q in questions) {
      await db.insert(reflectionQuestionsTable, q);
    }

    // 3. Insert Activity Tags
    final activityTags = [
      {
        'id': 'tag_1',
        'tagName': 'Work',
        'color': '#FF5252',
        'createdAt': isoNow,
      },
      {
        'id': 'tag_2',
        'tagName': 'Exercise',
        'color': '#4CAF50',
        'createdAt': isoNow,
      },
      {
        'id': 'tag_3',
        'tagName': 'Reading',
        'color': '#2196F3',
        'createdAt': isoNow,
      },
      {
        'id': 'tag_4',
        'tagName': 'Coding',
        'color': '#9C27B0',
        'createdAt': isoNow,
      },
    ];
    for (var tag in activityTags) {
      await db.insert(activityTagsTable, tag);
    }

    // 4. Insert Dummy Notes
    final notes = [
      {
        'id': 'note_1',
        'title': '🚀 Welcome to MyNotes',
        'content':
            '[{"insert":"Welcome to your next-generation productivity hub!\\n","attributes":{"header":1}},{"insert":"\\nThis app helps you manage:\\n- "},{"insert":"Notes","attributes":{"bold":true}},{"insert":" with rich text\\n- "},{"insert":"Todos","attributes":{"bold":true}},{"insert":" linked to context\\n- "},{"insert":"Reminders","attributes":{"bold":true}},{"insert":" for everything\\n- "},{"insert":"Reflections","attributes":{"bold":true}},{"insert":" to track growth\\n"}]',
        'color': 0, // Default
        'category': 'General',
        'tags': 'welcome,tutorial',
        'isPinned': 1,
        'createdAt': isoNow,
        'updatedAt': isoNow,
      },
      {
        'id': 'note_2',
        'title': '💡 Future App Features',
        'content':
            '[{"insert":"List of features to implement:\\n"},{"insert":"1. Cloud Sync with Firebase\\n2. Desktop version using Flutter\\n3. Advanced AI document parsing\\n"}]',
        'color': 4, // Blue
        'category': 'Work',
        'tags': 'ideas,work',
        'isFavorite': 1,
        'createdAt': now.subtract(const Duration(days: 1)).toIso8601String(),
        'updatedAt': isoNow,
      },
      {
        'id': 'note_3',
        'title': '📦 Archived Project: Old App',
        'content':
            '[{"insert":"This project has been archived. Check my GitHub for the latest version.\\n"}]',
        'color': 9, // Grey
        'category': 'Archive',
        'isArchived': 1,
        'createdAt': now.subtract(const Duration(days: 30)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 15)).toIso8601String(),
      },
      {
        'id': 'note_4',
        'title': '🍏 Weekly Shopping',
        'content':
            '[{"insert":"- Milk\\n- Eggs\\n- Sourdough Bread\\n- Greek Yogurt\\n- Avocados\\n"}]',
        'color': 5, // Green
        'category': 'Personal',
        'tags': 'shopping,home',
        'createdAt': isoNow,
        'updatedAt': isoNow,
      },
    ];

    for (var note in notes) {
      await db.insert(notesTable, note);
    }

    // 5. Insert Dummy Todos
    final todos = [
      {
        'id': 'todo_1',
        'title': 'Implement BLoC Pattern',
        'description':
            'Refactor the existing state management to use BLoC for scalability.',
        'noteId': 'note_2',
        'category': 'Work',
        'priority': 3, // High
        'isImportant': 1,
        'dueDate': now.add(const Duration(days: 2)).toIso8601String(),
        'isCompleted': 0,
        'createdAt': isoNow,
        'updatedAt': isoNow,
      },
      {
        'id': 'todo_2',
        'title': 'Buy groceries',
        'noteId': 'note_4',
        'category': 'Personal',
        'priority': 2,
        'dueDate': isoNow,
        'isCompleted': 1,
        'completedAt': isoNow,
        'createdAt': now.subtract(const Duration(hours: 2)).toIso8601String(),
        'updatedAt': isoNow,
      },
      {
        'id': 'todo_3',
        'title': 'Update Portfolio',
        'description': 'Add the new MyNotes project to my portfolio website.',
        'category': 'Career',
        'priority': 1,
        'dueDate': now.subtract(const Duration(days: 1)).toIso8601String(),
        'isCompleted': 0,
        'createdAt': now.subtract(const Duration(days: 2)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 2)).toIso8601String(),
      },
    ];

    for (var todo in todos) {
      await db.insert(todosTable, todo);
    }

    // 6. Insert Dummy Reminders
    final reminders = [
      {
        'id': 'rem_1',
        'title': 'Meeting with Design Team',
        'message': 'Discuss the new UI components and layout.',
        'linkedNoteId': 'note_2',
        'scheduledTime': now.add(const Duration(hours: 1)).toIso8601String(),
        'isActive': 1,
        'createdAt': isoNow,
        'updatedAt': isoNow,
      },
      {
        'id': 'rem_2',
        'title': 'Task Overdue!',
        'message': 'You missed the deadline for Portfolio Update.',
        'linkedTodoId': 'todo_3',
        'scheduledTime': now
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
        'isActive': 0,
        'isCompleted': 1,
        'createdAt': isoNow,
        'updatedAt': isoNow,
      },
      {
        'id': 'rem_3',
        'title': 'Daily Standup',
        'message': 'Prep your notes for the standup meeting.',
        'scheduledTime': now.add(const Duration(days: 1)).toIso8601String(),
        'recurrence': 'daily',
        'isActive': 1,
        'createdAt': isoNow,
        'updatedAt': isoNow,
      },
    ];

    for (var reminder in reminders) {
      await db.insert(remindersTable, reminder);
    }

    // 7. Insert Reflections & Moods
    final reflectionId = 'ref_1';
    await db.insert(reflectionsTable, {
      'id': reflectionId,
      'questionId': 'q_1',
      'answerText':
          'I am grateful for the progress I made on MyNotes and for my supportive colleagues.',
      'mood': 'Happy',
      'moodValue': 5,
      'energyLevel': 4,
      'activityTags': 'Work,Coding',
      'reflectionDate': isoNow,
      'createdAt': isoNow,
      'updatedAt': isoNow,
    });

    await db.insert(moodEntriesTable, {
      'id': 'mood_1',
      'reflectionId': reflectionId,
      'mood': 'Happy',
      'moodValue': 5,
      'recordedAt': isoNow,
    });

    // 8. Insert Focus Sessions
    await db.insert(focusSessionsTable, {
      'id': 'focus_1',
      'startTime': now.subtract(const Duration(hours: 2)).toIso8601String(),
      'endTime': now
          .subtract(const Duration(hours: 1, minutes: 35))
          .toIso8601String(),
      'durationSeconds': 1500, // 25 min
      'taskTitle': 'Work on Editor UI',
      'category': 'Coding',
      'isCompleted': 1,
      'rating': 5,
      'createdAt': isoNow,
      'updatedAt': isoNow,
    });

    // 9. Insert Note Link for Graph View
    await db.insert(noteLinksTable, {
      'sourceId': 'note_1',
      'targetId': 'note_2',
      'type': 'reference',
      'createdAt': isoNow,
    });

    await db.insert(noteLinksTable, {
      'sourceId': 'note_2',
      'targetId': 'note_4',
      'type': 'task',
      'createdAt': isoNow,
    });

    // 10. Insert Smart Collection
    await db.insert(smartCollectionsTable, {
      'id': 'coll_1',
      'name': 'Active Work',
      'description': 'Filters for Work category notes that are not archived.',
      'itemCount': 1,
      'lastUpdated': isoNow,
      'isActive': 1,
      'logic': 'AND',
    });

    await db.insert(collectionRulesTable, {
      'collectionId': 'coll_1',
      'type': 'category',
      'operator': 'equals',
      'value': 'Work',
    });

    // 11. Insert Location Reminders
    final locations = [
      {
        'id': 'loc_1',
        'name': 'Home',
        'latitude': 40.7128,
        'longitude': -74.0060,
        'address': 'New York, NY',
        'created_at': isoNow,
      },
      {
        'id': 'loc_2',
        'name': 'Work Office',
        'latitude': 34.0522,
        'longitude': -118.2437,
        'address': 'Los Angeles, CA',
        'created_at': isoNow,
      },
    ];
    for (var loc in locations) {
      await db.insert(savedLocationsTable, loc);
    }

    final locationReminders = [
      {
        'id': 'lrem_1',
        'message': 'Buy milk when arriving home',
        'latitude': 40.7128,
        'longitude': -74.0060,
        'radius': 100.0,
        'trigger_type': 'arrive',
        'place_name': 'Home',
        'place_address': 'New York, NY',
        'linked_note_id': 'note_4',
        'is_active': 1,
        'created_at': isoNow,
        'updated_at': isoNow,
      },
      {
        'id': 'lrem_2',
        'message': 'Submit report when leaving work',
        'latitude': 34.0522,
        'longitude': -118.2437,
        'radius': 200.0,
        'trigger_type': 'leave',
        'place_name': 'Work Office',
        'place_address': 'Los Angeles, CA',
        'is_active': 1,
        'created_at': isoNow,
        'updated_at': isoNow,
      },
    ];
    for (var lrem in locationReminders) {
      await db.insert(locationRemindersTable, lrem);
    }
  }

  /// Delete all data (for testing)
  Future<void> clearAll() async {
    final db = await database;
    await db.delete(focusSessionsTable);
    await db.delete(moodEntriesTable);
    await db.delete(reflectionsTable);
    await db.delete(reflectionQuestionsTable);
    await db.delete(activityTagsTable);
    await db.delete(userSettingsTable);
    await db.delete(mediaTable);
    await db.delete(remindersTable);
    await db.delete(todosTable);
    await db.delete(notesTable);
    await db.delete(locationRemindersTable);
    await db.delete(savedLocationsTable);
    await db.delete(smartCollectionsTable);
    await db.delete(collectionRulesTable);
    await db.delete(reminderTemplatesTable);
    await db.delete(noteLinksTable);
  }

  /// Convert Note to database map
  Map<String, dynamic> _noteToMap(Note note) {
    return {
      'id': note.id,
      'title': note.title,
      'content': note.content,
      'color': note.color.index,
      'category': note.category,
      'isPinned': note.isPinned ? 1 : 0,
      'isArchived': note.isArchived ? 1 : 0,
      'isFavorite': note.isFavorite ? 1 : 0,
      'tags': note.tags.join(','),
      'priority': note.priority,
      'linkedReflectionId': note.linkedReflectionId,
      'linkedTodoId': note.linkedTodoId,
      'createdAt': note.createdAt.toIso8601String(),
      'updatedAt': note.updatedAt.toIso8601String(),
    };
  }

  /// Convert database map to Note
  Note _noteFromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      color: NoteColor.values[map['color'] ?? 0],
      category: map['category'] ?? 'General',
      isPinned: map['isPinned'] == 1,
      isArchived: map['isArchived'] == 1,
      isFavorite: map['isFavorite'] == 1,
      priority: map['priority'] ?? 1,
      tags:
          (map['tags'] as String?)
              ?.split(',')
              .where((t) => t.isNotEmpty)
              .toList() ??
          [],
      linkedReflectionId: map['linkedReflectionId'],
      linkedTodoId: map['linkedTodoId'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  /// Add media to note
  Future<void> addMediaToNote(String noteId, MediaItem media) async {
    final db = await database;
    await db.insert(
      mediaTable,
      mediaToMap(noteId, media),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Sync all media for a note (batch update)
  Future<void> syncMediaForNote(String noteId, List<MediaItem> media) async {
    final db = await database;
    // For now, clear and re-insert for consistency (small lists only)
    await db.delete(mediaTable, where: 'noteId = ?', whereArgs: [noteId]);

    for (final item in media) {
      await db.insert(
        mediaTable,
        mediaToMap(noteId, item),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Get all media for a note
  Future<List<MediaItem>> getMediaForNote(String noteId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      mediaTable,
      where: 'noteId = ?',
      whereArgs: [noteId],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => mediaFromMap(maps[i]));
  }

  /// Remove media from note
  Future<void> removeMediaFromNote(String noteId, String mediaId) async {
    final db = await database;
    await db.delete(
      mediaTable,
      where: 'noteId = ? AND id = ?',
      whereArgs: [noteId, mediaId],
    );
  }

  /// Convert MediaItem to database map
  Map<String, dynamic> mediaToMap(String noteId, MediaItem media) {
    return {
      'id': media.id,
      'noteId': noteId,
      'type': media.type.toString().split('.').last,
      'name': media.name,
      'size': media.size,
      'filePath': media.filePath,
      'thumbnailPath': media.thumbnailPath,
      'durationMs': media.durationMs,
      'metadata': jsonEncode(media.metadata),
      'createdAt': media.createdAt.toIso8601String(),
    };
  }

  /// Convert database map to MediaItem
  MediaItem mediaFromMap(Map<String, dynamic> map) {
    MediaType type;
    switch (map['type']) {
      case 'image':
        type = MediaType.image;
        break;
      case 'video':
        type = MediaType.video;
        break;
      case 'audio':
        type = MediaType.audio;
        break;
      default:
        type = MediaType.image;
    }

    return MediaItem(
      id: map['id'],
      type: type,
      name: map['name'] ?? '',
      size: map['size'] ?? 0,
      filePath: map['filePath'],
      thumbnailPath: map['thumbnailPath'],
      durationMs: map['durationMs'] ?? 0,
      metadata: map['metadata'] != null
          ? jsonDecode(map['metadata'])
          : const {},
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  /// Convert TodoItem to database map
  Map<String, dynamic> _todoToMap(TodoItem todo, [String? noteId]) {
    return {
      'id': todo.id,
      'noteId': noteId ?? todo.noteId,
      'title': todo.text,
      'description': todo.notes,
      'category': todo.category.displayName,
      'priority': todo.priority.level,
      'isCompleted': todo.isCompleted ? 1 : 0,
      'isImportant': todo.isImportant ? 1 : 0,
      'hasReminder': todo.hasReminder ? 1 : 0,
      'reminderId': todo.reminderId,
      'dueDate': todo.dueDate?.toIso8601String(),
      'completedAt': todo.completedAt?.toIso8601String(),
      'subtasksJson': jsonEncode(todo.subtasks.map((s) => s.toJson()).toList()),
      'attachmentsJson': jsonEncode(todo.attachmentPaths),
      'createdAt': todo.createdAt.toIso8601String(),
      'updatedAt': todo.updatedAt.toIso8601String(),
    };
  }

  /// Convert database map to TodoItem
  TodoItem _todoFromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'],
      text: map['title'] ?? '',
      isCompleted: (map['isCompleted'] ?? 0) == 1,
      isImportant: (map['isImportant'] ?? 0) == 1,
      hasReminder: (map['hasReminder'] ?? 0) == 1,
      reminderId: map['reminderId'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      priority: _parseTodoPriority(map['priority'] ?? 2),
      category: _parseTodoCategory(map['category'] ?? 'Personal'),
      notes: map['description'],
      subtasks: map['subtasksJson'] != null
          ? (jsonDecode(map['subtasksJson']) as List)
                .map((s) => SubTask.fromJson(Map<String, dynamic>.from(s)))
                .toList()
          : [],
      attachmentPaths: map['attachmentsJson'] != null
          ? (jsonDecode(map['attachmentsJson']) as List)
                .map((a) => a as String)
                .toList()
          : [],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }

  /// Parse priority int to TodoPriority enum
  TodoPriority _parseTodoPriority(int level) {
    switch (level) {
      case 1:
        return TodoPriority.low;
      case 2:
        return TodoPriority.medium;
      case 3:
        return TodoPriority.high;
      case 4:
        return TodoPriority.urgent;
      default:
        return TodoPriority.medium;
    }
  }

  /// Parse category string to TodoCategory enum
  TodoCategory _parseTodoCategory(String category) {
    return TodoCategory.values.firstWhere(
      (cat) => cat.displayName == category,
      orElse: () => TodoCategory.personal,
    );
  }

  // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
  // Link Helper Methods
  Future<void> addLink(
    String sourceId,
    String targetId, {
    String type = 'manual',
  }) async {
    final db = await database;
    await db.insert(noteLinksTable, {
      'sourceId': sourceId,
      'targetId': targetId,
      'type': type,
      'createdAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
  Future<void> removeLink(String sourceId, String targetId) async {
    final db = await database;
    await db.delete(
      noteLinksTable,
      where: 'sourceId = ? AND targetId = ?',
      whereArgs: [sourceId, targetId],
    );
  }

  // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
  Future<List<String>> getBacklinks(String noteId) async {
    final db = await database;
    final result = await db.query(
      noteLinksTable,
      columns: ['sourceId'],
      where: 'targetId = ?',
      whereArgs: [noteId],
    );
    return result.map((row) => row['sourceId'] as String).toList();
  }

  // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
  Future<List<String>> getOutlinks(String noteId) async {
    final db = await database;
    final result = await db.query(
      noteLinksTable,
      columns: ['targetId'],
      where: 'sourceId = ?',
      whereArgs: [noteId],
    );
    return result.map((row) => row['targetId'] as String).toList();
  }
}
