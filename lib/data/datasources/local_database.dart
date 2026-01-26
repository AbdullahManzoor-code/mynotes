import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/todo_item.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/entities/alarm.dart';

/// Local SQLite database for notes storage
class NotesDatabase {
  static const String _databaseName = 'notes.db';
  static const int _databaseVersion = 2;

  static const String notesTable = 'notes';
  static const String todosTable = 'todos';
  static const String alarmTable = 'alarm';
  static const String mediaTable = 'media';

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
    // Notes table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $notesTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        color INTEGER NOT NULL,
        isPinned INTEGER NOT NULL DEFAULT 0,
        isArchived INTEGER NOT NULL DEFAULT 0,
        tags TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Todos table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $todosTable (
        id TEXT PRIMARY KEY,
        noteId TEXT NOT NULL,
        text TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        dueDate TEXT,
        FOREIGN KEY (noteId) REFERENCES $notesTable(id) ON DELETE CASCADE
      )
    ''');

    // Alarms table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $alarmTable (
        id TEXT PRIMARY KEY,
        noteId TEXT NOT NULL,
        alarmTime TEXT NOT NULL,
        repeatType TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        message TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        FOREIGN KEY (noteId) REFERENCES $notesTable(id) ON DELETE CASCADE
      )
    ''');

    // Media table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $mediaTable (
        id TEXT PRIMARY KEY,
        noteId TEXT NOT NULL,
        type TEXT NOT NULL,
        filePath TEXT NOT NULL,
        thumbnailPath TEXT,
        durationMs INTEGER,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (noteId) REFERENCES $notesTable(id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for performance
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
      'CREATE INDEX IF NOT EXISTS idx_todos_noteId ON $todosTable(noteId)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_alarms_noteId ON $alarmTable(noteId)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_media_noteId ON $mediaTable(noteId)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Upgrade alarms table
      // Since it's development, we can drop and recreate or alter
      // Let's force consistent schema by recreating for this task to be safe
      await db.execute('DROP TABLE IF EXISTS $alarmTable');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $alarmTable (
          id TEXT PRIMARY KEY,
          noteId TEXT NOT NULL,
          alarmTime TEXT NOT NULL,
          repeatType TEXT NOT NULL,
          isActive INTEGER NOT NULL DEFAULT 1,
          message TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT,
          FOREIGN KEY (noteId) REFERENCES $notesTable(id) ON DELETE CASCADE
        )
      ''');
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
        'text': todo.text,
        'completed': todo.isCompleted ? 1 : 0,
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
        text: maps[i]['text'],
        isCompleted: maps[i]['completed'] == 1,
      ),
    );
  }

  /// Add alarms to note
  Future<void> updateAlarms(String noteId, List<Alarm> alarms) async {
    final db = await database;
    // Clear existing alarms for this note
    await db.delete(alarmTable, where: 'noteId = ?', whereArgs: [noteId]);

    for (final alarm in alarms) {
      await db.insert(
        alarmTable,
        _alarmToMap(alarm),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Get alarms for note
  Future<List<Alarm>> getAlarms(String noteId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      alarmTable,
      where: 'noteId = ?',
      whereArgs: [noteId],
    );

    return List.generate(maps.length, (i) => _alarmFromMap(maps[i]));
  }

  Map<String, dynamic> _alarmToMap(Alarm alarm) {
    return {
      'id': alarm.id,
      'noteId': alarm.noteId,
      'alarmTime': alarm.alarmTime.toIso8601String(),
      'repeatType': alarm.repeatType.name, // Storing enum name
      'isActive': alarm.isActive ? 1 : 0,
      'message': alarm.message,
      'createdAt': alarm.createdAt.toIso8601String(),
      'updatedAt': alarm.updatedAt?.toIso8601String(),
    };
  }

  Alarm _alarmFromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id'],
      noteId: map['noteId'],
      alarmTime: DateTime.parse(map['alarmTime']),
      repeatType: AlarmRepeatType.values.firstWhere(
        (e) => e.name == map['repeatType'],
        orElse: () => AlarmRepeatType.none,
      ),
      isActive: map['isActive'] == 1,
      message: map['message'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }

  /// Delete all data (for testing)
  Future<void> clearAll() async {
    final db = await database;
    await db.delete(todosTable);
    await db.delete(alarmTable);
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
      _mediaToMap(noteId, media),
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
    return List.generate(maps.length, (i) => _mediaFromMap(maps[i]));
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
  Map<String, dynamic> _mediaToMap(String noteId, MediaItem media) {
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
  MediaItem _mediaFromMap(Map<String, dynamic> map) {
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
