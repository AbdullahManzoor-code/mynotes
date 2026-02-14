import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/note.dart';
import '../bloc/note/note_bloc.dart';
import '../bloc/note/note_state.dart';
import '../bloc/note/note_event.dart';
import '../design_system/design_system.dart';
import '../widgets/note_card_widget.dart';
import 'enhanced_note_editor_screen.dart';

/// Search & Filter Screen
/// Advanced search with filtering by content, media, reminders, and date
/// Refactored to use NotesBloc for centralized state management
class SearchFilterScreen extends StatelessWidget {
  const SearchFilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotesBloc, NoteState>(
      builder: (context, state) {
        final query = state is NotesLoaded ? state.searchQuery : '';
        final searchController = TextEditingController(text: query);
        searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: searchController.text.length),
        );

        return Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60.h),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AppBar(
                  backgroundColor: AppColors.background(
                    context,
                  ).withOpacity(0.8),
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, size: 20.sp),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: TextField(
                    controller: searchController,
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
                    onChanged: (value) => _performSearch(context, value),
                    onSubmitted: (value) => _performSearch(context, value),
                  ),
                  actions: [
                    IconButton(
                      icon: Badge(
                        isLabelVisible: _hasActiveFilters(state),
                        child: Icon(Icons.filter_list, size: 22.sp),
                      ),
                      onPressed: () => _showFilterSheet(context, state),
                    ),
                    SizedBox(width: 4.w),
                  ],
                ),
              ),
            ),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------------

  void _performSearch(BuildContext context, String query) {
    context.read<NotesBloc>().add(
      UpdateNoteViewConfigEvent(searchQuery: query),
    );
  }

  // ---------------------------------------------------------------------------
  // Filters
  // ---------------------------------------------------------------------------

  bool _hasActiveFilters(NoteState state) {
    if (state is! NotesLoaded) return false;
    return state.filterWithImages ||
        state.filterWithAudio ||
        state.filterWithVideo ||
        state.filterWithReminders ||
        state.filterWithTodos;
  }

  void _clearFilters(BuildContext context) {
    context.read<NotesBloc>().add(
      const UpdateNoteViewConfigEvent(
        filterWithImages: false,
        filterWithAudio: false,
        filterWithVideo: false,
        filterWithReminders: false,
        filterWithTodos: false,
        sortBy: NoteSortOption.dateModified,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------------

  Widget _buildBody(BuildContext context, NoteState state) {
    if (state is NoteLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is NoteError) {
      return _buildError(context, state);
    }

    if (state is NotesLoaded) {
      if (state.searchQuery.isEmpty) return _buildEmptySearch();
      if (state.displayedNotes.isEmpty) return _buildNoResults(context);
      return _buildResultsList(context, state);
    }

    return const SizedBox.shrink();
  }

  // ---------------------------------------------------------------------------
  // Error
  // ---------------------------------------------------------------------------

  Widget _buildError(BuildContext context, NoteError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.errorColor),
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
            onPressed: () =>
                context.read<NotesBloc>().add(const LoadNotesEvent()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Results list
  // ---------------------------------------------------------------------------

  Widget _buildResultsList(BuildContext context, NotesLoaded state) {
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
                '${state.displayedNotes.length} result'
                '${state.displayedNotes.length == 1 ? '' : 's'}',
                style: AppTypography.bodyLarge(null, null, FontWeight.w600),
              ),
              const Spacer(),
              if (_hasActiveFilters(state))
                GestureDetector(
                  onTap: () => _clearFilters(context),
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

        // Notes
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: state.displayedNotes.length,
            itemBuilder: (context, index) {
              final note = state.displayedNotes[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: NoteCardWidget(
                  note: note,
                  onTap: () => _openNote(context, note),
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

  // ---------------------------------------------------------------------------
  // Empty / no‑results states
  // ---------------------------------------------------------------------------

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

  Widget _buildNoResults(BuildContext context) {
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
          GestureDetector(
            onTap: () => _clearFilters(context),
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

  // ---------------------------------------------------------------------------
  // Filter bottom sheet
  // ---------------------------------------------------------------------------

  void _showFilterSheet(BuildContext context, NoteState state) {
    if (state is! NotesLoaded) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) {
          return BlocBuilder<NotesBloc, NoteState>(
            builder: (context, currentState) {
              if (currentState is! NotesLoaded) {
                return const SizedBox.shrink();
              }

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
                          // --- Media filters ---
                          Text(
                            'Filter by Media',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 12.h),
                          _buildFilterChip(
                            'Images',
                            Icons.image,
                            currentState.filterWithImages,
                            (v) => context.read<NotesBloc>().add(
                              UpdateNoteViewConfigEvent(filterWithImages: v),
                            ),
                          ),
                          _buildFilterChip(
                            'Audio',
                            Icons.audiotrack,
                            currentState.filterWithAudio,
                            (v) => context.read<NotesBloc>().add(
                              UpdateNoteViewConfigEvent(filterWithAudio: v),
                            ),
                          ),
                          _buildFilterChip(
                            'Video',
                            Icons.videocam,
                            currentState.filterWithVideo,
                            (v) => context.read<NotesBloc>().add(
                              UpdateNoteViewConfigEvent(filterWithVideo: v),
                            ),
                          ),

                          SizedBox(height: 24.h),

                          // --- Feature filters ---
                          Text(
                            'Filter by Features',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 12.h),
                          _buildFilterChip(
                            'Has Reminders',
                            Icons.alarm,
                            currentState.filterWithReminders,
                            (v) => context.read<NotesBloc>().add(
                              UpdateNoteViewConfigEvent(filterWithReminders: v),
                            ),
                          ),
                          _buildFilterChip(
                            'Has To-dos',
                            Icons.checklist,
                            currentState.filterWithTodos,
                            (v) => context.read<NotesBloc>().add(
                              UpdateNoteViewConfigEvent(filterWithTodos: v),
                            ),
                          ),

                          SizedBox(height: 24.h),

                          // --- Sort options ---
                          Text(
                            'Sort by',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 12.h),
                          ...NoteSortOption.values.map((option) {
                            return RadioListTile<NoteSortOption>(
                              value: option,
                              groupValue: currentState.sortBy,
                              onChanged: (value) {
                                if (value != null) {
                                  context.read<NotesBloc>().add(
                                    UpdateNoteViewConfigEvent(sortBy: value),
                                  );
                                }
                              },
                              title: Text(option.displayName),
                              activeColor: AppColors.primaryColor,
                            );
                          }),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(color: Colors.white),
                        ),
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

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _openNote(BuildContext context, Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EnhancedNoteEditorScreen(note: note)),
    );
  }
}
