part of 'note_folders_bloc.dart';

abstract class NoteFoldersEvent extends Equatable {
  const NoteFoldersEvent();

  @override
  List<Object?> get props => [];
}

class LoadFoldersEvent extends NoteFoldersEvent {
  const LoadFoldersEvent();
}

class CreateFolderEvent extends NoteFoldersEvent {
  final String name;
  final int? color;

  const CreateFolderEvent(this.name, {this.color});

  @override
  List<Object?> get props => [name, color];
}

class RenameFolderEvent extends NoteFoldersEvent {
  final String folderId;
  final String newName;

  const RenameFolderEvent(this.folderId, this.newName);

  @override
  List<Object?> get props => [folderId, newName];
}

class DeleteFolderEvent extends NoteFoldersEvent {
  final String folderId;

  const DeleteFolderEvent(this.folderId);

  @override
  List<Object?> get props => [folderId];
}

class MoveFolderEvent extends NoteFoldersEvent {
  final String folderId;
  final String targetParentId;

  const MoveFolderEvent(this.folderId, this.targetParentId);

  @override
  List<Object?> get props => [folderId, targetParentId];
}

class ReorderFoldersEvent extends NoteFoldersEvent {
  final List<NoteFolder> reorderedFolders;

  const ReorderFoldersEvent(this.reorderedFolders);

  @override
  List<Object?> get props => [reorderedFolders];
}

class AddNoteToFolderEvent extends NoteFoldersEvent {
  final String noteId;
  final String folderId;

  const AddNoteToFolderEvent(this.noteId, this.folderId);

  @override
  List<Object?> get props => [noteId, folderId];
}

class RemoveNoteFromFolderEvent extends NoteFoldersEvent {
  final String noteId;
  final String folderId;

  const RemoveNoteFromFolderEvent(this.noteId, this.folderId);

  @override
  List<Object?> get props => [noteId, folderId];
}
