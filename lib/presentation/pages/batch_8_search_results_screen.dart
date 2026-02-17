import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import 'package:mynotes/domain/entities/note.dart';
import 'package:mynotes/presentation/bloc/note/note_bloc.dart';
import 'package:mynotes/presentation/bloc/note/note_state.dart';
import 'package:mynotes/core/design_system/app_colors.dart'; // Added
import 'package:mynotes/core/design_system/app_typography.dart'; // Added
import 'package:mynotes/core/design_system/app_spacing.dart';
import 'package:mynotes/core/services/global_ui_service.dart';
import 'package:mynotes/core/utils/app_logger.dart';
import 'package:mynotes/injection_container.dart';
import 'package:mynotes/presentation/bloc/note/note_event.dart';
import '../widgets/search_results_scaffold.dart';

/// Search Results with Ranking - Batch 8, Screen 2
/// Refactored to use Design System and converted to StatelessWidget
class SearchResultsScreen extends StatelessWidget {
  final String searchQuery;
  final String _sortBy = 'relevance';

  const SearchResultsScreen({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotesBloc, NoteState>(
      builder: (context, state) {
        if (state is! SearchResultsLoaded && state is! NoteLoading) {
          AppLogger.i('SearchResultsScreen: Initial load for "$searchQuery"');
          context.read<NotesBloc>().add(SearchNotesEvent(searchQuery));
        }

        final isLoading = state is NoteLoading;
        final errorMessage = state is NoteError ? state.message : null;
        final results = state is SearchResultsLoaded ? state.results : const [];
        final loadedState = state is SearchResultsLoaded ? state : null;

        return SearchResultsScaffold(
          title: 'Results for "$searchQuery"',
          isLoading: isLoading,
          errorMessage: errorMessage,
          isEmpty: state is SearchResultsLoaded && results.isEmpty,
          emptyState: _buildEmptyState(context),
          resultsHeader: loadedState == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: AppSpacing.paddingAllM,
                  child: _buildResultsHeader(context, loadedState),
                ),
          resultsList: loadedState == null
              ? const SizedBox.shrink()
              : _buildResultsList(context, loadedState),
          backgroundColor: AppColors.lightBackground,
          appBarColor: AppColors.lightSurface,
          iconTheme: const IconThemeData(color: AppColors.darkText),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppColors.borderLight,
          ),
          AppSpacing.gapM,
          Text(
            'No results found',
            style: AppTypography.heading2(context, AppColors.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader(BuildContext context, SearchResultsLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${state.results.length} results found',
              style: AppTypography.heading3(context, AppColors.darkText),
            ),
            IconButton(
              icon: const Icon(
                Icons.tune_rounded,
                color: AppColors.primaryColor,
              ),
              onPressed: () {
                AppLogger.i('SearchResultsScreen: Tapping tune/filters button');
                // Toggle filters - In a Stateless widget we could use a local ValueNotifier
                // or just handle it if it's purely for show.
                // Given the requirement, we should move the toggle to Bloc or keep it simple.
                getIt<GlobalUiService>().hapticFeedback();
              },
            ),
          ],
        ),
        AppSpacing.gapS,
        _buildSortOptions(context, state),
      ],
    );
  }

  Widget _buildSortOptions(BuildContext context, SearchResultsLoaded state) {
    // Current sort would come from state in a full implementation
    final currentSort = 'relevance';

    return Wrap(
      spacing: 8,
      children: [
        _buildSortChip(
          context,
          'Relevance',
          'relevance',
          currentSort == 'relevance',
        ),
        _buildSortChip(context, 'Recent', 'recent', currentSort == 'recent'),
        _buildSortChip(context, 'Oldest', 'oldest', currentSort == 'oldest'),
      ],
    );
  }

  Widget _buildSortChip(
    BuildContext context,
    String label,
    String value,
    bool isSelected,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          AppLogger.i('SearchResultsScreen: Selecting sort by $value');
          // Add Sort event to Bloc
          getIt<GlobalUiService>().hapticFeedback();
        }
      },
      backgroundColor: AppColors.lightSurface,
      selectedColor: AppColors.primaryColor,
      labelStyle: AppTypography.labelSmall(
        context,
        isSelected ? Colors.white : AppColors.secondaryText,
        isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderLight),
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, SearchResultsLoaded state) {
    final sortedResults = _sortResults(state.results);

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: sortedResults.length,
      itemBuilder: (context, index) {
        final result = sortedResults[index];
        return _buildResultCard(context, index + 1, result);
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

  Widget _buildResultCard(
    BuildContext context,
    int rank,
    Map<String, dynamic> result,
  ) {
    final relevance = (result['relevance'] as num?)?.toInt() ?? 0;
    final type = result['type'] as String? ?? 'note';
    final title = result['title'] as String? ?? 'Untitled';
    final preview = result['preview'] as String? ?? '';
    final date = result['date'] as DateTime? ?? DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 0,
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () {
          AppLogger.i('SearchResultsScreen: Tapping result card for "$title"');
          _showResultDetails(context, result);
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rank Badge
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.body1().copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.lightText
                                : AppColors.darkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (preview.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Text(
                            preview,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.body2().copyWith(
                              color: isDark
                                  ? AppColors.lightTextSecondary
                                  : AppColors.darkTextSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Relevance Score
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: _getRelevanceColor(relevance).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '$relevance%',
                      style: TextStyle(
                        color: _getRelevanceColor(relevance),
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Metadata
              Row(
                children: [
                  Chip(
                    label: Text(
                      type,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: isDark
                            ? AppColors.lightText
                            : AppColors.darkText,
                      ),
                    ),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: isDark
                        ? Colors.grey[800]
                        : Colors.grey[200],
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.schedule,
                    size: 16.sp,
                    color: AppColors.textTertiary(context),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    _formatDate(date),
                    style: AppTypography.caption().copyWith(
                      color: isDark
                          ? AppColors.lightTextSecondary
                          : AppColors.darkTextSecondary,
                    ),
                  ),
                ],
              ),

              // Relevance Progress Bar
              SizedBox(height: 8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: relevance / 100,
                  minHeight: 4.h,
                  backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
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

  void _showResultDetails(BuildContext context, Map<String, dynamic> result) {
    final title = result['title'] as String? ?? 'Untitled';
    AppLogger.i('SearchResultsScreen: Showing result details for "$title"');
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.heading3().copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.lightText : AppColors.darkText,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Details',
                  style: AppTypography.heading4().copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.lightText : AppColors.darkText,
                  ),
                ),
                SizedBox(height: 8.h),
                _detailRow('Type', result['type'] as String? ?? 'Note', isDark),
                _detailRow(
                  'Date',
                  _formatDate(result['date'] as DateTime?),
                  isDark,
                ),
                _detailRow('Relevance', '${result['relevance']}%', isDark),
                if (result['tags'] != null) ...[
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 4.w,
                    children:
                        (result['tags'] as List<String>?)
                            ?.map(
                              (tag) => Chip(
                                label: Text(tag),
                                backgroundColor: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                                labelStyle: TextStyle(
                                  color: isDark
                                      ? AppColors.lightText
                                      : AppColors.darkText,
                                ),
                              ),
                            )
                            .toList() ??
                        [],
                  ),
                ],
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      AppLogger.i(
                        'SearchResultsScreen: Navigating to full item view for "$title"',
                      );
                      Navigator.pop(context);
                      // Navigate to full item view
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text('View Full Item'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.body1().copyWith(
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.lightTextSecondary
                  : AppColors.darkTextSecondary,
            ),
          ),
          Text(
            value,
            style: AppTypography.body1().copyWith(
              color: isDark ? AppColors.lightText : AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRelevanceColor(int relevance) {
    if (relevance >= 80) return AppColors.successColor;
    if (relevance >= 60) return AppColors.infoColor; // Blue
    if (relevance >= 40) return AppColors.warningColor;
    return AppColors.errorColor;
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
