import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/media_gallery_bloc.dart';
import 'package:mynotes/domain/services/advanced_search_ranking_service.dart';

/// Media Search Results - Batch 4, Screen 4
class MediaSearchResultsScreen extends StatefulWidget {
  final String query;

  const MediaSearchResultsScreen({Key? key, required this.query})
    : super(key: key);

  @override
  State<MediaSearchResultsScreen> createState() =>
      _MediaSearchResultsScreenState();
}

class _MediaSearchResultsScreenState extends State<MediaSearchResultsScreen> {
  final _search = AdvancedSearchRankingService();
  late Future<List<({dynamic item, double score})>> _searchResults;

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  void _performSearch() {
    final state = context.read<MediaGalleryBloc>().state;
    if (state is MediaGalleryLoaded) {
      _searchResults = _search.advancedSearch(
        items: state.mediaItems,
        query: widget.query,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results: "${widget.query}"'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<({dynamic item, double score})>>(
        future: _searchResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final results = snapshot.data ?? [];

          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No results found for "${widget.query}"',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('Try using different keywords or filters'),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Results Count
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${results.length} result${results.length != 1 ? 's' : ''} found',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Text('Relevance (High to Low)'),
                          onTap: () {
                            // Already sorted by relevance
                          },
                        ),
                        PopupMenuItem(
                          child: Text('Most Recent'),
                          onTap: () {
                            // Sort by date
                          },
                        ),
                        PopupMenuItem(
                          child: Text('Oldest First'),
                          onTap: () {
                            // Sort by date ascending
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Results List
              Expanded(
                child: ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    final item = result.item;
                    final score = result.score;
                    return _buildResultCard(item, score, index + 1);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResultCard(dynamic item, double score, int rank) {
    final relevancePercentage = (score * 10).clamp(0, 100).toInt();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rank and Title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name ?? 'Unnamed',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.description != null &&
                          item.description.isNotEmpty)
                        Text(
                          item.description,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Relevance Score
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Relevance'),
                          Text('$relevancePercentage%'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: relevancePercentage / 100,
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Metadata
            Row(
              children: [
                if (item.type != null) ...[
                  Chip(
                    label: Text(item.type),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                ],
                if (item.tags != null && (item.tags as List).isNotEmpty) ...[
                  Chip(
                    label: Text('${(item.tags as List).length} tags'),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                ],
                if (item.createdAt != null)
                  Text(
                    _formatDate(item.createdAt),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.open_in_full),
                  label: Text('View'),
                  onPressed: () {
                    // View item details
                  },
                ),
                SizedBox(width: 4),
                TextButton.icon(
                  icon: Icon(Icons.info_outline),
                  label: Text('Details'),
                  onPressed: () {
                    _showItemDetails(item);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showItemDetails(dynamic item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Item Details',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Name'),
              subtitle: Text(item.name ?? 'Unnamed'),
            ),
            if (item.type != null)
              ListTile(title: Text('Type'), subtitle: Text(item.type)),
            if (item.size != null)
              ListTile(
                title: Text('Size'),
                subtitle: Text(_formatBytes(item.size)),
              ),
            if (item.createdAt != null)
              ListTile(
                title: Text('Created'),
                subtitle: Text(item.createdAt.toString()),
              ),
            if (item.tags != null && (item.tags as List).isNotEmpty)
              ListTile(
                title: Text('Tags'),
                subtitle: Wrap(
                  spacing: 8,
                  children: (item.tags as List).map((tag) {
                    return Chip(label: Text(tag.toString()));
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
