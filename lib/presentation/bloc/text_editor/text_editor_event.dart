part of 'text_editor_bloc.dart';

abstract class TextEditorEvent extends Equatable {
  const TextEditorEvent();

  @override
  List<Object?> get props => [];
}

class LoadFileContentEvent extends TextEditorEvent {
  final String filePath;

  const LoadFileContentEvent(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class UpdateContentEvent extends TextEditorEvent {
  final String content;

  const UpdateContentEvent(this.content);

  @override
  List<Object?> get props => [content];
}

class SaveFileEvent extends TextEditorEvent {
  final String filePath;
  final String content;

  const SaveFileEvent({required this.filePath, required this.content});

  @override
  List<Object?> get props => [filePath, content];
}

class ClearEditorEvent extends TextEditorEvent {
  const ClearEditorEvent();
}
