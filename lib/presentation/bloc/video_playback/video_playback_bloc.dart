import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'video_playback_event.dart';
import 'video_playback_state.dart';

class VideoPlaybackBloc extends Bloc<VideoPlaybackEvent, VideoPlaybackState> {
  VideoPlaybackBloc() : super(const VideoPlaybackInitial(filePath: '')) {
    on<InitializeVideoEvent>(_onInitializeVideo);
    on<PlayVideoEvent>(_onPlayVideo);
    on<PauseVideoEvent>(_onPauseVideo);
    on<StopVideoEvent>(_onStopVideo);
    on<DisposeVideoEvent>(_onDisposeVideo);
    on<VideoErrorEvent>(_onVideoError);
    on<FullScreenToggleEvent>(_onFullScreenToggle);
  }

  Future<void> _onInitializeVideo(
    InitializeVideoEvent event,
    Emitter<VideoPlaybackState> emit,
  ) async {
    try {
      emit(VideoPlaybackLoading(filePath: event.filePath));

      // Check if file exists
      final file = File(event.filePath);
      if (!await file.exists()) {
        emit(
          VideoPlaybackError(
            filePath: event.filePath,
            error: 'Video file not found',
          ),
        );
        return;
      }

      emit(VideoPlaybackReady(filePath: event.filePath));
    } catch (e) {
      emit(VideoPlaybackError(filePath: event.filePath, error: e.toString()));
    }
  }

  Future<void> _onPlayVideo(
    PlayVideoEvent event,
    Emitter<VideoPlaybackState> emit,
  ) async {
    try {
      if (state is VideoPlaybackReady || state is VideoPlaybackPaused) {
        emit(
          VideoPlaybackPlaying(
            filePath: state.filePath,
            isFullScreen: state.isFullScreen,
          ),
        );
      }
    } catch (e) {
      emit(VideoPlaybackError(filePath: state.filePath, error: e.toString()));
    }
  }

  Future<void> _onPauseVideo(
    PauseVideoEvent event,
    Emitter<VideoPlaybackState> emit,
  ) async {
    try {
      if (state is VideoPlaybackPlaying) {
        emit(
          VideoPlaybackPaused(
            filePath: state.filePath,
            isFullScreen: state.isFullScreen,
          ),
        );
      }
    } catch (e) {
      emit(VideoPlaybackError(filePath: state.filePath, error: e.toString()));
    }
  }

  Future<void> _onStopVideo(
    StopVideoEvent event,
    Emitter<VideoPlaybackState> emit,
  ) async {
    try {
      emit(
        VideoPlaybackReady(
          filePath: state.filePath,
          isFullScreen: state.isFullScreen,
        ),
      );
    } catch (e) {
      emit(VideoPlaybackError(filePath: state.filePath, error: e.toString()));
    }
  }

  Future<void> _onDisposeVideo(
    DisposeVideoEvent event,
    Emitter<VideoPlaybackState> emit,
  ) async {
    // Cleanup resources if needed
  }

  void _onVideoError(VideoErrorEvent event, Emitter<VideoPlaybackState> emit) {
    emit(VideoPlaybackError(filePath: state.filePath, error: event.error));
  }

  Future<void> _onFullScreenToggle(
    FullScreenToggleEvent event,
    Emitter<VideoPlaybackState> emit,
  ) async {
    emit(
      VideoPlaybackFullScreen(
        filePath: state.filePath,
        isFullScreen: event.isFullScreen,
      ),
    );
  }
}
