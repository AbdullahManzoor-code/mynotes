import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/todo_item.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/entities/alarm.dart';

/// Local SQLite database for notes storage
class NotesDatabase {
  static const String _databaseName = 'notes.db';
  static const int _databaseVersion = 4;

  // P0 Tables
  static const String notesTable = 'notes';
  static const String todosTable = 'todos';
  static const String remindersTable = 'reminders';
  static const String mediaTable = 'media';

  // P1 Tables (Phase 2A)
  static const String reflectionsTable = 'reflections';
  static const String reflectionQuestionsTable = 'reflection_questions';
  static const String activityTagsTable = 'activity_tags';
  static const String moodEntriesTable = 'mood_entries';
  static const String userSettingsTable = 'user_settings';

  // Location-based Reminders (Phase 2B)
  static const String locationRemindersTable = 'location_reminders';
  static const String savedLocationsTable = 'saved_locations';

  // Full-text search
  static const String notesFtsTable = 'notes_fts';

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createTables(Database db, int version) async {
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
        hasReminder INTEGER DEFAULT 0,
        estimatedMinutes INTEGER,
        actualMinutes INTEGER,
        subtaskCount INTEGER DEFAULT 0,
        completedSubtasks INTEGER DEFAULT 0,
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
        recurPattern TEXT,
        recurDays TEXT,
        recurEndDate TEXT,
        recurEndType TEXT,
        recurEndValue INTEGER,
        isActive INTEGER NOT NULL DEFAULT 1,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        status TEXT DEFAULT 'pending',
        snoozedUntil TEXT,
        snoozeCount INTEGER DEFAULT 0,
        notificationId INTEGER,
        soundUri TEXT,
        hasVibration INTEGER DEFAULT 1,
        hasLED INTEGER DEFAULT 1,
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
        usageCount INTEGER DEFAULT 0,
        lastUsedAt TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        question_order INTEGER,
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
      // FTS5 may not be available on all Android devices
      // Log the error but continue without FTS5 support
      print(
        'Warning: FTS5 not available. Full-text search will be disabled. Error: $e',
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
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // v1 → v2: Upgrade alarms table
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS ${remindersTable}');
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
      await _migrateToV3(db);
    }

    // v3 → v4: Create new tables for Phase 2A
    if (oldVersion < 4) {
      await _migrateToV4(db);
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
    final db = await database;
    await db.insert(
      notesTable,
      _noteToMap(note),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all notes
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(notesTable);

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (i) => _noteFromMap(maps[i]));
  }

  /// Get note by ID
  Future<Note?> getNoteById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return _noteFromMap(maps[0]);
  }

  /// Update note
  Future<void> updateNote(Note note) async {
    final db = await database;
    await db.update(
      notesTable,
      _noteToMap(note),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  /// Delete note
  Future<void> deleteNote(String id) async {
    final db = await database;
    await db.delete(notesTable, where: 'id = ?', whereArgs: [id]);
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

  /// Add todos to note
  Future<void> addTodos(String noteId, List<TodoItem> todos) async {
    final db = await database;
    // Clear existing todos for this note to ensure sync
    await db.delete(todosTable, where: 'noteId = ?', whereArgs: [noteId]);

    for (final todo in todos) {
      await db.insert(todosTable, {
        'id': todo.id,
        'noteId': noteId,
        'title': todo.text,
        'description': todo.notes,
        'category': todo.category.displayName,
        'priority': todo.priority.level,
        'isCompleted': todo.isCompleted ? 1 : 0,
        'dueDate': todo.dueDate?.toIso8601String(),
        'completedAt': todo.completedAt?.toIso8601String(),
        'createdAt': todo.createdAt.toIso8601String(),
        'updatedAt': todo.updatedAt.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
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

    return List.generate(
      maps.length,
      (i) => TodoItem(
        id: maps[i]['id'],
        text: maps[i]['title'] ?? '',
        isCompleted: (maps[i]['isCompleted'] ?? 0) == 1,
        dueDate: maps[i]['dueDate'] != null
            ? DateTime.parse(maps[i]['dueDate'])
            : null,
        completedAt: maps[i]['completedAt'] != null
            ? DateTime.parse(maps[i]['completedAt'])
            : null,
        priority: _parseTodoPriority(maps[i]['priority'] ?? 2),
        category: _parseTodoCategory(maps[i]['category'] ?? 'Personal'),
        notes: maps[i]['description'],
        createdAt: maps[i]['createdAt'] != null
            ? DateTime.parse(maps[i]['createdAt'])
            : DateTime.now(),
        updatedAt: maps[i]['updatedAt'] != null
            ? DateTime.parse(maps[i]['updatedAt'])
            : DateTime.now(),
      ),
    );
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
        _alarmToMap(alarm),
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

  TodoCategory _parseTodoCategory(String category) {
    return TodoCategory.values.firstWhere(
      (c) => c.displayName == category,
      orElse: () => TodoCategory.personal,
    );
  }

  Map<String, dynamic> _alarmToMap(Alarm alarm) {
    return {
      'id': alarm.id,
      'linkedNoteId': alarm.linkedNoteId,
      'scheduledTime': alarm.scheduledTime.toIso8601String(),
      'recurrence': alarm.recurrence.name,
      'isActive': alarm.isActive ? 1 : 0,
      'message': alarm.message,
      'status': alarm.status.name,
      'vibrate': alarm.vibrate ? 1 : 0,
      'createdAt': alarm.createdAt.toIso8601String(),
      'updatedAt': alarm.updatedAt.toIso8601String(),
      'lastTriggered': alarm.lastTriggered?.toIso8601String(),
      'snoozedUntil': alarm.snoozedUntil?.toIso8601String(),
      'soundPath': alarm.soundPath,
      'weekDays': alarm.weekDays?.join(','),
    };
  }

  Alarm _alarmFromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id'],
      linkedNoteId: map['linkedNoteId'],
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
      message: map['message'] ?? '',
      vibrate: (map['vibrate'] ?? 1) == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      lastTriggered: map['lastTriggered'] != null
          ? DateTime.parse(map['lastTriggered'])
          : null,
      snoozedUntil: map['snoozedUntil'] != null
          ? DateTime.parse(map['snoozedUntil'])
          : null,
      soundPath: map['soundPath'],
      weekDays:
          map['weekDays'] != null && (map['weekDays'] as String).isNotEmpty
          ? (map['weekDays'] as String)
                .split(',')
                .map((e) => int.parse(e))
                .toList()
          : null,
    );
  }

  /// Delete all data (for testing)
  Future<void> clearAll() async {
    final db = await database;
    await db.delete(moodEntriesTable);
    await db.delete(reflectionsTable);
    await db.delete(reflectionQuestionsTable);
    await db.delete(activityTagsTable);
    await db.delete(userSettingsTable);
    await db.delete(mediaTable);
    await db.delete(remindersTable);
    await db.delete(todosTable);
    await db.delete(notesTable);
  }

  /// Convert Note to database map
  Map<String, dynamic> _noteToMap(Note note) {
    return {
      'id': note.id,
      'title': note.title,
      'content': note.content,
      'color': note.color.index,
      'isPinned': note.isPinned ? 1 : 0,
      'isArchived': note.isArchived ? 1 : 0,
      'tags': note.tags.join(','),
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
      isPinned: map['isPinned'] == 1,
      isArchived: map['isArchived'] == 1,
      tags:
          (map['tags'] as String?)
              ?.split(',')
              .where((t) => t.isNotEmpty)
              .toList() ??
          [],
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
      'filePath': media.filePath,
      'thumbnailPath': media.thumbnailPath,
      'durationMs': media.durationMs,
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
      filePath: map['filePath'],
      thumbnailPath: map['thumbnailPath'],
      durationMs: map['durationMs'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
} // End class
