import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/media_gallery_bloc.dart';
import 'package:mynotes/domain/services/media_filtering_service.dart';

/// Media Organization View - Batch 4, Screen 3
class MediaOrganizationView extends StatefulWidget {
  const MediaOrganizationView({Key? key}) : super(key: key);

  @override
  State<MediaOrganizationView> createState() => _MediaOrganizationViewState();
}

class _MediaOrganizationViewState extends State<MediaOrganizationView> {
  final _filtering = MediaFilteringService();
  String _groupBy = 'type'; // type, date, size

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Organization'),
        centerTitle: true,
      ),
      body: BlocBuilder<MediaGalleryBloc, MediaGalleryState>(
        builder: (context, state) {
          if (state is MediaGalleryLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is! MediaGalleryLoaded) {
            return Center(child: Text('No media loaded'));
          }

          return Column(
            children: [
              // Group By Selector
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildGroupBySelector(),
              ),
              // Grouped Content
              Expanded(
                child: FutureBuilder<Map<String, List<dynamic>>>(
                  future: _filtering.groupMedia(
                    state.mediaItems,
                    groupBy: _groupBy,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final grouped = snapshot.data ?? {};

                    return ListView.builder(
                      itemCount: grouped.length,
                      itemBuilder: (context, index) {
                        final groupKey = grouped.keys.elementAt(index);
                        final items = grouped[groupKey] ?? [];

                        return _buildGroupCard(groupKey, items);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGroupBySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildGroupButton('Type', 'type'),
        _buildGroupButton('Date', 'date'),
        _buildGroupButton('Size', 'size'),
      ],
    );
  }

  Widget _buildGroupButton(String label, String value) {
    final isSelected = _groupBy == value;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          _groupBy = value;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
      ),
      child: Text(
        label,
        style: TextStyle(color: isSelected ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _buildGroupCard(String groupKey, List<dynamic> items) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text(
          '$groupKey (${items.length})',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: _getMediaIcon(item),
                  title: Text(item.name ?? 'Unnamed'),
                  subtitle: Text('Size: ${_formatBytes(item.size ?? 0)}'),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Text('View'),
                        onTap: () {
                          // View action
                        },
                      ),
                      PopupMenuItem(
                        child: Text('Organize'),
                        onTap: () {
                          _showOrganizeDialog(context, item);
                        },
                      ),
                      PopupMenuItem(
                        child: Text('Delete'),
                        onTap: () {
                          // Delete action
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showOrganizeDialog(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Organize Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Add Tags',
                hintText: 'e.g., important, work',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(labelText: 'Add to Collection'),
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

  Widget _getMediaIcon(dynamic item) {
    final type = item.type?.toString().toLowerCase() ?? 'unknown';

    switch (type) {
      case 'image':
        return Icon(Icons.image, color: Colors.blue);
      case 'video':
        return Icon(Icons.video_library, color: Colors.red);
      case 'audio':
        return Icon(Icons.audio_file, color: Colors.orange);
      case 'document':
        return Icon(Icons.description, color: Colors.green);
      default:
        return Icon(Icons.file_present, color: Colors.grey);
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

