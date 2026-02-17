import 'package:equatable/equatable.dart';

class AudioPlaybackState extends Equatable {
  final String audioPath;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final String? error;
  final bool isInitialized;

  const AudioPlaybackState({
    required this.audioPath,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.error,
    this.isInitialized = false,
  });

  AudioPlaybackState copyWith({
    String? audioPath,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    String? error,
    bool? isInitialized,
  }) {
    return AudioPlaybackState(
      audioPath: audioPath ?? this.audioPath,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      error: error,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  List<Object?> get props => [
    audioPath,
    isPlaying,
    position,
    duration,
    error,
    isInitialized,
  ];
}

class AudioPlaybackInitial extends AudioPlaybackState {
  const AudioPlaybackInitial({required super.audioPath});
}

class AudioPlaybackReady extends AudioPlaybackState {
  const AudioPlaybackReady({required super.audioPath, required super.duration})
    : super(isInitialized: true);
}

class AudioPlaybackLoading extends AudioPlaybackState {
  const AudioPlaybackLoading({required super.audioPath});
}

class AudioPlaybackPlaying extends AudioPlaybackState {
  const AudioPlaybackPlaying({
    required super.audioPath,
    required super.duration,
    required super.position,
  }) : super(isPlaying: true, isInitialized: true);
}

class AudioPlaybackPaused extends AudioPlaybackState {
  const AudioPlaybackPaused({
    required super.audioPath,
    required super.duration,
    required super.position,
  }) : super(isPlaying: false, isInitialized: true);
}

class AudioPlaybackCompleted extends AudioPlaybackState {
  const AudioPlaybackCompleted({
    required super.audioPath,
    required super.duration,
  }) : super(isPlaying: false, position: duration, isInitialized: true);
}

class AudioPlaybackError extends AudioPlaybackState {
  const AudioPlaybackError({
    required super.audioPath,
    required String super.error,
  });
}
