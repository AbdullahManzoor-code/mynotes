import 'package:mynotes/domain/entities/media_item.dart' show MediaItem;
import 'package:mynotes/domain/entities/note.dart' show Note;
import 'package:sqflite/sqflite.dart';

import '../mappers/notes_mapper.dart';
import '../mappers/media_mapper.dart';
import 'tables_reference.dart';

class NotesDAO {
  final Database db;

  NotesDAO(this.db);

  /// Create a new note
  Future<void> createNote(Note note) async {
    await db.insert(
      TablesReference.notesTable,
      NotesMapper.toMap(note),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all notes (non-archived)
  Future<List<Note>> getAllNotes() async {
    final List<Map<String, dynamic>> maps = await db.query(
      TablesReference.notesTable,
      where: 'isArchived = ?',
      whereArgs: [0],
      orderBy: 'isPinned DESC, updatedAt DESC',
    );
    return List.generate(maps.length, (i) => NotesMapper.fromMap(maps[i]));
  }

  /// Get a single note by ID
  Future<Note?> getNoteById(String id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      TablesReference.notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return NotesMapper.fromMap(maps.first);
  }

  /// Update an existing note
  Future<void> updateNote(Note note) async {
    await db.update(
      TablesReference.notesTable,
      NotesMapper.toMap(note),
      where: 'id = ?',
      whereArgs: [note.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Delete a note by ID
  Future<void> deleteNote(String id) async {
    await db.delete(
      TablesReference.notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get notes filtered by category
  Future<List<Note>> getNotes({String? category, bool archived = false}) async {
    String whereClause = 'isArchived = ?';
    List<dynamic> args = [archived ? 1 : 0];

    if (category != null && category.isNotEmpty) {
      whereClause += ' AND category = ?';
      args.add(category);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      TablesReference.notesTable,
      where: whereClause,
      whereArgs: args,
      orderBy: 'isPinned DESC, updatedAt DESC',
    );
    return List.generate(maps.length, (i) => NotesMapper.fromMap(maps[i]));
  }

  /// Get pinned notes
  Future<List<Note>> getPinnedNotes() async {
    final List<Map<String, dynamic>> maps = await db.query(
      TablesReference.notesTable,
      where: 'isPinned = ? AND isArchived = ?',
      whereArgs: [1, 0],
      orderBy: 'updatedAt DESC',
    );
    return List.generate(maps.length, (i) => NotesMapper.fromMap(maps[i]));
  }

  /// Search notes by FTS (full-text search)
  Future<List<Note>> searchNotes(String query) async {
    if (query.isEmpty) return getAllNotes();

    final List<Map<String, dynamic>> searchResults = await db.query(
      TablesReference.notesFtsTable,
      where: '$TablesReference.notesFtsTable MATCH ?',
      whereArgs: ['$query*'],
      columns: ['id'],
    );

    if (searchResults.isEmpty) return [];

    final ids = searchResults.map((r) => r['id'] as String).toList();
    final placeholders = ids.map((_) => '?').join(',');

    final List<Map<String, dynamic>> maps = await db.query(
      TablesReference.notesTable,
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    return List.generate(maps.length, (i) => NotesMapper.fromMap(maps[i]));
  }

  /// Add media to a note
  Future<void> addMediaToNote(String noteId, MediaItem media) async {
    await db.insert(
      TablesReference.mediaTable,
      MediaMapper.toMap(noteId, media),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Sync all media for a note (batch update)
  Future<void> syncMediaForNote(String noteId, List<MediaItem> media) async {
    // Clear existing media for this note
    await db.delete(
      TablesReference.mediaTable,
      where: 'noteId = ?',
      whereArgs: [noteId],
    );

    // Re-insert all media items
    for (final item in media) {
      await db.insert(
        TablesReference.mediaTable,
        MediaMapper.toMap(noteId, item),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Get all media for a note
  Future<List<MediaItem>> getMediaForNote(String noteId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      TablesReference.mediaTable,
      where: 'noteId = ?',
      whereArgs: [noteId],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => MediaMapper.fromMap(maps[i]));
  }

  /// Remove a specific media item from a note
  Future<void> removeMediaFromNote(String noteId, String mediaId) async {
    await db.delete(
      TablesReference.mediaTable,
      where: 'noteId = ? AND id = ?',
      whereArgs: [noteId, mediaId],
    );
  }
}
