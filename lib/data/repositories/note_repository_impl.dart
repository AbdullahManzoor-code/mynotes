import '../../core/pdf/pdf_export_service.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/local_database.dart';

/// Real implementation of NoteRepository using SQLite
class NoteRepositoryImpl implements NoteRepository {
  final NotesDatabase _database;

  NoteRepositoryImpl({required NotesDatabase database}) : _database = database;

  @override
  Future<List<Note>> getNotes() async {
    try {
      return await _database.getNotes(archived: false);
    } catch (e) {
      throw Exception('Failed to get notes: $e');
    }
  }

  @override
  Future<List<Note>> getAllNotes() async {
    try {
      return await _database.getAllNotes();
    } catch (e) {
      throw Exception('Failed to get all notes: $e');
    }
  }

  @override
  Future<Note?> getNoteById(String id) async {
    try {
      return await _database.getNoteById(id);
    } catch (e) {
      throw Exception('Failed to get note: $e');
    }
  }

  @override
  Future<void> addNote(Note note) async {
    try {
      await _database.createNote(note);
    } catch (e) {
      throw Exception('Failed to add note: $e');
    }
  }

  @override
  Future<void> createNote(Note note) async {
    try {
      await _database.createNote(note);
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }

  @override
  Future<void> updateNote(Note note) async {
    try {
      await _database.updateNote(note);
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      await _database.deleteNote(id);
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  @override
  Future<String> exportNotePdf(Note note, String filePath) async {
    try {
      // Use PdfExportService to generate actual PDF
      final outputPath = await PdfExportService.exportNoteToPdf(note);
      return outputPath;
    } catch (e) {
      throw Exception('Failed to export PDF: $e');
    }
  }

  @override
  Future<void> scheduleReminder(String noteId, DateTime dateTime) async {
    try {
      // TODO: Connect to AlarmService
      // This will be implemented in next phase
    } catch (e) {
      throw Exception('Failed to schedule reminder: $e');
    }
  }

  @override
  Future<void> cancelReminder(String noteId) async {
    try {
      // TODO: Connect to AlarmService
      // This will be implemented in next phase
    } catch (e) {
      throw Exception('Failed to cancel reminder: $e');
    }
  }
}
