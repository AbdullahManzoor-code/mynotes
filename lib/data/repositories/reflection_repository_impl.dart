import '../../domain/entities/reflection.dart';
import '../../domain/entities/reflection_question.dart';
import '../../domain/entities/reflection_answer.dart';
import '../../domain/repositories/reflection_repository.dart';
import '../datasources/local_database.dart';

/// Repository for reflection/journaling entries
class ReflectionRepositoryImpl implements ReflectionRepository {
  final NotesDatabase _database;

  ReflectionRepositoryImpl(this._database);

  /// Create a new reflection entry
  Future<Reflection> createReflection(Reflection reflection) async {
    final db = await _database.database;

    await db.insert(NotesDatabase.reflectionsTable, reflection.toMap());

    return reflection;
  }

  /// Get reflection by ID
  Future<Reflection?> getReflectionById(String id) async {
    final db = await _database.database;

    final maps = await db.query(
      NotesDatabase.reflectionsTable,
      where: 'id = ? AND isDeleted = 0',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Reflection.fromMap(maps.first);
  }

  /// Get all reflections
  Future<List<Reflection>> getAllReflections({
    int limit = 100,
    int offset = 0,
  }) async {
    final db = await _database.database;

    final maps = await db.query(
      NotesDatabase.reflectionsTable,
      where: 'isDeleted = 0',
      orderBy: 'createdAt DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map((map) => Reflection.fromMap(map)).toList();
  }

  /// Get reflections by date range
  Future<List<Reflection>> getReflectionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _database.database;

    final maps = await db.query(
      NotesDatabase.reflectionsTable,
      where: 'createdAt >= ? AND createdAt <= ? AND isDeleted = 0',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => Reflection.fromMap(map)).toList();
  }

  /// Get today's reflections
  Future<List<Reflection>> getTodayReflections() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getReflectionsByDateRange(startOfDay, endOfDay);
  }

  /// Get week's reflections
  Future<List<Reflection>> getWeekReflections() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    return getReflectionsByDateRange(startOfDay, DateTime.now());
  }

  /// Get month's reflections
  Future<List<Reflection>> getMonthReflections() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return getReflectionsByDateRange(startOfMonth, DateTime.now());
  }

  /// Update reflection
  Future<void> updateReflection(Reflection reflection) async {
    final db = await _database.database;

    await db.update(
      NotesDatabase.reflectionsTable,
      reflection.toMap(),
      where: 'id = ?',
      whereArgs: [reflection.id],
    );
  }

  /// Soft delete reflection
  Future<void> deleteReflection(String id) async {
    final db = await _database.database;

    await db.update(
      NotesDatabase.reflectionsTable,
      {'isDeleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Permanently delete reflection
  Future<void> permanentlyDeleteReflection(String id) async {
    final db = await _database.database;

    await db.delete(
      NotesDatabase.reflectionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get reflections count
  Future<int> getReflectionsCount() async {
    final db = await _database.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${NotesDatabase.reflectionsTable} WHERE isDeleted = 0',
    );

    return (result.first['count'] as int?) ?? 0;
  }

  /// Create reflection question
  Future<ReflectionQuestion> createQuestion(ReflectionQuestion question) async {
    final db = await _database.database;

    await db.insert(NotesDatabase.reflectionQuestionsTable, {
      'id': question.id,
      'text': question.questionText,
      'category': question.category,
      'isDefault': 0,
      'isCustom': question.isUserCreated ? 1 : 0,
      'frequency': question.frequency,
      'createdAt': question.createdAt.toIso8601String(),
      'order': 999,
    });

    return question;
  }

  /// Get all reflection questions
  Future<List<ReflectionQuestion>> getAllQuestions() async {
    final db = await _database.database;

    final maps = await db.query(
      NotesDatabase.reflectionQuestionsTable,
      orderBy: 'order ASC, createdAt DESC',
    );

    return maps
        .map(
          (map) => ReflectionQuestion(
            id: map['id'] as String,
            questionText: map['text'] as String,
            category: map['category'] as String,
            isUserCreated: (map['isCustom'] as int?) == 1,
            frequency: map['frequency'] as String? ?? 'daily',
            createdAt: DateTime.parse(map['createdAt'] as String),
          ),
        )
        .toList();
  }

  /// Get default questions
  Future<List<ReflectionQuestion>> getDefaultQuestions() async {
    final db = await _database.database;

    final maps = await db.query(
      NotesDatabase.reflectionQuestionsTable,
      where: 'isDefault = 1',
      orderBy: 'order ASC',
    );

    return maps
        .map(
          (map) => ReflectionQuestion(
            id: map['id'] as String,
            questionText: map['text'] as String,
            category: map['category'] as String,
            isUserCreated: (map['isCustom'] as int?) == 1,
            frequency: map['frequency'] as String? ?? 'daily',
            createdAt: DateTime.parse(map['createdAt'] as String),
          ),
        )
        .toList();
  }

  /// Get custom questions
  Future<List<ReflectionQuestion>> getCustomQuestions() async {
    final db = await _database.database;

    final maps = await db.query(
      NotesDatabase.reflectionQuestionsTable,
      where: 'isCustom = 1',
      orderBy: 'createdAt DESC',
    );

    return maps
        .map(
          (map) => ReflectionQuestion(
            id: map['id'] as String,
            questionText: map['text'] as String,
            category: map['category'] as String,
            isUserCreated: (map['isCustom'] as int?) == 1,
            frequency: map['frequency'] as String? ?? 'daily',
            createdAt: DateTime.parse(map['createdAt'] as String),
          ),
        )
        .toList();
  }

  @override
  Future<void> addQuestion(ReflectionQuestion question) async {
    await createQuestion(question);
  }

  @override
  Future<void> deleteDraft(String questionId) async {
    final db = await _database.database;
    await db.delete(
      'reflection_drafts',
      where: 'questionId = ?',
      whereArgs: [questionId],
    );
  }

  @override
  Future<void> deleteQuestion(String questionId) async {
    final db = await _database.database;
    await db.delete(
      NotesDatabase.reflectionQuestionsTable,
      where: 'id = ?',
      whereArgs: [questionId],
    );
  }

  @override
  Future<List<ReflectionAnswer>> getAllAnswers() async {
    final db = await _database.database;
    final maps = await db.query(
      'reflection_answers',
      orderBy: 'createdAt DESC',
    );
    return maps
        .map(
          (map) => ReflectionAnswer(
            id: map['id'] as String,
            questionId: map['questionId'] as String,
            answerText: map['answerText'] as String,
            mood: map['mood'] as String?,
            createdAt: DateTime.parse(map['createdAt'] as String),
            draft: map['draft'] as String?,
          ),
        )
        .toList();
  }

  @override
  Future<int> getAnswerCountForToday() async {
    final db = await _database.database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM reflection_answers WHERE createdAt >= ? AND createdAt < ?',
      [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );

    return (result.first['count'] as int?) ?? 0;
  }

  @override
  Future<List<ReflectionAnswer>> getAnswersByQuestion(String questionId) async {
    final db = await _database.database;
    final maps = await db.query(
      'reflection_answers',
      where: 'questionId = ?',
      whereArgs: [questionId],
      orderBy: 'createdAt DESC',
    );
    return maps
        .map(
          (map) => ReflectionAnswer(
            id: map['id'] as String,
            questionId: map['questionId'] as String,
            answerText: map['answerText'] as String,
            mood: map['mood'] as String?,
            createdAt: DateTime.parse(map['createdAt'] as String),
            draft: map['draft'] as String?,
          ),
        )
        .toList();
  }

  @override
  Future<List<String>> getAvailableCategories() async {
    return ['life', 'daily', 'career', 'mental_health'];
  }

  @override
  Future<String?> getDraft(String questionId) async {
    final db = await _database.database;
    final maps = await db.query(
      'reflection_drafts',
      where: 'questionId = ?',
      whereArgs: [questionId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first['draftText'] as String?;
  }

  @override
  Future<ReflectionQuestion?> getQuestionById(String id) async {
    final db = await _database.database;
    final maps = await db.query(
      NotesDatabase.reflectionQuestionsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    final map = maps.first;
    return ReflectionQuestion(
      id: map['id'] as String,
      questionText: map['text'] as String,
      category: map['category'] as String,
      isUserCreated: (map['isCustom'] as int?) == 1,
      frequency: map['frequency'] as String? ?? 'daily',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  Future<List<ReflectionQuestion>> getQuestionsByCategory(
    String category,
  ) async {
    final db = await _database.database;
    final maps = await db.query(
      NotesDatabase.reflectionQuestionsTable,
      where: 'category = ?',
      whereArgs: [category],
    );
    return maps
        .map(
          (map) => ReflectionQuestion(
            id: map['id'] as String,
            questionText: map['text'] as String,
            category: map['category'] as String,
            isUserCreated: (map['isCustom'] as int?) == 1,
            frequency: map['frequency'] as String? ?? 'daily',
            createdAt: DateTime.parse(map['createdAt'] as String),
          ),
        )
        .toList();
  }

  @override
  Future<void> saveAnswer(ReflectionAnswer answer) async {
    final db = await _database.database;
    await db.insert('reflection_answers', {
      'id': answer.id,
      'questionId': answer.questionId,
      'answerText': answer.answerText,
      'mood': answer.mood,
      'createdAt': answer.createdAt.toIso8601String(),
      'draft': answer.draft,
    });
  }

  @override
  Future<void> saveDraft(String questionId, String draftText) async {
    final db = await _database.database;
    final existing = await db.query(
      'reflection_drafts',
      where: 'questionId = ?',
      whereArgs: [questionId],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      await db.update(
        'reflection_drafts',
        {'draftText': draftText, 'updatedAt': DateTime.now().toIso8601String()},
        where: 'questionId = ?',
        whereArgs: [questionId],
      );
    } else {
      await db.insert('reflection_drafts', {
        'id': '${questionId}_draft',
        'questionId': questionId,
        'draftText': draftText,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }
  }

  @override
  Future<void> updateQuestion(ReflectionQuestion question) async {
    final db = await _database.database;
    await db.update(
      NotesDatabase.reflectionQuestionsTable,
      {
        'text': question.questionText,
        'category': question.category,
        'frequency': question.frequency,
      },
      where: 'id = ?',
      whereArgs: [question.id],
    );
  }
}
