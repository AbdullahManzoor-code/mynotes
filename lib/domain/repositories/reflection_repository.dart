import '../../domain/entities/reflection_question.dart';
import '../../domain/entities/reflection_answer.dart';

abstract class ReflectionRepository {
  // Question operations
  Future<List<ReflectionQuestion>> getAllQuestions();
  Future<List<ReflectionQuestion>> getQuestionsByCategory(String category);
  Future<ReflectionQuestion?> getQuestionById(String id);
  Future<void> addQuestion(ReflectionQuestion question);
  Future<void> updateQuestion(ReflectionQuestion question);
  Future<void> deleteQuestion(String questionId);

  // Answer operations
  Future<List<ReflectionAnswer>> getAnswersByQuestion(String questionId);
  Future<List<ReflectionAnswer>> getAllAnswers();
  Future<void> saveAnswer(ReflectionAnswer answer);
  Future<void> saveDraft(String questionId, String draftText);
  Future<String?> getDraft(String questionId);
  Future<void> deleteDraft(String questionId);

  // Category operations
  Future<List<String>> getAvailableCategories();
  Future<int> getAnswerCountForToday();

  // Stats & Utility
  Future<int> getStreakCount();
  Future<int> getLongestStreak();
  Future<int> getTotalReflectionsCount();
  Future<ReflectionQuestion?> getRandomQuestion();
  Future<void> pinQuestion(String questionId);
  Future<void> unpinAllQuestions();
}
