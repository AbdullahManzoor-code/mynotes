part of 'note_folders_bloc.dart';

abstract class NoteFoldersState extends Equatable {
  const NoteFoldersState();

  @override
  List<Object?> get props => [];
}

class NoteFoldersInitial extends NoteFoldersState {
  const NoteFoldersInitial();
}

class NoteFoldersLoading extends NoteFoldersState {
  const NoteFoldersLoading();
}

class FoldersLoaded extends NoteFoldersState {
  final List<NoteFolder> folders;

  const FoldersLoaded(this.folders);

  @override
  List<Object?> get props => [folders];
}

class FoldersError extends NoteFoldersState {
  final String message;

  const FoldersError(this.message);

  @override
  List<Object?> get props => [message];
}
