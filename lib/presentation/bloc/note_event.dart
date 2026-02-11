import 'package:equatable/equatable.dart';
import '../../domain/entities/note.dart';
import 'params/note_params.dart';
import 'note_state.dart';

/// Events for Notes BLoC
/// Each event represents a user action or system event
abstract class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object?> get props => [];
}

/// Load all notes
class LoadNotesEvent extends NoteEvent {
  const LoadNotesEvent();
}

/// Load single note by ID
class LoadNoteByIdEvent extends NoteEvent {
  final String noteId;
  const LoadNoteByIdEvent(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

/// Create new note using Complete Param pattern
/// 📦 Pass the complete NoteParams object instead of individual parameters
class CreateNoteEvent extends NoteEvent {
  final NoteParams params;

  /// Create with NoteParams (preferred way)
  const CreateNoteEvent({required this.params});

  /// Convenience constructor for backward compatibility
  factory CreateNoteEvent.withDefaults({
    required String title,
    String content = '',
    NoteColor color = NoteColor.defaultColor,
    List<String>? tags,
    bool isPinned = false,
  }) {
    return CreateNoteEvent(
      params: NoteParams(
        title: title,
        content: content,
        color: color,
        tags: tags ?? [],
        isPinned: isPinned,
      ),
    );
  }

  @override
  List<Object?> get props => [params];
}

/// Update existing note using Complete Param pattern
/// 📦 Use NoteParams instead of individual fields
class UpdateNoteEvent extends NoteEvent {
  final NoteParams params;

  /// Create with NoteParams (preferred way)
  const UpdateNoteEvent(this.params);

  /// Convenience: update from Note entity
  factory UpdateNoteEvent.fromNote(Note note) {
    return UpdateNoteEvent(NoteParams.fromNote(note));
  }

  @override
  List<Object?> get props => [params];
}

/// Delete note
class DeleteNoteEvent extends NoteEvent {
  final String noteId;

  const DeleteNoteEvent(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

/// Delete multiple notes
class DeleteMultipleNotesEvent extends NoteEvent {
  final List<String> noteIds;

  const DeleteMultipleNotesEvent(this.noteIds);

  @override
  List<Object?> get props => [noteIds];
}

/// Toggle pin status using Complete Param pattern
/// 📦 Use NoteParams instead of separate event
class TogglePinNoteEvent extends NoteEvent {
  final NoteParams params;

  /// Create with updated params
  const TogglePinNoteEvent(this.params);

  /// Convenience: directly toggle using the helper method
  factory TogglePinNoteEvent.toggle(NoteParams params) {
    return TogglePinNoteEvent(params.togglePin());
  }

  @override
  List<Object?> get props => [params];
}

/// Toggle archive status using Complete Param pattern
/// 📦 Use NoteParams instead of separate event
class ToggleArchiveNoteEvent extends NoteEvent {
  final NoteParams params;

  /// Create with updated params
  const ToggleArchiveNoteEvent(this.params);

  /// Convenience: directly toggle using the helper method
  factory ToggleArchiveNoteEvent.toggle(NoteParams params) {
    return ToggleArchiveNoteEvent(params.toggleArchive());
  }

  @override
  List<Object?> get props => [params];
}

/// Add tag to note using Complete Param pattern
/// 📦 Use NoteParams.withTag() instead of separate event
class AddTagEvent extends NoteEvent {
  final NoteParams params;

  /// Create with tag already added to params
  const AddTagEvent(this.params);

  /// Convenience: create with tag added
  factory AddTagEvent.withTag(NoteParams params, String tag) {
    return AddTagEvent(params.withTag(tag));
  }

  @override
  List<Object?> get props => [params];
}

/// Remove tag from note using Complete Param pattern
/// 📦 Use NoteParams.withoutTag() instead of separate event
class RemoveTagEvent extends NoteEvent {
  final NoteParams params;

  /// Create with tag already removed from params
  const RemoveTagEvent(this.params);

  /// Convenience: create with tag removed
  factory RemoveTagEvent.withoutTag(NoteParams params, String tag) {
    return RemoveTagEvent(params.withoutTag(tag));
  }

  @override
  List<Object?> get props => [params];
}

/// Search notes
class SearchNotesEvent extends NoteEvent {
  final String query;

  const SearchNotesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Load pinned notes
class LoadPinnedNotesEvent extends NoteEvent {
  const LoadPinnedNotesEvent();
}

/// Load archived notes
class LoadArchivedNotesEvent extends NoteEvent {
  const LoadArchivedNotesEvent();
}

/// Load notes by tag
class LoadNotesByTagEvent extends NoteEvent {
  final String tag;

  const LoadNotesByTagEvent(this.tag);

  @override
  List<Object?> get props => [tag];
}

/// Export note to PDF
class ExportNoteToPdfEvent extends NoteEvent {
  final String noteId;

  const ExportNoteToPdfEvent(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

/// Export multiple notes to PDF
class ExportMultipleNotesToPdfEvent extends NoteEvent {
  final List<String> noteIds;

  const ExportMultipleNotesToPdfEvent(this.noteIds);

  @override
  List<Object?> get props => [noteIds];
}

/// Add alarm to note
class AddAlarmToNoteEvent extends NoteEvent {
  final String noteId;
  final dynamic alarm;

  const AddAlarmToNoteEvent(this.noteId, this.alarm);

  @override
  List<Object?> get props => [noteId, alarm];
}

/// Remove alarm from note
class RemoveAlarmFromNoteEvent extends NoteEvent {
  final String noteId;
  final String alarmId;

  const RemoveAlarmFromNoteEvent(this.noteId, this.alarmId);

  @override
  List<Object?> get props => [noteId, alarmId];
}

/// Clear old notes (archive cleanup)
class ClearOldNotesEvent extends NoteEvent {
  final int daysOld;

  const ClearOldNotesEvent({this.daysOld = 30});

  @override
  List<Object?> get props => [daysOld];
}

/// Restore archived note
class RestoreArchivedNoteEvent extends NoteEvent {
  final String noteId;

  const RestoreArchivedNoteEvent(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

/// Batch update notes color
class BatchUpdateNotesColorEvent extends NoteEvent {
  final List<String> noteIds;
  final NoteColor color;

  const BatchUpdateNotesColorEvent(this.noteIds, this.color);

  @override
  List<Object?> get props => [noteIds, color];
}

/// Update note view configuration (filters, sort, mode)
class UpdateNoteViewConfigEvent extends NoteEvent {
  final String? searchQuery;
  final List<String>? selectedTags;
  final List<NoteColor>? selectedColors;
  final NoteSortOption? sortBy;
  final bool? sortDescending;
  final bool? filterPinned;
  final bool? filterWithMedia;
  final bool? filterWithReminders;
  final NoteViewMode? viewMode;

  const UpdateNoteViewConfigEvent({
    this.searchQuery,
    this.selectedTags,
    this.selectedColors,
    this.sortBy,
    this.sortDescending,
    this.filterPinned,
    this.filterWithMedia,
    this.filterWithReminders,
    this.viewMode,
  });

  @override
  List<Object?> get props => [
    searchQuery,
    selectedTags,
    selectedColors,
    sortBy,
    sortDescending,
    filterPinned,
    filterWithMedia,
    filterWithReminders,
    viewMode,
  ];
}

/// Sort notes
class SortNotesEvent extends NoteEvent {
  final NoteSortBy sortBy;

  const SortNotesEvent(this.sortBy);

  @override
  List<Object?> get props => [sortBy];
}

/// Enum for note sorting options
enum NoteSortBy {
  newest,
  oldest,
  alphabetical,
  mostModified,
  pinned,
  completion,
}

/// Load more notes for pagination
class LoadMoreNotesEvent extends NoteEvent {
  final int offset;
  final int limit;

  const LoadMoreNotesEvent({this.offset = 0, this.limit = 50});

  @override
  List<Object?> get props => [offset, limit];
}

/// Clipboard text detected
class ClipboardTextDetectedEvent extends NoteEvent {
  final String text;

  const ClipboardTextDetectedEvent(this.text);

  @override
  List<Object?> get props => [text];
}

/// Save clipboard text as note
class SaveClipboardAsNoteEvent extends NoteEvent {
  final String text;
  final String? title;

  const SaveClipboardAsNoteEvent(this.text, {this.title});

  @override
  List<Object?> get props => [text, title];
}

/// Add link to note
class AddLinkToNoteEvent extends NoteEvent {
  final String noteId;
  final String url;
  final String? title;

  const AddLinkToNoteEvent(this.noteId, this.url, {this.title});

  @override
  List<Object?> get props => [noteId, url, title];
}

/// Remove link from note
class RemoveLinkFromNoteEvent extends NoteEvent {
  final String noteId;
  final String linkId;

  const RemoveLinkFromNoteEvent(this.noteId, this.linkId);

  @override
  List<Object?> get props => [noteId, linkId];
}
