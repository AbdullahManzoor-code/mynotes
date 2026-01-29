import 'package:mynotes/domain/entities/smart_collection.dart';

/// Local data source for smart collections - handles SQLite operations
abstract class SmartCollectionLocalDataSource {
  /// Load all collections
  Future<List<SmartCollection>> getAllCollections();

  /// Insert new collection
  Future<int> insertCollection(SmartCollection collection);

  /// Update collection
  Future<int> updateCollection(SmartCollection collection);

  /// Delete collection
  Future<int> deleteCollection(String id);

  /// Get collection by ID
  Future<SmartCollection?> getCollectionById(String id);

  /// Get active collections only
  Future<List<SmartCollection>> getActiveCollections();

  /// Get archived collections
  Future<List<SmartCollection>> getArchivedCollections();

  /// Toggle collection active status
  Future<int> toggleCollectionStatus(String id, bool isActive);

  /// Search collections by name
  Future<List<SmartCollection>> searchCollectionsByName(String query);

  /// Get collection with all rules
  Future<SmartCollection?> getCollectionWithRules(String id);

  /// Insert collection rule
  Future<int> insertCollectionRule(
    String collectionId,
    Map<String, dynamic> rule,
  );

  /// Get collection rules
  Future<List<Map<String, dynamic>>> getCollectionRules(String collectionId);

  /// Delete collection rule
  Future<int> deleteCollectionRule(String ruleId);

  /// Update item count
  Future<int> updateItemCount(String collectionId, int count);

  /// Get collection statistics
  Future<Map<String, dynamic>> getCollectionStats(String collectionId);

  /// Clear all collections (for testing)
  Future<int> clearAllCollections();
}
