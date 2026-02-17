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

/* CONSOLIDATED (SESSION 15 FIX): Event Name Collision Resolution
   PlayAudioEvent was defined in both:
   - MediaBloc.media_event.dart (here) — minimal implementation
   - AudioPlaybackBloc.audio_playback_event.dart — full featured
   
   RESOLUTION: Use AudioPlaybackBloc.PlayAudioEvent for all audio playback.
   This event is now DISABLED in MediaBloc. If needed, use:
   - AudioPlaybackBloc.InitializeAudioEvent(audioPath: path)
   - AudioPlaybackBloc.PlayAudioEvent()
   - AudioPlaybackBloc.PauseAudioEvent()
   
   For voice memo playback from notes:
   1. NoteEditorBloc dispatches AddMediaEvent with audio path
   2. UI creates AudioPlaybackBloc context for that recording
   3. Playback controlled via AudioPlaybackBloc (not MediaBloc)

class PlayAudioEvent extends MediaEvent {
  final String noteId;
  final String mediaId;
  const PlayAudioEvent(this.noteId, this.mediaId);
  @override
  List<Object?> get props => [noteId, mediaId];
}
*/

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
