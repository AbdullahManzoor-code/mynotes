import 'package:uuid/uuid.dart';

/// Reflection Database Layer
/// Handles all SQLite operations for reflection questions and answers
class ReflectionDatabase {
  static const String questionsTable = 'reflection_questions';
  static const String answersTable = 'reflection_answers';

  // Column names for questions table
  static const String columnId = 'id';
  static const String columnQuestionText = 'question_text';
  static const String columnCategory = 'category';
  static const String columnIsUserCreated = 'is_user_created';
  static const String columnFrequency = 'frequency';
  static const String columnCreatedAt = 'created_at';

  // Column names for answers table
  static const String columnQuestionId = 'question_id';
  static const String columnAnswerText = 'answer_text';
  static const String columnMood = 'mood';
  static const String columnDraft = 'draft';

  // Preset questions as JSON maps for database insertion
  static final List<Map<String, dynamic>> presetQuestions = [
    // Life & Purpose (3 questions)
    {
      columnId: 'q1',
      columnQuestionText: 'What is the main goal of my life right now?',
      columnCategory: 'life',
      columnIsUserCreated: 0,
      columnFrequency: 'weekly',
      columnCreatedAt: DateTime.now().toIso8601String(),
    },
    {
      columnId: 'q2',
      columnQuestionText: 'Why am I doing what I am doing?',
      columnCategory: 'life',
      columnIsUserCreated: 0,
      columnFrequency: 'weekly',
      columnCreatedAt: DateTime.now().toIso8601String(),
    },
    {
      columnId: 'q3',
      columnQuestionText: 'What kind of person do I want to become?',
      columnCategory: 'life',
      columnIsUserCreated: 0,
      columnFrequency: 'monthly',
      columnCreatedAt: DateTime.now().toIso8601String(),
    },

    // Daily Reflection (3 questions)
    {
      columnId: 'q4',
      columnQuestionText: 'What did I do well today?',
      columnCategory: 'daily',
      columnIsUserCreated: 0,
      columnFrequency: 'daily',
      columnCreatedAt: DateTime.now().toIso8601String(),
    },
    {
      columnId: 'q5',
      columnQuestionText: 'What could I improve tomorrow?',
      columnCategory: 'daily',
      columnIsUserCreated: 0,
      columnFrequency: 'daily',
      columnCreatedAt: DateTime.now().toIso8601String(),
    },
    {
      columnId: 'q6',
      columnQuestionText: 'What drained my energy today?',
      columnCategory: 'daily',
      columnIsUserCreated: 0,
      columnFrequency: 'daily',
      columnCreatedAt: DateTime.now().toIso8601String(),
    },

    // Career & Study (3 questions)
    {
      columnId: 'q7',
      columnQuestionText: 'Am I learning the right skills?',
      columnCategory: 'career',
      columnIsUserCreated: 0,
      columnFrequency: 'weekly',
      columnCreatedAt: DateTime.now().toIso8601String(),
    },
    {
      columnId: 'q8',
      columnQuestionText: 'What is blocking my progress?',
      columnCategory: 'career',
      columnIsUserCreated: 0,
      columnFrequency: 'weekly',
      columnCreatedAt: DateTime.now().toIso8601String(),
    },
    {
      columnId: 'q9',
      columnQuestionText: 'What small step can I take today?',
      columnCategory: 'career',
      columnIsUserCreated: 0,
      columnFrequency: 'daily',
      columnCreatedAt: DateTime.now().toIso8601String(),
    },

    // Mental Health (3 questions)
    {
      columnId: 'q10',
      columnQuestionText: 'What am I feeling right now?',
      columnCategory: 'mental_health',
      columnIsUserCreated: 0,
      columnFrequency: 'daily',
      columnCreatedAt: DateTime.now().toIso8601String(),
    },
    {
      columnId: 'q11',
      columnQuestionText: 'What am I worried about?',
      columnCategory: 'mental_health',
      columnIsUserCreated: 0,
      columnFrequency: 'weekly',
      columnCreatedAt: DateTime.now().toIso8601String(),
    },
    {
      columnId: 'q12',
      columnQuestionText: 'What helped me feel calm today?',
      columnCategory: 'mental_health',
      columnIsUserCreated: 0,
      columnFrequency: 'daily',
      columnCreatedAt: DateTime.now().toIso8601String(),
    },
  ];

  static String generateId() => const Uuid().v4();
}
