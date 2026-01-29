import 'package:equatable/equatable.dart';

/// Reminder Suggestion from AI model
class ReminderSuggestion extends Equatable {
  final String id;
  final String title;
  final String suggestedTime;
  final double confidence; // 0.0 to 1.0
  final String frequency;
  final String reason;

  const ReminderSuggestion({
    required this.id,
    required this.title,
    required this.suggestedTime,
    required this.confidence,
    required this.frequency,
    required this.reason,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    suggestedTime,
    confidence,
    frequency,
    reason,
  ];

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'suggestedTime': suggestedTime,
    'confidence': confidence,
    'frequency': frequency,
    'reason': reason,
  };

  /// Create from JSON
  factory ReminderSuggestion.fromJson(Map<String, dynamic> json) {
    return ReminderSuggestion(
      id: json['id'] as String,
      title: json['title'] as String,
      suggestedTime: json['suggestedTime'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      frequency: json['frequency'] as String,
      reason: json['reason'] as String,
    );
  }
}

/// Detected Pattern in user behavior
class ReminderPattern extends Equatable {
  final String id;
  final String title;
  final String time;
  final String frequency;
  final int completed;
  final int total;
  final double completionRate;

  const ReminderPattern({
    required this.id,
    required this.title,
    required this.time,
    required this.frequency,
    required this.completed,
    required this.total,
    required this.completionRate,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    time,
    frequency,
    completed,
    total,
    completionRate,
  ];

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'time': time,
    'frequency': frequency,
    'completed': completed,
    'total': total,
    'completionRate': completionRate,
  };

  /// Create from JSON
  factory ReminderPattern.fromJson(Map<String, dynamic> json) {
    return ReminderPattern(
      id: json['id'] as String,
      title: json['title'] as String,
      time: json['time'] as String,
      frequency: json['frequency'] as String,
      completed: json['completed'] as int,
      total: json['total'] as int,
      completionRate: (json['completionRate'] as num).toDouble(),
    );
  }
}
