import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/note_bloc.dart';
import 'package:mynotes/presentation/bloc/note_event.dart';
import 'package:mynotes/domain/services/advanced_search_ranking_service.dart';

/// Advanced Search Interface - Batch 8, Screen 1
class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final _searchController = TextEditingController();
  final _rankingService = AdvancedSearchRankingService();
  List<String> _searchHistory = [];
  List<String> _savedSearches = [];
  String _selectedSort = 'relevance';
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  void _loadSearchHistory() {
    // TODO: Load from storage
    _searchHistory = ['Flutter', 'Dart', 'BLoC pattern', 'Mobile app'];
    _savedSearches = ['High priority reminders', 'Recent notes'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Search'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Field with Suggestions
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildSearchField(),
            ),

            // Filter and Sort Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterOptions(),
                  const SizedBox(height: 12),
                  _buildSortOptions(),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Suggestions or History
            if (_searchController.text.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSavedSearches(),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSearchHistory(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search notes, reminders, collections...',
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        if (_searchController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _buildSearchSuggestions(),
          ),
      ],
    );
  }

  Widget _buildSearchSuggestions() {
    final suggestions = [
      'Search by title',
      'Search by tag',
      'Search by date',
      'Search by content',
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.search_outlined),
            title: Text(suggestions[index]),
            onTap: () {
              _searchController.text = suggestions[index];
              _performSearch();
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Type',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildFilterChip('all', 'All'),
            _buildFilterChip('notes', 'Notes'),
            _buildFilterChip('reminders', 'Reminders'),
            _buildFilterChip('collections', 'Collections'),
            _buildFilterChip('tags', 'Tags'),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = value);
      },
    );
  }

  Widget _buildSortOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort by',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(label: Text('Relevance'), value: 'relevance'),
            ButtonSegment(label: Text('Recent'), value: 'recent'),
            ButtonSegment(label: Text('Oldest'), value: 'oldest'),
          ],
          selected: {_selectedSort},
          onSelectionChanged: (Set<String> newSelection) {
            setState(() => _selectedSort = newSelection.first);
          },
        ),
      ],
    );
  }

  Widget _buildSavedSearches() {
    if (_savedSearches.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saved Searches',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._savedSearches.map((search) {
          return Card(
            child: ListTile(
              leading: Icon(Icons.bookmark, color: Colors.blue),
              title: Text(search),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text('View'),
                    onTap: () => _performSearch(search),
                  ),
                  PopupMenuItem(
                    child: Text('Delete'),
                    onTap: () {
                      setState(() => _savedSearches.remove(search));
                    },
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSearchHistory() {
    if (_searchHistory.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => setState(() => _searchHistory.clear()),
              child: Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: _searchHistory.map((search) {
            return InputChip(
              label: Text(search),
              onSelected: (_) => _performSearch(search),
              onDeleted: () {
                setState(() => _searchHistory.remove(search));
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _performSearch([String? query]) {
    final searchQuery = query ?? _searchController.text;
    if (searchQuery.isEmpty) return;

    // Add to history
    if (!_searchHistory.contains(searchQuery)) {
      _searchHistory.insert(0, searchQuery);
      if (_searchHistory.length > 10) _searchHistory.removeLast();
    }

    // Perform search
    context.read<NotesBloc>().add(SearchNotesEvent(searchQuery));

    // Navigate to results
    Navigator.pushNamed(context, '/search_results', arguments: searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
