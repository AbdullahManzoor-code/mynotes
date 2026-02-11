import 'package:equatable/equatable.dart';

class SmartRemindersParams extends Equatable {
  final List<Map<String, dynamic>> suggestions;
  final List<Map<String, dynamic>> patterns;
  final List<Map<String, dynamic>> reminders;
  final String selectedPeriod;
  final int acceptedCount;
  final double averageCompletionRate;
  final Map<String, bool> learningSettings;
  final bool isLoading;
  final String? errorMessage;

  const SmartRemindersParams({
    this.suggestions = const [],
    this.patterns = const [],
    this.reminders = const [],
    this.selectedPeriod = 'week',
    this.acceptedCount = 0,
    this.averageCompletionRate = 0.0,
    this.learningSettings = const {
      'note_content_analysis': true,
      'time_based_patterns': true,
      'location_context': false,
      'urgency_detection': true,
    },
    this.isLoading = false,
    this.errorMessage,
  });

  SmartRemindersParams copyWith({
    List<Map<String, dynamic>>? suggestions,
    List<Map<String, dynamic>>? patterns,
    List<Map<String, dynamic>>? reminders,
    String? selectedPeriod,
    int? acceptedCount,
    double? averageCompletionRate,
    Map<String, bool>? learningSettings,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SmartRemindersParams(
      suggestions: suggestions ?? this.suggestions,
      patterns: patterns ?? this.patterns,
      reminders: reminders ?? this.reminders,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      acceptedCount: acceptedCount ?? this.acceptedCount,
      averageCompletionRate:
          averageCompletionRate ?? this.averageCompletionRate,
      learningSettings: learningSettings ?? this.learningSettings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    suggestions,
    patterns,
    reminders,
    selectedPeriod,
    acceptedCount,
    averageCompletionRate,
    learningSettings,
    isLoading,
    errorMessage,
  ];
}
