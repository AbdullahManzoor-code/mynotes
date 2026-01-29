import 'package:mynotes/data/datasources/local/smart_collection_local_datasource.dart';
import 'package:mynotes/domain/entities/smart_collection.dart';
import 'package:mynotes/domain/repositories/smart_collection_repository.dart';

/// Implementation of SmartCollectionRepository
class SmartCollectionRepositoryImpl implements SmartCollectionRepository {
  final SmartCollectionLocalDataSource localDataSource;

  SmartCollectionRepositoryImpl({required this.localDataSource});

  @override
  Future<List<SmartCollection>> loadCollections() async {
    return await localDataSource.getAllCollections();
  }

  @override
  Future<SmartCollection?> getCollectionById(String id) async {
    return await localDataSource.getCollectionById(id);
  }

  @override
  Future<String> createCollection(SmartCollection collection) async {
    final result = await localDataSource.insertCollection(collection);

    // Insert rules
    for (final rule in collection.rules) {
      await localDataSource.insertCollectionRule(collection.id, {
        'type': rule.type,
        'operator': rule.operator,
        'value': rule.value,
      });
    }

    return result > 0 ? collection.id : '';
  }

  @override
  Future<bool> updateCollection(SmartCollection collection) async {
    // Update collection
    await localDataSource.updateCollection(collection);

    // Delete old rules and insert new ones
    final existingRules = await localDataSource.getCollectionRules(
      collection.id,
    );
    for (final rule in existingRules) {
      await localDataSource.deleteCollectionRule(rule['id']);
    }

    for (final rule in collection.rules) {
      await localDataSource.insertCollectionRule(collection.id, {
        'type': rule.type,
        'operator': rule.operator,
        'value': rule.value,
      });
    }

    return true;
  }

  @override
  Future<bool> deleteCollection(String id) async {
    final result = await localDataSource.deleteCollection(id);
    return result > 0;
  }

  @override
  Future<bool> archiveCollection(String id) async {
    final result = await localDataSource.toggleCollectionStatus(id, false);
    return result > 0;
  }

  @override
  Future<List<SmartCollection>> getActiveCollections() async {
    return await localDataSource.getActiveCollections();
  }

  @override
  Future<List<Map<String, dynamic>>> getCollectionItems(
    String collectionId,
  ) async {
    // This would typically query items matching the collection rules
    // For now, return empty list - implement based on your data structure
    return [];
  }

  @override
  Future<Map<String, dynamic>> getCollectionStats(String collectionId) async {
    return await localDataSource.getCollectionStats(collectionId);
  }

  @override
  Future<bool> toggleCollectionStatus(String id, bool isActive) async {
    final result = await localDataSource.toggleCollectionStatus(id, isActive);
    return result > 0;
  }

  @override
  Future<List<SmartCollection>> searchCollections(String query) async {
    return await localDataSource.searchCollectionsByName(query);
  }

  @override
  Future<bool> updateItemCount(String collectionId, int count) async {
    final result = await localDataSource.updateItemCount(collectionId, count);
    return result > 0;
  }
}
