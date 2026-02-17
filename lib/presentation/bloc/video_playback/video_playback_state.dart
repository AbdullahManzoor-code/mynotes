import 'package:equatable/equatable.dart';

class VideoPlaybackState extends Equatable {
  final String filePath;
  final bool isInitialized;
  final bool isPlaying;
  final bool isFullScreen;
  final String? error;

  const VideoPlaybackState({
    required this.filePath,
    this.isInitialized = false,
    this.isPlaying = false,
    this.isFullScreen = false,
    this.error,
  });

  VideoPlaybackState copyWith({
    String? filePath,
    bool? isInitialized,
    bool? isPlaying,
    bool? isFullScreen,
    String? error,
  }) {
    return VideoPlaybackState(
      filePath: filePath ?? this.filePath,
      isInitialized: isInitialized ?? this.isInitialized,
      isPlaying: isPlaying ?? this.isPlaying,
      isFullScreen: isFullScreen ?? this.isFullScreen,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    filePath,
    isInitialized,
    isPlaying,
    isFullScreen,
    error,
  ];
}

class VideoPlaybackInitial extends VideoPlaybackState {
  const VideoPlaybackInitial({required super.filePath});
}

class VideoPlaybackLoading extends VideoPlaybackState {
  const VideoPlaybackLoading({required super.filePath});
}

class VideoPlaybackReady extends VideoPlaybackState {
  const VideoPlaybackReady({required super.filePath, super.isFullScreen})
    : super(isInitialized: true);
}

class VideoPlaybackPlaying extends VideoPlaybackState {
  const VideoPlaybackPlaying({required super.filePath, super.isFullScreen})
    : super(isInitialized: true, isPlaying: true);
}

class VideoPlaybackPaused extends VideoPlaybackState {
  const VideoPlaybackPaused({required super.filePath, super.isFullScreen})
    : super(isInitialized: true, isPlaying: false);
}

class VideoPlaybackError extends VideoPlaybackState {
  const VideoPlaybackError({
    required super.filePath,
    required String super.error,
  });
}

class VideoPlaybackFullScreen extends VideoPlaybackState {
  const VideoPlaybackFullScreen({
    required super.filePath,
    required super.isFullScreen,
  }) : super(isInitialized: true);
}
