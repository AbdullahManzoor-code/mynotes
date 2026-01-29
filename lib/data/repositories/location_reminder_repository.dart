import 'package:sqflite/sqflite.dart';
import 'package:mynotes/domain/entities/location_reminder_model.dart';
import 'package:mynotes/domain/entities/saved_location_model.dart';
import 'package:mynotes/data/datasources/local_database.dart';

class LocationReminderRepository {
  final NotesDatabase _database = NotesDatabase();

  // Location Reminders CRUD operations

  /// Insert a new location reminder
  Future<void> insertLocationReminder(LocationReminder reminder) async {
    final db = await _database.database;
    await db.insert(
      'location_reminders',
      reminder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all location reminders
  Future<List<LocationReminder>> getAllLocationReminders() async {
    final db = await _database.database;
    final maps = await db.query('location_reminders');
    return maps.map((map) => LocationReminder.fromMap(map)).toList();
  }

  /// Get active location reminders only
  Future<List<LocationReminder>> getActiveLocationReminders() async {
    final db = await _database.database;
    final maps = await db.query(
      'location_reminders',
      where: 'is_active = ?',
      whereArgs: [1],
    );
    return maps.map((map) => LocationReminder.fromMap(map)).toList();
  }

  /// Get a specific location reminder by ID
  Future<LocationReminder?> getLocationReminderById(String id) async {
    final db = await _database.database;
    final maps = await db.query(
      'location_reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return LocationReminder.fromMap(maps.first);
  }

  /// Update a location reminder
  Future<void> updateLocationReminder(LocationReminder reminder) async {
    final db = await _database.database;
    await db.update(
      'location_reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  /// Delete a location reminder
  Future<void> deleteLocationReminder(String reminderId) async {
    final db = await _database.database;
    await db.delete(
      'location_reminders',
      where: 'id = ?',
      whereArgs: [reminderId],
    );
  }

  /// Get reminders linked to a specific note
  Future<List<LocationReminder>> getRemindersByNoteId(String noteId) async {
    final db = await _database.database;
    final maps = await db.query(
      'location_reminders',
      where: 'linked_note_id = ?',
      whereArgs: [noteId],
    );
    return maps.map((map) => LocationReminder.fromMap(map)).toList();
  }

  // Saved Locations CRUD operations

  /// Insert a new saved location
  Future<void> insertSavedLocation(SavedLocation location) async {
    final db = await _database.database;
    await db.insert(
      'saved_locations',
      location.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all saved locations
  Future<List<SavedLocation>> getSavedLocations() async {
    final db = await _database.database;
    final maps = await db.query('saved_locations');
    return maps.map((map) => SavedLocation.fromMap(map)).toList();
  }

  /// Get a specific saved location by ID
  Future<SavedLocation?> getSavedLocationById(String id) async {
    final db = await _database.database;
    final maps = await db.query(
      'saved_locations',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return SavedLocation.fromMap(maps.first);
  }

  /// Update a saved location
  Future<void> updateSavedLocation(SavedLocation location) async {
    final db = await _database.database;
    await db.update(
      'saved_locations',
      location.toMap(),
      where: 'id = ?',
      whereArgs: [location.id],
    );
  }

  /// Delete a saved location
  Future<void> deleteSavedLocation(String locationId) async {
    final db = await _database.database;
    await db.delete(
      'saved_locations',
      where: 'id = ?',
      whereArgs: [locationId],
    );
  }

  /// Check if a location name already exists
  Future<bool> locationNameExists(String name, {String? excludeId}) async {
    final db = await _database.database;
    String query = 'name = ?';
    List<dynamic> args = [name];

    if (excludeId != null) {
      query += ' AND id != ?';
      args.add(excludeId);
    }

    final maps = await db.query(
      'saved_locations',
      where: query,
      whereArgs: args,
    );
    return maps.isNotEmpty;
  }
}
