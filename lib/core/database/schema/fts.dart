import 'package:sqflite/sqflite.dart';

/// Full-Text Search configuration and management
class DatabaseFTS {
  static const String notesFtsTable = 'notes_fts';

  /// Create FTS5 virtual table and triggers for notes search
  static Future<void> createFullTextSearch(Database db) async {
    // Create FTS5 virtual table
    await db.execute('''
      CREATE VIRTUAL TABLE IF NOT EXISTS $notesFtsTable USING fts5(
        id UNINDEXED,
        title,
        content,
        tags
      )
    ''');

    // Populate FTS table from existing notes
    await _populateFromExistingNotes(db);

    // Create triggers to maintain FTS sync
    await _createFTSTriggers(db);
  }

  /// Populate FTS table from existing notes data
  static Future<void> _populateFromExistingNotes(Database db) async {
    await db.execute('''
      INSERT OR IGNORE INTO $notesFtsTable (id, title, content, tags)
      SELECT id, title, content, tags FROM notes
    ''');
  }

  /// Create triggers to automatically update FTS when notes change
  static Future<void> _createFTSTriggers(Database db) async {
    // Insert trigger
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS notes_ai AFTER INSERT ON notes BEGIN
        INSERT INTO $notesFtsTable (id, title, content, tags)
        VALUES (new.id, new.title, new.content, new.tags);
      END
    ''');

    // Update trigger
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS notes_au AFTER UPDATE ON notes BEGIN
        INSERT INTO $notesFtsTable ($notesFtsTable, id, title, content, tags)
        VALUES ('delete', old.id, old.title, old.content, old.tags);
        INSERT INTO $notesFtsTable (id, title, content, tags)
        VALUES (new.id, new.title, new.content, new.tags);
      END
    ''');

    // Delete trigger
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS notes_ad AFTER DELETE ON notes BEGIN
        INSERT INTO $notesFtsTable ($notesFtsTable, id, title, content, tags)
        VALUES ('delete', old.id, old.title, old.content, old.tags);
      END
    ''');
  }

  /// Search notes using FTS
  static Future<List<String>> searchNotes(Database db, String query) async {
    final result = await db.query(
      notesFtsTable,
      where: 'notes_fts MATCH ?',
      whereArgs: ['$query*'],
      columns: ['id'],
    );
    return result.map((row) => row['id'] as String).toList();
  }
}
