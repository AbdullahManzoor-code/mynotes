import 'package:equatable/equatable.dart';
import '../../domain/entities/media_item.dart';

abstract class MediaState extends Equatable {
  const MediaState();
  @override
  List<Object?> get props => [];
}

class MediaInitial extends MediaState {}

class MediaLoading extends MediaState {
  final String noteId;
  const MediaLoading(this.noteId);
  @override
  List<Object?> get props => [noteId];
}

class MediaCompressing extends MediaState {
  final String noteId;
  final String mediaId;
  const MediaCompressing(this.noteId, this.mediaId);
  @override
  List<Object?> get props => [noteId, mediaId];
}

class MediaCompressed extends MediaState {
  final String noteId;
  final String mediaId;
  final String compressedPath;
  const MediaCompressed(this.noteId, this.mediaId, this.compressedPath);
  @override
  List<Object?> get props => [noteId, mediaId, compressedPath];
}

class MediaAdded extends MediaState {
  final String noteId;
  final MediaItem media;
  const MediaAdded(this.noteId, this.media);
  @override
  List<Object?> get props => [noteId, media];
}

class MediaRemoved extends MediaState {
  final String noteId;
  final String mediaId;
  const MediaRemoved(this.noteId, this.mediaId);
  @override
  List<Object?> get props => [noteId, mediaId];
}

class MediaError extends MediaState {
  final String noteId;
  final String message;
  const MediaError(this.noteId, this.message);
  @override
  List<Object?> get props => [noteId, message];
}

// Audio states
class AudioRecordingState extends MediaState {
  final String noteId;
  final bool isRecording;
  const AudioRecordingState(this.noteId, this.isRecording);
  @override
  List<Object?> get props => [noteId, isRecording];
}

class AudioPlayingState extends MediaState {
  final String noteId;
  final String mediaId;
  final bool isPlaying;
  const AudioPlayingState(this.noteId, this.mediaId, this.isPlaying);
  @override
  List<Object?> get props => [noteId, mediaId, isPlaying];
}
