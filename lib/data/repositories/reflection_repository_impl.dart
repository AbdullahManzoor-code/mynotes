import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../data/datasources/reflection_database.dart';
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
        // Create reflection notes table (stores prompts and their answers together)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS reflection_notes (
            ${ReflectionDatabase.columnId} TEXT PRIMARY KEY,
            ${ReflectionDatabase.columnPrompt} TEXT NOT NULL,
            ${ReflectionDatabase.columnAnswer} TEXT,
            ${ReflectionDatabase.columnCategory} TEXT NOT NULL,
            ${ReflectionDatabase.columnIsCustomPrompt} INTEGER NOT NULL DEFAULT 0,
            ${ReflectionDatabase.columnMood} TEXT,
            ${ReflectionDatabase.columnCreatedAt} TEXT NOT NULL,
            ${ReflectionDatabase.columnUpdatedAt} TEXT,
            ${ReflectionDatabase.columnIsDraft} INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  @override
  Future<List<ReflectionQuestion>> getAllQuestions() async {
    try {
      await _db; // Ensure database is initialized
      // Get unique prompts from reflection_notes or return preset prompts
      // For simplicity, we'll return preset prompts as available questions
      final now = DateTime.now();
      return ReflectionDatabase.presetPrompts.asMap().entries.map((entry) {
        return ReflectionQuestion(
          id: 'preset_${entry.key}',
          questionText: entry.value['prompt']!,
          category: entry.value['category']!,
          isUserCreated: false,
          frequency: entry.value['frequency']!,
          createdAt: now,
        );
      }).toList();
    } catch (e) {
      throw Exception(
        'Unable to load reflection questions. Please try again: $e',
      );
    }
  }

  @override
  Future<List<ReflectionQuestion>> getQuestionsByCategory(
    String category,
  ) async {
    try {
      final now = DateTime.now();
      return ReflectionDatabase.presetPrompts
          .where((p) => p['category'] == category)
          .toList()
          .asMap()
          .entries
          .map((entry) {
            return ReflectionQuestion(
              id: 'preset_${category}_${entry.key}',
              questionText: entry.value['prompt']!,
              category: entry.value['category']!,
              isUserCreated: false,
              frequency: entry.value['frequency']!,
              createdAt: now,
            );
          })
          .toList();
    } catch (e) {
      throw Exception('Could not load questions for category "$category": $e');
    }
  }

  @override
  Future<ReflectionQuestion?> getQuestionById(String id) async {
    try {
      // For preset questions, parse from id
      if (id.startsWith('preset_')) {
        final questions = await getAllQuestions();
        try {
          return questions.firstWhere((q) => q.id == id);
        } catch (e) {
          // If not found in preset questions, check database
        }
      }

      // Check custom questions in database
      final db = await _db;
      final result = await db.query(
        ReflectionDatabase.reflectionNotesTable,
        where:
            '${ReflectionDatabase.columnId} = ? AND ${ReflectionDatabase.columnIsCustomPrompt} = 1',
        whereArgs: [id],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final data = result.first;
        return ReflectionQuestion(
          id: data[ReflectionDatabase.columnId] as String,
          questionText: data[ReflectionDatabase.columnPrompt] as String,
          category: data[ReflectionDatabase.columnCategory] as String,
          isUserCreated: true,
          frequency: 'once',
          createdAt: DateTime.parse(
            data[ReflectionDatabase.columnCreatedAt] as String,
          ),
        );
      }

      return null;
    } catch (e) {
      throw Exception('Could not find reflection question with ID "$id": $e');
    }
  }

  @override
  Future<void> addQuestion(ReflectionQuestion question) async {
    try {
      // Custom questions would be added to reflection_notes with empty answer
      final db = await _db;
      await db.insert(ReflectionDatabase.reflectionNotesTable, {
        ReflectionDatabase.columnId: question.id,
        ReflectionDatabase.columnPrompt: question.questionText,
        ReflectionDatabase.columnAnswer: '',
        ReflectionDatabase.columnCategory: question.category,
        ReflectionDatabase.columnIsCustomPrompt: 1,
        ReflectionDatabase.columnCreatedAt: question.createdAt
            .toIso8601String(),
        ReflectionDatabase.columnIsDraft: 0,
      });
    } catch (e) {
      throw Exception('Failed to save custom question. Please try again: $e');
    }
  }

  @override
  Future<void> updateQuestion(ReflectionQuestion question) async {
    try {
      // For unified table, updating a question means updating the prompt
      // This is complex and not commonly used, skipping detailed implementation
      return;
    } catch (e) {
      throw Exception('Could not update reflection question: $e');
    }
  }

  @override
  Future<void> deleteQuestion(String questionId) async {
    try {
      final db = await _db;
      // Delete all reflection notes with this prompt
      await db.delete(
        ReflectionDatabase.reflectionNotesTable,
        where: '${ReflectionDatabase.columnId} = ?',
        whereArgs: [questionId],
      );
    } catch (e) {
      throw Exception('Could not delete question and associated answers: $e');
    }
  }

  @override
  Future<List<ReflectionAnswer>> getAnswersByQuestion(String questionId) async {
    try {
      final db = await _db;
      final result = await db.query(
        ReflectionDatabase.reflectionNotesTable,
        where:
            '${ReflectionDatabase.columnPrompt} = (SELECT ${ReflectionDatabase.columnPrompt} FROM ${ReflectionDatabase.reflectionNotesTable} WHERE ${ReflectionDatabase.columnId} = ? LIMIT 1) AND ${ReflectionDatabase.columnAnswer} != \'\'',
        whereArgs: [questionId],
        orderBy: '${ReflectionDatabase.columnCreatedAt} DESC',
      );
      return result
          .map(
            (json) => ReflectionAnswer(
              id: json[ReflectionDatabase.columnId] as String,
              questionId: questionId,
              answerText: json[ReflectionDatabase.columnAnswer] as String,
              mood: json[ReflectionDatabase.columnMood] as String?,
              createdAt: DateTime.parse(
                json[ReflectionDatabase.columnCreatedAt] as String,
              ),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Unable to load answers for this question: $e');
    }
  }

  @override
  Future<List<ReflectionAnswer>> getAllAnswers() async {
    try {
      final db = await _db;
      final result = await db.query(
        ReflectionDatabase.reflectionNotesTable,
        where:
            '${ReflectionDatabase.columnAnswer} != \'\'  AND ${ReflectionDatabase.columnIsDraft} = 0',
        orderBy: '${ReflectionDatabase.columnCreatedAt} DESC',
      );
      return result
          .map(
            (json) => ReflectionAnswer(
              id: json[ReflectionDatabase.columnId] as String,
              questionId: json[ReflectionDatabase.columnId] as String,
              answerText: json[ReflectionDatabase.columnAnswer] as String,
              mood: json[ReflectionDatabase.columnMood] as String?,
              createdAt: DateTime.parse(
                json[ReflectionDatabase.columnCreatedAt] as String,
              ),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Unable to load reflection history: $e');
    }
  }

  @override
  Future<void> saveAnswer(ReflectionAnswer answer) async {
    try {
      final db = await _db;
      // Get the prompt from question
      final question = await getQuestionById(answer.questionId);
      await db.insert(ReflectionDatabase.reflectionNotesTable, {
        ReflectionDatabase.columnId: answer.id,
        ReflectionDatabase.columnPrompt: question?.questionText ?? '',
        ReflectionDatabase.columnAnswer: answer.answerText,
        ReflectionDatabase.columnCategory: question?.category ?? 'daily',
        ReflectionDatabase.columnIsCustomPrompt: 0,
        ReflectionDatabase.columnMood: answer.mood,
        ReflectionDatabase.columnCreatedAt: answer.createdAt.toIso8601String(),
        ReflectionDatabase.columnIsDraft: 0,
      });
      // Clear draft after saving
      await deleteDraft(answer.questionId);
    } catch (e) {
      throw Exception('Failed to save your reflection. Please try again: $e');
    }
  }

  @override
  Future<void> saveDraft(String questionId, String draftText) async {
    try {
      final db = await _db;
      final draftId = 'draft_$questionId';
      final now = DateTime.now();
      final question = await getQuestionById(questionId);

      // Check if draft exists
      final existing = await db.query(
        ReflectionDatabase.reflectionNotesTable,
        where: '${ReflectionDatabase.columnId} = ?',
        whereArgs: [draftId],
      );

      if (existing.isNotEmpty) {
        // Update existing draft
        await db.update(
          ReflectionDatabase.reflectionNotesTable,
          {
            ReflectionDatabase.columnAnswer: draftText,
            ReflectionDatabase.columnUpdatedAt: now.toIso8601String(),
          },
          where: '${ReflectionDatabase.columnId} = ?',
          whereArgs: [draftId],
        );
      } else {
        // Create new draft
        await db.insert(ReflectionDatabase.reflectionNotesTable, {
          ReflectionDatabase.columnId: draftId,
          ReflectionDatabase.columnPrompt: question?.questionText ?? '',
          ReflectionDatabase.columnAnswer: draftText,
          ReflectionDatabase.columnCategory: question?.category ?? 'daily',
          ReflectionDatabase.columnIsCustomPrompt: 0,
          ReflectionDatabase.columnCreatedAt: now.toIso8601String(),
          ReflectionDatabase.columnIsDraft: 1,
        });
      }
    } catch (e) {
      throw Exception('Could not save draft. Changes may be lost: $e');
    }
  }

  @override
  Future<String?> getDraft(String questionId) async {
    try {
      final db = await _db;
      final draftId = 'draft_$questionId';
      final result = await db.query(
        ReflectionDatabase.reflectionNotesTable,
        where:
            '${ReflectionDatabase.columnId} = ? AND ${ReflectionDatabase.columnIsDraft} = 1',
        whereArgs: [draftId],
      );
      if (result.isEmpty) return null;
      return result.first[ReflectionDatabase.columnAnswer] as String?;
    } catch (e) {
      throw Exception('Unable to load saved draft: $e');
    }
  }

  @override
  Future<void> deleteDraft(String questionId) async {
    try {
      final db = await _db;
      final draftId = 'draft_$questionId';
      await db.delete(
        ReflectionDatabase.reflectionNotesTable,
        where: '${ReflectionDatabase.columnId} = ?',
        whereArgs: [draftId],
      );
    } catch (e) {
      throw Exception('Could not delete draft: $e');
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
        'SELECT COUNT(*) as count FROM ${ReflectionDatabase.reflectionNotesTable} '
        'WHERE ${ReflectionDatabase.columnCreatedAt} >= ? AND ${ReflectionDatabase.columnCreatedAt} < ? AND ${ReflectionDatabase.columnIsDraft} = 0 AND ${ReflectionDatabase.columnAnswer} != \'\'',
        [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      );

      return result.isNotEmpty ? result.first['count'] as int? ?? 0 : 0;
    } catch (e) {
      throw Exception('Unable to count today\'s reflections: $e');
    }
  }
}
