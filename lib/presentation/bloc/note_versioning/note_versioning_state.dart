part of 'note_versioning_bloc.dart';

abstract class NoteVersioningState extends Equatable {
  const NoteVersioningState();

  @override
  List<Object?> get props => [];
}

class NoteVersioningInitial extends NoteVersioningState {
  const NoteVersioningInitial();
}

class NoteVersioningLoading extends NoteVersioningState {
  const NoteVersioningLoading();
}

class NoteVersionSaved extends NoteVersioningState {
  final NoteVersion version;

  const NoteVersionSaved(this.version);

  @override
  List<Object?> get props => [version];
}

class NoteVersionsLoaded extends NoteVersioningState {
  final List<NoteVersion> versions;

  const NoteVersionsLoaded(this.versions);

  @override
  List<Object?> get props => [versions];
}

class NoteVersionRestored extends NoteVersioningState {
  final NoteVersion version;

  const NoteVersionRestored(this.version);

  @override
  List<Object?> get props => [version];
}

class NoteVersioningError extends NoteVersioningState {
  final String message;

  const NoteVersioningError(this.message);

  @override
  List<Object?> get props => [message];
}

class NoteVersion {
  final String id;
  final String noteId;
  final String title;
  final String content;
  final String reason;
  final DateTime createdAt;
  final int size;

  NoteVersion({
    required this.id,
    required this.noteId,
    required this.title,
    required this.content,
    required this.reason,
    required this.createdAt,
    required this.size,
  });

  String get formattedDate => createdAt.toString().split('.')[0];
  String get displayReason => reason.isEmpty ? 'Manual save' : reason;
}
