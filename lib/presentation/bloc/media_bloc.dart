import 'package:flutter_bloc/flutter_bloc.dart';
import 'media_event.dart';
import 'media_state.dart';
import '../../domain/repositories/media_repository.dart';
import '../../domain/entities/media_item.dart';

class MediaBloc extends Bloc<MediaEvent, MediaState> {
  final MediaRepository repository;

  MediaBloc({required this.repository}) : super(MediaInitial()) {
    on<AddImageToNoteEvent>(_onAddImageToNote);
    on<RemoveImageFromNoteEvent>(_onRemoveImageFromNote);
    on<StartAudioRecordingEvent>(_onStartAudioRecording);
    on<StopAudioRecordingEvent>(_onStopAudioRecording);
    on<PlayAudioEvent>(_onPlayAudio);
    on<AddVideoToNoteEvent>(_onAddVideoToNote);
    on<RemoveVideoFromNoteEvent>(_onRemoveVideoFromNote);
    on<CompressImageEvent>(_onCompressImage);
    on<CompressVideoEvent>(_onCompressVideo);
  }

  Future<void> _onAddImageToNote(AddImageToNoteEvent event, Emitter<MediaState> emit) async {
    try {
      emit(MediaLoading(event.noteId));
      final media = await repository.addImageToNote(event.noteId, event.imagePath);
      emit(MediaAdded(event.noteId, media));
    } catch (e) {
      emit(MediaError(event.noteId, e.toString()));
    }
  }

  Future<void> _onAddVideoToNote(AddVideoToNoteEvent event, Emitter<MediaState> emit) async {
    try {
      emit(MediaLoading(event.noteId));
      final media = await repository.addVideoToNote(event.noteId, event.videoPath);
      emit(MediaAdded(event.noteId, media));
    } catch (e) {
      emit(MediaError(event.noteId, e.toString()));
    }
  }

  Future<void> _onRemoveImageFromNote(RemoveImageFromNoteEvent event, Emitter<MediaState> emit) async {
    try {
      emit(MediaLoading(event.noteId));
      await repository.removeMediaFromNote(event.noteId, event.mediaId);
      emit(MediaRemoved(event.noteId, event.mediaId));
    } catch (e) {
      emit(MediaError(event.noteId, e.toString()));
    }
  }

  Future<void> _onRemoveVideoFromNote(RemoveVideoFromNoteEvent event, Emitter<MediaState> emit) async {
    try {
      emit(MediaLoading(event.noteId));
      await repository.removeMediaFromNote(event.noteId, event.mediaId);
      emit(MediaRemoved(event.noteId, event.mediaId));
    } catch (e) {
      emit(MediaError(event.noteId, e.toString()));
    }
  }

  Future<void> _onStartAudioRecording(StartAudioRecordingEvent event, Emitter<MediaState> emit) async {
    try {
      emit(AudioRecordingState(event.noteId, true));
      await repository.startAudioRecording(event.noteId);
    } catch (e) {
      emit(MediaError(event.noteId, e.toString()));
    }
  }

  Future<void> _onStopAudioRecording(StopAudioRecordingEvent event, Emitter<MediaState> emit) async {
    try {
      await repository.stopAudioRecording(event.noteId);
      emit(AudioRecordingState(event.noteId, false));
    } catch (e) {
      emit(MediaError(event.noteId, e.toString()));
    }
  }

  Future<void> _onPlayAudio(PlayAudioEvent event, Emitter<MediaState> emit) async {
    try {
      emit(AudioPlayingState(event.noteId, event.mediaId, true));
      await repository.playMedia(event.noteId, event.mediaId);
      emit(AudioPlayingState(event.noteId, event.mediaId, false));
    } catch (e) {
      emit(MediaError(event.noteId, e.toString()));
    }
  }

  Future<void> _onCompressImage(CompressImageEvent event, Emitter<MediaState> emit) async {
    try {
      emit(MediaLoading(event.noteId));
      // In a real app, you'd fetch the media first; here we just simulate
      final dummy = MediaItem(id: event.mediaId, type: MediaType.image, filePath: '');
      final compressed = await repository.compressMedia(dummy);
      emit(MediaCompressed(event.noteId, event.mediaId, compressed.filePath));
    } catch (e) {
      emit(MediaError(event.noteId, e.toString()));
    }
  }

  Future<void> _onCompressVideo(CompressVideoEvent event, Emitter<MediaState> emit) async {
    try {
      emit(MediaLoading(event.noteId));
      final dummy = MediaItem(id: event.mediaId, type: MediaType.video, filePath: '');
      final compressed = await repository.compressMedia(dummy);
      emit(MediaCompressed(event.noteId, event.mediaId, compressed.filePath));
    } catch (e) {
      emit(MediaError(event.noteId, e.toString()));
    }
  }
}
