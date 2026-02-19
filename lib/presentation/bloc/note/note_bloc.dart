import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/injection_container.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/repositories/note_repository.dart';
import '../../../domain/entities/note.dart';
import '../../../core/pdf/pdf_export_service.dart';
import '../../../core/notifications/alarm_service.dart';
import '../../../core/services/link_parser_service.dart';
import '../../../domain/repositories/alarm_repository.dart';
import 'package:mynotes/core/services/app_logger.dart';
import 'note_event.dart';
import 'note_state.dart';
import '../../../domain/services/advanced_search_ranking_service.dart';

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
  final AlarmRepository _alarmRepository;
  final LinkParserService _linkParserService;
  final AdvancedSearchRankingService _rankingService =
      AdvancedSearchRankingService();

  /// Stores recently deleted notes for undo functionality
  /// Maps noteId -> (Note, deleteTime)
  final Map<String, (Note, DateTime)> _recentlyDeletedNotes = {};

  NotesBloc({
    required NoteRepository noteRepository,
    AlarmService? alarmService,
    AlarmRepository? alarmRepository,
    LinkParserService? linkParserService,
  }) : _noteRepository = noteRepository,
       _alarmService = alarmService ?? AlarmService(),
       _alarmRepository = alarmRepository ?? getIt<AlarmRepository>(),
       _linkParserService = linkParserService ?? LinkParserService(),
       super(const NoteInitial()) {
    // Register event handlers
    on<LoadNotesEvent>(_onLoadNotes);
    on<LoadNoteByIdEvent>(_onLoadNoteById);
    on<CreateNoteEvent>(_onCreateNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);
    on<UndoDeleteNoteEvent>(_onUndoDeleteNote);
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
    on<UpdateNoteViewConfigEvent>(_onUpdateNoteViewConfig);
    on<ToggleSearchExpandedEvent>(_onToggleSearchExpanded);
  }

  Future<void> _onLoadNotes(
    LoadNotesEvent event,
    Emitter<NoteState> emit,
  ) async {
    AppLogger.i('Handling LoadNotesEvent');
    try {
      emit(const NoteLoading());
      final notes = await _noteRepository.getNotes();
      AppLogger.i('Fetched ${notes.length} notes from repository.');

      if (notes.isEmpty) {
        AppLogger.i('No notes available.');
        emit(const NoteEmpty());
      } else {
        // If we are already in a NotesLoaded state, preserve configuration
        if (state is NotesLoaded) {
          final current = state as NotesLoaded;
          final displayed = _filterAndSortNotes(
            notes: notes,
            query: current.searchQuery,
            tags: current.selectedTags,
            colors: current.selectedColors,
            sortOption: current.sortBy,
            descending: current.sortDescending,
            filterPinned: current.filterPinned,
            filterMedia: current.filterWithMedia,
            filterImages: current.filterWithImages,
            filterAudio: current.filterWithAudio,
            filterVideo: current.filterWithVideo,
            filterReminders: current.filterWithReminders,
            filterTodos: current.filterWithTodos,
            secondarySortBy: current.secondarySortBy,
            secondarySortDescending: current.secondarySortDescending,
            manualSortItems: current.manualSortItems,
          );
          emit(
            current.copyWith(
              allNotes: notes,
              displayedNotes: displayed,
              totalCount: notes.length,
            ),
          );
        } else {
          // FIX: Load saved viewMode from SharedPreferences [SESSION 24]
          NoteViewMode savedViewMode = NoteViewMode.list;
          try {
            final prefs = await SharedPreferences.getInstance();
            final savedMode = prefs.getString('notes_view_mode');
            if (savedMode != null) {
              // Parse the saved mode (e.g., "NoteViewMode.grid" → "grid")
              if (savedMode.contains('grid')) {
                savedViewMode = NoteViewMode.grid;
              } else if (savedMode.contains('list')) {
                savedViewMode = NoteViewMode.list;
              }
              AppLogger.i(
                'Restored note view mode: ${savedViewMode.toString()}',
              );
            }
          } catch (e) {
            AppLogger.w('Failed to load saved view mode: $e');
          }

          // [N021 FIX] Load saved sort preference from SharedPreferences
          NoteSortOption savedSortBy = NoteSortOption.dateCreated;
          try {
            final prefs = await SharedPreferences.getInstance();
            final savedSort = prefs.getString('notes_sort_preference');
            if (savedSort != null) {
              // Parse enum from string (e.g., "NoteSortBy.alphabetical" → alphabetical)
              if (savedSort.contains('alphabetical')) {
                savedSortBy = NoteSortOption.alphabetical;
              } else if (savedSort.contains('oldest')) {
                savedSortBy = NoteSortOption.oldest;
              } else if (savedSort.contains('mostModified')) {
                savedSortBy = NoteSortOption.mostModified;
              } else if (savedSort.contains('pinned')) {
                savedSortBy = NoteSortOption.pinned;
              } else if (savedSort.contains('completion')) {
                savedSortBy = NoteSortOption.completion;
              } else {
                savedSortBy = NoteSortOption.dateCreated; // default
              }
              AppLogger.i(
                'Restored sort preference: ${savedSortBy.toString()}',
              );
            }
          } catch (e) {
            AppLogger.w('Failed to load sort preference: $e');
          }

          // Apply saved sort preference
          List<Note> notesToDisplay = List.from(notes);
          switch (savedSortBy) {
            case NoteSortOption.dateCreated:
              notesToDisplay.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              break;
            case NoteSortOption.oldest:
              notesToDisplay.sort((a, b) => a.createdAt.compareTo(b.createdAt));
              break;
            case NoteSortOption.alphabetical:
              notesToDisplay.sort((a, b) => a.title.compareTo(b.title));
              break;
            case NoteSortOption.dateModified:
            case NoteSortOption.mostModified:
              notesToDisplay.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
              break;
            case NoteSortOption.pinned:
              notesToDisplay.sort(
                (a, b) => (b.isPinned ? 1 : 0).compareTo(a.isPinned ? 1 : 0),
              );
              break;
            case NoteSortOption.completion:
              notesToDisplay.sort(
                (a, b) =>
                    (b.completionPercentage).compareTo(a.completionPercentage),
              );
              break;
            case NoteSortOption.titleAZ:
            case NoteSortOption.titleZA:
            case NoteSortOption.color:
            case NoteSortOption.frequency:
            case NoteSortOption.priority:
            case NoteSortOption.manual:
              notesToDisplay.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
              break;
          }

          emit(
            NotesLoaded(
              allNotes: notes,
              displayedNotes: notesToDisplay,
              totalCount: notes.length,
              viewMode: savedViewMode,
              sortBy: savedSortBy,
            ),
          );
        }
      }
      AppLogger.i('Notes loaded successfully.');
    } catch (e, stack) {
      AppLogger.e('Error loading notes: $e', e, stack);
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
    AppLogger.i('Handling CreateNoteEvent');
    try {
      emit(const NoteLoading());

      // Convert params to Note entity
      final newNote = event.params
          .copyWith(
            noteId: DateTime.now().millisecondsSinceEpoch.toString(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          )
          .toNote();

      AppLogger.i('Created note entity locally: ${newNote.id}');
      await _noteRepository.createNote(newNote);

      // Sync links
      if (newNote.content.isNotEmpty) {
        AppLogger.i('Parsing links from note content...');
        final titles = _linkParserService.extractLinks(newNote.content);
        if (titles.isNotEmpty) {
          AppLogger.i('Found ${titles.length} link titles. Syncing...');
          await _noteRepository.resolveAndSyncLinks(newNote.id, titles);
        }
      }

      emit(NoteCreated(newNote));

      // Refresh notes list with current configuration
      await _onLoadNotes(const LoadNotesEvent(), emit);
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
    AppLogger.i('Handling UpdateNoteEvent for note: ${event.params.noteId}');
    try {
      emit(const NoteLoading());

      // Convert params to Note entity with updated timestamp
      final updatedNote = event.params
          .copyWith(updatedAt: DateTime.now())
          .toNote();

      await _noteRepository.updateNote(updatedNote);

      // Sync links
      if (updatedNote.content.isNotEmpty) {
        final titles = _linkParserService.extractLinks(updatedNote.content);
        await _noteRepository.resolveAndSyncLinks(updatedNote.id, titles);
      }

      emit(NoteUpdated(updatedNote));
      AppLogger.i('Note ${updatedNote.id} updated successfully.');

      // Refresh notes list with current configuration
      await _onLoadNotes(const LoadNotesEvent(), emit);
    } catch (e, stack) {
      AppLogger.e('Error updating note: $e', e, stack);
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
      // Store deleted note for undo (5-second window)
      final deletedNote = await _noteRepository.getNoteById(event.noteId);
      if (deletedNote != null) {
        _recentlyDeletedNotes[event.noteId] = (deletedNote, DateTime.now());
      }

      // Clean up associated resources BEFORE deleting the note
      try {
        // Cancel any alarms for this note
        final alarms = deletedNote?.alarms ?? [];
        for (final alarm in alarms) {
          // Cancel the alarm via AlarmRepository
          await _alarmRepository.deleteAlarm(alarm.id);
          AppLogger.i('Note deletion: Cancelled alarm ${alarm.id}');
        }
      } catch (e) {
        AppLogger.w('Failed to cleanup alarms for deleted note: $e');
      }

      try {
        // Delete associated media files from disk
        // This would need MediaService integration
        AppLogger.i('Note deletion: Media cleanup would occur here');
      } catch (e) {
        AppLogger.w('Failed to cleanup media for deleted note: $e');
      }

      try {
        // Clean up link associations
        await _noteRepository.updateNoteLinks(event.noteId, []);
      } catch (e) {
        AppLogger.w('Failed to cleanup links for deleted note: $e');
      }

      // Now delete the note itself
      await _noteRepository.deleteNote(event.noteId);
      emit(NoteDeleted(event.noteId));

      // Show undo snackbar
      emit(const NoteDeletedWithUndo());

      // Refresh notes list with current configuration
      await _onLoadNotes(const LoadNotesEvent(), emit);

      // Also refresh archived list just in case we were there
      final archivedNotes = await _noteRepository.getArchivedNotes();
      emit(ArchivedNotesLoaded(archivedNotes));

      // Auto-remove from undo history after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        _recentlyDeletedNotes.remove(event.noteId);
      });
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

  /// Undo the last delete (within 5-second window)
  Future<void> _onUndoDeleteNote(
    UndoDeleteNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      final deletedData = _recentlyDeletedNotes[event.noteId];
      if (deletedData == null) {
        emit(
          NoteError(
            'Cannot undo: note was deleted more than 5 seconds ago',
            exception: Exception('UNDO_EXPIRED'),
          ),
        );
        return;
      }

      final (deletedNote, _) = deletedData;

      // Re-insert the note
      await _noteRepository.createNote(deletedNote);
      emit(NoteRestored(deletedNote));

      // Remove from undo history
      _recentlyDeletedNotes.remove(event.noteId);

      // Refresh notes list
      await _onLoadNotes(const LoadNotesEvent(), emit);
    } catch (e) {
      emit(
        NoteError(
          'Failed to undo delete: ${e.toString()}',
          exception: e as Exception,
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
      emit(const NoteLoading()); // Show loading while deleting

      int deletedCount = 0;
      final deletedNotes = <String, (Note, DateTime)>{};

      for (final noteId in event.noteIds) {
        try {
          // Get note for undo history
          final noteToDelete = await _noteRepository.getNoteById(noteId);
          if (noteToDelete != null) {
            deletedNotes[noteId] = (noteToDelete, DateTime.now());
            // Store in undo map
            _recentlyDeletedNotes[noteId] = (noteToDelete, DateTime.now());
          }

          // Clean up associated resources
          try {
            // Cancel alarms
            final alarms = noteToDelete?.alarms ?? [];
            for (final alarm in alarms) {
              await _alarmRepository.deleteAlarm(alarm.id);
              AppLogger.i('Batch delete: Cancelled alarm ${alarm.id}');
            }
          } catch (e) {
            AppLogger.w('Failed to cleanup alarms: $e');
          }

          try {
            // Clean up links
            await _noteRepository.updateNoteLinks(noteId, []);
          } catch (e) {
            AppLogger.w('Failed to cleanup links: $e');
          }

          // Delete the note
          await _noteRepository.deleteNote(noteId);
          deletedCount++;
        } catch (e) {
          AppLogger.e('Error deleting note $noteId in batch delete: $e');
          // Continue with next note instead of failing entire batch
        }
      }

      emit(NotesDeleted(event.noteIds, deletedCount));

      // Show undo snackbar for batch delete
      if (deletedCount > 0) {
        emit(const NoteDeletedWithUndo());
      }

      // Refresh notes list with current configuration
      await _onLoadNotes(const LoadNotesEvent(), emit);

      // Auto-remove from undo after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        for (final noteId in deletedNotes.keys) {
          _recentlyDeletedNotes.remove(noteId);
        }
      });
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

  /// Toggle pin status using Complete Param pattern
  Future<void> _onTogglePinNote(
    TogglePinNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      // Convert params to Note entity with updated timestamp
      final updatedNote = event.params
          .copyWith(updatedAt: DateTime.now())
          .toNote();

      await _noteRepository.updateNote(updatedNote);
      emit(NotePinToggled(updatedNote, updatedNote.isPinned));

      // Refresh notes list with current configuration
      await _onLoadNotes(const LoadNotesEvent(), emit);
    } catch (e) {
      emit(
        NoteError(
          'Failed to toggle pin: ${e.toString()}',
          exception: e as Exception,
        ),
      );
    }
  }

  /// Toggle archive status using Complete Param pattern
  Future<void> _onToggleArchiveNote(
    ToggleArchiveNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      // Convert params to Note entity with updated timestamp
      final updatedNote = event.params
          .copyWith(updatedAt: DateTime.now())
          .toNote();

      await _noteRepository.updateNote(updatedNote);
      emit(NoteArchiveToggled(updatedNote, updatedNote.isArchived));

      // Refresh notes list with current configuration
      await _onLoadNotes(const LoadNotesEvent(), emit);

      // Also refresh archived list for observers
      final allNotes = await _noteRepository.getAllNotes();
      emit(ArchivedNotesLoaded(allNotes.where((n) => n.isArchived).toList()));
    } catch (e) {
      emit(
        NoteError(
          'Failed to toggle archive: ${e.toString()}',
          exception: e as Exception,
        ),
      );
    }
  }

  /// Add tag to note using Complete Param pattern
  /// [SESSION 24 - SG202-001] Prevent duplicate tags
  Future<void> _onAddTag(AddTagEvent event, Emitter<NoteState> emit) async {
    try {
      // Convert params to Note entity with updated timestamp
      final updatedNote = event.params
          .copyWith(updatedAt: DateTime.now())
          .toNote();

      // Extract the newly added tag (last in the list)
      final newTag = event.params.tags.isNotEmpty ? event.params.tags.last : '';

      // FIX: Check if tag already exists before adding [SESSION 24]
      final existingNote = await _noteRepository.getNoteById(updatedNote.id);
      if (existingNote != null && existingNote.tags.contains(newTag)) {
        emit(
          NoteError(
            'Tag "$newTag" already exists on this note',
            exception: Exception('DUPLICATE_TAG'),
          ),
        );
        return;
      }

      await _noteRepository.updateNote(updatedNote);
      emit(TagAdded(updatedNote, newTag));

      // Refresh notes list with current configuration
      await _onLoadNotes(const LoadNotesEvent(), emit);
    } catch (e) {
      emit(
        NoteError(
          'Failed to add tag: ${e.toString()}',
          exception: e as Exception,
        ),
      );
    }
  }

  /// Remove tag from note using Complete Param pattern
  Future<void> _onRemoveTag(
    RemoveTagEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      // Convert params to Note entity with updated timestamp
      final updatedNote = event.params
          .copyWith(updatedAt: DateTime.now())
          .toNote();

      await _noteRepository.updateNote(updatedNote);
      // Extract removed tag from params comparison
      final removedTag = event.params.tags.isNotEmpty
          ? event.params.tags.first
          : '';
      emit(TagRemoved(updatedNote, removedTag));

      // Refresh notes list with current configuration
      await _onLoadNotes(const LoadNotesEvent(), emit);
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

      // Use AdvancedSearchRankingService for better results
      final rankedResults = await _rankingService.advancedSearch(
        items: notes,
        query: event.query,
      );

      final results = rankedResults.map((r) {
        final note = r.item as Note;
        return {
          'note': note,
          'id': note.id,
          'title': note.title,
          'preview': note.content,
          'date': note.updatedAt,
          'relevance': r.score.clamp(0, 100).toInt(),
          'type': 'note',
          'tags': note.tags,
        };
      }).toList();

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
      final notes = await _noteRepository.getArchivedNotes();
      emit(ArchivedNotesLoaded(notes));
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
        // Update alarm with linked note ID
        final alarm = event.alarm.copyWith(linkedNoteId: note.id);

        // Add to global reminders list (Persistence)
        await _alarmRepository.createAlarm(alarm);

        final updatedNote = note.addAlarm(alarm);
        await _noteRepository.updateNote(updatedNote);

        // Initialize AlarmService before scheduling
        AppLogger.i('[NOTE-ALARM] Initializing AlarmService...');
        try {
          await _alarmService.init();
          await _alarmService.requestPermissions();
          AppLogger.i('[NOTE-ALARM] ✅ AlarmService ready for scheduling');
        } catch (e) {
          AppLogger.w('[NOTE-ALARM] ⚠️ AlarmService init warning: $e');
        }

        // Schedule the actual alarm notification
        await _alarmService.scheduleAlarm(
          dateTime: alarm.scheduledTime,
          id: alarm.id,
          title: 'Reminder: ${note.title}',
          payload: jsonEncode({
            'type': 'note',
            'id': alarm.id,
            'linkedNoteId': note.id,
          }),
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

        // Remove from global reminders list (Persistence)
        await _alarmRepository.deleteAlarm(event.alarmId);

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

        // Refresh lists - both active and archived
        await _onLoadNotes(const LoadNotesEvent(), emit);

        // Also refresh archived list to ensure UI is in sync
        final archivedNotes = await _noteRepository.getArchivedNotes();
        emit(ArchivedNotesLoaded(archivedNotes));
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
      // Reload all notes to reflect changes with current configuration
      await _onLoadNotes(const LoadNotesEvent(), emit);
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

      // [N021 FIX] Persist sort preference to SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('notes_sort_preference', event.sortBy.toString());
        AppLogger.i('💾 Saved sort preference: ${event.sortBy}');
      } catch (e) {
        AppLogger.w('Failed to save sort preference: $e');
      }

      emit(NotesLoaded.simple(notes));
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

  /// Handle view configuration changes
  /// [SESSION 24 - SG202-002] Added viewMode persistence to SharedPreferences
  Future<void> _onUpdateNoteViewConfig(
    UpdateNoteViewConfigEvent event,
    Emitter<NoteState> emit,
  ) async {
    if (state is NotesLoaded) {
      final current = state as NotesLoaded;

      final newQuery = event.searchQuery ?? current.searchQuery;
      final newTags = event.selectedTags ?? current.selectedTags;
      final newColors = event.selectedColors ?? current.selectedColors;
      final newSort = event.sortBy ?? current.sortBy;
      final newDesc = event.sortDescending ?? current.sortDescending;
      final newSecSort = event.secondarySortBy ?? current.secondarySortBy;
      final newSecDesc =
          event.secondarySortDescending ?? current.secondarySortDescending;
      final newManual = event.manualSortItems ?? current.manualSortItems;
      final newPinned = event.filterPinned ?? current.filterPinned;
      final newMedia = event.filterWithMedia ?? current.filterWithMedia;
      final newImages = event.filterWithImages ?? current.filterWithImages;
      final newAudio = event.filterWithAudio ?? current.filterWithAudio;
      final newVideo = event.filterWithVideo ?? current.filterWithVideo;
      final newReminders =
          event.filterWithReminders ?? current.filterWithReminders;
      final newTodos = event.filterWithTodos ?? current.filterWithTodos;
      final newViewMode = event.viewMode ?? current.viewMode;
      final newIsSearchExpanded =
          event.isSearchExpanded ?? current.isSearchExpanded;
      final newSearchHistory = event.searchHistory ?? current.searchHistory;
      final newTagSearchQuery =
          event.tagManagementSearchQuery ?? current.tagManagementSearchQuery;
      final newTagSelectedTags =
          event.tagManagementSelectedTags ?? current.tagManagementSelectedTags;

      final displayed = _filterAndSortNotes(
        notes: current.allNotes,
        query: newQuery,
        tags: newTags,
        colors: newColors,
        sortOption: newSort,
        descending: newDesc,
        filterPinned: newPinned,
        filterMedia: newMedia,
        filterImages: newImages,
        filterAudio: newAudio,
        filterVideo: newVideo,
        filterReminders: newReminders,
        filterTodos: newTodos,
        secondarySortBy: newSecSort,
        secondarySortDescending: newSecDesc,
        manualSortItems: newManual,
      );

      // FIX: Save viewMode to SharedPreferences [SESSION 24]
      if (event.viewMode != null && event.viewMode != current.viewMode) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('notes_view_mode', newViewMode.toString());
          AppLogger.i('Note view mode persisted: ${newViewMode.toString()}');
        } catch (e) {
          AppLogger.w('Failed to persist note view mode: $e');
        }
      }

      emit(
        current.copyWith(
          searchQuery: newQuery,
          selectedTags: newTags,
          selectedColors: newColors,
          sortBy: newSort,
          sortDescending: newDesc,
          secondarySortBy: newSecSort,
          secondarySortDescending: newSecDesc,
          manualSortItems: newManual,
          filterPinned: newPinned,
          filterWithMedia: newMedia,
          filterWithImages: newImages,
          filterWithAudio: newAudio,
          filterWithVideo: newVideo,
          filterWithReminders: newReminders,
          filterWithTodos: newTodos,
          viewMode: newViewMode,
          isSearchExpanded: newIsSearchExpanded,
          searchHistory: newSearchHistory,
          tagManagementSearchQuery: newTagSearchQuery,
          tagManagementSelectedTags: newTagSelectedTags,
          displayedNotes: displayed,
        ),
      );
    }
  }

  /// Toggle search bar expanded state
  void _onToggleSearchExpanded(
    ToggleSearchExpandedEvent event,
    Emitter<NoteState> emit,
  ) {
    if (state is NotesLoaded) {
      final current = state as NotesLoaded;
      emit(
        current.copyWith(
          isSearchExpanded: event.isExpanded ?? !current.isSearchExpanded,
        ),
      );
    }
  }

  /// Helper to filter and sort notes
  List<Note> _filterAndSortNotes({
    required List<Note> notes,
    required String query,
    required List<String> tags,
    required List<NoteColor> colors,
    required NoteSortOption sortOption,
    required bool descending,
    NoteSortOption? secondarySortBy,
    bool? secondarySortDescending,
    List<String> manualSortItems = const [],
    required bool filterPinned,
    required bool filterMedia,
    bool filterImages = false,
    bool filterAudio = false,
    bool filterVideo = false,
    bool filterReminders = false,
    bool filterTodos = false,
  }) {
    List<Note> filtered = List.from(notes);

    // Apply search
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      filtered = filtered
          .where(
            (n) =>
                n.title.toLowerCase().contains(q) ||
                n.content.toLowerCase().contains(q) ||
                n.tags.any((t) => t.toLowerCase().contains(q)),
          )
          .toList();
    }

    // Apply tags
    if (tags.isNotEmpty) {
      filtered = filtered
          .where((n) => tags.any((t) => n.tags.contains(t)))
          .toList();
    }

    // Apply colors
    if (colors.isNotEmpty) {
      filtered = filtered.where((n) => colors.contains(n.color)).toList();
    }

    // Apply special filters
    if (filterPinned) {
      filtered = filtered.where((n) => n.isPinned).toList();
    }
    if (filterMedia) {
      filtered = filtered.where((n) => n.media.isNotEmpty).toList();
    }
    if (filterImages) {
      filtered = filtered.where((n) => n.imagesCount > 0).toList();
    }
    if (filterAudio) {
      filtered = filtered.where((n) => n.audioCount > 0).toList();
    }
    if (filterVideo) {
      filtered = filtered.where((n) => n.videoCount > 0).toList();
    }
    if (filterReminders) {
      filtered = filtered
          .where((n) => n.alarms != null && n.alarms!.isNotEmpty)
          .toList();
    }
    if (filterTodos) {
      filtered = filtered.where((n) => n.hasTodos).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      int compare(Note n1, Note n2, NoteSortOption option, bool isDesc) {
        int cmp;
        switch (option) {
          case NoteSortOption.dateCreated:
          case NoteSortOption.oldest:
            cmp = n1.createdAt.compareTo(n2.createdAt);
            break;
          case NoteSortOption.dateModified:
          case NoteSortOption.mostModified:
            cmp = n1.updatedAt.compareTo(n2.updatedAt);
            break;
          case NoteSortOption.titleAZ:
          case NoteSortOption.alphabetical:
            cmp = n1.title.compareTo(n2.title);
            break;
          case NoteSortOption.titleZA:
            cmp = n2.title.compareTo(n1.title);
            break;
          case NoteSortOption.color:
            cmp = n1.color.index.compareTo(n2.color.index);
            break;
          case NoteSortOption.pinned:
            if (n1.isPinned == n2.isPinned) {
              cmp = n2.updatedAt.compareTo(n1.updatedAt);
            } else {
              cmp = n1.isPinned ? -1 : 1;
            }
            break;
          case NoteSortOption.completion:
            cmp = n1.completionPercentage.compareTo(n2.completionPercentage);
            break;
          case NoteSortOption.frequency:
            cmp = n1.updatedAt.compareTo(n2.updatedAt);
            break;
          case NoteSortOption.priority:
            if (n1.isPinned == n2.isPinned) {
              cmp = 0;
            } else {
              cmp = n1.isPinned ? -1 : 1;
            }
            break;
          case NoteSortOption.manual:
            int idx1 = manualSortItems.indexOf(n1.id);
            int idx2 = manualSortItems.indexOf(n2.id);
            if (idx1 == -1) idx1 = 999;
            if (idx2 == -1) idx2 = 999;
            cmp = idx1.compareTo(idx2);
            break;
        }
        return isDesc ? -cmp : cmp;
      }

      int res = compare(a, b, sortOption, descending);
      if (res == 0 && secondarySortBy != null) {
        res = compare(
          a,
          b,
          secondarySortBy,
          secondarySortDescending ?? descending,
        );
      }
      return res;
    });

    return filtered;
  }
}
