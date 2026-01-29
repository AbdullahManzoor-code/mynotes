part of 'note_versioning_bloc.dart';

abstract class NoteVersioningEvent extends Equatable {
  const NoteVersioningEvent();

  @override
  List<Object?> get props => [];
}

class SaveNoteVersionEvent extends NoteVersioningEvent {
  final String noteId;
  final String title;
  final String content;
  final String reason;

  const SaveNoteVersionEvent({
    required this.noteId,
    required this.title,
    required this.content,
    this.reason = 'Auto-save',
  });

  @override
  List<Object?> get props => [noteId, title, content, reason];
}

class LoadNoteVersionsEvent extends NoteVersioningEvent {
  final String noteId;

  const LoadNoteVersionsEvent(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

class RestoreNoteVersionEvent extends NoteVersioningEvent {
  final String noteId;
  final int versionIndex;

  const RestoreNoteVersionEvent({
    required this.noteId,
    required this.versionIndex,
  });

  @override
  List<Object?> get props => [noteId, versionIndex];
}

class DeleteNoteVersionEvent extends NoteVersioningEvent {
  final String noteId;
  final int versionIndex;

  const DeleteNoteVersionEvent({
    required this.noteId,
    required this.versionIndex,
  });

  @override
  List<Object?> get props => [noteId, versionIndex];
}

class ClearNoteVersionsEvent extends NoteVersioningEvent {
  final String noteId;

  const ClearNoteVersionsEvent(this.noteId);

  @override
  List<Object?> get props => [noteId];
}
