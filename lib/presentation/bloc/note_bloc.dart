import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/entities/note.dart';
import '../../core/pdf/pdf_export_service.dart';
import '../../core/notifications/alarm_service.dart';
import 'note_event.dart';
import 'note_state.dart';

/// Notes BLoC
/// Manages all note-related operations and state
///
/// DESIGN PRINCIPLES:
/// - Events represent user actions
/// - States represent UI states
/// - Repository pattern for data access
/// - Clean separation of concerns
/// - Error handling with meaningful messages
class NotesBloc extends Bloc<NoteEvent, NoteState> {
  final NoteRepository _noteRepository;
  final AlarmService _alarmService;

  NotesBloc({
    required NoteRepository noteRepository,
    AlarmService? alarmService,
  }) : _noteRepository = noteRepository,
       _alarmService = alarmService ?? AlarmService(),
       super(const NoteInitial()) {
    // Register event handlers
    on<LoadNotesEvent>(_onLoadNotes);
    on<LoadNoteByIdEvent>(_onLoadNoteById);
    on<CreateNoteEvent>(_onCreateNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);
    on<DeleteMultipleNotesEvent>(_onDeleteMultipleNotes);
    on<TogglePinNoteEvent>(_onTogglePinNote);
    on<ToggleArchiveNoteEvent>(_onToggleArchiveNote);
    on<AddTagEvent>(_onAddTag);
    on<RemoveTagEvent>(_onRemoveTag);
    on<SearchNotesEvent>(_onSearchNotes);
    on<LoadPinnedNotesEvent>(_onLoadPinnedNotes);
    on<LoadArchivedNotesEvent>(_onLoadArchivedNotes);
    on<LoadNotesByTagEvent>(_onLoadNotesByTag);
    on<ExportNoteToPdfEvent>(_onExportNoteToPdf);
    on<ExportMultipleNotesToPdfEvent>(_onExportMultipleNotesToPdf);
    on<AddAlarmToNoteEvent>(_onAddAlarmToNote);
    on<RemoveAlarmFromNoteEvent>(_onRemoveAlarmFromNote);
    on<ClearOldNotesEvent>(_onClearOldNotes);
    on<RestoreArchivedNoteEvent>(_onRestoreArchivedNote);
    on<BatchUpdateNotesColorEvent>(_onBatchUpdateNotesColor);
    on<SortNotesEvent>(_onSortNotes);
    on<ClipboardTextDetectedEvent>(_onClipboardTextDetected);
    on<SaveClipboardAsNoteEvent>(_onSaveClipboardAsNote);
  }

  /// Load all notes
  Future<void> _onLoadNotes(
    LoadNotesEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      emit(const NoteLoading());
      final notes = await _noteRepository.getNotes();

      if (notes.isEmpty) {
        emit(const NoteEmpty());
      } else {
        emit(NotesLoaded(notes, totalCount: notes.length));
      }
    } catch (e) {
      emit(
        NoteError(
          'Failed to load notes: ${e.toString()}',
          exception: e as Exception,
        ),
      );
    }
  }

  /// Load single note by ID
  Future<void> _onLoadNoteById(
    LoadNoteByIdEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      emit(const NoteLoading());
      final note = await _noteRepository.getNoteById(event.noteId);

      if (note != null) {
        emit(NoteLoaded(note));
      } else {
        emit(const NoteError('Note not found'));
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(
        NoteError(
          errorMsg,
          exception: e is Exception ? e : Exception(errorMsg),
        ),
      );
    }
  }

  /// Create new note
  Future<void> _onCreateNote(
    CreateNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      emit(const NoteLoading());

      final newNote = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: event.title,
        content: event.content,
        color: event.color,
        tags: event.tags ?? [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _noteRepository.createNote(newNote);
      emit(NoteCreated(newNote));
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(
        NoteError(
          errorMsg,
          exception: e is Exception ? e : Exception(errorMsg),
        ),
      );
    }
  }

  /// Update existing note
  Future<void> _onUpdateNote(
    UpdateNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      emit(const NoteLoading());

      final updatedNote = event.note.copyWith(updatedAt: DateTime.now());

      await _noteRepository.updateNote(updatedNote);
      emit(NoteUpdated(updatedNote));
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(
        NoteError(
          errorMsg,
          exception: e is Exception ? e : Exception(errorMsg),
        ),
      );
    }
  }

  /// Delete single note
  Future<void> _onDeleteNote(
    DeleteNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      await _noteRepository.deleteNote(event.noteId);
      emit(NoteDeleted(event.noteId));
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(
        NoteError(
          errorMsg,
          exception: e is Exception ? e : Exception(errorMsg),
        ),
      );
    }
  }

  /// Delete multiple notes
  Future<void> _onDeleteMultipleNotes(
    DeleteMultipleNotesEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      int deletedCount = 0;
      for (final noteId in event.noteIds) {
        await _noteRepository.deleteNote(noteId);
        deletedCount++;
      }
      emit(NotesDeleted(event.noteIds, deletedCount));
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(
        NoteError(
          errorMsg,
          exception: e is Exception ? e : Exception(errorMsg),
        ),
      );
    }
  }

  /// Toggle pin status
  Future<void> _onTogglePinNote(
    TogglePinNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      final note = await _noteRepository.getNoteById(event.noteId);
      if (note != null) {
        final updatedNote = note.togglePin();
        await _noteRepository.updateNote(updatedNote);
        emit(NotePinToggled(updatedNote, updatedNote.isPinned));
      }
    } catch (e) {
      emit(
        NoteError(
          'Failed to toggle pin: ${e.toString()}',
          exception: e as Exception,
        ),
      );
    }
  }

  /// Toggle archive status
  Future<void> _onToggleArchiveNote(
    ToggleArchiveNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      final note = await _noteRepository.getNoteById(event.noteId);
      if (note != null) {
        final updatedNote = note.toggleArchive();
        await _noteRepository.updateNote(updatedNote);
        emit(NoteArchiveToggled(updatedNote, updatedNote.isArchived));
      }
    } catch (e) {
      emit(
        NoteError(
          'Failed to toggle archive: ${e.toString()}',
          exception: e as Exception,
        ),
      );
    }
  }

  /// Add tag to note
  Future<void> _onAddTag(AddTagEvent event, Emitter<NoteState> emit) async {
    try {
      final note = await _noteRepository.getNoteById(event.noteId);
      if (note != null) {
        final updatedNote = note.addTag(event.tag);
        await _noteRepository.updateNote(updatedNote);
        emit(TagAdded(updatedNote, event.tag));
      }
    } catch (e) {
      emit(
        NoteError(
          'Failed to add tag: ${e.toString()}',
          exception: e as Exception,
        ),
      );
    }
  }

  /// Remove tag from note
  Future<void> _onRemoveTag(
    RemoveTagEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      final note = await _noteRepository.getNoteById(event.noteId);
      if (note != null) {
        final updatedNote = note.removeTag(event.tag);
        await _noteRepository.updateNote(updatedNote);
        emit(TagRemoved(updatedNote, event.tag));
      }
    } catch (e) {
      emit(
        NoteError(
          'Failed to remove tag: ${e.toString()}',
          exception: e as Exception,
        ),
      );
    }
  }

  /// Search notes
  Future<void> _onSearchNotes(
    SearchNotesEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      if (event.query.isEmpty) {
        emit(const SearchResultsLoaded([], '', resultCount: 0));
        return;
      }

      final notes = await _noteRepository.getNotes();
      final results = notes
          .where(
            (note) =>
                note.title.toLowerCase().contains(event.query.toLowerCase()) ||
                note.content.toLowerCase().contains(event.query.toLowerCase()),
          )
          .toList();

      emit(
        SearchResultsLoaded(results, event.query, resultCount: results.length),
      );
    } catch (e) {
      emit(
        NoteError('Search failed: ${e.toString()}', exception: e as Exception),
      );
    }
  }

  /// Load pinned notes
  Future<void> _onLoadPinnedNotes(
    LoadPinnedNotesEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      emit(const NoteLoading());
      final notes = await _noteRepository.getNotes();
      final pinnedNotes = notes.where((note) => note.isPinned).toList();

      emit(PinnedNotesLoaded(pinnedNotes));
    } catch (e) {
      emit(
        NoteError(
          'Failed to load pinned notes: ${e.toString()}',
          exception: e as Exception,
        ),
      );
    }
  }

  /// Load archived notes
  Future<void> _onLoadArchivedNotes(
    LoadArchivedNotesEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      emit(const NoteLoading());
      final notes = await _noteRepository.getNotes();
      final archivedNotes = notes.where((note) => note.isArchived).toList();

      emit(ArchivedNotesLoaded(archivedNotes));
    } catch (e) {
      emit(
        NoteError(
          'Failed to load archived notes: ${e.toString()}',
          exception: e as Exception,
        ),
      );
    }
  }

  /// Load notes by tag
  Future<void> _onLoadNotesByTag(
    LoadNotesByTagEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      emit(const NoteLoading());
      final notes = await _noteRepository.getNotes();
      final taggedNotes = notes
          .where((note) => note.tags.contains(event.tag))
          .toList();

      emit(NotesByTagLoaded(taggedNotes, event.tag));
    } catch (e) {
      emit(
        NoteError(
          'Failed to load notes by tag: ${e.toString()}',
          exception: e as Exception,
        ),
      );
    }
  }

  /// Export note to PDF
  Future<void> _onExportNoteToPdf(
    ExportNoteToPdfEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      emit(const NoteLoading());
      final note = await _noteRepository.getNoteById(event.noteId);

      if (note != null) {
        final filePath = await PdfExportService.exportNoteToPdf(note);
        emit(PdfExported(filePath, note.title));
      } else {
        emit(const NoteError('Note not found for export'));
      }
    } catch (e) {
      emit(
        NoteError(
          'Failed to export PDF: ${e.toString()}',
          exception: e as Exception,
        ),
      );
    }
  }

  /// Export multiple notes to PDF
  Future<void> _onExportMultipleNotesToPdf(
    ExportMultipleNotesToPdfEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      emit(const NoteLoading());
      final allNotes = await _noteRepository.getNotes();
      final notesToExport = allNotes
          .where((note) => event.noteIds.contains(note.id))
          .toList();

      if (notesToExport.isNotEmpty) {
        final filePath = await PdfExportService.exportMultipleNotesToPdf(
          notesToExport,
        );
        emit(PdfExported(filePath, 'notes_export'));
      } else {
        emit(const NoteError('No notes found to export'));
      }
    } catch (e) {
      emit(
        NoteError(
          'Failed to export PDFs: ${e.toString()}',
          exception: e as Exception,
        ),
      );
    }
  }

  /// Add alarm to note
  Future<void> _onAddAlarmToNote(
    AddAlarmToNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      final note = await _noteRepository.getNoteById(event.noteId);
      if (note != null) {
        final updatedNote = note.addAlarm(event.alarm);
        await _noteRepository.updateNote(updatedNote);

        // Schedule the actual alarm notification
        await _alarmService.scheduleAlarm(
          dateTime: event.alarm.dateTime,
          id: event.alarm.id,
          title: 'Reminder: ${note.title}',
        );

        emit(AlarmAdded(updatedNote));
      }
    } catch (e) {
      emit(
        NoteError(
          'Failed to add alarm: ${e.toString()}',
          exception: e as Exception,
        ),
      );
    }
  }

  /// Remove alarm from note
  Future<void> _onRemoveAlarmFromNote(
    RemoveAlarmFromNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      final note = await _noteRepository.getNoteById(event.noteId);
      if (note != null) {
        // Cancel the alarm notification
        await _alarmService.cancelAlarm(event.alarmId);

        final updatedNote = note.removeAlarm(event.alarmId);
        await _noteRepository.updateNote(updatedNote);
        emit(AlarmRemoved(updatedNote));
      }
    } catch (e) {
      emit(
        NoteError(
          'Failed to remove alarm: ${e.toString()}',
          exception: e as Exception,
        ),
      );
    }
  }

  /// Clear old notes
  Future<void> _onClearOldNotes(
    ClearOldNotesEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      emit(const NoteLoading());
      final notes = await _noteRepository.getNotes();
      final cutoffDate = DateTime.now().subtract(Duration(days: event.daysOld));

      int deletedCount = 0;
      for (final note in notes) {
        if (note.updatedAt.isBefore(cutoffDate)) {
          await _noteRepository.deleteNote(note.id);
          deletedCount++;
        }
      }

      emit(OldNotesCleared(deletedCount));
    } catch (e) {
      emit(
        NoteError(
          'Failed to clear old notes: ${e.toString()}',
          exception: e as Exception,
        ),
      );
    }
  }

  /// Restore archived note
  Future<void> _onRestoreArchivedNote(
    RestoreArchivedNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      final note = await _noteRepository.getNoteById(event.noteId);
      if (note != null && note.isArchived) {
        final restoredNote = note.toggleArchive();
        await _noteRepository.updateNote(restoredNote);
        emit(NoteRestored(restoredNote));
      }
    } catch (e) {
      emit(
        NoteError(
          'Failed to restore note: ${e.toString()}',
          exception: e as Exception,
        ),
      );
    }
  }

  /// Batch update notes color
  Future<void> _onBatchUpdateNotesColor(
    BatchUpdateNotesColorEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      final allNotes = await _noteRepository.getNotes();
      for (final noteId in event.noteIds) {
        final note = allNotes.firstWhere((n) => n.id == noteId);
        final updatedNote = note.copyWith(color: event.color);
        await _noteRepository.updateNote(updatedNote);
      }
      // Reload all notes to reflect changes
      final updatedNotes = await _noteRepository.getNotes();
      emit(NotesLoaded(updatedNotes, totalCount: updatedNotes.length));
    } catch (e) {
      emit(
        NoteError(
          'Failed to update colors: ${e.toString()}',
          exception: e as Exception,
        ),
      );
    }
  }

  /// Sort notes
  Future<void> _onSortNotes(
    SortNotesEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      emit(const NoteLoading());
      var notes = await _noteRepository.getNotes();

      switch (event.sortBy) {
        case NoteSortBy.newest:
          notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case NoteSortBy.oldest:
          notes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          break;
        case NoteSortBy.alphabetical:
          notes.sort((a, b) => a.title.compareTo(b.title));
          break;
        case NoteSortBy.mostModified:
          notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          break;
        case NoteSortBy.pinned:
          notes.sort(
            (a, b) => (b.isPinned ? 1 : 0).compareTo(a.isPinned ? 1 : 0),
          );
          break;
        case NoteSortBy.completion:
          notes.sort(
            (a, b) =>
                (b.completionPercentage).compareTo(a.completionPercentage),
          );
          break;
      }

      emit(NotesLoaded(notes, totalCount: notes.length));
    } catch (e) {
      emit(
        NoteError(
          'Failed to sort notes: ${e.toString()}',
          exception: e as Exception,
        ),
      );
    }
  }

  /// Handle clipboard text detected
  Future<void> _onClipboardTextDetected(
    ClipboardTextDetectedEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      // Emit state to show dialog in UI
      emit(ClipboardTextDetected(event.text));
    } catch (e) {
      emit(
        NoteError(
          'Failed to detect clipboard: ${e.toString()}',
          exception: e as Exception,
        ),
      );
    }
  }

  /// Save clipboard text as note
  Future<void> _onSaveClipboardAsNote(
    SaveClipboardAsNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      emit(const NoteLoading());

      // Create note from clipboard text
      final note = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: event.title ?? 'Clipboard Note',
        content: event.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to database
      await _noteRepository.createNote(note);

      // Emit success state
      emit(ClipboardNoteSaved(note));

      // Reload notes
      await _onLoadNotes(const LoadNotesEvent(), emit);
    } catch (e) {
      emit(
        NoteError(
          'Failed to save clipboard: ${e.toString()}',
          exception: e as Exception,
        ),
      );
    }
  }
}
