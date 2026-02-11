import 'package:equatable/equatable.dart';

class VoiceSettingsParams extends Equatable {
  final String currentLocale;
  final double minConfidence;
  final int timeout;
  final bool autoPunctuation;
  final bool autoCapitalize;
  final bool commandsEnabled;
  final bool hapticsEnabled;
  final bool soundFeedback;
  final bool batteryOptimization;
  final bool isLoading;

  const VoiceSettingsParams({
    this.currentLocale = 'en_US',
    this.minConfidence = 0.5,
    this.timeout = 30,
    this.autoPunctuation = true,
    this.autoCapitalize = true,
    this.commandsEnabled = true,
    this.hapticsEnabled = true,
    this.soundFeedback = false,
    this.batteryOptimization = false,
    this.isLoading = true,
  });

  VoiceSettingsParams copyWith({
    String? currentLocale,
    double? minConfidence,
    int? timeout,
    bool? autoPunctuation,
    bool? autoCapitalize,
    bool? commandsEnabled,
    bool? hapticsEnabled,
    bool? soundFeedback,
    bool? batteryOptimization,
    bool? isLoading,
  }) {
    return VoiceSettingsParams(
      currentLocale: currentLocale ?? this.currentLocale,
      minConfidence: minConfidence ?? this.minConfidence,
      timeout: timeout ?? this.timeout,
      autoPunctuation: autoPunctuation ?? this.autoPunctuation,
      autoCapitalize: autoCapitalize ?? this.autoCapitalize,
      commandsEnabled: commandsEnabled ?? this.commandsEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundFeedback: soundFeedback ?? this.soundFeedback,
      batteryOptimization: batteryOptimization ?? this.batteryOptimization,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    currentLocale,
    minConfidence,
    timeout,
    autoPunctuation,
    autoCapitalize,
    commandsEnabled,
    hapticsEnabled,
    soundFeedback,
    batteryOptimization,
    isLoading,
  ];
}
