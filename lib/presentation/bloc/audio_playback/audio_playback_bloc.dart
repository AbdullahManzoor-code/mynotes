import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

import 'audio_playback_event.dart';
import 'audio_playback_state.dart';

class AudioPlaybackBloc extends Bloc<AudioPlaybackEvent, AudioPlaybackState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _completeSubscription;

  AudioPlaybackBloc() : super(const AudioPlaybackInitial(audioPath: '')) {
    on<InitializeAudioEvent>(_onInitializeAudio);
    on<PlayAudioEvent>(_onPlayAudio);
    on<PauseAudioEvent>(_onPauseAudio);
    on<UpdatePositionEvent>(_onUpdatePosition);
    on<UpdateDurationEvent>(_onUpdateDuration);
    on<AudioCompleteEvent>(_onAudioComplete);
    on<StopAudioEvent>(_onStopAudio);
    on<DisposeAudioEvent>(_onDisposeAudio);
  }

  Future<void> _onInitializeAudio(
    InitializeAudioEvent event,
    Emitter<AudioPlaybackState> emit,
  ) async {
    try {
      emit(AudioPlaybackLoading(audioPath: event.audioPath));

      // Check if file exists
      final file = File(event.audioPath);
      if (!await file.exists()) {
        emit(
          AudioPlaybackError(
            audioPath: event.audioPath,
            error: 'Audio file not found',
          ),
        );
        return;
      }

      // Setup listeners
      _setupAudioListeners(event.audioPath, emit);

      // Emit ready state
      emit(
        AudioPlaybackReady(
          audioPath: event.audioPath,
          duration: event.initialDuration ?? Duration.zero,
        ),
      );
    } catch (e) {
      emit(AudioPlaybackError(audioPath: event.audioPath, error: e.toString()));
    }
  }

  void _setupAudioListeners(
    String audioPath,
    Emitter<AudioPlaybackState> emit,
  ) {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _completeSubscription?.cancel();

    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      add(UpdatePositionEvent(position));
    });

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      add(UpdateDurationEvent(duration));
    });

    _completeSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      add(const AudioCompleteEvent());
    });
  }

  Future<void> _onPlayAudio(
    PlayAudioEvent event,
    Emitter<AudioPlaybackState> emit,
  ) async {
    try {
      if (state is! AudioPlaybackReady &&
          state is! AudioPlaybackPaused &&
          state is! AudioPlaybackCompleted) {
        return;
      }

      await _audioPlayer.play(DeviceFileSource(state.audioPath));

      emit(
        AudioPlaybackPlaying(
          audioPath: state.audioPath,
          duration: state.duration,
          position: state.position,
        ),
      );
    } catch (e) {
      emit(AudioPlaybackError(audioPath: state.audioPath, error: e.toString()));
    }
  }

  Future<void> _onPauseAudio(
    PauseAudioEvent event,
    Emitter<AudioPlaybackState> emit,
  ) async {
    try {
      if (state is! AudioPlaybackPlaying) return;

      await _audioPlayer.pause();

      emit(
        AudioPlaybackPaused(
          audioPath: state.audioPath,
          duration: state.duration,
          position: state.position,
        ),
      );
    } catch (e) {
      emit(AudioPlaybackError(audioPath: state.audioPath, error: e.toString()));
    }
  }

  void _onUpdatePosition(
    UpdatePositionEvent event,
    Emitter<AudioPlaybackState> emit,
  ) {
    if (state is AudioPlaybackPlaying) {
      emit(
        AudioPlaybackPlaying(
          audioPath: state.audioPath,
          duration: state.duration,
          position: event.position,
        ),
      );
    }
  }

  void _onUpdateDuration(
    UpdateDurationEvent event,
    Emitter<AudioPlaybackState> emit,
  ) {
    if (state is AudioPlaybackReady || state is AudioPlaybackPlaying) {
      if (state is AudioPlaybackPlaying) {
        emit(
          AudioPlaybackPlaying(
            audioPath: state.audioPath,
            duration: event.duration,
            position: state.position,
          ),
        );
      } else {
        emit(
          AudioPlaybackReady(
            audioPath: state.audioPath,
            duration: event.duration,
          ),
        );
      }
    }
  }

  void _onAudioComplete(
    AudioCompleteEvent event,
    Emitter<AudioPlaybackState> emit,
  ) {
    emit(
      AudioPlaybackCompleted(
        audioPath: state.audioPath,
        duration: state.duration,
      ),
    );
  }

  Future<void> _onStopAudio(
    StopAudioEvent event,
    Emitter<AudioPlaybackState> emit,
  ) async {
    try {
      await _audioPlayer.stop();
      emit(
        AudioPlaybackReady(
          audioPath: state.audioPath,
          duration: state.duration,
        ),
      );
    } catch (e) {
      emit(AudioPlaybackError(audioPath: state.audioPath, error: e.toString()));
    }
  }

  Future<void> _onDisposeAudio(
    DisposeAudioEvent event,
    Emitter<AudioPlaybackState> emit,
  ) async {
    try {
      await _audioPlayer.dispose();
      _positionSubscription?.cancel();
      _durationSubscription?.cancel();
      _completeSubscription?.cancel();
    } catch (e) {
      // Ignore errors during disposal
    }
  }

  @override
  Future<void> close() {
    add(const DisposeAudioEvent());
    return super.close();
  }
}
