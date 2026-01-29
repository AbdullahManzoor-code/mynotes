import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/media_gallery_bloc.dart';
import 'package:mynotes/domain/services/media_filtering_service.dart';

/// Media Analytics Dashboard - Batch 4, Screen 2
class MediaAnalyticsDashboard extends StatefulWidget {
  const MediaAnalyticsDashboard({Key? key}) : super(key: key);

  @override
  State<MediaAnalyticsDashboard> createState() =>
      _MediaAnalyticsDashboardState();
}

class _MediaAnalyticsDashboardState extends State<MediaAnalyticsDashboard> {
  final _filtering = MediaFilteringService();
  late Future<Map<String, dynamic>> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  void _loadAnalytics() {
    // This will be called with actual data from BLoC
    final state = context.read<MediaGalleryBloc>().state;
    if (state is MediaGalleryLoaded) {
      _analyticsFuture = _filtering.getMediaAnalytics(state.mediaItems);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Analytics'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loadAnalytics();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _analyticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final analytics = snapshot.data ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall Stats
                _buildOverallStatsCards(analytics),
                const SizedBox(height: 24),

                // Media Type Breakdown
                _buildTypeBreakdownSection(analytics),
                const SizedBox(height: 24),

                // Storage Analysis
                _buildStorageAnalysisSection(analytics),
                const SizedBox(height: 24),

                // Timeline Stats
                _buildTimelineStatsSection(analytics),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverallStatsCards(Map<String, dynamic> analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overall Statistics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildStatCard(
              'Total Items',
              '${analytics['totalCount'] ?? 0}',
              Icons.image,
              Colors.blue,
            ),
            _buildStatCard(
              'Total Size',
              _formatBytes(analytics['totalSize'] ?? 0),
              Icons.storage,
              Colors.orange,
            ),
            _buildStatCard(
              'Avg Size',
              _formatBytes(analytics['averageSize'] ?? 0),
              Icons.straighten,
              Colors.green,
            ),
            _buildStatCard(
              'Items/Day',
              '${(analytics['averageItemsPerDay'] ?? 0).toStringAsFixed(1)}',
              Icons.calendar_today,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBreakdownSection(Map<String, dynamic> analytics) {
    final typeBreakdown = analytics['typeBreakdown'] as Map<String, dynamic>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Media Type Distribution',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: typeBreakdown.length,
          itemBuilder: (context, index) {
            final type = typeBreakdown.keys.elementAt(index);
            final count = typeBreakdown[type] as int;
            final total = analytics['totalCount'] as int? ?? 1;
            final percentage = (count / total * 100).toStringAsFixed(1);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$type ($count)'),
                      Text('$percentage%'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: count / total,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStorageAnalysisSection(Map<String, dynamic> analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Storage Analysis',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  title: Text('Total Size'),
                  trailing: Text(
                    _formatBytes(analytics['totalSize'] ?? 0),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text('Average Size per Item'),
                  trailing: Text(
                    _formatBytes(analytics['averageSize'] ?? 0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineStatsSection(Map<String, dynamic> analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timeline',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  title: Text('Oldest Item'),
                  subtitle: Text(analytics['oldestItem']?.toString() ?? 'N/A'),
                  leading: Icon(Icons.history),
                ),
                Divider(),
                ListTile(
                  title: Text('Newest Item'),
                  subtitle: Text(analytics['newestItem']?.toString() ?? 'N/A'),
                  leading: Icon(Icons.new_releases),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

