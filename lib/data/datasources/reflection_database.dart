import 'package:uuid/uuid.dart';

/// Reflection Database Layer
/// Handles all SQLite operations for reflection notes
class ReflectionDatabase {
  static const String reflectionNotesTable = 'reflection_notes';

  // Column names for reflection_notes table
  static const String columnId = 'id';
  static const String columnPrompt = 'prompt';
  static const String columnAnswer = 'answer';
  static const String columnCategory = 'category';
  static const String columnIsCustomPrompt = 'is_custom_prompt';
  static const String columnMood = 'mood';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  static const String columnIsDraft = 'is_draft';

  // Preset prompts as a list (not inserted into DB, used for daily rotation)
  static final List<Map<String, String>> presetPrompts = [
    // Life & Purpose
    {
      'prompt': 'What is the main goal of my life right now?',
      'category': 'life',
      'frequency': 'weekly',
    },
    {
      'prompt': 'Why am I doing what I am doing?',
      'category': 'life',
      'frequency': 'weekly',
    },
    {
      'prompt': 'What kind of person do I want to become?',
      'category': 'life',
      'frequency': 'monthly',
    },

    // Daily Reflection
    {
      'prompt': 'What did I do well today?',
      'category': 'daily',
      'frequency': 'daily',
    },
    {
      'prompt': 'What could I improve tomorrow?',
      'category': 'daily',
      'frequency': 'daily',
    },
    {
      'prompt': 'What drained my energy today?',
      'category': 'daily',
      'frequency': 'daily',
    },

    // Career & Study
    {
      'prompt': 'Am I learning the right skills?',
      'category': 'career',
      'frequency': 'weekly',
    },
    {
      'prompt': 'What is blocking my progress?',
      'category': 'career',
      'frequency': 'weekly',
    },
    {
      'prompt': 'What small step can I take today?',
      'category': 'career',
      'frequency': 'daily',
    },

    // Mental Health
    {
      'prompt': 'What am I feeling right now?',
      'category': 'mental_health',
      'frequency': 'daily',
    },
    {
      'prompt': 'What am I worried about?',
      'category': 'mental_health',
      'frequency': 'weekly',
    },
    {
      'prompt': 'What helped me feel calm today?',
      'category': 'mental_health',
      'frequency': 'daily',
    },
  ];

  static String generateId() => const Uuid().v4();

  /// Get a daily rotating prompt based on current date
  static Map<String, String> getDailyPrompt() {
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year, 1, 1))
        .inDays;
    final index = dayOfYear % presetPrompts.length;
    return presetPrompts[index];
  }
}
