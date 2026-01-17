import 'package:equatable/equatable.dart';
import '../../domain/entities/note.dart';

/// States for Notes BLoC
abstract class NoteState extends Equatable {
  const NoteState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class NoteInitial extends NoteState {
  const NoteInitial();
}

/// Loading state
class NoteLoading extends NoteState {
  const NoteLoading();
}

/// Notes loaded successfully
class NotesLoaded extends NoteState {
  final List<Note> notes;
  final int totalCount;

  const NotesLoaded(this.notes, {this.totalCount = 0});

  @override
  List<Object?> get props => [notes, totalCount];
}

/// Single note loaded
class NoteLoaded extends NoteState {
  final Note note;

  const NoteLoaded(this.note);

  @override
  List<Object?> get props => [note];
}

/// Note created successfully
class NoteCreated extends NoteState {
  final Note note;

  const NoteCreated(this.note);

  @override
  List<Object?> get props => [note];
}

/// Note updated successfully
class NoteUpdated extends NoteState {
  final Note note;

  const NoteUpdated(this.note);

  @override
  List<Object?> get props => [note];
}

/// Note deleted successfully
class NoteDeleted extends NoteState {
  final String noteId;

  const NoteDeleted(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

/// Multiple notes deleted
class NotesDeleted extends NoteState {
  final List<String> noteIds;
  final int deletedCount;

  const NotesDeleted(this.noteIds, this.deletedCount);

  @override
  List<Object?> get props => [noteIds, deletedCount];
}

/// Note pin status toggled
class NotePinToggled extends NoteState {
  final Note note;
  final bool isPinned;

  const NotePinToggled(this.note, this.isPinned);

  @override
  List<Object?> get props => [note, isPinned];
}

/// Note archive status toggled
class NoteArchiveToggled extends NoteState {
  final Note note;
  final bool isArchived;

  const NoteArchiveToggled(this.note, this.isArchived);

  @override
  List<Object?> get props => [note, isArchived];
}

/// Tag added to note
class TagAdded extends NoteState {
  final Note note;
  final String tag;

  const TagAdded(this.note, this.tag);

  @override
  List<Object?> get props => [note, tag];
}

/// Tag removed from note
class TagRemoved extends NoteState {
  final Note note;
  final String tag;

  const TagRemoved(this.note, this.tag);

  @override
  List<Object?> get props => [note, tag];
}

/// Search results loaded
class SearchResultsLoaded extends NoteState {
  final List<Note> results;
  final String query;
  final int resultCount;

  const SearchResultsLoaded(this.results, this.query, {this.resultCount = 0});

  @override
  List<Object?> get props => [results, query, resultCount];
}

/// Pinned notes loaded
class PinnedNotesLoaded extends NoteState {
  final List<Note> notes;

  const PinnedNotesLoaded(this.notes);

  @override
  List<Object?> get props => [notes];
}

/// Archived notes loaded
class ArchivedNotesLoaded extends NoteState {
  final List<Note> notes;

  const ArchivedNotesLoaded(this.notes);

  @override
  List<Object?> get props => [notes];
}

/// Notes by tag loaded
class NotesByTagLoaded extends NoteState {
  final List<Note> notes;
  final String tag;

  const NotesByTagLoaded(this.notes, this.tag);

  @override
  List<Object?> get props => [notes, tag];
}

/// PDF exported successfully
class PdfExported extends NoteState {
  final String filePath;
  final String fileName;

  const PdfExported(this.filePath, this.fileName);

  @override
  List<Object?> get props => [filePath, fileName];
}

/// Alarm added to note
class AlarmAdded extends NoteState {
  final Note note;

  const AlarmAdded(this.note);

  @override
  List<Object?> get props => [note];
}

/// Alarm removed from note
class AlarmRemoved extends NoteState {
  final Note note;

  const AlarmRemoved(this.note);

  @override
  List<Object?> get props => [note];
}

/// Old notes cleared
class OldNotesCleared extends NoteState {
  final int clearedCount;

  const OldNotesCleared(this.clearedCount);

  @override
  List<Object?> get props => [clearedCount];
}

/// Note restored from archive
class NoteRestored extends NoteState {
  final Note note;

  const NoteRestored(this.note);

  @override
  List<Object?> get props => [note];
}

/// Error state
class NoteError extends NoteState {
  final String message;
  final String? errorCode;
  final Exception? exception;

  const NoteError(this.message, {this.errorCode, this.exception});

  @override
  List<Object?> get props => [message, errorCode, exception];
}

/// Empty state (no notes found)
class NoteEmpty extends NoteState {
  final String message;

  const NoteEmpty({this.message = 'No notes found'});

  @override
  List<Object?> get props => [message];
}

/// Clipboard text detected - ready to save
class ClipboardTextDetected extends NoteState {
  final String text;

  const ClipboardTextDetected(this.text);

  @override
  List<Object?> get props => [text];
}

/// Clipboard note saved successfully
class ClipboardNoteSaved extends NoteState {
  final Note note;

  const ClipboardNoteSaved(this.note);

  @override
  List<Object?> get props => [note];
}

/// Link added to note
class LinkAddedToNote extends NoteState {
  final Note note;

  const LinkAddedToNote(this.note);

  @override
  List<Object?> get props => [note];
}

/// Link removed from note
class LinkRemovedFromNote extends NoteState {
  final Note note;

  const LinkRemovedFromNote(this.note);

  @override
  List<Object?> get props => [note];
}
