import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/smart_collections_bloc.dart';

/// Collection Details - Batch 5, Screen 3
class CollectionDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> collection;

  const CollectionDetailsScreen({Key? key, required this.collection})
    : super(key: key);

  @override
  State<CollectionDetailsScreen> createState() =>
      _CollectionDetailsScreenState();
}

class _CollectionDetailsScreenState extends State<CollectionDetailsScreen> {
  late Map<String, dynamic> _collection;

  @override
  void initState() {
    super.initState();
    _collection = widget.collection;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_collection['name'] ?? 'Collection'),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('Edit'),
                onTap: () => _showEditDialog(),
              ),
              PopupMenuItem(
                child: Text('Delete'),
                onTap: () => _deleteCollection(),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Collection Info
            _buildCollectionInfo(),
            const SizedBox(height: 24),

            // Rules Section
            _buildRulesSection(),
            const SizedBox(height: 24),

            // Items in Collection
            _buildItemsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Collection Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Name'),
              subtitle: Text(_collection['name'] ?? 'Unnamed'),
            ),
            if (_collection['description'] != null)
              ListTile(
                title: Text('Description'),
                subtitle: Text(_collection['description']),
              ),
            ListTile(
              title: Text('Created'),
              subtitle: Text(_collection['createdAt']?.toString() ?? 'Unknown'),
            ),
            ListTile(
              title: Text('Items'),
              subtitle: Text('${_collection['itemCount'] ?? 0} items'),
            ),
            ListTile(
              title: Text('Logic'),
              subtitle: Text(_collection['logic'] ?? 'AND'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesSection() {
    final rules = _collection['rules'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtering Rules (${rules.length})',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (rules.isEmpty)
          Center(child: Text('No rules defined'))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: rules.length,
            itemBuilder: (context, index) {
              final rule = rules[index] as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(
                    '${rule['field']} ${rule['operator']} ${rule['value']}',
                  ),
                  subtitle: Text('Rule ${index + 1}'),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildItemsSection() {
    final items = _collection['items'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items (${items.length})',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Center(
            child: Column(
              children: [
                Icon(Icons.folder_open, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text('No items match this collection'),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  title: Text(item['name'] ?? 'Unnamed'),
                  subtitle: Text(item['type'] ?? 'Unknown'),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    // Navigate to item details
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Collection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Name'),
              controller: TextEditingController(text: _collection['name']),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(labelText: 'Description'),
              controller: TextEditingController(
                text: _collection['description'],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteCollection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Collection?'),
        content: Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Delete via BLoC
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}

