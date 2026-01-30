import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/smart_collections_bloc.dart';

/// Collection Management - Batch 5, Screen 4
class CollectionManagementScreen extends StatefulWidget {
  const CollectionManagementScreen({Key? key}) : super(key: key);

  @override
  State<CollectionManagementScreen> createState() =>
      _CollectionManagementScreenState();
}

class _CollectionManagementScreenState
    extends State<CollectionManagementScreen> {
  final _searchController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _collectionsFuture;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  void _loadCollections() {
    // Load from BLoC
    final state = context.read<SmartCollectionsBloc>().state;
    if (state is SmartCollectionsLoaded) {
      // Mock data for now
      _collectionsFuture = Future.value(state.collections);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Collections'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Navigate to create wizard
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search collections',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          // Collections List
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _collectionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                var collections = snapshot.data ?? [];

                // Filter
                if (_searchController.text.isNotEmpty) {
                  collections = collections
                      .where(
                        (c) =>
                            (c['name'] as String?)?.toLowerCase().contains(
                              _searchController.text.toLowerCase(),
                            ) ??
                            false,
                      )
                      .toList();
                }

                if (collections.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text('No collections found'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: collections.length,
                  itemBuilder: (context, index) {
                    final collection = collections[index];
                    return _buildCollectionTile(collection);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionTile(Map<String, dynamic> collection) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(Icons.folder, size: 32, color: Colors.blue),
        title: Text(
          collection['name'] ?? 'Unnamed',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (collection['description'] != null)
              Text(
                collection['description'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              '${collection['itemCount'] ?? 0} items • ${collection['ruleCount'] ?? 0} rules',
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Text('View'),
              onTap: () {
                // Navigate to details
              },
            ),
            PopupMenuItem(
              child: Text('Edit'),
              onTap: () {
                // Edit collection
              },
            ),
            PopupMenuItem(
              child: Text('Duplicate'),
              onTap: () {
                // Duplicate collection
              },
            ),
            PopupMenuItem(
              child: Text('Delete'),
              onTap: () {
                // Delete collection
              },
            ),
          ],
        ),
        onTap: () {
          // Navigate to collection details
        },
      ),
    );
  }
}
