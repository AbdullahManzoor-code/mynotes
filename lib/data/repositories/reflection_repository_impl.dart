import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../data/datasources/reflection_database.dart';
import '../../data/models/reflection_question_model.dart';
import '../../data/models/reflection_answer_model.dart';
import '../../domain/entities/reflection_question.dart';
import '../../domain/entities/reflection_answer.dart';
import '../../domain/repositories/reflection_repository.dart';

class ReflectionRepositoryImpl implements ReflectionRepository {
  static Database? _database;
  static final ReflectionRepositoryImpl _instance =
      ReflectionRepositoryImpl._internal();

  ReflectionRepositoryImpl._internal();

  factory ReflectionRepositoryImpl() {
    return _instance;
  }

  Future<Database> get _db async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'reflection.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create questions table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ${ReflectionDatabase.questionsTable} (
            ${ReflectionDatabase.columnId} TEXT PRIMARY KEY,
            ${ReflectionDatabase.columnQuestionText} TEXT NOT NULL,
            ${ReflectionDatabase.columnCategory} TEXT NOT NULL,
            ${ReflectionDatabase.columnIsUserCreated} INTEGER NOT NULL DEFAULT 0,
            ${ReflectionDatabase.columnFrequency} TEXT NOT NULL DEFAULT 'daily',
            ${ReflectionDatabase.columnCreatedAt} TEXT NOT NULL
          )
        ''');

        // Create answers table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ${ReflectionDatabase.answersTable} (
            ${ReflectionDatabase.columnId} TEXT PRIMARY KEY,
            ${ReflectionDatabase.columnQuestionId} TEXT NOT NULL,
            ${ReflectionDatabase.columnAnswerText} TEXT NOT NULL,
            ${ReflectionDatabase.columnMood} TEXT,
            ${ReflectionDatabase.columnCreatedAt} TEXT NOT NULL,
            ${ReflectionDatabase.columnDraft} TEXT,
            FOREIGN KEY(${ReflectionDatabase.columnQuestionId}) REFERENCES ${ReflectionDatabase.questionsTable}(${ReflectionDatabase.columnId})
          )
        ''');

        // Insert preset questions
        for (var question in ReflectionDatabase.presetQuestions) {
          await db.insert(
            ReflectionDatabase.questionsTable,
            question,
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      },
    );
  }

  @override
  Future<List<ReflectionQuestion>> getAllQuestions() async {
    try {
      final db = await _db;
      final result = await db.query(ReflectionDatabase.questionsTable);
      return result
          .map((json) => ReflectionQuestionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load questions: $e');
    }
  }

  @override
  Future<List<ReflectionQuestion>> getQuestionsByCategory(
    String category,
  ) async {
    try {
      final db = await _db;
      final result = await db.query(
        ReflectionDatabase.questionsTable,
        where: 'category = ?',
        whereArgs: [category],
      );
      return result
          .map((json) => ReflectionQuestionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load questions by category: $e');
    }
  }

  @override
  Future<ReflectionQuestion?> getQuestionById(String id) async {
    try {
      final db = await _db;
      final result = await db.query(
        ReflectionDatabase.questionsTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isEmpty) return null;
      return ReflectionQuestionModel.fromJson(result.first);
    } catch (e) {
      throw Exception('Failed to load question: $e');
    }
  }

  @override
  Future<void> addQuestion(ReflectionQuestion question) async {
    try {
      final db = await _db;
      final model = ReflectionQuestionModel.fromEntity(question);
      await db.insert(ReflectionDatabase.questionsTable, model.toJson());
    } catch (e) {
      throw Exception('Failed to add question: $e');
    }
  }

  @override
  Future<void> updateQuestion(ReflectionQuestion question) async {
    try {
      final db = await _db;
      final model = ReflectionQuestionModel.fromEntity(question);
      await db.update(
        ReflectionDatabase.questionsTable,
        model.toJson(),
        where: 'id = ?',
        whereArgs: [question.id],
      );
    } catch (e) {
      throw Exception('Failed to update question: $e');
    }
  }

  @override
  Future<void> deleteQuestion(String questionId) async {
    try {
      final db = await _db;
      // Delete all answers for this question
      await db.delete(
        ReflectionDatabase.answersTable,
        where: 'questionId = ?',
        whereArgs: [questionId],
      );
      // Delete question
      await db.delete(
        ReflectionDatabase.questionsTable,
        where: 'id = ?',
        whereArgs: [questionId],
      );
    } catch (e) {
      throw Exception('Failed to delete question: $e');
    }
  }

  @override
  Future<List<ReflectionAnswer>> getAnswersByQuestion(String questionId) async {
    try {
      final db = await _db;
      final result = await db.query(
        ReflectionDatabase.answersTable,
        where: 'questionId = ?',
        whereArgs: [questionId],
        orderBy: 'createdAt DESC',
      );
      return result
          .map((json) => ReflectionAnswerModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load answers: $e');
    }
  }

  @override
  Future<List<ReflectionAnswer>> getAllAnswers() async {
    try {
      final db = await _db;
      final result = await db.query(
        ReflectionDatabase.answersTable,
        orderBy: 'createdAt DESC',
      );
      return result
          .map((json) => ReflectionAnswerModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load all answers: $e');
    }
  }

  @override
  Future<void> saveAnswer(ReflectionAnswer answer) async {
    try {
      final db = await _db;
      final model = ReflectionAnswerModel.fromEntity(answer);
      await db.insert(ReflectionDatabase.answersTable, model.toJson());
      // Clear draft after saving
      await deleteDraft(answer.questionId);
    } catch (e) {
      throw Exception('Failed to save answer: $e');
    }
  }

  @override
  Future<void> saveDraft(String questionId, String draftText) async {
    try {
      final db = await _db;
      final draftId = 'draft_$questionId';
      final now = DateTime.now();

      // Check if draft exists
      final existing = await db.query(
        ReflectionDatabase.answersTable,
        where: 'id = ?',
        whereArgs: [draftId],
      );

      if (existing.isNotEmpty) {
        // Update existing draft
        await db.update(
          ReflectionDatabase.answersTable,
          {'draft': draftText, 'createdAt': now.toIso8601String()},
          where: 'id = ?',
          whereArgs: [draftId],
        );
      } else {
        // Create new draft
        final draft = ReflectionAnswerModel(
          id: draftId,
          questionId: questionId,
          answerText: '',
          draft: draftText,
          createdAt: now,
        );
        await db.insert(ReflectionDatabase.answersTable, draft.toJson());
      }
    } catch (e) {
      throw Exception('Failed to save draft: $e');
    }
  }

  @override
  Future<String?> getDraft(String questionId) async {
    try {
      final db = await _db;
      final draftId = 'draft_$questionId';
      final result = await db.query(
        ReflectionDatabase.answersTable,
        where: 'id = ?',
        whereArgs: [draftId],
      );
      if (result.isEmpty) return null;
      return result.first['draft'] as String?;
    } catch (e) {
      throw Exception('Failed to load draft: $e');
    }
  }

  @override
  Future<void> deleteDraft(String questionId) async {
    try {
      final db = await _db;
      final draftId = 'draft_$questionId';
      await db.delete(
        ReflectionDatabase.answersTable,
        where: 'id = ?',
        whereArgs: [draftId],
      );
    } catch (e) {
      throw Exception('Failed to delete draft: $e');
    }
  }

  @override
  Future<List<String>> getAvailableCategories() async {
    return ['life', 'daily', 'career', 'mental_health'];
  }

  @override
  Future<int> getAnswerCountForToday() async {
    try {
      final db = await _db;
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${ReflectionDatabase.answersTable} '
        'WHERE createdAt >= ? AND createdAt < ? AND draft IS NULL',
        [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      );

      return result.isNotEmpty ? result.first['count'] as int? ?? 0 : 0;
    } catch (e) {
      throw Exception('Failed to get answer count: $e');
    }
  }
}
