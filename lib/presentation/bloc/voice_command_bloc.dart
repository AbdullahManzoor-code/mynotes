import 'package:flutter_bloc/flutter_bloc.dart';

part 'voice_command_event.dart';
part 'voice_command_state.dart';

class VoiceCommandBloc extends Bloc<VoiceCommandEvent, VoiceCommandState> {
  bool _isSoundEnabled = true;
  bool _isVibrationEnabled = true;
  bool _isListening = false;

  VoiceCommandBloc() : super(VoiceCommandInitial()) {
    on<StartListeningEvent>(_onStartListening);
    on<StopListeningEvent>(_onStopListening);
    on<ProcessVoiceInputEvent>(_onProcessVoiceInput);
    on<RecognizeCommandEvent>(_onRecognizeCommand);
    on<ToggleSoundFeedbackEvent>(_onToggleSoundFeedback);
    on<ToggleVibrationFeedbackEvent>(_onToggleVibrationFeedback);
    on<PlayFeedbackEvent>(_onPlayFeedback);
  }

  Future<void> _onStartListening(
    StartListeningEvent event,
    Emitter<VoiceCommandState> emit,
  ) async {
    _isListening = true;
    emit(VoiceCommandListening());
  }

  Future<void> _onStopListening(
    StopListeningEvent event,
    Emitter<VoiceCommandState> emit,
  ) async {
    _isListening = false;
    emit(VoiceCommandInitial());
  }

  Future<void> _onProcessVoiceInput(
    ProcessVoiceInputEvent event,
    Emitter<VoiceCommandState> emit,
  ) async {
    emit(VoiceCommandProcessing());

    try {
      final command = VoiceCommandParser.parseCommand(event.input);
      final content = VoiceCommandParser.extractContent(event.input, command);

      if (_isSoundEnabled) {
        add(PlayFeedbackEvent(VoiceCommandFeedbackType.commandRecognized));
      }

      emit(VoiceCommandRecognized(
        commandType: command,
        extractedContent: content,
      ));
    } catch (e) {
      if (_isSoundEnabled) {
        add(PlayFeedbackEvent(VoiceCommandFeedbackType.error));
      }
      emit(VoiceCommandError('Failed to process voice input'));
    }
  }

  Future<void> _onRecognizeCommand(
    RecognizeCommandEvent event,
    Emitter<VoiceCommandState> emit,
  ) async {
    final command = VoiceCommandParser.parseCommand(event.input);
    emit(VoiceCommandRecognized(
      commandType: command,
      extractedContent: null,
    ));
  }

  Future<void> _onToggleSoundFeedback(
    ToggleSoundFeedbackEvent event,
    Emitter<VoiceCommandState> emit,
  ) async {
    _isSoundEnabled = event.enabled;
    emit(VoiceCommandFeedbackToggled(
      soundEnabled: _isSoundEnabled,
      vibrationEnabled: _isVibrationEnabled,
    ));
  }

  Future<void> _onToggleVibrationFeedback(
    ToggleVibrationFeedbackEvent event,
    Emitter<VoiceCommandState> emit,
  ) async {
    _isVibrationEnabled = event.enabled;
    emit(VoiceCommandFeedbackToggled(
      soundEnabled: _isSoundEnabled,
      vibrationEnabled: _isVibrationEnabled,
    ));
  }

  Future<void> _onPlayFeedback(
    PlayFeedbackEvent event,
    Emitter<VoiceCommandState> emit,
  ) async {
    switch (event.type) {
      case VoiceCommandFeedbackType.commandRecognized:
        // Play 800Hz beep
        break;
      case VoiceCommandFeedbackType.commandExecuted:
        // Play 1000Hz beep
        break;
      case VoiceCommandFeedbackType.error:
        // Play 400Hz beep
        break;
      case VoiceCommandFeedbackType.listening:
        // Play 600Hz beep
        break;
    }
    emit(VoiceCommandFeedbackPlayed(event.type));
  }
}
