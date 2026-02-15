import 'package:sqflite/sqflite.dart';
import 'package:mynotes/core/database/core_database.dart';

/// Database helper singleton that delegates to CoreDatabase
/// Provides backward compatibility for injection_container imports
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;

  DatabaseHelper._internal();

  final CoreDatabase _coreDatabase = CoreDatabase();

  /// Get the database instance
  Future<Database> get database => _coreDatabase.database;
}
