import 'package:equatable/equatable.dart';

abstract class VideoPlaybackEvent extends Equatable {
  const VideoPlaybackEvent();

  @override
  List<Object?> get props => [];
}

class InitializeVideoEvent extends VideoPlaybackEvent {
  final String filePath;

  const InitializeVideoEvent(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class PlayVideoEvent extends VideoPlaybackEvent {
  const PlayVideoEvent();
}

class PauseVideoEvent extends VideoPlaybackEvent {
  const PauseVideoEvent();
}

class StopVideoEvent extends VideoPlaybackEvent {
  const StopVideoEvent();
}

class DisposeVideoEvent extends VideoPlaybackEvent {
  const DisposeVideoEvent();
}

class VideoErrorEvent extends VideoPlaybackEvent {
  final String error;

  const VideoErrorEvent(this.error);

  @override
  List<Object?> get props => [error];
}

class FullScreenToggleEvent extends VideoPlaybackEvent {
  final bool isFullScreen;

  const FullScreenToggleEvent(this.isFullScreen);

  @override
  List<Object?> get props => [isFullScreen];
}
