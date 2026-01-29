import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/domain/entities/note.dart';
import 'package:mynotes/presentation/bloc/note_bloc.dart';
import 'package:mynotes/presentation/bloc/note_state.dart';
import 'package:mynotes/domain/services/advanced_search_ranking_service.dart';

/// Search Results with Ranking - Batch 8, Screen 2
class SearchResultsScreen extends StatefulWidget {
  final String searchQuery;

  const SearchResultsScreen({Key? key, required this.searchQuery})
    : super(key: key);

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final _rankingService = AdvancedSearchRankingService();
  String _sortBy = 'relevance';
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Results for "${widget.searchQuery}"')),
      body: BlocBuilder<NotesBloc, NoteState>(
        builder: (context, state) {
          if (state is NoteError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is SearchResultsLoaded) {
            if (state.results.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('No results found'),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Results Summary and Sorting
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildResultsHeader(state),
                ),

                // Results List
                Expanded(child: _buildResultsList(state)),
              ],
            );
          }

          return Center(child: Text('Start searching'));
        },
      ),
    );
  }

  Widget _buildResultsHeader(SearchResultsLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${state.results.length} results found',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.tune),
              onPressed: () => setState(() => _showFilters = !_showFilters),
            ),
          ],
        ),
        if (_showFilters) ...[const SizedBox(height: 12), _buildSortOptions()],
      ],
    );
  }

  Widget _buildSortOptions() {
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: Text('Relevance'),
          selected: _sortBy == 'relevance',
          onSelected: (selected) {
            setState(() => _sortBy = 'relevance');
          },
        ),
        FilterChip(
          label: Text('Recent'),
          selected: _sortBy == 'recent',
          onSelected: (selected) {
            setState(() => _sortBy = 'recent');
          },
        ),
        FilterChip(
          label: Text('Oldest'),
          selected: _sortBy == 'oldest',
          onSelected: (selected) {
            setState(() => _sortBy = 'oldest');
          },
        ),
      ],
    );
  }

  Widget _buildResultsList(SearchResultsLoaded state) {
    final sortedResults = _sortResults(state.results);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedResults.length,
      itemBuilder: (context, index) {
        final result = sortedResults[index];
        return _buildResultCard(index + 1, result);
      },
    );
  }

  List<Map<String, dynamic>> _sortResults(List<dynamic> results) {
    var rawResults = results.map((e) {
      if (e is Note) {
        return {
          'title': e.title,
          'preview': e.content,
          'date': e.updatedAt,
          'relevance': 100, // Default relevance for simple search
          'type': 'note',
        };
      }
      return e as Map<String, dynamic>;
    }).toList();

    final sorted = List<Map<String, dynamic>>.from(rawResults);
    if (_sortBy == 'relevance') {
      sorted.sort(
        (a, b) => (b['relevance'] as num).compareTo(a['relevance'] as num),
      );
    } else if (_sortBy == 'recent') {
      sorted.sort((a, b) {
        final dateA = (a['date'] as DateTime?);
        final dateB = (b['date'] as DateTime?);
        if (dateA == null || dateB == null) return 0;
        return dateB.compareTo(dateA);
      });
    }
    return sorted;
  }

  Widget _buildResultCard(int rank, Map<String, dynamic> result) {
    final relevance = (result['relevance'] as num?)?.toInt() ?? 0;
    final type = result['type'] as String? ?? 'note';
    final title = result['title'] as String? ?? 'Untitled';
    final preview = result['preview'] as String? ?? '';
    final date = result['date'] as DateTime? ?? DateTime.now();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showResultDetails(result),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rank Badge
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
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (preview.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            preview,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Relevance Score
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getRelevanceColor(relevance).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$relevance%',
                      style: TextStyle(
                        color: _getRelevanceColor(relevance),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Metadata
              Row(
                children: [
                  Chip(label: Text(type), visualDensity: VisualDensity.compact),
                  const SizedBox(width: 8),
                  Icon(Icons.schedule, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),

              // Relevance Progress Bar
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: relevance / 100,
                  minHeight: 4,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation(
                    _getRelevanceColor(relevance),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResultDetails(Map<String, dynamic> result) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                result['title'] as String? ?? 'Untitled',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Details',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _detailRow('Type', result['type'] as String? ?? 'Note'),
              _detailRow('Date', _formatDate(result['date'] as DateTime?)),
              _detailRow('Relevance', '${result['relevance']}%'),
              if (result['tags'] != null) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children:
                      (result['tags'] as List<String>?)
                          ?.map((tag) => Chip(label: Text(tag)))
                          .toList() ??
                      [],
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to full item view
                  },
                  child: Text('View Full Item'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  Color _getRelevanceColor(int relevance) {
    if (relevance >= 80) return Colors.green;
    if (relevance >= 60) return Colors.blue;
    if (relevance >= 40) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
