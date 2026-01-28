import 'package:equatable/equatable.dart';

/// Mood Entry for Reflection/Ask Yourself feature
enum MoodType {
  veryHappy,
  happy,
  neutral,
  sad,
  verySad,
  excited,
  stressed,
  calm,
  anxious,
  grateful;

  String get emoji {
    switch (this) {
      case MoodType.veryHappy:
        return '😄';
      case MoodType.happy:
        return '🙂';
      case MoodType.neutral:
        return '😐';
      case MoodType.sad:
        return '😔';
      case MoodType.verySad:
        return '😢';
      case MoodType.excited:
        return '🤩';
      case MoodType.stressed:
        return '😰';
      case MoodType.calm:
        return '😌';
      case MoodType.anxious:
        return '😟';
      case MoodType.grateful:
        return '🙏';
    }
  }

  String get displayName {
    switch (this) {
      case MoodType.veryHappy:
        return 'Very Happy';
      case MoodType.happy:
        return 'Happy';
      case MoodType.neutral:
        return 'Neutral';
      case MoodType.sad:
        return 'Sad';
      case MoodType.verySad:
        return 'Very Sad';
      case MoodType.excited:
        return 'Excited';
      case MoodType.stressed:
        return 'Stressed';
      case MoodType.calm:
        return 'Calm';
      case MoodType.anxious:
        return 'Anxious';
      case MoodType.grateful:
        return 'Grateful';
    }
  }

  int get value {
    switch (this) {
      case MoodType.veryHappy:
        return 5;
      case MoodType.happy:
        return 4;
      case MoodType.neutral:
        return 3;
      case MoodType.sad:
        return 2;
      case MoodType.verySad:
        return 1;
      case MoodType.excited:
        return 5;
      case MoodType.stressed:
        return 2;
      case MoodType.calm:
        return 4;
      case MoodType.anxious:
        return 2;
      case MoodType.grateful:
        return 5;
    }
  }
}

/// Mood Entry Entity
class MoodEntry extends Equatable {
  final String id;
  final MoodType mood;
  final String? note;
  final List<String> tags;
  final DateTime timestamp;
  final int? energyLevel; // 1-5
  final int? sleepQuality; // 1-5
  final List<String>? activities;

  const MoodEntry({
    required this.id,
    required this.mood,
    this.note,
    this.tags = const [],
    required this.timestamp,
    this.energyLevel,
    this.sleepQuality,
    this.activities,
  });

  @override
  List<Object?> get props => [
    id,
    mood,
    note,
    tags,
    timestamp,
    energyLevel,
    sleepQuality,
    activities,
  ];

  MoodEntry copyWith({
    String? id,
    MoodType? mood,
    String? note,
    List<String>? tags,
    DateTime? timestamp,
    int? energyLevel,
    int? sleepQuality,
    List<String>? activities,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      timestamp: timestamp ?? this.timestamp,
      energyLevel: energyLevel ?? this.energyLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      activities: activities ?? this.activities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mood': mood.name,
      'note': note,
      'tags': tags,
      'timestamp': timestamp.toIso8601String(),
      'energyLevel': energyLevel,
      'sleepQuality': sleepQuality,
      'activities': activities,
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as String,
      mood: MoodType.values.firstWhere(
        (e) => e.name == json['mood'],
        orElse: () => MoodType.neutral,
      ),
      note: json['note'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      timestamp: DateTime.parse(json['timestamp'] as String),
      energyLevel: json['energyLevel'] as int?,
      sleepQuality: json['sleepQuality'] as int?,
      activities: (json['activities'] as List<dynamic>?)?.cast<String>(),
    );
  }
}

