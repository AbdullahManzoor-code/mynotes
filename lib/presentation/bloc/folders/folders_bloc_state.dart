part of 'folders_bloc.dart';

abstract class FoldersBlocState extends Equatable {
  const FoldersBlocState();

  @override
  List<Object?> get props => [];
}

class FoldersBlocInitial extends FoldersBlocState {
  const FoldersBlocInitial();
}

class FoldersBlocLoading extends FoldersBlocState {
  const FoldersBlocLoading();
}

class FoldersLoaded extends FoldersBlocState {
  final List<FolderItem> folders;

  const FoldersLoaded({required this.folders});

  @override
  List<Object?> get props => [folders];
}

class FolderCreated extends FoldersBlocState {
  final FolderItem folder;

  const FolderCreated({required this.folder});

  @override
  List<Object?> get props => [folder];
}

class FolderRenamed extends FoldersBlocState {
  final String folderId;
  final String newName;

  const FolderRenamed({required this.folderId, required this.newName});

  @override
  List<Object?> get props => [folderId, newName];
}

class FolderDeleted extends FoldersBlocState {
  final String folderId;

  const FolderDeleted({required this.folderId});

  @override
  List<Object?> get props => [folderId];
}

class FolderMoved extends FoldersBlocState {
  final String folderId;
  final String? newParentId;

  const FolderMoved({required this.folderId, required this.newParentId});

  @override
  List<Object?> get props => [folderId, newParentId];
}

class FoldersReordered extends FoldersBlocState {
  final List<String> folderIds;

  const FoldersReordered({required this.folderIds});

  @override
  List<Object?> get props => [folderIds];
}

class FoldersBlocError extends FoldersBlocState {
  final String message;

  const FoldersBlocError(this.message);

  @override
  List<Object?> get props => [message];
}
