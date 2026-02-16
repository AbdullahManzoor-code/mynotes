import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'schema/tables.dart';
import 'schema/indexes.dart';
// import 'schema/fts.dart'; // FTS5 disabled - causes issues on some devices
import 'seed/database_seed.dart';
import 'dao/tables_reference.dart';
import 'dao/notes_dao.dart';
import 'dao/todos_dao.dart';
import 'dao/reminders_dao.dart';
import 'dao/links_dao.dart';
import 'package:mynotes/domain/entities/note.dart';
import 'package:mynotes/domain/entities/todo_item.dart';
import 'package:mynotes/domain/entities/alarm.dart';
import 'package:mynotes/domain/entities/media_item.dart';

/// MyNotes SQLite Database Singleton
/// Manages all database operations with version 1 (flat schema, no migrations)
class CoreDatabase {
  static final CoreDatabase _instance = CoreDatabase._internal();
  static const int _databaseVersion = 1;

  factory CoreDatabase() {
    return _instance;
  }

  CoreDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // Expose table constants from schema
  static const String notesTable = TablesReference.notesTable;
  static const String todosTable = TablesReference.todosTable;
  static const String remindersTable = TablesReference.remindersTable;
  static const String mediaTable = TablesReference.mediaTable;
  static const String reflectionsTable = TablesReference.reflectionsTable;
  static const String reflectionAnswersTable =
      TablesReference.reflectionAnswersTable;
  static const String reflectionDraftsTable =
      TablesReference.reflectionDraftsTable;
  static const String reflectionQuestionsTable =
      TablesReference.reflectionQuestionsTable;
  static const String activityTagsTable = TablesReference.activityTagsTable;
  static const String moodEntriesTable = TablesReference.moodEntriesTable;
  static const String userSettingsTable = TablesReference.userSettingsTable;
  static const String locationRemindersTable =
      TablesReference.locationRemindersTable;
  static const String savedLocationsTable = TablesReference.savedLocationsTable;
  static const String focusSessionsTable = TablesReference.focusSessionsTable;
  static const String smartCollectionsTable =
      TablesReference.smartCollectionsTable;
  static const String collectionRulesTable =
      TablesReference.collectionRulesTable;
  static const String reminderTemplatesTable =
      TablesReference.reminderTemplatesTable;
  static const String noteLinksTable = TablesReference.noteLinksTable;

  /// Initialize database and create schema at version 1
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'mynotes.db');

    return openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  /// Database creation callback (version 1 only - no migrations)
  Future<void> _onCreate(Database db, int version) async {
    // Create all tables with final schema
    await DatabaseSchema.createAll(db);

    // Create all indexes
    await DatabaseIndexes.createAll(db);

    // FTS5 disabled - causes issues on some devices
    // await DatabaseFTS.createFullTextSearch(db);

    // Insert seed data
    await DatabaseSeed.insertTestData(db);
  }

  // ============================================================================
  // PUBLIC CRUD METHODS - Delegates to DAOs
  // ============================================================================

  // Notes CRUD
  Future<void> createNote(Note note) async {
    final db = await database;
    return NotesDAO(db).createNote(note);
  }

  Future<List<Note>> getAllNotes() async {
    final db = await database;
    return NotesDAO(db).getAllNotes();
  }

  Future<Note?> getNoteById(String id) async {
    final db = await database;
    return NotesDAO(db).getNoteById(id);
  }

  Future<void> updateNote(Note note) async {
    final db = await database;
    return NotesDAO(db).updateNote(note);
  }

  Future<void> deleteNote(String id) async {
    final db = await database;
    return NotesDAO(db).deleteNote(id);
  }

  Future<List<Note>> getNotes({String? category, bool archived = false}) async {
    final db = await database;
    return NotesDAO(db).getNotes(category: category, archived: archived);
  }

  Future<List<Note>> getPinnedNotes() async {
    final db = await database;
    return NotesDAO(db).getPinnedNotes();
  }

  Future<List<Note>> searchNotes(String query) async {
    final db = await database;
    return NotesDAO(db).searchNotes(query);
  }

  // Media CRUD
  Future<void> addMediaToNote(String noteId, MediaItem media) async {
    final db = await database;
    return NotesDAO(db).addMediaToNote(noteId, media);
  }

  Future<void> syncMediaForNote(String noteId, List<MediaItem> media) async {
    final db = await database;
    return NotesDAO(db).syncMediaForNote(noteId, media);
  }

  Future<List<MediaItem>> getMediaForNote(String noteId) async {
    final db = await database;
    return NotesDAO(db).getMediaForNote(noteId);
  }

  Future<void> removeMediaFromNote(String noteId, String mediaId) async {
    final db = await database;
    return NotesDAO(db).removeMediaFromNote(noteId, mediaId);
  }

  // Todos CRUD
  Future<void> createTodo(TodoItem todo, [String? noteId]) async {
    final db = await database;
    return TodosDAO(db).createTodo(todo, noteId);
  }

  Future<List<TodoItem>> getAllTodos() async {
    final db = await database;
    return TodosDAO(db).getAllTodos();
  }

  Future<TodoItem?> getTodoById(String id) async {
    final db = await database;
    return TodosDAO(db).getTodoById(id);
  }

  Future<void> updateTodo(TodoItem todo, [String? noteId]) async {
    final db = await database;
    return TodosDAO(db).updateTodo(todo, noteId);
  }

  Future<void> deleteTodo(String id) async {
    final db = await database;
    return TodosDAO(db).deleteTodo(id);
  }

  Future<List<TodoItem>> getTodos({
    String? noteId,
    bool? isCompleted,
    String? category,
  }) async {
    final db = await database;
    return TodosDAO(
      db,
    ).getTodos(noteId: noteId, isCompleted: isCompleted, category: category);
  }

  Future<void> addTodos(List<TodoItem> todos, [String? noteId]) async {
    final db = await database;
    return TodosDAO(db).addTodos(todos, noteId);
  }

  Future<List<TodoItem>> searchTodos(String query) async {
    final db = await database;
    return TodosDAO(db).searchTodos(query);
  }

  // Reminders/Alarms CRUD
  Future<void> createAlarm(Alarm alarm) async {
    final db = await database;
    return RemindersDAO(db).createAlarm(alarm);
  }

  Future<List<Alarm>> getAllAlarms() async {
    final db = await database;
    return RemindersDAO(db).getAllAlarms();
  }

  Future<Alarm?> getAlarmById(String id) async {
    final db = await database;
    return RemindersDAO(db).getAlarmById(id);
  }

  Future<void> updateAlarm(Alarm alarm) async {
    final db = await database;
    return RemindersDAO(db).updateAlarm(alarm);
  }

  Future<void> deleteAlarm(String id) async {
    final db = await database;
    return RemindersDAO(db).deleteAlarm(id);
  }

  Future<List<Alarm>> getAlarms() async {
    final db = await database;
    return RemindersDAO(db).getAlarms();
  }

  Future<void> updateAlarms(List<Alarm> alarms) async {
    final db = await database;
    return RemindersDAO(db).updateAlarms(alarms);
  }

  Future<List<Alarm>> searchAlarms(String query) async {
    final db = await database;
    return RemindersDAO(db).searchAlarms(query);
  }

  // Knowledge Graph / Links (Optional)
  Future<void> addLink(
    String sourceId,
    String targetId, {
    String type = 'manual',
  }) async {
    final db = await database;
    return LinksDAO(db).addLink(sourceId, targetId, type: type);
  }

  Future<void> removeLink(String sourceId, String targetId) async {
    final db = await database;
    return LinksDAO(db).removeLink(sourceId, targetId);
  }

  Future<List<String>> getBacklinks(String noteId) async {
    final db = await database;
    return LinksDAO(db).getBacklinks(noteId);
  }

  Future<List<String>> getOutlinks(String noteId) async {
    final db = await database;
    return LinksDAO(db).getOutlinks(noteId);
  }

  // Testing & Seed Data
  Future<void> seedDummyData() async {
    final db = await database;
    // Seed data is already inserted in _onCreate
  }

  Future<void> clearAll() async {
    final db = await database;
    await DatabaseSeed.clearAll(db);
  }
}
