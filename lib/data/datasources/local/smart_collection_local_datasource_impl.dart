import 'package:sqflite/sqflite.dart';
import 'package:mynotes/data/datasources/local/smart_collection_local_datasource.dart';
import 'package:mynotes/domain/entities/smart_collection.dart';

/// Implementation of SmartCollectionLocalDataSource using SQLite
class SmartCollectionLocalDataSourceImpl
    implements SmartCollectionLocalDataSource {
  final Database database;

  SmartCollectionLocalDataSourceImpl({required this.database});

  static const String tableName = 'smart_collections';
  static const String tableRules = 'collection_rules';

  @override
  Future<List<SmartCollection>> getAllCollections() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(tableName);

      final collections = <SmartCollection>[];
      for (final map in maps) {
        final rules = await getCollectionRules(map['id']);
        collections.add(
          SmartCollection(
            id: map['id'],
            name: map['name'],
            description: map['description'] ?? '',
            rules: rules
                .map(
                  (r) => CollectionRule(
                    type: r['type'],
                    operator: r['operator'],
                    value: r['value'],
                  ),
                )
                .toList(),
            itemCount: map['itemCount'] ?? 0,
            lastUpdated: DateTime.parse(map['lastUpdated']),
            isActive: map['isActive'] == 1,
            logic: map['logic'] ?? 'AND',
          ),
        );
      }
      return collections;
    } catch (e) {
      throw Exception('Failed to load collections: $e');
    }
  }

  @override
  Future<int> insertCollection(SmartCollection collection) async {
    try {
      return await database.insert(tableName, {
        'id': collection.id,
        'name': collection.name,
        'description': collection.description,
        'itemCount': collection.itemCount,
        'lastUpdated': collection.lastUpdated.toIso8601String(),
        'isActive': collection.isActive ? 1 : 0,
        'logic': collection.logic,
      });
    } catch (e) {
      throw Exception('Failed to insert collection: $e');
    }
  }

  @override
  Future<int> updateCollection(SmartCollection collection) async {
    try {
      return await database.update(
        tableName,
        {
          'name': collection.name,
          'description': collection.description,
          'itemCount': collection.itemCount,
          'lastUpdated': DateTime.now().toIso8601String(),
          'isActive': collection.isActive ? 1 : 0,
          'logic': collection.logic,
        },
        where: 'id = ?',
        whereArgs: [collection.id],
      );
    } catch (e) {
      throw Exception('Failed to update collection: $e');
    }
  }

  @override
  Future<int> deleteCollection(String id) async {
    try {
      await database.delete(
        tableRules,
        where: 'collectionId = ?',
        whereArgs: [id],
      );
      return await database.delete(tableName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Failed to delete collection: $e');
    }
  }

  @override
  Future<SmartCollection?> getCollectionById(String id) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) return null;

      final map = maps.first;
      final rules = await getCollectionRules(id);

      return SmartCollection(
        id: map['id'],
        name: map['name'],
        description: map['description'] ?? '',
        rules: rules
            .map(
              (r) => CollectionRule(
                type: r['type'],
                operator: r['operator'],
                value: r['value'],
              ),
            )
            .toList(),
        itemCount: map['itemCount'] ?? 0,
        lastUpdated: DateTime.parse(map['lastUpdated']),
        isActive: map['isActive'] == 1,
        logic: map['logic'] ?? 'AND',
      );
    } catch (e) {
      throw Exception('Failed to get collection: $e');
    }
  }

  @override
  Future<List<SmartCollection>> getActiveCollections() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        tableName,
        where: 'isActive = ?',
        whereArgs: [1],
      );

      final collections = <SmartCollection>[];
      for (final map in maps) {
        final rules = await getCollectionRules(map['id']);
        collections.add(
          SmartCollection(
            id: map['id'],
            name: map['name'],
            description: map['description'] ?? '',
            rules: rules
                .map(
                  (r) => CollectionRule(
                    type: r['type'],
                    operator: r['operator'],
                    value: r['value'],
                  ),
                )
                .toList(),
            itemCount: map['itemCount'] ?? 0,
            lastUpdated: DateTime.parse(map['lastUpdated']),
            isActive: true,
            logic: map['logic'] ?? 'AND',
          ),
        );
      }
      return collections;
    } catch (e) {
      throw Exception('Failed to get active collections: $e');
    }
  }

  @override
  Future<List<SmartCollection>> getArchivedCollections() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        tableName,
        where: 'isActive = ?',
        whereArgs: [0],
      );

      final collections = <SmartCollection>[];
      for (final map in maps) {
        final rules = await getCollectionRules(map['id']);
        collections.add(
          SmartCollection(
            id: map['id'],
            name: map['name'],
            description: map['description'] ?? '',
            rules: rules
                .map(
                  (r) => CollectionRule(
                    type: r['type'],
                    operator: r['operator'],
                    value: r['value'],
                  ),
                )
                .toList(),
            itemCount: map['itemCount'] ?? 0,
            lastUpdated: DateTime.parse(map['lastUpdated']),
            isActive: false,
            logic: map['logic'] ?? 'AND',
          ),
        );
      }
      return collections;
    } catch (e) {
      throw Exception('Failed to get archived collections: $e');
    }
  }

  @override
  Future<int> toggleCollectionStatus(String id, bool isActive) async {
    try {
      return await database.update(
        tableName,
        {'isActive': isActive ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to toggle collection status: $e');
    }
  }

  @override
  Future<List<SmartCollection>> searchCollectionsByName(String query) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        tableName,
        where: 'name LIKE ?',
        whereArgs: ['%$query%'],
      );

      final collections = <SmartCollection>[];
      for (final map in maps) {
        final rules = await getCollectionRules(map['id']);
        collections.add(
          SmartCollection(
            id: map['id'],
            name: map['name'],
            description: map['description'] ?? '',
            rules: rules
                .map(
                  (r) => CollectionRule(
                    type: r['type'],
                    operator: r['operator'],
                    value: r['value'],
                  ),
                )
                .toList(),
            itemCount: map['itemCount'] ?? 0,
            lastUpdated: DateTime.parse(map['lastUpdated']),
            isActive: map['isActive'] == 1,
            logic: map['logic'] ?? 'AND',
          ),
        );
      }
      return collections;
    } catch (e) {
      throw Exception('Failed to search collections: $e');
    }
  }

  @override
  Future<SmartCollection?> getCollectionWithRules(String id) async {
    return getCollectionById(id);
  }

  @override
  Future<int> insertCollectionRule(
    String collectionId,
    Map<String, dynamic> rule,
  ) async {
    try {
      return await database.insert(tableRules, {
        'collectionId': collectionId,
        'type': rule['type'],
        'operator': rule['operator'],
        'value': rule['value'],
      });
    } catch (e) {
      throw Exception('Failed to insert rule: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCollectionRules(
    String collectionId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        tableRules,
        where: 'collectionId = ?',
        whereArgs: [collectionId],
      );
      return maps;
    } catch (e) {
      throw Exception('Failed to get collection rules: $e');
    }
  }

  @override
  Future<int> deleteCollectionRule(String ruleId) async {
    try {
      return await database.delete(
        tableRules,
        where: 'id = ?',
        whereArgs: [ruleId],
      );
    } catch (e) {
      throw Exception('Failed to delete rule: $e');
    }
  }

  @override
  Future<int> updateItemCount(String collectionId, int count) async {
    try {
      return await database.update(
        tableName,
        {'itemCount': count, 'lastUpdated': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [collectionId],
      );
    } catch (e) {
      throw Exception('Failed to update item count: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getCollectionStats(String collectionId) async {
    try {
      final collection = await getCollectionById(collectionId);
      if (collection == null) return {};

      return {
        'totalItems': collection.itemCount,
        'ruleCount': collection.rules.length,
        'lastUpdated': collection.lastUpdated.toIso8601String(),
        'isActive': collection.isActive,
      };
    } catch (e) {
      throw Exception('Failed to get collection stats: $e');
    }
  }

  @override
  Future<int> clearAllCollections() async {
    try {
      await database.delete(tableRules);
      return await database.delete(tableName);
    } catch (e) {
      throw Exception('Failed to clear collections: $e');
    }
  }
}
