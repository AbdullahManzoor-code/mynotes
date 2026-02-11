import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/note.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_state.dart';
import '../bloc/note_event.dart';
import '../design_system/design_system.dart';
import '../widgets/note_card_widget.dart';
import 'enhanced_note_editor_screen.dart';

/// Search & Filter Screen
/// Advanced search with filtering by content, media, reminders, and date
class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

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

  List<dynamic> _searchResults = [];

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

  void _applyFilters(List<dynamic> results) {
    // Convert results to Notes if they are in Map format
    var filtered = results
        .map((item) {
          if (item is Note) return item;
          if (item is Map<String, dynamic> && item['note'] is Note) {
            return item['note'] as Note;
          }
          return null;
        })
        .whereType<Note>()
        .toList();

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
      backgroundColor: AppColors.background(context),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: AppColors.background(context).withOpacity(0.8),
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, size: 20.sp),
                onPressed: () => Navigator.pop(context),
              ),
              title: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                style: AppTypography.bodyLarge(null, null, FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  hintStyle: AppTypography.bodyLarge(
                    null,
                    AppColors.textMuted.withOpacity(0.5),
                    FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, size: 22.sp),
                ),
                onChanged: _performSearch,
              ),
              actions: [
                IconButton(
                  icon: Badge(
                    isLabelVisible: _hasActiveFilters,
                    child: Icon(Icons.filter_list, size: 22.sp),
                  ),
                  onPressed: _showFilterSheet,
                ),
                SizedBox(width: 4.w),
              ],
            ),
          ),
        ),
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

            if (state is NoteError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.errorColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading notes',
                      style: AppTypography.heading3(
                        context,
                        AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: AppTypography.bodyMedium(
                        context,
                        AppColors.textSecondary(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<NotesBloc>().add(const LoadNotesEvent());
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
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
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            border: Border(
              bottom: BorderSide(
                color: AppColors.borderLight.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                '${_searchResults.length} result${_searchResults.length == 1 ? '' : 's'}',
                style: AppTypography.bodyLarge(null, null, FontWeight.w600),
              ),
              const Spacer(),
              if (_hasActiveFilters)
                GestureDetector(
                  onTap: _clearFilters,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusFull,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.close,
                          size: 16.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Clear filters',
                          style: AppTypography.captionSmall(null).copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
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
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_rounded,
              size: 56.sp,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Search your notes',
            style: AppTypography.heading2(null, null, FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            'Type to find notes by title or content',
            style: AppTypography.bodyMedium(null, AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48.w),
            child: Text(
              'Try searching for keywords, tags, or phrases',
              style: AppTypography.captionSmall(
                null,
              ).copyWith(color: AppColors.textMuted.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
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
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 56.sp,
              color: Colors.orange.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No results found',
            style: AppTypography.heading2(null, null, FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try adjusting your search or filters',
            style: AppTypography.bodyMedium(null, AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          if (_hasActiveFilters)
            GestureDetector(
              onTap: _clearFilters,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.filter_list_off,
                      size: 20.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Clear all filters',
                      style: AppTypography.bodyMedium(
                        null,
                        AppColors.primary,
                        FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                          }),
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
      MaterialPageRoute(builder: (_) => EnhancedNoteEditorScreen(note: note)),
    );
  }
}
