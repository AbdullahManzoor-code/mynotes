import 'package:mynotes/domain/entities/smart_collection.dart';

/// Repository interface for smart collections
abstract class SmartCollectionRepository {
  /// Load all collections
  Future<List<SmartCollection>> loadCollections();

  /// Create a new collection
  Future<String> createCollection(SmartCollection collection);

  /// Update a collection
  Future<bool> updateCollection(SmartCollection collection);

  /// Delete a collection
  Future<bool> deleteCollection(String collectionId);

  /// Archive a collection
  Future<bool> archiveCollection(String collectionId);

  /// Get collection by ID
  Future<SmartCollection?> getCollectionById(String collectionId);

  /// Get items in collection
  Future<List<Map<String, dynamic>>> getCollectionItems(String collectionId);

  /// Get collection statistics
  Future<Map<String, dynamic>> getCollectionStats(String collectionId);

  /// Search collections
  Future<List<SmartCollection>> searchCollections(String query);

  /// Get active collections only
  Future<List<SmartCollection>> getActiveCollections();

  /// Update collection item count
  Future<bool> updateItemCount(String collectionId, int count);
}
