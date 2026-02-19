import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/app_logger.dart';
import 'package:mynotes/presentation/design_system/app_colors.dart';
import 'package:mynotes/presentation/design_system/app_typography.dart';
import 'package:mynotes/presentation/bloc/note/note_bloc.dart';
import 'package:mynotes/presentation/bloc/note/note_state.dart';
import 'package:mynotes/presentation/bloc/note/note_event.dart';

/// Search Operators Screen (ORG-006)
/// Advanced query syntax support (tag:work, color:blue, etc.)
/// Refactored to use NotesBloc for centralized state management
class SearchOperatorsScreen extends StatelessWidget {
  const SearchOperatorsScreen({super.key});

  final operatorDefinitions = const [
    {
      'operator': 'tag:',
      'description': 'Filter by tag',
      'example': 'tag:work',
      'color': Colors.blue,
    },
    {
      'operator': 'color:',
      'description': 'Filter by color',
      'example': 'color:blue',
      'color': Colors.purple,
    },
    {
      'operator': 'type:',
      'description': 'Filter by note type',
      'example': 'type:text',
      'color': Colors.green,
    },
    {
      'operator': 'before:',
      'description': 'Created before date',
      'example': 'before:2024-01-01',
      'color': Colors.orange,
    },
    {
      'operator': 'after:',
      'description': 'Created after date',
      'example': 'after:2024-01-01',
      'color': Colors.red,
    },
    {
      'operator': 'is:',
      'description': 'Filter by status',
      'example': 'is:pinned',
      'color': Colors.pink,
    },
    {
      'operator': '-',
      'description': 'Exclude terms',
      'example': '-tag:personal',
      'color': Colors.grey,
    },
    {
      'operator': '""',
      'description': 'Exact phrase match',
      'example': '"exact phrase"',
      'color': Colors.indigo,
    },
  ];

  @override
  Widget build(BuildContext context) {
    AppLogger.i('SearchOperatorsScreen: build');
    return BlocBuilder<NotesBloc, NoteState>(
      builder: (context, state) {
        if (state is! NotesLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final searchController = TextEditingController(text: state.searchQuery);
        searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: searchController.text.length),
        );

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
          appBar: _buildAppBar(context),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(context, state, searchController),
                if (_parseAppliedOperators(state.searchQuery).isNotEmpty) ...[
                  _buildAppliedOperators(context, state),
                ],
                _buildOperatorsGrid(context, state, searchController),
                _buildSearchHistory(context, state),
                _buildHelpSection(context),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? AppColors.lightText : AppColors.darkText,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Advanced Search',
        style: AppTypography.heading2().copyWith(
          color: isDark ? AppColors.lightText : AppColors.darkText,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.help_outline,
            color: isDark ? AppColors.lightText : AppColors.darkText,
          ),
          onPressed: () => _showSearchHelp(context),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    NotesLoaded state,
    TextEditingController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider(context), width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Try: tag:work color:blue before:2024-01-01',
              hintStyle: AppTypography.body2().copyWith(
                color: isDark
                    ? AppColors.lightTextSecondary
                    : AppColors.darkTextSecondary,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: isDark
                    ? AppColors.lightTextSecondary
                    : AppColors.darkTextSecondary,
              ),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        context.read<NotesBloc>().add(
                          const UpdateNoteViewConfigEvent(searchQuery: ''),
                        );
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
            ),
            onChanged: (value) {
              context.read<NotesBloc>().add(
                UpdateNoteViewConfigEvent(searchQuery: value),
              );
            },
            onSubmitted: (value) {
              final newHistory = List<String>.from(state.searchHistory);
              if (value.isNotEmpty && !newHistory.contains(value)) {
                newHistory.insert(0, value);
                if (newHistory.length > 10) newHistory.removeLast();
                context.read<NotesBloc>().add(
                  UpdateNoteViewConfigEvent(searchHistory: newHistory),
                );
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Search: $value'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            children: [
              _buildQuickOperatorChip('tag:', context, controller),
              _buildQuickOperatorChip('color:', context, controller),
              _buildQuickOperatorChip('before:', context, controller),
              _buildQuickOperatorChip('is:', context, controller),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickOperatorChip(
    String operator,
    BuildContext context,
    TextEditingController controller,
  ) {
    return GestureDetector(
      onTap: () {
        final newText =
            '${controller.text}${controller.text.isEmpty ? '' : ' '}$operator ';
        context.read<NotesBloc>().add(
          UpdateNoteViewConfigEvent(searchQuery: newText),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.primaryColor, width: 1),
        ),
        child: Text(
          operator,
          style: AppTypography.body3().copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  List<String> _parseAppliedOperators(String query) {
    final ops = <String>[];
    for (final def in operatorDefinitions) {
      if (query.contains(def['operator'] as String)) {
        ops.add(def['operator'] as String);
      }
    }
    return ops;
  }

  Widget _buildAppliedOperators(BuildContext context, NotesLoaded state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ops = _parseAppliedOperators(state.searchQuery);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: AppColors.divider(context), width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Applied Operators',
            style: AppTypography.body2().copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.lightText : AppColors.darkText,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            children: ops.map((op) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      op,
                      style: AppTypography.body3().copyWith(
                        color: Colors.white,
                        fontFamily: 'monospace',
                      ),
                    ),
                    SizedBox(width: 6.w),
                    GestureDetector(
                      onTap: () {
                        final newQuery = state.searchQuery
                            .replaceAll(op, '')
                            .trim();
                        context.read<NotesBloc>().add(
                          UpdateNoteViewConfigEvent(searchQuery: newQuery),
                        );
                      },
                      child: Icon(
                        Icons.close,
                        size: 14.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorsGrid(
    BuildContext context,
    NotesLoaded state,
    TextEditingController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider(context), width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Operators',
            style: AppTypography.heading3().copyWith(
              color: isDark ? AppColors.lightText : AppColors.darkText,
            ),
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 0.8,
            ),
            itemCount: operatorDefinitions.length,
            itemBuilder: (context, index) {
              final def = operatorDefinitions[index];
              final opColor = def['color'] as Color;
              return InkWell(
                onTap: () {
                  final newText =
                      controller.text +
                      (controller.text.isEmpty ? '' : ' ') +
                      (def['operator'] as String);
                  context.read<NotesBloc>().add(
                    UpdateNoteViewConfigEvent(searchQuery: newText),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: opColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: opColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: opColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          def['operator'] as String,
                          style: TextStyle(
                            color: opColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        def['description'] as String,
                        style: AppTypography.body3().copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.lightText
                              : AppColors.darkText,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Example: ${def['example']}',
                        style: AppTypography.caption().copyWith(
                          color: isDark
                              ? AppColors.lightTextSecondary
                              : AppColors.darkTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory(BuildContext context, NotesLoaded state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: AppTypography.heading3().copyWith(
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<NotesBloc>().add(
                    const UpdateNoteViewConfigEvent(searchHistory: []),
                  );
                },
                child: Text(
                  'Clear All',
                  style: TextStyle(color: AppColors.primaryColor),
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.searchHistory.length,
          itemBuilder: (context, index) {
            final query = state.searchHistory[index];
            return ListTile(
              leading: Icon(
                Icons.history,
                size: 20.sp,
                color: isDark
                    ? AppColors.lightTextSecondary
                    : AppColors.darkTextSecondary,
              ),
              title: Text(
                query,
                style: AppTypography.body2().copyWith(
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                ),
              ),
              onTap: () {
                context.read<NotesBloc>().add(
                  UpdateNoteViewConfigEvent(searchQuery: query),
                );
              },
              trailing: IconButton(
                icon: Icon(Icons.close, size: 16.sp),
                onPressed: () {
                  final newHistory = List<String>.from(state.searchHistory);
                  newHistory.removeAt(index);
                  context.read<NotesBloc>().add(
                    UpdateNoteViewConfigEvent(searchHistory: newHistory),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHelpSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.amber.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Pro Tip',
                  style: AppTypography.body2().copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Combine multiple operators for precise results. '
              'Example: tag:work before:2024-01-01 -tag:todo',
              style: AppTypography.body3(),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Syntax Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• tag:name - find tags'),
              Text('• color:blue - find by color'),
              Text('• before:YYYY-MM-DD - older than'),
              Text('• after:YYYY-MM-DD - newer than'),
              Text('• is:pinned - find pinned only'),
              Text('• "phrase" - exact match'),
              Text('• -term - exclude term'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}


