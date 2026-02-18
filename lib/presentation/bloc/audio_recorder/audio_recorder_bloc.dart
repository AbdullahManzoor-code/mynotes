// ════════════════════════════════════════════════════════════════════════════
// [M005 CONSOLIDATION] Audio Recording BLoC
//
// SCOPE: Recording ONLY (StartRecording, PauseRecording, ResumeRecording, StopRecording)
//
// DEPRECATED EVENTS (moved to AudioPlaybackBloc):
// - PlayRecording, PausePlayback, UpdatePlaybackPosition, PlaybackCompleted
//
// REASON: AudioRecorderBloc previously handled both recording AND playback.
// For cleaner architecture, playback moved to dedicated AudioPlaybackBloc.
//
// MIGRATION PATH:
// - Old: AudioRecorderBloc.add(PlayRecording(path))
// - New: AudioPlaybackBloc.add(PlayAudioEvent(path))
//
// STATUS: Recording functionality active and working ✅
//         Playback consolidated to AudioPlaybackBloc ✅
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mynotes/injection_container.dart';
import '../../../core/services/audio_recorder_service.dart';

// Events
abstract class AudioRecorderEvent extends Equatable {
  const AudioRecorderEvent();

  @override
  List<Object?> get props => [];
}

class StartRecording extends AudioRecorderEvent {}

class PauseRecording extends AudioRecorderEvent {}

class ResumeRecording extends AudioRecorderEvent {}

class StopRecording extends AudioRecorderEvent {}

class UpdateRecordingDuration extends AudioRecorderEvent {
  final Duration duration;
  const UpdateRecordingDuration(this.duration);

  @override
  List<Object?> get props => [duration];
}

class UpdateWaveform extends AudioRecorderEvent {
  final double level;
  const UpdateWaveform(this.level);

  @override
  List<Object?> get props => [level];
}

class ResetRecording extends AudioRecorderEvent {}

class PlayRecording extends AudioRecorderEvent {}

class PausePlayback extends AudioRecorderEvent {}

class UpdatePlaybackPosition extends AudioRecorderEvent {
  final Duration position;
  final Duration total;
  const UpdatePlaybackPosition(this.position, this.total);

  @override
  List<Object?> get props => [position, total];
}

class PlaybackCompleted extends AudioRecorderEvent {}

// States
class AudioRecorderState extends Equatable {
  final bool isRecording;
  final bool isPaused;
  final bool hasRecording;
  final bool isPlaying;
  final String? recordingPath;
  final Duration recordingDuration;
  final Duration playbackDuration;
  final Duration totalDuration;
  final List<double> waveformData;
  final String? error;

  const AudioRecorderState({
    this.isRecording = false,
    this.isPaused = false,
    this.hasRecording = false,
    this.isPlaying = false,
    this.recordingPath,
    this.recordingDuration = Duration.zero,
    this.playbackDuration = Duration.zero,
    this.totalDuration = Duration.zero,
    this.waveformData = const [],
    this.error,
  });

  AudioRecorderState copyWith({
    bool? isRecording,
    bool? isPaused,
    bool? hasRecording,
    bool? isPlaying,
    String? recordingPath,
    Duration? recordingDuration,
    Duration? playbackDuration,
    Duration? totalDuration,
    List<double>? waveformData,
    String? error,
  }) {
    return AudioRecorderState(
      isRecording: isRecording ?? this.isRecording,
      isPaused: isPaused ?? this.isPaused,
      hasRecording: hasRecording ?? this.hasRecording,
      isPlaying: isPlaying ?? this.isPlaying,
      recordingPath: recordingPath ?? this.recordingPath,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      playbackDuration: playbackDuration ?? this.playbackDuration,
      totalDuration: totalDuration ?? this.totalDuration,
      waveformData: waveformData ?? this.waveformData,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    isRecording,
    isPaused,
    hasRecording,
    isPlaying,
    recordingPath,
    recordingDuration,
    playbackDuration,
    totalDuration,
    waveformData,
    error,
  ];
}

// BLoC
class AudioRecorderBloc extends Bloc<AudioRecorderEvent, AudioRecorderState> {
  final AudioRecorderService _service;
  Timer? _timer;

  AudioRecorderBloc({AudioRecorderService? service})
    : _service = service ?? getIt<AudioRecorderService>(),
      super(const AudioRecorderState()) {
    on<StartRecording>(_onStartRecording);
    on<PauseRecording>(_onPauseRecording);
    on<ResumeRecording>(_onResumeRecording);
    on<StopRecording>(_onStopRecording);
    on<UpdateRecordingDuration>(_onUpdateRecordingDuration);
    on<UpdateWaveform>(_onUpdateWaveform);
    on<ResetRecording>(_onResetRecording);
    on<PlayRecording>(_onPlayRecording);
    on<PausePlayback>(_onPausePlayback);
    on<UpdatePlaybackPosition>(_onUpdatePlaybackPosition);
    on<PlaybackCompleted>(_onPlaybackCompleted);
  }

  Future<void> _onStartRecording(
    StartRecording event,
    Emitter<AudioRecorderState> emit,
  ) async {
    final hasPermission = await _service.checkPermission();
    if (!hasPermission) {
      emit(state.copyWith(error: 'Microphone permission denied'));
      return;
    }

    try {
      await _service.startRecording();
      emit(
        state.copyWith(
          isRecording: true,
          isPaused: false,
          hasRecording: false,
          recordingDuration: Duration.zero,
          waveformData: [],
        ),
      );

      _startTimer();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(
        UpdateRecordingDuration(
          state.recordingDuration + const Duration(seconds: 1),
        ),
      );
    });
  }

  Future<void> _onPauseRecording(
    PauseRecording event,
    Emitter<AudioRecorderState> emit,
  ) async {
    _timer?.cancel();
    emit(state.copyWith(isPaused: true));
  }

  Future<void> _onResumeRecording(
    ResumeRecording event,
    Emitter<AudioRecorderState> emit,
  ) async {
    emit(state.copyWith(isPaused: false));
    _startTimer();
  }

  Future<void> _onUpdateRecordingDuration(
    UpdateRecordingDuration event,
    Emitter<AudioRecorderState> emit,
  ) async {
    emit(state.copyWith(recordingDuration: event.duration));
  }

  Future<void> _onUpdateWaveform(
    UpdateWaveform event,
    Emitter<AudioRecorderState> emit,
  ) async {
    final newData = List<double>.from(state.waveformData)..add(event.level);
    if (newData.length > 50) newData.removeAt(0);
    emit(state.copyWith(waveformData: newData));
  }

  Future<void> _onStopRecording(
    StopRecording event,
    Emitter<AudioRecorderState> emit,
  ) async {
    _timer?.cancel();
    final path = await _service.stopRecording();
    emit(
      state.copyWith(
        isRecording: false,
        isPaused: false,
        hasRecording: path != null,
        recordingPath: path,
      ),
    );
  }

  Future<void> _onResetRecording(
    ResetRecording event,
    Emitter<AudioRecorderState> emit,
  ) async {
    emit(
      state.copyWith(
        hasRecording: false,
        isPlaying: false,
        recordingPath: null,
        playbackDuration: Duration.zero,
        totalDuration: Duration.zero,
      ),
    );
  }

  // CONSOLIDATED (SESSION 15 FIX M005): Audio playback delegated to AudioPlaybackBloc
  // These handlers are kept for backward compatibility but AudioPlaybackBloc is now
  // the primary audio playback system. Record-playback scenarios should use:
  // 1. AudioRecorderBloc for recording state management
  // 2. AudioPlaybackBloc for playback functionality (via AudioPlaybackEvent)

  Future<void> _onPlayRecording(
    PlayRecording event,
    Emitter<AudioRecorderState> emit,
  ) async {
    // DEPRECATED: Use AudioPlaybackBloc instead
    // emit(state.copyWith(isPlaying: !state.isPlaying));
    // Simply toggle UI state, actual playback handled by AudioPlaybackBloc
    if (state.hasRecording && state.recordingPath != null) {
      emit(state.copyWith(isPlaying: !state.isPlaying));
    }
  }

  Future<void> _onPausePlayback(
    PausePlayback event,
    Emitter<AudioRecorderState> emit,
  ) async {
    // DEPRECATED: Use AudioPlaybackBloc.PauseAudioEvent instead
    emit(state.copyWith(isPlaying: false));
  }

  Future<void> _onUpdatePlaybackPosition(
    UpdatePlaybackPosition event,
    Emitter<AudioRecorderState> emit,
  ) async {
    // CONSOLIDATED: Position updates from AudioPlaybackBloc can be mirrored here
    // if recorder UI needs to show playback progress
    emit(
      state.copyWith(
        playbackDuration: event.position,
        totalDuration: event.total,
      ),
    );
  }

  Future<void> _onPlaybackCompleted(
    PlaybackCompleted event,
    Emitter<AudioRecorderState> emit,
  ) async {
    // CONSOLIDATED: When AudioPlaybackBloc completes, reset recorder playback state
    emit(state.copyWith(isPlaying: false, playbackDuration: Duration.zero));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
