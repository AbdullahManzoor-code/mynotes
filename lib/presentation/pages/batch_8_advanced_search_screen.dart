import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/presentation/bloc/note/note_bloc.dart';
import 'package:mynotes/presentation/bloc/note/note_event.dart';
import 'package:mynotes/presentation/bloc/advanced_search/advanced_search_bloc.dart';
import 'package:mynotes/core/routes/app_routes.dart';
import 'package:mynotes/presentation/design_system/app_colors.dart';
import 'package:mynotes/presentation/design_system/app_typography.dart';
import 'package:mynotes/presentation/design_system/app_spacing.dart';
import 'package:mynotes/core/services/global_ui_service.dart';
import 'package:mynotes/core/utils/app_logger.dart';
import 'package:mynotes/injection_container.dart';

/// Advanced Search Interface - Batch 8, Screen 1
/// Modernized to use Design System, Global UI Services, and BLoC
class AdvancedSearchScreen extends StatelessWidget {
  const AdvancedSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        AppLogger.i(
          'AdvancedSearchScreen: Building provider and loading history',
        );
        return getIt<AdvancedSearchBloc>()
          ..add(LoadAdvancedSearchHistoryEvent());
      },
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          title: Text(
            'Advanced Search',
            style: AppTypography.displayMedium(context, AppColors.darkText),
          ),
          centerTitle: true,
          backgroundColor: AppColors.lightSurface,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.darkText),
        ),
        body: const _AdvancedSearchBody(),
      ),
    );
  }
}

class _AdvancedSearchBody extends StatefulWidget {
  const _AdvancedSearchBody();

  @override
  State<_AdvancedSearchBody> createState() => _AdvancedSearchBodyState();
}

class _AdvancedSearchBodyState extends State<_AdvancedSearchBody> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    AppLogger.i('AdvancedSearchScreen: Body Disposed');
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdvancedSearchBloc, AdvancedSearchState>(
      builder: (context, state) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Field with Suggestions
              Padding(
                padding: AppSpacing.paddingAllM,
                child: _buildSearchField(context, state),
              ),

              // Filter and Sort Options
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterOptions(context, state),
                    AppSpacing.gapM,
                    _buildSortOptions(context, state),
                  ],
                ),
              ),
              AppSpacing.gapL,

              // Quick Suggestions or History
              if (_searchController.text.isEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: _buildSavedSearches(context, state),
                ),
                AppSpacing.gapM,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: _buildSearchHistory(context, state),
                ),
              ],
              AppSpacing.gapXXXL,
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchField(BuildContext context, AdvancedSearchState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          style: AppTypography.bodyMedium(context, AppColors.darkText),
          onChanged: (value) {
            AppLogger.i(
              'AdvancedSearchScreen: Search query changed to "$value"',
            );
            // Trigger rebuild for clear button visibility
            context.read<AdvancedSearchBloc>().add(
              AdvancedSearchQueryChangedEvent(value),
            );
          },
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              AppLogger.i(
                'AdvancedSearchScreen: Search query submitted: "$value"',
              );
              _performSearch(context, value);
            }
          },
          decoration: InputDecoration(
            hintText: 'Search notes, reminders, collections...',
            hintStyle: AppTypography.bodySmall(context, AppColors.tertiaryText),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.tertiaryText,
            ),
            filled: true,
            fillColor: AppColors.lightSurface,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(
                      Icons.bookmark_add_outlined,
                      color: AppColors.primaryColor,
                    ),
                    tooltip: 'Save Search',
                    onPressed: () {
                      final query = _searchController.text;
                      AppLogger.i(
                        'AdvancedSearchScreen: Saving search query "$query"',
                      );
                      context.read<AdvancedSearchBloc>().add(
                        SaveSearchEvent(query),
                      );
                      getIt<GlobalUiService>().showSuccess('Search saved');
                      getIt<GlobalUiService>().hapticFeedback();
                    },
                  ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(
                      Icons.clear_rounded,
                      color: AppColors.tertiaryText,
                    ),
                    onPressed: () {
                      AppLogger.i(
                        'AdvancedSearchScreen: Clearing search field',
                      );
                      _searchController.clear();
                      context.read<AdvancedSearchBloc>().add(
                        const AdvancedSearchQueryChangedEvent(''),
                      );
                    },
                  ),
              ],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 2.w),
            ),
          ),
        ),
        if (_searchController.text.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: _buildSearchSuggestions(context),
          ),
      ],
    );
  }

  Widget _buildSearchSuggestions(BuildContext context) {
    final suggestions =
        ['Recent idea', 'Meeting notes', 'Grocery list', 'Project plan']
            .where(
              (s) => s.toLowerCase().contains(
                _searchController.text.toLowerCase(),
              ),
            )
            .toList();

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ListTile(
            leading: const Icon(
              Icons.history_rounded,
              color: AppColors.tertiaryText,
              size: 20,
            ),
            title: Text(
              suggestion,
              style: AppTypography.bodySmall(context, AppColors.darkText),
            ),
            onTap: () {
              AppLogger.i(
                'AdvancedSearchScreen: Tapping suggestion "$suggestion"',
              );
              _performSearch(context, suggestion);
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterOptions(BuildContext context, AdvancedSearchState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Filter by Type', style: AppTypography.heading3(context)),
        AppSpacing.gapS,
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _buildFilterChip(context, state, 'all', 'All'),
            _buildFilterChip(context, state, 'notes', 'Notes'),
            _buildFilterChip(context, state, 'reminders', 'Reminders'),
            _buildFilterChip(context, state, 'collections', 'Collections'),
            _buildFilterChip(context, state, 'tags', 'Tags'),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    AdvancedSearchState state,
    String value,
    String label,
  ) {
    final isSelected = state.selectedFilter == value;

    return FilterChip(
      label: Text(label),
      labelStyle: AppTypography.labelSmall(
        context,
        isSelected ? AppColors.lightSurface : AppColors.secondaryText,
        isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      selected: isSelected,
      onSelected: (selected) {
        AppLogger.i('AdvancedSearchScreen: Selecting filter "$value"');
        context.read<AdvancedSearchBloc>().add(UpdateSearchFilterEvent(value));
        getIt<GlobalUiService>().hapticFeedback();
      },
      backgroundColor: AppColors.lightSurface,
      selectedColor: AppColors.primaryColor,
      checkmarkColor: AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
        side: BorderSide(
          color: isSelected ? Colors.transparent : AppColors.borderLight,
        ),
      ),
    );
  }

  Widget _buildSortOptions(BuildContext context, AdvancedSearchState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sort by', style: AppTypography.heading3(context)),
        AppSpacing.gapS,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildSortOption(context, state, 'Relevance', 'relevance'),
              AppSpacing.gapS,
              _buildSortOption(context, state, 'Recent', 'recent'),
              AppSpacing.gapS,
              _buildSortOption(context, state, 'Oldest', 'oldest'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    AdvancedSearchState state,
    String label,
    String value,
  ) {
    final isSelected = state.selectedSort == value;
    return GestureDetector(
      onTap: () {
        AppLogger.i('AdvancedSearchScreen: Selecting sort option "$value"');
        context.read<AdvancedSearchBloc>().add(UpdateSearchSortEvent(value));
        getIt<GlobalUiService>().hapticFeedback();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall(
            context,
            isSelected ? AppColors.lightSurface : AppColors.secondaryText,
            isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSavedSearches(BuildContext context, AdvancedSearchState state) {
    if (state.savedSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Saved Searches', style: AppTypography.heading3(context)),
        AppSpacing.gapS,
        ...state.savedSearches.map((search) {
          return Card(
            elevation: 0,
            color: AppColors.lightSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
              side: const BorderSide(color: AppColors.borderLight),
            ),
            margin: EdgeInsets.only(bottom: 8.h),
            child: ListTile(
              leading: const Icon(
                Icons.bookmark_rounded,
                color: AppColors.primaryColor,
                size: 20,
              ),
              title: Text(
                search,
                style: AppTypography.bodyMedium(
                  context,
                  AppColors.primaryText,
                  FontWeight.bold,
                ),
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.secondaryText,
                ),
                onSelected: (value) {
                  if (value == 'view') {
                    AppLogger.i(
                      'AdvancedSearchScreen: Viewing saved search "$search"',
                    );
                    _performSearch(context, search);
                  } else if (value == 'delete') {
                    AppLogger.i(
                      'AdvancedSearchScreen: Deleting saved search "$search"',
                    );
                    context.read<AdvancedSearchBloc>().add(
                      RemoveSavedSearchEvent(search),
                    );
                    getIt<GlobalUiService>().hapticFeedback();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'view',
                    child: Text(
                      'View',
                      style: AppTypography.bodySmall(context),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete',
                      style: AppTypography.bodySmall(
                        context,
                        AppColors.errorColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSearchHistory(BuildContext context, AdvancedSearchState state) {
    if (state.searchHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Searches', style: AppTypography.heading3(context)),
            TextButton(
              onPressed: () {
                AppLogger.i('AdvancedSearchScreen: Clearing search history');
                context.read<AdvancedSearchBloc>().add(
                  const ClearSearchHistoryEvent(),
                );
                getIt<GlobalUiService>().hapticFeedback();
              },
              child: Text(
                'Clear',
                style: AppTypography.labelSmall(context, AppColors.errorColor),
              ),
            ),
          ],
        ),
        AppSpacing.gapS,
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: state.searchHistory.map((search) {
            return InputChip(
              label: Text(search),
              labelStyle: AppTypography.bodySmall(context),
              onSelected: (_) {
                AppLogger.i(
                  'AdvancedSearchScreen: Tapping history item "$search"',
                );
                _performSearch(context, search);
              },
              onDeleted: () {
                AppLogger.i(
                  'AdvancedSearchScreen: Removing history item "$search"',
                );
                context.read<AdvancedSearchBloc>().add(
                  RemoveFromSearchHistoryEvent(search),
                );
                getIt<GlobalUiService>().hapticFeedback();
              },
              backgroundColor: AppColors.lightSurface,
              deleteIconColor: AppColors.secondaryText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: const BorderSide(color: AppColors.borderLight),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _performSearch(BuildContext context, String query) {
    if (query.isEmpty) return;

    AppLogger.i('AdvancedSearchScreen: Performing search for "$query"');
    // Use the controller if provided from outside, but here we just navigate
    _searchController.text = query;

    context.read<AdvancedSearchBloc>().add(AddToSearchHistoryEvent(query));
    getIt<GlobalUiService>().hapticFeedback();

    // Perform search in NoteBloc
    context.read<NotesBloc>().add(SearchNotesEvent(query));

    // Navigate to results
    Navigator.pushNamed(context, AppRoutes.searchResults, arguments: query);
  }
}
