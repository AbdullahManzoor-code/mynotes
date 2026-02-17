part of 'video_trimming_bloc.dart';

class VideoTrimmingState extends Equatable {
  final String videoPath;
  final int totalDurationMs;
  final int startPositionMs;
  final int endPositionMs;
  final int currentPositionMs;
  final bool isPlaying;
  final bool isTrimmed;
  final String? errorMessage;

  const VideoTrimmingState({
    this.videoPath = '',
    this.totalDurationMs = 0,
    this.startPositionMs = 0,
    this.endPositionMs = 0,
    this.currentPositionMs = 0,
    this.isPlaying = false,
    this.isTrimmed = false,
    this.errorMessage,
  });

  VideoTrimmingState copyWith({
    String? videoPath,
    int? totalDurationMs,
    int? startPositionMs,
    int? endPositionMs,
    int? currentPositionMs,
    bool? isPlaying,
    bool? isTrimmed,
    String? errorMessage,
  }) {
    return VideoTrimmingState(
      videoPath: videoPath ?? this.videoPath,
      totalDurationMs: totalDurationMs ?? this.totalDurationMs,
      startPositionMs: startPositionMs ?? this.startPositionMs,
      endPositionMs: endPositionMs ?? this.endPositionMs,
      currentPositionMs: currentPositionMs ?? this.currentPositionMs,
      isPlaying: isPlaying ?? this.isPlaying,
      isTrimmed: isTrimmed ?? this.isTrimmed,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    videoPath,
    totalDurationMs,
    startPositionMs,
    endPositionMs,
    currentPositionMs,
    isPlaying,
    isTrimmed,
    errorMessage,
  ];
}

class VideoTrimmingInitial extends VideoTrimmingState {
  const VideoTrimmingInitial();
}

class VideoTrimmingReady extends VideoTrimmingState {
  const VideoTrimmingReady({
    required super.videoPath,
    required super.totalDurationMs,
  });
}

class VideoTrimmingInProgress extends VideoTrimmingState {
  const VideoTrimmingInProgress({
    required super.videoPath,
    required super.totalDurationMs,
    required super.startPositionMs,
    required super.endPositionMs,
    required super.currentPositionMs,
    required super.isPlaying,
  });
}

class VideoTrimmingSuccess extends VideoTrimmingState {
  const VideoTrimmingSuccess({
    required super.videoPath,
    required super.totalDurationMs,
    required super.startPositionMs,
    required super.endPositionMs,
  }) : super(isTrimmed: true);
}

class VideoTrimmingError extends VideoTrimmingState {
  const VideoTrimmingError({required String message})
    : super(errorMessage: message);
}
