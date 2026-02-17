import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

/// Folder/Collection System - Hierarchical note organization
/// Supports creating, managing, and organizing notes into collections
class CollectionManagerWidget extends StatefulWidget {
  final Function(NoteCollection) onCollectionSelected;
  final Function(NoteCollection) onCollectionCreated;

  const CollectionManagerWidget({
    super.key,
    required this.onCollectionSelected,
    required this.onCollectionCreated,
  });

  @override
  State<CollectionManagerWidget> createState() =>
      _CollectionManagerWidgetState();
}

class _CollectionManagerWidgetState extends State<CollectionManagerWidget> {
  final List<NoteCollection> _collections = [];
  late TextEditingController _collectionNameController;

  @override
  void initState() {
    super.initState();
    _collectionNameController = TextEditingController();
    _loadCollections();
  }

  @override
  void dispose() {
    _collectionNameController.dispose();
    super.dispose();
  }

  void _loadCollections() {
    // TODO: Load from database
    // For now, initialize with default collections
    _collections.addAll([
      NoteCollection(
        id: '1',
        name: 'Work',
        description: 'Work-related notes',
        color: Colors.blue,
        itemCount: 12,
        createdAt: DateTime.now(),
      ),
      NoteCollection(
        id: '2',
        name: 'Personal',
        description: 'Personal notes',
        color: Colors.green,
        itemCount: 8,
        createdAt: DateTime.now(),
      ),
      NoteCollection(
        id: '3',
        name: 'Ideas',
        description: 'Creative ideas and inspiration',
        color: Colors.purple,
        itemCount: 5,
        createdAt: DateTime.now(),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collections'),
        backgroundColor: AppColors.getSurfaceColor(
          Theme.of(context).brightness,
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showCreateCollectionDialog,
          ),
        ],
      ),
      body: _buildCollectionsList(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'collection_manager_fab',
        onPressed: _showCreateCollectionDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildCollectionsList() {
    if (_collections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64.sp,
              color: AppColors.getSecondaryTextColor(
                Theme.of(context).brightness,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'No collections yet',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextColor(Theme.of(context).brightness),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Create your first collection to organize notes',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.getSecondaryTextColor(
                  Theme.of(context).brightness,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(12.w),
      itemCount: _collections.length,
      itemBuilder: (context, index) =>
          _buildCollectionCard(_collections[index], context),
    );
  }

  Widget _buildCollectionCard(NoteCollection collection, BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onCollectionSelected(collection);
        Navigator.pop(context);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: collection.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: collection.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: collection.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      collection.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.getTextColor(
                          Theme.of(context).brightness,
                        ),
                      ),
                    ),
                  ],
                ),
                PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditCollectionDialog(collection);
                    } else if (value == 'delete') {
                      _showDeleteCollectionDialog(collection);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),
            if (collection.description != null)
              Text(
                collection.description!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.getSecondaryTextColor(
                    Theme.of(context).brightness,
                  ),
                ),
              ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: collection.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '${collection.itemCount} notes',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: collection.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateCollectionDialog() {
    _collectionNameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New Collection'),
        content: TextField(
          controller: _collectionNameController,
          decoration: InputDecoration(
            hintText: 'Collection name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_collectionNameController.text.isNotEmpty) {
                final newCollection = NoteCollection(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _collectionNameController.text,
                  description: '',
                  color: _getRandomColor(),
                  itemCount: 0,
                  createdAt: DateTime.now(),
                );
                setState(() {
                  _collections.add(newCollection);
                });
                widget.onCollectionCreated(newCollection);
                Navigator.pop(context);
              }
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditCollectionDialog(NoteCollection collection) {
    _collectionNameController.text = collection.name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Collection'),
        content: TextField(
          controller: _collectionNameController,
          decoration: InputDecoration(
            hintText: 'Collection name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_collectionNameController.text.isNotEmpty) {
                setState(() {
                  final index = _collections.indexOf(collection);
                  _collections[index].name = _collectionNameController.text;
                });
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCollectionDialog(NoteCollection collection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Collection?'),
        content: Text(
          'Are you sure you want to delete "${collection.name}"?\nNotes in this collection will be moved to "Uncategorized".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _collections.remove(collection);
              });
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[DateTime.now().microsecond % colors.length];
  }
}

/// NoteCollection Entity
class NoteCollection {
  String id;
  String name;
  String? description;
  Color color;
  int itemCount;
  DateTime createdAt;

  NoteCollection({
    required this.id,
    required this.name,
    this.description,
    required this.color,
    required this.itemCount,
    required this.createdAt,
  });
}
