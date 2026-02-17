part of 'video_trimming_bloc.dart';

abstract class VideoTrimmingEvent extends Equatable {
  const VideoTrimmingEvent();

  @override
  List<Object?> get props => [];
}

class InitializeVideoTrimmingEvent extends VideoTrimmingEvent {
  final String videoPath;
  final int durationMs;

  const InitializeVideoTrimmingEvent({
    required this.videoPath,
    required this.durationMs,
  });

  @override
  List<Object?> get props => [videoPath, durationMs];
}

class UpdateStartPositionEvent extends VideoTrimmingEvent {
  final int positionMs;

  const UpdateStartPositionEvent(this.positionMs);

  @override
  List<Object?> get props => [positionMs];
}

class UpdateEndPositionEvent extends VideoTrimmingEvent {
  final int positionMs;

  const UpdateEndPositionEvent(this.positionMs);

  @override
  List<Object?> get props => [positionMs];
}

class UpdateCurrentPositionEvent extends VideoTrimmingEvent {
  final int positionMs;

  const UpdateCurrentPositionEvent(this.positionMs);

  @override
  List<Object?> get props => [positionMs];
}

class TogglePlaybackEvent extends VideoTrimmingEvent {
  const TogglePlaybackEvent();
}

class ApplyTrimmingEvent extends VideoTrimmingEvent {
  const ApplyTrimmingEvent();
}

class CancelTrimmingEvent extends VideoTrimmingEvent {
  const CancelTrimmingEvent();
}
