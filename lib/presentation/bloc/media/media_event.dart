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

class CapturePhotoEvent extends MediaEvent {
  final String noteId;
  const CapturePhotoEvent(this.noteId);
  @override
  List<Object?> get props => [noteId];
}

class PickPhotoFromGalleryEvent extends MediaEvent {
  final String noteId;
  const PickPhotoFromGalleryEvent(this.noteId);
  @override
  List<Object?> get props => [noteId];
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
  final String fileName;
  const StartAudioRecordingEvent(this.noteId, [this.fileName = 'recording']);
  @override
  List<Object?> get props => [noteId, fileName];
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

class CaptureVideoEvent extends MediaEvent {
  final String noteId;
  const CaptureVideoEvent(this.noteId);
  @override
  List<Object?> get props => [noteId];
}

class PickVideoFromGalleryEvent extends MediaEvent {
  final String noteId;
  const PickVideoFromGalleryEvent(this.noteId);
  @override
  List<Object?> get props => [noteId];
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

class ScanDocumentEvent extends MediaEvent {
  final String noteId;
  final String documentTitle;
  const ScanDocumentEvent(this.noteId, this.documentTitle);
  @override
  List<Object?> get props => [noteId, documentTitle];
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

class LoadMediaEvent extends MediaEvent {
  const LoadMediaEvent();
  @override
  List<Object?> get props => [];
}

class FilterMediaEvent extends MediaEvent {
  final String? type;
  final String? searchQuery;
  const FilterMediaEvent({this.type, this.searchQuery});
  @override
  List<Object?> get props => [type, searchQuery];
}
