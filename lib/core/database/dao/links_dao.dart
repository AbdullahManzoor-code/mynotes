import 'package:sqflite/sqflite.dart';
import 'tables_reference.dart';

/// Optional Knowledge Graph & Linking DAO for managing note relationships
class LinksDAO {
  final Database db;

  LinksDAO(this.db);

  /// Add a link between two notes
  Future<void> addLink(
    String sourceId,
    String targetId, {
    String type = 'manual',
  }) async {
    await db.insert(TablesReference.noteLinksTable, {
      'sourceId': sourceId,
      'targetId': targetId,
      'type': type,
      'createdAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  /// Remove a link between two notes
  Future<void> removeLink(String sourceId, String targetId) async {
    await db.delete(
      TablesReference.noteLinksTable,
      where: 'sourceId = ? AND targetId = ?',
      whereArgs: [sourceId, targetId],
    );
  }

  /// Get all incoming links (backlinks) for a note
  Future<List<String>> getBacklinks(String noteId) async {
    final result = await db.query(
      TablesReference.noteLinksTable,
      columns: ['sourceId'],
      where: 'targetId = ?',
      whereArgs: [noteId],
    );
    return result.map((row) => row['sourceId'] as String).toList();
  }

  /// Get all outgoing links for a note
  Future<List<String>> getOutlinks(String noteId) async {
    final result = await db.query(
      TablesReference.noteLinksTable,
      columns: ['targetId'],
      where: 'sourceId = ?',
      whereArgs: [noteId],
    );
    return result.map((row) => row['targetId'] as String).toList();
  }
}
