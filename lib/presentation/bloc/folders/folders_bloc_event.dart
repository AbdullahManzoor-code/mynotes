part of 'folders_bloc.dart';

abstract class FoldersBlocEvent extends Equatable {
  const FoldersBlocEvent();

  @override
  List<Object?> get props => [];
}

class LoadFoldersEvent extends FoldersBlocEvent {
  const LoadFoldersEvent();
}

class CreateFolderEvent extends FoldersBlocEvent {
  final String folderName;
  final String? parentId;

  const CreateFolderEvent(this.folderName, {this.parentId});

  @override
  List<Object?> get props => [folderName, parentId];
}

class RenameFolderEvent extends FoldersBlocEvent {
  final String folderId;
  final String newName;

  const RenameFolderEvent(this.folderId, this.newName);

  @override
  List<Object?> get props => [folderId, newName];
}

class DeleteFolderEvent extends FoldersBlocEvent {
  final String folderId;

  const DeleteFolderEvent(this.folderId);

  @override
  List<Object?> get props => [folderId];
}

class MoveFolderEvent extends FoldersBlocEvent {
  final String folderId;
  final String? newParentId;

  const MoveFolderEvent(this.folderId, this.newParentId);

  @override
  List<Object?> get props => [folderId, newParentId];
}

class ReorderFoldersEvent extends FoldersBlocEvent {
  final List<String> folderIds;

  const ReorderFoldersEvent(this.folderIds);

  @override
  List<Object?> get props => [folderIds];
}
