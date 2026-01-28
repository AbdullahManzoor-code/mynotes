import 'package:equatable/equatable.dart';
import '../../domain/entities/note.dart';

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

/// Create new note
class CreateNoteEvent extends NoteEvent {
  final String title;
  final String content;
  final NoteColor color;
  final List<String>? tags;
  final bool isPinned;

  const CreateNoteEvent({
    required this.title,
    this.content = '',
    this.color = NoteColor.defaultColor,
    this.tags,
    this.isPinned = false,
  });

  @override
  List<Object?> get props => [title, content, color, tags, isPinned];
}

/// Update existing note
class UpdateNoteEvent extends NoteEvent {
  final Note note;

  const UpdateNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
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

/// Toggle pin status
class TogglePinNoteEvent extends NoteEvent {
  final String noteId;

  const TogglePinNoteEvent(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

/// Toggle archive status
class ToggleArchiveNoteEvent extends NoteEvent {
  final String noteId;

  const ToggleArchiveNoteEvent(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

/// Add tag to note
class AddTagEvent extends NoteEvent {
  final String noteId;
  final String tag;

  const AddTagEvent(this.noteId, this.tag);

  @override
  List<Object?> get props => [noteId, tag];
}

/// Remove tag from note
class RemoveTagEvent extends NoteEvent {
  final String noteId;
  final String tag;

  const RemoveTagEvent(this.noteId, this.tag);

  @override
  List<Object?> get props => [noteId, tag];
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
