part of 'voice_command_bloc.dart';

enum VoiceCommandType {
  createNote,
  createTodo,
  startFocus,
  pauseFocus,
  stopFocus,
  startReflection,
  search,
  openSettings,
  other,
}

enum VoiceCommandFeedbackType {
  commandRecognized,
  commandExecuted,
  error,
  listening,
}

abstract class VoiceCommandEvent {
  const VoiceCommandEvent();
}

class StartListeningEvent extends VoiceCommandEvent {
  const StartListeningEvent();
}

class StopListeningEvent extends VoiceCommandEvent {
  const StopListeningEvent();
}

class ProcessVoiceInputEvent extends VoiceCommandEvent {
  final String input;

  const ProcessVoiceInputEvent(this.input);
}

class RecognizeCommandEvent extends VoiceCommandEvent {
  final String input;

  const RecognizeCommandEvent(this.input);
}

class ToggleSoundFeedbackEvent extends VoiceCommandEvent {
  final bool enabled;

  const ToggleSoundFeedbackEvent(this.enabled);
}

class ToggleVibrationFeedbackEvent extends VoiceCommandEvent {
  final bool enabled;

  const ToggleVibrationFeedbackEvent(this.enabled);
}

class PlayFeedbackEvent extends VoiceCommandEvent {
  final VoiceCommandFeedbackType type;

  const PlayFeedbackEvent(this.type);
}
