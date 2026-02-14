part of 'note_linking_bloc.dart';

abstract class NoteLinkingEvent extends Equatable {
  const NoteLinkingEvent();

  @override
  List<Object?> get props => [];
}

class LinkNotesEvent extends NoteLinkingEvent {
  final String sourceNoteId;
  final String targetNoteId;

  const LinkNotesEvent({
    required this.sourceNoteId,
    required this.targetNoteId,
  });

  @override
  List<Object?> get props => [sourceNoteId, targetNoteId];
}

class UnlinkNotesEvent extends NoteLinkingEvent {
  final String sourceNoteId;
  final String targetNoteId;

  const UnlinkNotesEvent({
    required this.sourceNoteId,
    required this.targetNoteId,
  });

  @override
  List<Object?> get props => [sourceNoteId, targetNoteId];
}

class LoadLinkedNotesEvent extends NoteLinkingEvent {
  final String noteId;

  const LoadLinkedNotesEvent(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

class LoadBacklinksEvent extends NoteLinkingEvent {
  final String noteId;

  const LoadBacklinksEvent(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

class UpdateLinkMetadataEvent extends NoteLinkingEvent {
  final String sourceNoteId;
  final String targetNoteId;
  final String metadata;

  const UpdateLinkMetadataEvent({
    required this.sourceNoteId,
    required this.targetNoteId,
    required this.metadata,
  });

  @override
  List<Object?> get props => [sourceNoteId, targetNoteId, metadata];
}
