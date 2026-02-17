part of 'video_editor_bloc.dart';

abstract class VideoEditorEvent extends Equatable {
  const VideoEditorEvent();

  @override
  List<Object?> get props => [];
}

class InitializeVideoEditorEvent extends VideoEditorEvent {
  final String filePath;

  const InitializeVideoEditorEvent({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

class VideoEditorReadyEvent extends VideoEditorEvent {
  const VideoEditorReadyEvent();
}

class ExportVideoEvent extends VideoEditorEvent {
  final String filePath;

  const ExportVideoEvent({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}
