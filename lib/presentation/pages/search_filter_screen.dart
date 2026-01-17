import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/note.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_state.dart';
import '../bloc/note_event.dart';
import '../widgets/note_card_widget.dart';
import 'note_editor_page.dart';

/// Search & Filter Screen
/// Advanced search with filtering by content, media, reminders, and date
class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({Key? key}) : super(key: key);

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  // Filter options
  bool _filterImages = false;
  bool _filterAudio = false;
  bool _filterVideo = false;
  bool _filterReminders = false;
  bool _filterTodos = false;
  NoteSortBy _sortBy = NoteSortBy.newest;

  List<Note> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchFocus.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    context.read<NotesBloc>().add(SearchNotesEvent(query));
  }

  void _applyFilters(List<Note> notes) {
    var filtered = notes;

    // Filter by media types
    if (_filterImages) {
      filtered = filtered.where((note) => note.imagesCount > 0).toList();
    }
    if (_filterAudio) {
      filtered = filtered.where((note) => note.audioCount > 0).toList();
    }
    if (_filterVideo) {
      filtered = filtered.where((note) => note.videoCount > 0).toList();
    }

    // Filter by features
    if (_filterReminders) {
      filtered = filtered
          .where((note) => note.alarms != null && note.alarms!.isNotEmpty)
          .toList();
    }
    if (_filterTodos) {
      filtered = filtered.where((note) => note.hasTodos).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case NoteSortBy.newest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case NoteSortBy.oldest:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case NoteSortBy.alphabetical:
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case NoteSortBy.mostModified:
        filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case NoteSortBy.pinned:
        filtered.sort((a, b) {
          if (a.isPinned == b.isPinned) return 0;
          return a.isPinned ? -1 : 1;
        });
        break;
      case NoteSortBy.completion:
        filtered.sort((a, b) {
          final aPercent = a.completionPercentage;
          final bPercent = b.completionPercentage;
          return bPercent.compareTo(aPercent);
        });
        break;
    }

    setState(() => _searchResults = filtered);
  }

  void _clearFilters() {
    setState(() {
      _filterImages = false;
      _filterAudio = false;
      _filterVideo = false;
      _filterReminders = false;
      _filterTodos = false;
      _sortBy = NoteSortBy.newest;
    });
    _performSearch(_searchController.text);
  }

  bool get _hasActiveFilters =>
      _filterImages ||
      _filterAudio ||
      _filterVideo ||
      _filterReminders ||
      _filterTodos;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          decoration: const InputDecoration(
            hintText: 'Search notes...',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: _performSearch,
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _hasActiveFilters,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: BlocListener<NotesBloc, NoteState>(
        listener: (context, state) {
          if (state is SearchResultsLoaded) {
            _applyFilters(state.results);
          }
        },
        child: BlocBuilder<NotesBloc, NoteState>(
          builder: (context, state) {
            if (state is NoteLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_searchController.text.isEmpty) {
              return _buildEmptySearch();
            }

            if (_searchResults.isEmpty) {
              return _buildNoResults();
            }

            return _buildResultsList();
          },
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return Column(
      children: [
        // Results header
        Container(
          padding: EdgeInsets.all(16.w),
          color: AppColors.primaryColor.withOpacity(0.1),
          child: Row(
            children: [
              Text(
                '${_searchResults.length} result${_searchResults.length == 1 ? '' : 's'}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_hasActiveFilters)
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: Icon(Icons.clear, size: 18.sp),
                  label: const Text('Clear filters'),
                ),
            ],
          ),
        ),

        // Results list
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final note = _searchResults[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: NoteCardWidget(
                  note: note,
                  onTap: () => _openNote(note),
                  onLongPress: () {},
                  onDelete: () {},
                  onPin: () {},
                  onColorChange: (_) {},
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80.sp, color: AppColors.grey300),
          SizedBox(height: 16.h),
          Text(
            'Search your notes',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.grey600),
          ),
          SizedBox(height: 8.h),
          Text(
            'Type to find notes by title or content',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80.sp, color: AppColors.grey300),
          SizedBox(height: 16.h),
          Text(
            'No results found',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.grey600),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try different keywords or filters',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
          if (_hasActiveFilters) ...[
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear),
              label: const Text('Clear filters'),
            ),
          ],
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Text(
                          'Filters & Sort',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: [
                          // Media filters
                          Text(
                            'Filter by Media',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 12.h),
                          _buildFilterChip(
                            'Images',
                            Icons.image,
                            _filterImages,
                            (value) {
                              setState(() => _filterImages = value);
                              setModalState(() => _filterImages = value);
                            },
                          ),
                          _buildFilterChip(
                            'Audio',
                            Icons.audiotrack,
                            _filterAudio,
                            (value) {
                              setState(() => _filterAudio = value);
                              setModalState(() => _filterAudio = value);
                            },
                          ),
                          _buildFilterChip(
                            'Video',
                            Icons.videocam,
                            _filterVideo,
                            (value) {
                              setState(() => _filterVideo = value);
                              setModalState(() => _filterVideo = value);
                            },
                          ),

                          SizedBox(height: 24.h),

                          // Feature filters
                          Text(
                            'Filter by Features',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 12.h),
                          _buildFilterChip(
                            'Has Reminders',
                            Icons.alarm,
                            _filterReminders,
                            (value) {
                              setState(() => _filterReminders = value);
                              setModalState(() => _filterReminders = value);
                            },
                          ),
                          _buildFilterChip(
                            'Has To-dos',
                            Icons.checklist,
                            _filterTodos,
                            (value) {
                              setState(() => _filterTodos = value);
                              setModalState(() => _filterTodos = value);
                            },
                          ),

                          SizedBox(height: 24.h),

                          // Sort options
                          Text(
                            'Sort by',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 12.h),
                          ...NoteSortBy.values.map((sortOption) {
                            return RadioListTile<NoteSortBy>(
                              value: sortOption,
                              groupValue: _sortBy,
                              onChanged: (value) {
                                setState(() => _sortBy = value!);
                                setModalState(() => _sortBy = value!);
                              },
                              title: Text(_getSortLabel(sortOption)),
                              activeColor: AppColors.primaryColor,
                            );
                          }).toList(),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Apply button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _performSearch(_searchController.text);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    IconData icon,
    bool isSelected,
    Function(bool) onSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            SizedBox(width: 8.w),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: onSelected,
        selectedColor: AppColors.primaryColor.withOpacity(0.2),
        checkmarkColor: AppColors.primaryColor,
      ),
    );
  }

  String _getSortLabel(NoteSortBy sortBy) {
    switch (sortBy) {
      case NoteSortBy.newest:
        return 'Newest first';
      case NoteSortBy.oldest:
        return 'Oldest first';
      case NoteSortBy.alphabetical:
        return 'Alphabetical (A-Z)';
      case NoteSortBy.mostModified:
        return 'Recently modified';
      case NoteSortBy.pinned:
        return 'Pinned first';
      case NoteSortBy.completion:
        return 'Completion %';
    }
  }

  void _openNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorPage(note: note)),
    );
  }
}
