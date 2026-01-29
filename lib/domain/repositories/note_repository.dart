import '../entities/note.dart';

abstract class NoteRepository {
  Future<List<Note>> getNotes();
  Future<Note?> getNoteById(String noteId);
  Future<void> createNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String noteId);
  Future<void> addNote(Note note);
  Future<List<Note>> getAllNotes();
  Future<String> exportNotePdf(Note note, String outputDir);
  Future<void> scheduleReminder(String noteId, DateTime when);
  Future<void> cancelReminder(String noteId);
  Future<List<Note>> searchNotes(String query);
}
