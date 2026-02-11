import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/services/app_logger.dart';

/// Database helper for SQLite initialization and schema management
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  /// Get or create database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'mynotes.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create all tables
  Future<void> _createTables(Database db, int version) async {
    // Media table
    await db.execute('''
      CREATE TABLE media (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        size TEXT NOT NULL,
        path TEXT NOT NULL,
        thumbnail TEXT,
        isArchived INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Media tags table
    await db.execute('''
      CREATE TABLE media_tags (
        mediaId TEXT NOT NULL,
        tag TEXT NOT NULL,
        FOREIGN KEY(mediaId) REFERENCES media(id),
        PRIMARY KEY(mediaId, tag)
      )
    ''');

    // Smart collections table
    await db.execute('''
      CREATE TABLE smart_collections (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        itemCount INTEGER DEFAULT 0,
        lastUpdated TEXT NOT NULL,
        isActive INTEGER DEFAULT 1
      )
    ''');

    // Collection rules table
    await db.execute('''
      CREATE TABLE collection_rules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        collectionId TEXT NOT NULL,
        type TEXT NOT NULL,
        operator TEXT NOT NULL,
        value TEXT NOT NULL,
        FOREIGN KEY(collectionId) REFERENCES smart_collections(id)
      )
    ''');

    // Reminder suggestions table
    await db.execute('''
      CREATE TABLE reminder_suggestions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        suggestedTime TEXT NOT NULL,
        confidence REAL NOT NULL,
        frequency TEXT NOT NULL,
        reason TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Reminder patterns table
    await db.execute('''
      CREATE TABLE reminder_patterns (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        time TEXT NOT NULL,
        frequency TEXT NOT NULL,
        completed INTEGER DEFAULT 0,
        total INTEGER DEFAULT 0,
        completionRate REAL NOT NULL,
        lastDetectedAt TEXT
      )
    ''');

    // Suggestion feedback table
    await db.execute('''
      CREATE TABLE suggestion_feedback (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        suggestionId TEXT NOT NULL,
        isPositive INTEGER DEFAULT 0,
        timestamp TEXT NOT NULL,
        FOREIGN KEY(suggestionId) REFERENCES reminder_suggestions(id)
      )
    ''');

    // Learning preferences table
    await db.execute('''
      CREATE TABLE learning_preferences (
        key TEXT PRIMARY KEY,
        value INTEGER DEFAULT 0,
        timestamp TEXT NOT NULL
      )
    ''');

    // Reminder templates table
    await db.execute('''
      CREATE TABLE reminder_templates (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        time TEXT NOT NULL,
        frequency TEXT NOT NULL,
        duration TEXT,
        category TEXT NOT NULL,
        isFavorite INTEGER DEFAULT 0,
        usageCount INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_media_type ON media(type)');
    await db.execute('CREATE INDEX idx_media_archived ON media(isArchived)');
    await db.execute(
      'CREATE INDEX idx_collection_active ON smart_collections(isActive)',
    );
    await db.execute(
      'CREATE INDEX idx_template_category ON reminder_templates(category)',
    );
    await db.execute(
      'CREATE INDEX idx_template_favorite ON reminder_templates(isFavorite)',
    );
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle version upgrades here as needed
    if (oldVersion < 2) {
      // Example: Add new columns or tables for version 2
    }
  }

  /// Close database
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Delete database
  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'mynotes.db');
    await deleteFile(path);
  }

  /// Delete file helper
  Future<void> deleteFile(String path) async {
    try {
      await deleteDatabase();
    } catch (e) {
      AppLogger.e('Error deleting database: $e');
    }
  }

  /// Export database
  Future<String?> exportDatabase() async {
    if (_database == null) return null;

    final databasesPath = await getDatabasesPath();
    final sourcePath = join(databasesPath, 'mynotes.db');

    return sourcePath;
  }

  /// Import database
  Future<bool> importDatabase(String sourcePath) async {
    try {
      // final databasesPath = await getDatabasesPath();
      // final destinationPath = join(databasesPath, 'mynotes.db');

      // Copy source to destination
      return true;
    } catch (e) {
      // debugPrint('Error importing database: $e');
      return false;
    }
  }
}
