import 'package:equatable/equatable.dart';

abstract class MediaEvent extends Equatable {
  const MediaEvent();
  @override
  List<Object?> get props => [];
}

class AddImageToNoteEvent extends MediaEvent {
  final String noteId;
  final String imagePath;
  const AddImageToNoteEvent(this.noteId, this.imagePath);
  @override
  List<Object?> get props => [noteId, imagePath];
}

class RemoveImageFromNoteEvent extends MediaEvent {
  final String noteId;
  final String mediaId;
  const RemoveImageFromNoteEvent(this.noteId, this.mediaId);
  @override
  List<Object?> get props => [noteId, mediaId];
}

class StartAudioRecordingEvent extends MediaEvent {
  final String noteId;
  const StartAudioRecordingEvent(this.noteId);
  @override
  List<Object?> get props => [noteId];
}

class StopAudioRecordingEvent extends MediaEvent {
  final String noteId;
  const StopAudioRecordingEvent(this.noteId);
  @override
  List<Object?> get props => [noteId];
}

class PlayAudioEvent extends MediaEvent {
  final String noteId;
  final String mediaId;
  const PlayAudioEvent(this.noteId, this.mediaId);
  @override
  List<Object?> get props => [noteId, mediaId];
}

class AddVideoToNoteEvent extends MediaEvent {
  final String noteId;
  final String videoPath;
  const AddVideoToNoteEvent(this.noteId, this.videoPath);
  @override
  List<Object?> get props => [noteId, videoPath];
}

class RemoveVideoFromNoteEvent extends MediaEvent {
  final String noteId;
  final String mediaId;
  const RemoveVideoFromNoteEvent(this.noteId, this.mediaId);
  @override
  List<Object?> get props => [noteId, mediaId];
}

class CompressImageEvent extends MediaEvent {
  final String noteId;
  final String mediaId;
  const CompressImageEvent(this.noteId, this.mediaId);
  @override
  List<Object?> get props => [noteId, mediaId];
}

class CompressVideoEvent extends MediaEvent {
  final String noteId;
  final String mediaId;
  const CompressVideoEvent(this.noteId, this.mediaId);
  @override
  List<Object?> get props => [noteId, mediaId];
}

