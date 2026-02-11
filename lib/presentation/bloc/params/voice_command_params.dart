import 'package:equatable/equatable.dart';

/// Complete Param Model for Voice Command Operations
/// 📦 Container for all voice command-related data
class VoiceCommandParams extends Equatable {
  final String commandText;
  final String commandType; // create_note, create_todo, set_reminder, etc.
  final Map<String, dynamic> extractedData;
  final double confidence;
  final DateTime? executedAt;
  final bool requiresConfirmation;

  const VoiceCommandParams({
    required this.commandText,
    this.commandType = 'unknown',
    this.extractedData = const {},
    this.confidence = 1.0,
    this.executedAt,
    this.requiresConfirmation = false,
  });

  VoiceCommandParams copyWith({
    String? commandText,
    String? commandType,
    Map<String, dynamic>? extractedData,
    double? confidence,
    DateTime? executedAt,
    bool? requiresConfirmation,
  }) {
    return VoiceCommandParams(
      commandText: commandText ?? this.commandText,
      commandType: commandType ?? this.commandType,
      extractedData: extractedData ?? this.extractedData,
      confidence: confidence ?? this.confidence,
      executedAt: executedAt ?? this.executedAt,
      requiresConfirmation: requiresConfirmation ?? this.requiresConfirmation,
    );
  }

  VoiceCommandParams withData(String key, dynamic value) {
    final data = Map<String, dynamic>.from(extractedData);
    data[key] = value;
    return copyWith(extractedData: data);
  }

  @override
  List<Object?> get props => [
    commandText,
    commandType,
    extractedData,
    confidence,
    executedAt,
    requiresConfirmation,
  ];
}
