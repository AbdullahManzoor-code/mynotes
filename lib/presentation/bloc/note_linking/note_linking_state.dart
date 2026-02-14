part of 'note_linking_bloc.dart';

abstract class NoteLinkingState extends Equatable {
  const NoteLinkingState();

  @override
  List<Object?> get props => [];
}

class NoteLinkingInitial extends NoteLinkingState {
  const NoteLinkingInitial();
}

class NoteLinkingLoading extends NoteLinkingState {
  const NoteLinkingLoading();
}

class LinkedNotesLoaded extends NoteLinkingState {
  final List<NoteLink> linkedNotes;

  const LinkedNotesLoaded(this.linkedNotes);

  @override
  List<Object?> get props => [linkedNotes];
}

class BacklinksLoaded extends NoteLinkingState {
  final List<NoteLink> backlinks;

  const BacklinksLoaded(this.backlinks);

  @override
  List<Object?> get props => [backlinks];
}

class NotesLinked extends NoteLinkingState {
  final NoteLink link;

  const NotesLinked(this.link);

  @override
  List<Object?> get props => [link];
}

class NotesUnlinked extends NoteLinkingState {
  final String sourceNoteId;
  final String targetNoteId;

  const NotesUnlinked({
    required this.sourceNoteId,
    required this.targetNoteId,
  });

  @override
  List<Object?> get props => [sourceNoteId, targetNoteId];
}

class NoteLinkingError extends NoteLinkingState {
  final String message;

  const NoteLinkingError(this.message);

  @override
  List<Object?> get props => [message];
}

class NoteLink {
  final String sourceNoteId;
  final String targetNoteId;
  final String? sourceName;
  final String? targetName;
  final String? metadata;
  final DateTime createdAt;

  NoteLink({
    required this.sourceNoteId,
    required this.targetNoteId,
    this.sourceName,
    this.targetName,
    this.metadata,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteLink &&
          runtimeType == other.runtimeType &&
          sourceNoteId == other.sourceNoteId &&
          targetNoteId == other.targetNoteId;

  @override
  int get hashCode => sourceNoteId.hashCode ^ targetNoteId.hashCode;
}
