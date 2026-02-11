import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/services/speech_settings_service.dart';
import '../../core/services/language_service.dart';
import '../../core/services/audio_feedback_service.dart';
import 'params/voice_settings_params.dart';

// Events
abstract class VoiceSettingsEvent extends Equatable {
  const VoiceSettingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadVoiceSettingsEvent extends VoiceSettingsEvent {}

class UpdateLocaleEvent extends VoiceSettingsEvent {
  final String locale;
  const UpdateLocaleEvent(this.locale);
  @override
  List<Object?> get props => [locale];
}

class UpdateConfidenceEvent extends VoiceSettingsEvent {
  final double confidence;
  const UpdateConfidenceEvent(this.confidence);
  @override
  List<Object?> get props => [confidence];
}

class UpdateTimeoutEvent extends VoiceSettingsEvent {
  final int timeout;
  const UpdateTimeoutEvent(this.timeout);
  @override
  List<Object?> get props => [timeout];
}

class ToggleAutoPunctuationEvent extends VoiceSettingsEvent {
  final bool enabled;
  const ToggleAutoPunctuationEvent(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class ToggleAutoCapitalizeEvent extends VoiceSettingsEvent {
  final bool enabled;
  const ToggleAutoCapitalizeEvent(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class ToggleCommandsEvent extends VoiceSettingsEvent {
  final bool enabled;
  const ToggleCommandsEvent(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class ToggleHapticsEvent extends VoiceSettingsEvent {
  final bool enabled;
  const ToggleHapticsEvent(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class ToggleSoundFeedbackEvent extends VoiceSettingsEvent {
  final bool enabled;
  const ToggleSoundFeedbackEvent(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class ToggleBatteryOptimizationEvent extends VoiceSettingsEvent {
  final bool enabled;
  const ToggleBatteryOptimizationEvent(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class ResetVoiceSettingsEvent extends VoiceSettingsEvent {}

// States
abstract class VoiceSettingsState extends Equatable {
  final VoiceSettingsParams params;
  const VoiceSettingsState(this.params);
  @override
  List<Object?> get props => [params];
}

class VoiceSettingsInitial extends VoiceSettingsState {
  const VoiceSettingsInitial() : super(const VoiceSettingsParams());
}

class VoiceSettingsLoaded extends VoiceSettingsState {
  const VoiceSettingsLoaded(super.params);
}

// BLoC
class VoiceSettingsBloc extends Bloc<VoiceSettingsEvent, VoiceSettingsState> {
  final SpeechSettingsService _settingsService = SpeechSettingsService();
  final LanguageService _languageService = LanguageService();
  final AudioFeedbackService _feedbackService = AudioFeedbackService();

  VoiceSettingsBloc() : super(const VoiceSettingsInitial()) {
    on<LoadVoiceSettingsEvent>(_onLoadVoiceSettings);
    on<UpdateLocaleEvent>(_onUpdateLocale);
    on<UpdateConfidenceEvent>(_onUpdateConfidence);
    on<UpdateTimeoutEvent>(_onUpdateTimeout);
    on<ToggleAutoPunctuationEvent>(_onToggleAutoPunctuation);
    on<ToggleAutoCapitalizeEvent>(_onToggleAutoCapitalize);
    on<ToggleCommandsEvent>(_onToggleCommands);
    on<ToggleHapticsEvent>(_onToggleHaptics);
    on<ToggleSoundFeedbackEvent>(_onToggleSoundFeedback);
    on<ToggleBatteryOptimizationEvent>(_onToggleBatteryOptimization);
    on<ResetVoiceSettingsEvent>(_onResetVoiceSettings);
  }

  Future<void> _onLoadVoiceSettings(
    LoadVoiceSettingsEvent event,
    Emitter<VoiceSettingsState> emit,
  ) async {
    emit(VoiceSettingsLoaded(state.params.copyWith(isLoading: true)));

    final currentLocale = await _languageService.getSavedLanguage();
    final minConfidence = await _settingsService.getMinConfidence();
    final timeout = await _settingsService.getTimeout();
    final autoPunctuation = await _settingsService.getAutoPunctuation();
    final autoCapitalize = await _settingsService.getAutoCapitalize();
    final commandsEnabled = await _settingsService.getCommandsEnabled();
    final hapticsEnabled = await _settingsService.getHapticsEnabled();
    final soundFeedback = await _settingsService.getSoundFeedback();
    final batteryOptimization = await _settingsService.getBatteryOptimization();

    _feedbackService.setHapticsEnabled(hapticsEnabled);
    _feedbackService.setSoundEnabled(soundFeedback);

    emit(
      VoiceSettingsLoaded(
        VoiceSettingsParams(
          currentLocale: currentLocale,
          minConfidence: minConfidence,
          timeout: timeout,
          autoPunctuation: autoPunctuation,
          autoCapitalize: autoCapitalize,
          commandsEnabled: commandsEnabled,
          hapticsEnabled: hapticsEnabled,
          soundFeedback: soundFeedback,
          batteryOptimization: batteryOptimization,
          isLoading: false,
        ),
      ),
    );
  }

  Future<void> _onUpdateLocale(
    UpdateLocaleEvent event,
    Emitter<VoiceSettingsState> emit,
  ) async {
    await _languageService.saveLanguage(event.locale);
    emit(
      VoiceSettingsLoaded(state.params.copyWith(currentLocale: event.locale)),
    );
  }

  Future<void> _onUpdateConfidence(
    UpdateConfidenceEvent event,
    Emitter<VoiceSettingsState> emit,
  ) async {
    await _settingsService.setMinConfidence(event.confidence);
    emit(
      VoiceSettingsLoaded(
        state.params.copyWith(minConfidence: event.confidence),
      ),
    );
  }

  Future<void> _onUpdateTimeout(
    UpdateTimeoutEvent event,
    Emitter<VoiceSettingsState> emit,
  ) async {
    await _settingsService.setTimeout(event.timeout);
    emit(VoiceSettingsLoaded(state.params.copyWith(timeout: event.timeout)));
  }

  Future<void> _onToggleAutoPunctuation(
    ToggleAutoPunctuationEvent event,
    Emitter<VoiceSettingsState> emit,
  ) async {
    await _settingsService.setAutoPunctuation(event.enabled);
    emit(
      VoiceSettingsLoaded(
        state.params.copyWith(autoPunctuation: event.enabled),
      ),
    );
  }

  Future<void> _onToggleAutoCapitalize(
    ToggleAutoCapitalizeEvent event,
    Emitter<VoiceSettingsState> emit,
  ) async {
    await _settingsService.setAutoCapitalize(event.enabled);
    emit(
      VoiceSettingsLoaded(state.params.copyWith(autoCapitalize: event.enabled)),
    );
  }

  Future<void> _onToggleCommands(
    ToggleCommandsEvent event,
    Emitter<VoiceSettingsState> emit,
  ) async {
    await _settingsService.setCommandsEnabled(event.enabled);
    emit(
      VoiceSettingsLoaded(
        state.params.copyWith(commandsEnabled: event.enabled),
      ),
    );
  }

  Future<void> _onToggleHaptics(
    ToggleHapticsEvent event,
    Emitter<VoiceSettingsState> emit,
  ) async {
    await _settingsService.setHapticsEnabled(event.enabled);
    _feedbackService.setHapticsEnabled(event.enabled);
    emit(
      VoiceSettingsLoaded(state.params.copyWith(hapticsEnabled: event.enabled)),
    );
  }

  Future<void> _onToggleSoundFeedback(
    ToggleSoundFeedbackEvent event,
    Emitter<VoiceSettingsState> emit,
  ) async {
    await _settingsService.setSoundFeedback(event.enabled);
    _feedbackService.setSoundEnabled(event.enabled);
    emit(
      VoiceSettingsLoaded(state.params.copyWith(soundFeedback: event.enabled)),
    );
  }

  Future<void> _onToggleBatteryOptimization(
    ToggleBatteryOptimizationEvent event,
    Emitter<VoiceSettingsState> emit,
  ) async {
    await _settingsService.setBatteryOptimization(event.enabled);
    emit(
      VoiceSettingsLoaded(
        state.params.copyWith(batteryOptimization: event.enabled),
      ),
    );
  }

  Future<void> _onResetVoiceSettings(
    ResetVoiceSettingsEvent event,
    Emitter<VoiceSettingsState> emit,
  ) async {
    await _settingsService.resetToDefaults();
    add(LoadVoiceSettingsEvent());
  }
}
