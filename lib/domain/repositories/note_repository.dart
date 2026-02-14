import '../entities/note.dart';

abstract class NoteRepository {
  Future<List<Note>> getNotes();
  Future<List<Note>> getArchivedNotes();
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

  // Alarm operations
  Future<void> deleteAlarm(String alarmId);
  Future<void> updateAlarm(dynamic alarm);

  // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
  Future<void> updateNoteLinks(String sourceId, List<String> targetIds);
  Future<void> resolveAndSyncLinks(String sourceId, List<String> targetTitles);
  Future<List<String>> getBacklinks(String noteId);
  Future<List<String>> getOutgoingLinks(String noteId);
}
