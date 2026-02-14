import '../../core/pdf/pdf_export_service.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/local_database.dart';

/// Real implementation of NoteRepository using SQLite
class NoteRepositoryImpl implements NoteRepository {
  final NotesDatabase _database;

  NoteRepositoryImpl({required NotesDatabase database}) : _database = database;

  Future<Note> _enrichNote(Note note) async {
    final todos = await _database.getTodos(note.id);
    final alarms = await _database.getAlarms(note.id);
    final media = await _database.getMediaForNote(note.id);

    return note.copyWith(
      todos: todos,
      alarms: alarms,
      media: media,
      // media handled specially if needed, but getMediaForNote returns items.
      // note entity has media list.
    );
  }

  Future<List<Note>> _enrichNotes(List<Note> notes) async {
    return Future.wait(notes.map(_enrichNote));
  }

  @override
  Future<List<Note>> getNotes() async {
    try {
      final notes = await _database.getNotes(archived: false);
      return await _enrichNotes(notes);
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Unable to load notes from database: $e');
    }
  }

  @override
  Future<List<Note>> getAllNotes() async {
    try {
      final notes = await _database.getAllNotes();
      return await _enrichNotes(notes);
    } catch (e) {
      throw Exception('Failed to get all notes: $e');
    }
  }

  @override
  Future<Note?> getNoteById(String id) async {
    try {
      final note = await _database.getNoteById(id);
      if (note != null) {
        return await _enrichNote(note);
      }
      return null;
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Could not find note with ID $id: $e');
    }
  }

  @override
  Future<void> addNote(Note note) async {
    await createNote(note); // Use createNote logic
  }

  @override
  Future<void> createNote(Note note) async {
    try {
      await _database.createNote(note);
      if (note.todos != null) {
        await _database.addTodos(note.id, note.todos!);
      }
      if (note.alarms != null) {
        await _database.updateAlarms(note.id, note.alarms!);
      }
      // Media is usually added separately via addMediaToNote calls from Bloc
      // but if creating full note from backup/restore:
      for (final item in note.media) {
        await _database.addMediaToNote(note.id, item);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Failed to save note. Please try again: $e');
    }
  }

  @override
  Future<void> updateNote(Note note) async {
    try {
      await _database.updateNote(note);
      if (note.todos != null) {
        await _database.addTodos(note.id, note.todos!);
      }
      if (note.alarms != null) {
        await _database.updateAlarms(note.id, note.alarms!);
      }
      // Simple sync for now (inefficient but works for small number of items)
      // Actually MediaBloc handles 'AddImageToNoteEvent' which persists to DB immediately.
      // If we remove media in UI, we should probably call a RemoveMedia event or sync here.
      // NoteBloc calls UpdateNoteEvent.
      // Let's rely on NoteBloc logic.
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Failed to update note. Changes not saved: $e');
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      await _database.deleteNote(id);
      // SQLite CASCADE deletes related entities automatically
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Could not delete note. Please try again: $e');
    }
  }

  @override
  Future<String> exportNotePdf(Note note, String filePath) async {
    try {
      final outputPath = await PdfExportService.exportNoteToPdf(note);
      return outputPath;
    } catch (e) {
      throw Exception('Failed to export PDF: $e');
    }
  }

  @override
  Future<void> scheduleReminder(String noteId, DateTime dateTime) async {
    // Deprecated in favor of AlarmBloc and direct Alarm management,
    // but kept for interface compatibility if needed.
  }

  @override
  Future<void> cancelReminder(String noteId) async {
    // Deprecated
  }

  @override
  Future<List<Note>> searchNotes(String query) async {
    try {
      final notes = await _database.searchNotes(query);
      return await _enrichNotes(notes);
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
  @override
  Future<void> updateNoteLinks(String sourceId, List<String> targetIds) async {
    try {
      // Get existing links
      final currentLinks = await _database.getOutlinks(sourceId);

      // Determine links to add
      final toAdd = targetIds
          .where((id) => !currentLinks.contains(id))
          .toList();

      // Determine links to remove
      final toRemove = currentLinks
          .where((id) => !targetIds.contains(id))
          .toList();

      // Execute updates
      for (final targetId in toAdd) {
        await _database.addLink(sourceId, targetId);
      }

      for (final targetId in toRemove) {
        await _database.removeLink(sourceId, targetId);
      }
    } catch (e) {
      // Log error but don't fail the whole operation
      print('Failed to update note links: $e');
    }
  }

  @override
  Future<void> resolveAndSyncLinks(
    String sourceId,
    List<String> targetTitles,
  ) async {
    try {
      if (targetTitles.isEmpty) {
        await updateNoteLinks(sourceId, []);
        return;
      }

      final allNotes = await _database.getAllNotes();
      final targetIds = <String>[];

      for (final title in targetTitles) {
        final match = allNotes.cast<Note?>().firstWhere(
          (n) => n?.title.trim().toLowerCase() == title.trim().toLowerCase(),
          orElse: () => null,
        );
        if (match != null) {
          targetIds.add(match.id);
        }
      }

      await updateNoteLinks(sourceId, targetIds);
    } catch (e) {
      print('Failed to resolve and sync links: $e');
    }
  }

  // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
  @override
  Future<List<String>> getBacklinks(String noteId) async {
    try {
      return await _database.getBacklinks(noteId);
    } catch (e) {
      return [];
    }
  }

  // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
  @override
  Future<List<String>> getOutgoingLinks(String noteId) async {
    try {
      return await _database.getOutlinks(noteId);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> deleteAlarm(String alarmId) async {
    try {
      await _database.deleteAlarm(alarmId);
    } catch (e) {
      throw Exception('Failed to delete alarm: $e');
    }
  }

  @override
  Future<void> updateAlarm(dynamic alarm) async {
    try {
      await _database.updateAlarm(alarm);
    } catch (e) {
      throw Exception('Failed to update alarm: $e');
    }
  }
}
