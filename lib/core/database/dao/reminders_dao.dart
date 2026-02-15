import 'package:sqflite/sqflite.dart';
import 'package:mynotes/domain/entities/alarm.dart';
import '../mappers/reminders_mapper.dart';
import 'tables_reference.dart';

class RemindersDAO {
  final Database db;

  RemindersDAO(this.db);

  /// Create a new reminder
  Future<void> createAlarm(Alarm alarm) async {
    await db.insert(
      TablesReference.remindersTable,
      RemindersMapper.toMap(alarm),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all reminders
  Future<List<Alarm>> getAllAlarms() async {
    final List<Map<String, dynamic>> maps = await db.query(
      TablesReference.remindersTable,
      orderBy: 'scheduledTime ASC',
    );
    return List.generate(maps.length, (i) => RemindersMapper.fromMap(maps[i]));
  }

  /// Get a single reminder by ID
  Future<Alarm?> getAlarmById(String id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      TablesReference.remindersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return RemindersMapper.fromMap(maps.first);
  }

  /// Update an existing reminder
  Future<void> updateAlarm(Alarm alarm) async {
    await db.update(
      TablesReference.remindersTable,
      RemindersMapper.toMap(alarm),
      where: 'id = ?',
      whereArgs: [alarm.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Delete a reminder by ID
  Future<void> deleteAlarm(String id) async {
    await db.delete(
      TablesReference.remindersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get active reminders only
  Future<List<Alarm>> getAlarms() async {
    final List<Map<String, dynamic>> maps = await db.query(
      TablesReference.remindersTable,
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'scheduledTime ASC',
    );
    return List.generate(maps.length, (i) => RemindersMapper.fromMap(maps[i]));
  }

  /// Batch update reminders
  Future<void> updateAlarms(List<Alarm> alarms) async {
    for (final alarm in alarms) {
      await updateAlarm(alarm);
    }
  }

  /// Search reminders by title or message
  Future<List<Alarm>> searchAlarms(String query) async {
    if (query.isEmpty) return getAllAlarms();

    final List<Map<String, dynamic>> maps = await db.query(
      TablesReference.remindersTable,
      where: 'title LIKE ? OR message LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'scheduledTime ASC',
    );
    return List.generate(maps.length, (i) => RemindersMapper.fromMap(maps[i]));
  }
}

