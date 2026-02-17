import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/app_logger.dart';
import 'package:mynotes/core/design_system/app_colors.dart';
import 'package:mynotes/core/design_system/app_typography.dart';
import 'package:mynotes/presentation/bloc/note/note_bloc.dart';
import 'package:mynotes/presentation/bloc/note/note_state.dart';
import 'package:mynotes/presentation/bloc/note/note_event.dart';

/// Sort Customization Screen (ORG-007)
/// Multiple sort options with persistence and drag-drop manual sort
/// Refactored to use NotesBloc for centralized state management
class SortCustomizationScreen extends StatelessWidget {
  const SortCustomizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.i('SortCustomizationScreen: build');
    return DefaultTabController(
      length: 3,
      child: BlocBuilder<NotesBloc, NoteState>(
        builder: (context, state) {
          if (state is! NotesLoaded) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Scaffold(
            backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
            appBar: _buildAppBar(context, state),
            body: TabBarView(
              children: [
                _buildQuickSortTab(context, state),
                _buildCustomSortTab(context, state),
                _buildManualSortTab(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, NotesLoaded state) {
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
        'Sort & Organize',
        style: AppTypography.heading2().copyWith(
          color: isDark ? AppColors.lightText : AppColors.darkText,
        ),
      ),
      bottom: TabBar(
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: isDark
            ? AppColors.lightTextSecondary
            : AppColors.darkTextSecondary,
        indicatorColor: AppColors.primaryColor,
        tabs: const [
          Tab(text: 'Quick Sort'),
          Tab(text: 'Custom'),
          Tab(text: 'Manual'),
        ],
      ),
    );
  }

  Widget _buildQuickSortTab(BuildContext context, NotesLoaded state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final quickSortOptions = [
      {
        'name': 'Newest First',
        'primary': NoteSortOption.dateModified,
        'descending': true,
        'icon': Icons.calendar_today,
        'color': Colors.blue,
      },
      {
        'name': 'Oldest First',
        'primary': NoteSortOption.dateModified,
        'descending': false,
        'icon': Icons.calendar_today,
        'color': Colors.grey,
      },
      {
        'name': 'A to Z',
        'primary': NoteSortOption.titleAZ,
        'descending': false,
        'icon': Icons.sort_by_alpha,
        'color': Colors.green,
      },
      {
        'name': 'Z to A',
        'primary': NoteSortOption.titleAZ,
        'descending': true,
        'icon': Icons.sort_by_alpha,
        'color': Colors.orange,
      },
      {
        'name': 'Most Used',
        'primary': NoteSortOption.frequency,
        'descending': true,
        'icon': Icons.trending_up,
        'color': Colors.purple,
      },
      {
        'name': 'Priority',
        'primary': NoteSortOption.priority,
        'descending': true,
        'icon': Icons.priority_high,
        'color': Colors.red,
      },
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Sort Presets',
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
            ),
            itemCount: quickSortOptions.length,
            itemBuilder: (context, index) {
              final option = quickSortOptions[index];
              return _buildQuickSortCard(option, context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSortCard(
    Map<String, dynamic> option,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = option['color'] as Color;

    return GestureDetector(
      onTap: () {
        AppLogger.i(
          'SortCustomizationScreen: Quick sort selected - ${option['name']}',
        );
        context.read<NotesBloc>().add(
          UpdateNoteViewConfigEvent(
            sortBy: option['primary'] as NoteSortOption,
            sortDescending: option['descending'] as bool,
          ),
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sorted: ${option['name']}')));
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.divider(context), width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                option['icon'] as IconData,
                color: color,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              option['name'] as String,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge(context).copyWith(
                color: isDark ? AppColors.lightText : AppColors.darkText,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              option['descending'] == false ? '↑' : '↓',
              style: AppTypography.heading3().copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomSortTab(BuildContext context, NotesLoaded state) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSortLevelSection(
            'Primary Sort',
            state.sortBy,
            !state.sortDescending,
            (value) => context.read<NotesBloc>().add(
              UpdateNoteViewConfigEvent(sortBy: _stringToOption(value!)),
            ),
            (isAscending) => context.read<NotesBloc>().add(
              UpdateNoteViewConfigEvent(sortDescending: !isAscending),
            ),
            context,
          ),
          SizedBox(height: 24.h),
          _buildSortLevelSection(
            'Secondary Sort',
            state.secondarySortBy ?? NoteSortOption.titleAZ,
            !(state.secondarySortDescending ?? false),
            (value) => context.read<NotesBloc>().add(
              UpdateNoteViewConfigEvent(
                secondarySortBy: _stringToOption(value!),
              ),
            ),
            (isAscending) => context.read<NotesBloc>().add(
              UpdateNoteViewConfigEvent(secondarySortDescending: !isAscending),
            ),
            context,
          ),
          SizedBox(height: 24.h),
          _buildPreviewSection(context, state),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    AppLogger.i('SortCustomizationScreen: Reset sort settings');
                    context.read<NotesBloc>().add(
                      const UpdateNoteViewConfigEvent(
                        sortBy: NoteSortOption.dateModified,
                        sortDescending: true,
                        secondarySortBy: NoteSortOption.titleAZ,
                        secondarySortDescending: false,
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    AppLogger.i('SortCustomizationScreen: Save sort settings');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sort settings saved')),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  NoteSortOption _stringToOption(String value) {
    switch (value) {
      case 'date':
        return NoteSortOption.dateModified;
      case 'title':
        return NoteSortOption.titleAZ;
      case 'color':
        return NoteSortOption.color;
      case 'priority':
        return NoteSortOption.priority;
      case 'frequency':
        return NoteSortOption.frequency;
      case 'manual':
        return NoteSortOption.manual;
      default:
        return NoteSortOption.dateModified;
    }
  }

  String _optionToString(NoteSortOption option) {
    switch (option) {
      case NoteSortOption.dateModified:
      case NoteSortOption.dateCreated:
        return 'date';
      case NoteSortOption.titleAZ:
      case NoteSortOption.titleZA:
      case NoteSortOption.alphabetical:
        return 'title';
      case NoteSortOption.color:
        return 'color';
      case NoteSortOption.priority:
        return 'priority';
      case NoteSortOption.frequency:
        return 'frequency';
      case NoteSortOption.manual:
        return 'manual';
      default:
        return 'date';
    }
  }

  Widget _buildSortLevelSection(
    String label,
    NoteSortOption selectedSort,
    bool isAscending,
    Function(String?) onSortChanged,
    Function(bool) onOrderChanged,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.divider(context), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall(context).copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.lightText : AppColors.darkText,
            ),
          ),
          SizedBox(height: 12.h),
          DropdownButton<String>(
            value: _optionToString(selectedSort),
            isExpanded: true,
            items: ['date', 'title', 'color', 'priority', 'frequency', 'manual']
                .map((sort) {
                  return DropdownMenuItem(
                    value: sort,
                    child: Text(
                      sort.replaceFirst(sort[0], sort[0].toUpperCase()),
                      style: AppTypography.bodyLarge(context).copyWith(
                        color: isDark
                            ? AppColors.lightText
                            : AppColors.darkText,
                      ),
                    ),
                  );
                })
                .toList(),
            onChanged: onSortChanged,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 18.sp,
                color: AppColors.primaryColor,
              ),
              SizedBox(width: 8.w),
              Text(
                isAscending ? 'Ascending' : 'Descending',
                style: AppTypography.bodyLarge(context).copyWith(
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                ),
              ),
              const Spacer(),
              Switch(
                value: isAscending,
                onChanged: onOrderChanged,
                activeColor: AppColors.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(BuildContext context, NotesLoaded state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview',
          style: AppTypography.bodyLarge(context).copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.lightText : AppColors.darkText,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBg : AppColors.lightBg,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Primary: ${state.sortBy.displayName.toUpperCase()} (${!state.sortDescending ? '↑' : '↓'})',
                style: AppTypography.bodyMedium(context).copyWith(
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Secondary: ${(state.secondarySortBy ?? NoteSortOption.titleAZ).displayName.toUpperCase()} (${!(state.secondarySortDescending ?? false) ? '↑' : '↓'})',
                style: AppTypography.bodySmall(context).copyWith(
                  color: isDark
                      ? AppColors.lightTextSecondary
                      : AppColors.darkTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManualSortTab(BuildContext context, NotesLoaded state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final manualOrderItems = state.manualSortItems;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.primaryColor, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18.sp,
                  color: AppColors.primaryColor,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Drag items to reorder them manually',
                    style: AppTypography.bodySmall(
                      context,
                    ).copyWith(color: AppColors.primaryColor),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: (oldIndex, newIndex) {
              final newItems = List<String>.from(manualOrderItems);
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final item = newItems.removeAt(oldIndex);
              newItems.insert(newIndex, item);
              context.read<NotesBloc>().add(
                UpdateNoteViewConfigEvent(manualSortItems: newItems),
              );
            },
            children: List.generate(manualOrderItems.length, (index) {
              return Container(
                key: Key(manualOrderItems[index]),
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColors.divider(context),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    ReorderableDragStartListener(
                      index: index,
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        child: Icon(
                          Icons.drag_handle,
                          color: AppColors.primaryColor,
                          size: 20.sp,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ${manualOrderItems[index]}',
                              style: AppTypography.bodySmall(context).copyWith(
                                color: isDark
                                    ? AppColors.lightText
                                    : AppColors.darkText,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Last modified today',
                              style: AppTypography.captionSmall(context)
                                  .copyWith(
                                    color: isDark
                                        ? AppColors.lightTextSecondary
                                        : AppColors.darkTextSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          final newItems = List<String>.from(manualOrderItems);
                          newItems.removeAt(index);
                          context.read<NotesBloc>().add(
                            UpdateNoteViewConfigEvent(
                              manualSortItems: newItems,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 16.h),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Manual order saved')),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('Save Manual Order'),
            ),
          ),
        ],
      ),
    );
  }
}
