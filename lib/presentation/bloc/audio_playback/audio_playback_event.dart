import 'package:equatable/equatable.dart';

abstract class AudioPlaybackEvent extends Equatable {
  const AudioPlaybackEvent();

  @override
  List<Object?> get props => [];
}

class InitializeAudioEvent extends AudioPlaybackEvent {
  final String audioPath;
  final Duration? initialDuration;

  const InitializeAudioEvent({required this.audioPath, this.initialDuration});

  @override
  List<Object?> get props => [audioPath, initialDuration];
}

class PlayAudioEvent extends AudioPlaybackEvent {
  const PlayAudioEvent();
}

class PauseAudioEvent extends AudioPlaybackEvent {
  const PauseAudioEvent();
}

class UpdatePositionEvent extends AudioPlaybackEvent {
  final Duration position;

  const UpdatePositionEvent(this.position);

  @override
  List<Object?> get props => [position];
}

class UpdateDurationEvent extends AudioPlaybackEvent {
  final Duration duration;

  const UpdateDurationEvent(this.duration);

  @override
  List<Object?> get props => [duration];
}

class AudioCompleteEvent extends AudioPlaybackEvent {
  const AudioCompleteEvent();
}

class StopAudioEvent extends AudioPlaybackEvent {
  const StopAudioEvent();
}

class DisposeAudioEvent extends AudioPlaybackEvent {
  const DisposeAudioEvent();
}
