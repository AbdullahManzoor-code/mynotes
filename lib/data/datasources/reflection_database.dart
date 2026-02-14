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
    // Life & Purpose (12 questions)
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
    {
      'prompt': 'What values are most important to me?',
      'category': 'life',
      'frequency': 'monthly',
    },
    {
      'prompt': 'Am I living according to my values?',
      'category': 'life',
      'frequency': 'weekly',
    },
    {
      'prompt': 'What legacy do I want to leave?',
      'category': 'life',
      'frequency': 'monthly',
    },
    {
      'prompt': 'What brings me the most joy?',
      'category': 'life',
      'frequency': 'weekly',
    },
    {
      'prompt': 'What am I grateful for today?',
      'category': 'life',
      'frequency': 'daily',
    },
    {
      'prompt': 'Where do I want to be in 5 years?',
      'category': 'life',
      'frequency': 'monthly',
    },
    {
      'prompt': 'What is holding me back from my dreams?',
      'category': 'life',
      'frequency': 'weekly',
    },
    {
      'prompt': 'How can I serve others better?',
      'category': 'life',
      'frequency': 'weekly',
    },
    {
      'prompt': 'What would my ideal day look like?',
      'category': 'life',
      'frequency': 'monthly',
    },

    // Daily Reflection (15 questions)
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
    {
      'prompt': 'What energized me today?',
      'category': 'daily',
      'frequency': 'daily',
    },
    {
      'prompt': 'Did I accomplish my main goal today?',
      'category': 'daily',
      'frequency': 'daily',
    },
    {
      'prompt': 'What surprised me today?',
      'category': 'daily',
      'frequency': 'daily',
    },
    {
      'prompt': 'Who made a positive impact on my day?',
      'category': 'daily',
      'frequency': 'daily',
    },
    {
      'prompt': 'What did I learn today?',
      'category': 'daily',
      'frequency': 'daily',
    },
    {
      'prompt': 'What am I looking forward to tomorrow?',
      'category': 'daily',
      'frequency': 'daily',
    },
    {
      'prompt': 'How did I treat others today?',
      'category': 'daily',
      'frequency': 'daily',
    },
    {
      'prompt': 'What was the highlight of my day?',
      'category': 'daily',
      'frequency': 'daily',
    },
    {
      'prompt': 'Did I take care of my health today?',
      'category': 'daily',
      'frequency': 'daily',
    },
    {
      'prompt': 'What would make tomorrow better?',
      'category': 'daily',
      'frequency': 'daily',
    },
    {
      'prompt': 'How did I spend my free time?',
      'category': 'daily',
      'frequency': 'daily',
    },
    {
      'prompt': 'What am I proud of today?',
      'category': 'daily',
      'frequency': 'daily',
    },

    // Career & Study (13 questions)
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
    {
      'prompt': 'Am I building expertise in my field?',
      'category': 'career',
      'frequency': 'monthly',
    },
    {
      'prompt': 'What challenges did I overcome at work?',
      'category': 'career',
      'frequency': 'weekly',
    },
    {
      'prompt': 'How can I improve my performance?',
      'category': 'career',
      'frequency': 'weekly',
    },
    {
      'prompt': 'What projects excite me most?',
      'category': 'career',
      'frequency': 'monthly',
    },
    {
      'prompt': 'Am I satisfied with my career growth?',
      'category': 'career',
      'frequency': 'monthly',
    },
    {
      'prompt': 'What would my dream job look like?',
      'category': 'career',
      'frequency': 'monthly',
    },
    {
      'prompt': 'How can I add more value to my team?',
      'category': 'career',
      'frequency': 'weekly',
    },
    {
      'prompt': 'What skills do I need to develop?',
      'category': 'career',
      'frequency': 'monthly',
    },
    {
      'prompt': 'Did I make meaningful progress today?',
      'category': 'career',
      'frequency': 'daily',
    },
    {
      'prompt': 'What did I learn from my mistakes?',
      'category': 'career',
      'frequency': 'weekly',
    },

    // Mental Health & Wellness (14 questions)
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
    {
      'prompt': 'How is my mental health?',
      'category': 'mental_health',
      'frequency': 'weekly',
    },
    {
      'prompt': 'What self-care did I practice today?',
      'category': 'mental_health',
      'frequency': 'daily',
    },
    {
      'prompt': 'Am I taking care of my emotional needs?',
      'category': 'mental_health',
      'frequency': 'weekly',
    },
    {
      'prompt': 'What triggered my stress today?',
      'category': 'mental_health',
      'frequency': 'daily',
    },
    {
      'prompt': 'How can I manage stress better?',
      'category': 'mental_health',
      'frequency': 'weekly',
    },
    {
      'prompt': 'What brings me peace?',
      'category': 'mental_health',
      'frequency': 'weekly',
    },
    {
      'prompt': 'Am I being kind to myself?',
      'category': 'mental_health',
      'frequency': 'daily',
    },
    {
      'prompt': 'What boundaries do I need to set?',
      'category': 'mental_health',
      'frequency': 'weekly',
    },
    {
      'prompt': 'How did I handle difficult emotions?',
      'category': 'mental_health',
      'frequency': 'weekly',
    },
    {
      'prompt': 'What am I avoiding?',
      'category': 'mental_health',
      'frequency': 'weekly',
    },
    {
      'prompt': 'What small act of self-compassion can I do?',
      'category': 'mental_health',
      'frequency': 'daily',
    },

    // Gratitude & Positivity (Additional)
    {
      'prompt': 'What are three small things that brought you joy today?',
      'category': 'gratitude',
      'frequency': 'daily',
    },
    {
      'prompt': 'Who is someone you\'re thankful for, and why?',
      'category': 'gratitude',
      'frequency': 'weekly',
    },
    {
      'prompt':
          'What is a comfort in your life that you often take for granted?',
      'category': 'gratitude',
      'frequency': 'monthly',
    },
    {
      'prompt': 'What beautiful thing did you see today?',
      'category': 'gratitude',
      'frequency': 'daily',
    },

    // Mindfulness & Presence (Additional)
    {
      'prompt': 'How would you describe your current energy level?',
      'category': 'mindfulness',
      'frequency': 'daily',
    },
    {
      'prompt': 'What is a thought that has been repeating in your mind today?',
      'category': 'mindfulness',
      'frequency': 'daily',
    },
    {
      'prompt': 'What does "peace" look like to you right now?',
      'category': 'mindfulness',
      'frequency': 'weekly',
    },
    {
      'prompt': 'What can you hear right now if you listen closely?',
      'category': 'mindfulness',
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
