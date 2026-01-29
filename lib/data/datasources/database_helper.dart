import 'package:sqflite/sqflite.dart';
import 'local_database.dart';

/// Database helper singleton that delegates to NotesDatabase
/// Provides backward compatibility for injection_container imports
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;

  DatabaseHelper._internal();

  final NotesDatabase _notesDatabase = NotesDatabase();

  /// Get the database instance
  Future<Database> get database => _notesDatabase.database;
}
