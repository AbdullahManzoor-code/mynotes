import '../../data/datasources/local_database.dart';
import '../../data/repositories/reflection_repository_impl.dart';
import '../../domain/entities/note.dart';

/// Database health check utility
class DatabaseHealthCheck {
  final NotesDatabase _notesDb;
  final ReflectionRepositoryImpl _reflectionRepo;

  DatabaseHealthCheck({required NotesDatabase notesDb})
    : _notesDb = notesDb,
      _reflectionRepo = ReflectionRepositoryImpl();

  /// Run comprehensive database health checks
  Future<Map<String, dynamic>> runHealthCheck() async {
    final results = <String, dynamic>{};

    try {
      // Check Notes Database
      results['notes_db'] = await _checkNotesDatabase();

      // Check Reflection Database
      results['reflection_db'] = await _checkReflectionDatabase();

      // Check Foreign Keys
      results['foreign_keys'] = await _checkForeignKeys();

      // Check Indexes
      results['indexes'] = await _checkIndexes();

      results['status'] = 'healthy';
      results['timestamp'] = DateTime.now().toIso8601String();
    } catch (e) {
      results['status'] = 'error';
      results['error'] = e.toString();
    }

    return results;
  }

  /// Check Notes Database connectivity and tables
  Future<Map<String, dynamic>> _checkNotesDatabase() async {
    try {
      final db = await _notesDb.database;

      // Check tables exist
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ?',
        whereArgs: ['table'],
      );

      final tableNames = tables.map((t) => t['name'] as String).toList();

      return {
        'connected': true,
        'tables': tableNames,
        'expected_tables': ['notes', 'todos', 'alarm', 'media'],
        'all_tables_present':
            tableNames.contains('notes') &&
            tableNames.contains('todos') &&
            tableNames.contains('alarm') &&
            tableNames.contains('media'),
      };
    } catch (e) {
      return {'connected': false, 'error': e.toString()};
    }
  }

  /// Check Reflection Database
  Future<Map<String, dynamic>> _checkReflectionDatabase() async {
    try {
      final questions = await _reflectionRepo.getAllQuestions();

      return {
        'connected': true,
        'question_count': questions.length,
        'categories': ['life', 'daily', 'career', 'mental_health'],
      };
    } catch (e) {
      return {'connected': false, 'error': e.toString()};
    }
  }

  /// Check foreign key constraints
  Future<Map<String, dynamic>> _checkForeignKeys() async {
    try {
      final db = await _notesDb.database;

      // Enable foreign keys
      await db.execute('PRAGMA foreign_keys = ON');

      // Check foreign key status
      final result = await db.rawQuery('PRAGMA foreign_keys');
      final enabled = result.isNotEmpty && result.first['foreign_keys'] == 1;

      return {'enabled': enabled, 'status': enabled ? 'active' : 'inactive'};
    } catch (e) {
      return {'enabled': false, 'error': e.toString()};
    }
  }

  /// Check database indexes
  Future<Map<String, dynamic>> _checkIndexes() async {
    try {
      final db = await _notesDb.database;

      final indexes = await db.query(
        'sqlite_master',
        where: 'type = ?',
        whereArgs: ['index'],
      );

      final indexNames = indexes.map((i) => i['name'] as String).toList();

      final expectedIndexes = [
        'idx_notes_created',
        'idx_notes_pinned',
        'idx_notes_archived',
        'idx_todos_noteId',
        'idx_alarms_noteId',
        'idx_media_noteId',
      ];

      final missingIndexes = expectedIndexes
          .where((index) => !indexNames.contains(index))
          .toList();

      return {
        'total': indexNames.length,
        'found': indexNames,
        'expected': expectedIndexes,
        'missing': missingIndexes,
        'status': missingIndexes.isEmpty ? 'complete' : 'incomplete',
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Test CRUD operations
  Future<Map<String, dynamic>> testCRUDOperations() async {
    final results = <String, dynamic>{};

    try {
      // Test Note Creation
      final testNote = Note(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Health Check Test Note',
        content: 'This is a test note',
        tags: ['test', 'health_check'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _notesDb.createNote(testNote);
      results['create'] = 'success';

      // Test Note Retrieval
      final notes = await _notesDb.getAllNotes();
      results['read'] = 'success';
      results['note_count'] = notes.length;

      // Test Note Update
      final updatedNote = testNote.copyWith(
        title: 'Updated Test Note',
        updatedAt: DateTime.now(),
      );
      await _notesDb.updateNote(updatedNote);
      results['update'] = 'success';

      // Test Note Deletion
      await _notesDb.deleteNote(testNote.id);
      results['delete'] = 'success';

      results['crud_status'] = 'all_operations_successful';
    } catch (e) {
      results['crud_status'] = 'failed';
      results['error'] = e.toString();
    }

    return results;
  }

  /// Generate health report
  Future<String> generateHealthReport() async {
    final health = await runHealthCheck();
    final crud = await testCRUDOperations();

    final buffer = StringBuffer();
    buffer.writeln('=== DATABASE HEALTH REPORT ===');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('');

    buffer.writeln('Overall Status: ${health['status']}');
    buffer.writeln('');

    buffer.writeln('Notes Database:');
    buffer.writeln('  Connected: ${health['notes_db']['connected']}');
    buffer.writeln(
      '  Tables: ${health['notes_db']['all_tables_present'] ? "✅ All Present" : "❌ Missing"}',
    );
    buffer.writeln('');

    buffer.writeln('Reflection Database:');
    buffer.writeln('  Connected: ${health['reflection_db']['connected']}');
    buffer.writeln('  Questions: ${health['reflection_db']['question_count']}');
    buffer.writeln('');

    buffer.writeln('Foreign Keys:');
    buffer.writeln(
      '  Status: ${health['foreign_keys']['enabled'] ? "✅ Enabled" : "❌ Disabled"}',
    );
    buffer.writeln('');

    buffer.writeln('Indexes:');
    buffer.writeln('  Found: ${health['indexes']['total']}');
    buffer.writeln(
      '  Status: ${health['indexes']['status'] == "complete" ? "✅ Complete" : "⚠️ Incomplete"}',
    );
    if (health['indexes']['missing'].isNotEmpty) {
      buffer.writeln('  Missing: ${health['indexes']['missing'].join(", ")}');
    }
    buffer.writeln('');

    buffer.writeln('CRUD Operations Test:');
    buffer.writeln('  Create: ${crud['create']}');
    buffer.writeln('  Read: ${crud['read']}');
    buffer.writeln('  Update: ${crud['update']}');
    buffer.writeln('  Delete: ${crud['delete']}');
    buffer.writeln(
      '  Status: ${crud['crud_status'] == "all_operations_successful" ? "✅ Success" : "❌ Failed"}',
    );

    return buffer.toString();
  }
}

