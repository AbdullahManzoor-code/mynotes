import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/design_system/app_colors.dart';
import 'package:mynotes/presentation/design_system/app_typography.dart';
import 'package:mynotes/presentation/bloc/note/note_bloc.dart';
import 'package:mynotes/presentation/bloc/note/note_state.dart';
import 'package:mynotes/presentation/bloc/note/note_event.dart';

/// Tag Management Screen (ORG-008)
/// Comprehensive tag organization and management interface
/// Refactored to use NotesBloc for centralized state management
class TagManagementScreen extends StatelessWidget {
  const TagManagementScreen({super.key});

  static const tags = [
    {
      'name': 'work',
      'color': Colors.blue,
      'count': 24,
      'created': 'Jan 2024',
      'icon': Icons.work,
    },
    {
      'name': 'personal',
      'color': Colors.pink,
      'count': 18,
      'created': 'Jan 2024',
      'icon': Icons.person,
    },
    {
      'name': 'important',
      'color': Colors.red,
      'count': 12,
      'created': 'Feb 2024',
      'icon': Icons.star,
    },
    {
      'name': 'ideas',
      'color': Colors.purple,
      'count': 8,
      'created': 'Mar 2024',
      'icon': Icons.lightbulb,
    },
    {
      'name': 'review',
      'color': Colors.orange,
      'count': 5,
      'created': 'Apr 2024',
      'icon': Icons.done,
    },
    {
      'name': 'reading',
      'color': Colors.green,
      'count': 3,
      'created': 'May 2024',
      'icon': Icons.menu_book,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotesBloc, NoteState>(
      builder: (context, state) {
        if (state is! NotesLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
            appBar: _buildAppBar(context, state),
            body: TabBarView(
              children: [
                _buildAllTagsTab(context, state),
                _buildOrganizeTab(context, state),
                _buildStatsTab(context, state),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showCreateTagDialog(context),
              backgroundColor: AppColors.primaryColor,
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
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
        'Tag Management',
        style: AppTypography.heading2().copyWith(
          color: isDark ? AppColors.lightText : AppColors.darkText,
        ),
      ),
      actions: [
        if (state.tagManagementSelectedTags.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  '${state.tagManagementSelectedTags.length} selected',
                  style: AppTypography.body3().copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
      ],
      bottom: TabBar(
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: isDark
            ? AppColors.lightTextSecondary
            : AppColors.darkTextSecondary,
        indicatorColor: AppColors.primaryColor,
        tabs: const [
          Tab(text: 'All Tags'),
          Tab(text: 'Organize'),
          Tab(text: 'Stats'),
        ],
      ),
    );
  }

  Widget _buildAllTagsTab(BuildContext context, NotesLoaded state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredTags = tags.where((tag) => 
      (tag['name'] as String).toLowerCase().contains(state.tagManagementSearchQuery.toLowerCase())
    ).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSearchBar(context, state),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Tags (${filteredTags.length})',
                  style: AppTypography.heading3().copyWith(
                    color: isDark ? AppColors.lightText : AppColors.darkText,
                  ),
                ),
                SizedBox(height: 16.h),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredTags.length,
                  itemBuilder: (context, index) {
                    return _buildTagCard(filteredTags[index], context, state);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, NotesLoaded state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider(context), width: 0.5),
        ),
      ),
      child: TextField(
        onChanged: (value) {
          context.read<NotesBloc>().add(
            UpdateNoteViewConfigEvent(tagManagementSearchQuery: value),
          );
        },
        decoration: InputDecoration(
          hintText: 'Search tags...',
          prefixIcon: Icon(
            Icons.search,
            color: isDark
                ? AppColors.lightTextSecondary
                : AppColors.darkTextSecondary,
          ),
          suffixIcon: state.tagManagementSearchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    context.read<NotesBloc>().add(
                      const UpdateNoteViewConfigEvent(tagManagementSearchQuery: ''),
                    );
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }

  Widget _buildTagCard(
    Map<String, dynamic> tag,
    BuildContext context,
    NotesLoaded state,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = state.tagManagementSelectedTags.contains(tag['name']);

    void toggleSelection() {
      final newSelection = List<String>.from(state.tagManagementSelectedTags);
      if (isSelected) {
        newSelection.remove(tag['name'] as String);
      } else {
        newSelection.add(tag['name'] as String);
      }
      context.read<NotesBloc>().add(
        UpdateNoteViewConfigEvent(tagManagementSelectedTags: newSelection),
      );
    }

    return GestureDetector(
      onLongPress: toggleSelection,
      onTap: () {
        if (state.tagManagementSelectedTags.isNotEmpty) {
          toggleSelection();
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? (tag['color'] as Color).withOpacity(0.2)
              : isDark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? tag['color'] as Color
                : AppColors.divider(context),
            width: isSelected ? 2 : 0.5,
          ),
        ),
        child: Row(
          children: [
            if (isSelected)
              Container(
                margin: EdgeInsets.only(right: 12.w),
                child: Icon(
                  Icons.check_circle,
                  color: tag['color'] as Color,
                  size: 24.sp,
                ),
              ),
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: (tag['color'] as Color).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                tag['icon'] as IconData,
                color: tag['color'] as Color,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tag['name'] as String,
                    style: AppTypography.heading4().copyWith(
                      color: isDark ? AppColors.lightText : AppColors.darkText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${tag['count']} items • Created ${tag['created']}',
                    style: AppTypography.caption().copyWith(
                      color: isDark
                          ? AppColors.lightTextSecondary
                          : AppColors.darkTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: isDark ? AppColors.lightText : AppColors.darkText,
              ),
              itemBuilder: (context) => <PopupMenuEntry<String>>[
                PopupMenuItem(
                  onTap: () => _showEditTagDialog(tag, context),
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18.sp),
                      SizedBox(width: 8.w),
                      const Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.palette, size: 18.sp),
                      SizedBox(width: 8.w),
                      const Text('Change Color'),
                    ],
                  ),
                  onTap: () {},
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.merge, size: 18.sp),
                      SizedBox(width: 8.w),
                      const Text('Merge'),
                    ],
                  ),
                  onTap: () {},
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18.sp, color: Colors.red),
                      SizedBox(width: 8.w),
                      const Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizeTab(BuildContext context, NotesLoaded state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tag Organization',
            style: AppTypography.heading3().copyWith(
              color: isDark ? AppColors.lightText : AppColors.darkText,
            ),
          ),
          SizedBox(height: 16.h),
          _buildOrganizeSection(
            'Favorite Tags',
            tags.take(3).toList(),
            context,
          ),
          SizedBox(height: 16.h),
          _buildOrganizeSection(
            'Recent Tags',
            tags.skip(1).take(3).toList(),
            context,
          ),
          SizedBox(height: 16.h),
          Container(
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
                  'Bulk Actions',
                  style: AppTypography.heading4().copyWith(
                    color: isDark ? AppColors.lightText : AppColors.darkText,
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Merge Tags'),
                  ),
                ),
                SizedBox(height: 8.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Rename Tags'),
                  ),
                ),
                SizedBox(height: 8.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Delete Unused Tags'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizeSection(
    String title,
    List<Map<String, dynamic>> tagsList,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.body2().copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.lightText : AppColors.darkText,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: tagsList.map((tag) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: (tag['color'] as Color).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: tag['color'] as Color, width: 1),
              ),
              child: Text(
                tag['name'] as String,
                style: AppTypography.body3().copyWith(
                  color: tag['color'] as Color,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatsTab(BuildContext context, NotesLoaded state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalItems = tags.fold<int>(
      0,
      (sum, tag) => sum + (tag['count'] as int),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tag Statistics',
            style: AppTypography.heading3().copyWith(
              color: isDark ? AppColors.lightText : AppColors.darkText,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.divider(context), width: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Tags',
                  '${tags.length}',
                  Icons.label,
                  context,
                ),
                _buildStatItem(
                  'Total Items',
                  '$totalItems',
                  Icons.insert_drive_file,
                  context,
                ),
                _buildStatItem(
                  'Avg per Tag',
                  (totalItems / tags.length).toStringAsFixed(1),
                  Icons.trending_up,
                  context,
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Tag Distribution',
            style: AppTypography.heading4().copyWith(
              color: isDark ? AppColors.lightText : AppColors.darkText,
            ),
          ),
          SizedBox(height: 12.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final tag = tags[index];
              final percentage = ((tag['count'] as int) / totalItems * 100)
                  .toStringAsFixed(1);

              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12.w,
                              height: 12.w,
                              decoration: BoxDecoration(
                                color: tag['color'] as Color,
                                borderRadius: BorderRadius.circular(3.r),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              tag['name'] as String,
                              style: AppTypography.body2().copyWith(
                                color: isDark
                                    ? AppColors.lightText
                                    : AppColors.darkText,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$percentage%',
                          style: AppTypography.body3().copyWith(
                            color: isDark
                                ? AppColors.lightTextSecondary
                                : AppColors.darkTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: (tag['count'] as int) / totalItems,
                        backgroundColor: isDark
                            ? AppColors.darkBg
                            : AppColors.lightBg,
                        valueColor: AlwaysStoppedAnimation(
                          tag['color'] as Color,
                        ),
                        minHeight: 8.h,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Icon(
          icon,
          size: 24.sp,
          color: isDark
              ? AppColors.lightTextSecondary
              : AppColors.darkTextSecondary,
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: AppTypography.heading3().copyWith(
            color: isDark ? AppColors.lightText : AppColors.darkText,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: AppTypography.caption().copyWith(
            color: isDark
                ? AppColors.lightTextSecondary
                : AppColors.darkTextSecondary,
          ),
        ),
      ],
    );
  }

  void _showCreateTagDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        title: Text(
          'Create New Tag',
          style: AppTypography.heading3().copyWith(
            color: isDark ? AppColors.lightText : AppColors.darkText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Tag name',
                hintStyle: AppTypography.body2().copyWith(
                  color: isDark
                      ? AppColors.lightTextSecondary
                      : AppColors.darkTextSecondary,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Tag Color',
              style: AppTypography.body2().copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.lightText : AppColors.darkText,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 12.w,
              children:
                  [
                    Colors.blue,
                    Colors.pink,
                    Colors.red,
                    Colors.purple,
                    Colors.orange,
                    Colors.green,
                  ].map((color) {
                    return GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditTagDialog(Map<String, dynamic> tag, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        title: Text(
          'Edit Tag',
          style: AppTypography.heading3().copyWith(
            color: isDark ? AppColors.lightText : AppColors.darkText,
          ),
        ),
        content: TextField(
          controller: TextEditingController(text: tag['name'] as String),
          decoration: InputDecoration(
            hintText: 'Tag name',
            hintStyle: AppTypography.body2().copyWith(
              color: isDark
                  ? AppColors.lightTextSecondary
                  : AppColors.darkTextSecondary,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     tag['name'] as String,
//                     style: AppTypography.heading4().copyWith(
//                       color: isDark ? AppColors.lightText : AppColors.darkText,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   SizedBox(height: 4.h),
//                   Text(
//                     '${tag['count']} items • Created ${tag['created']}',
//                     style: AppTypography.caption().copyWith(
//                       color: isDark
//                           ? AppColors.lightTextSecondary
//                           : AppColors.darkTextSecondary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             PopupMenuButton<String>(
//               icon: Icon(
//                 Icons.more_vert,
//                 color: isDark ? AppColors.lightText : AppColors.darkText,
//               ),
//               itemBuilder: (context) => <PopupMenuEntry<String>>[
//                 PopupMenuItem(
//                   child: Row(
//                     children: [
//                       Icon(Icons.edit, size: 18.sp),
//                       SizedBox(width: 8.w),
//                       Text('Edit'),
//                     ],
//                   ),
//                   onTap: () => _showEditTagDialog(tag, context),
//                 ),
//                 PopupMenuItem(
//                   child: Row(
//                     children: [
//                       Icon(Icons.palette, size: 18.sp),
//                       SizedBox(width: 8.w),
//                       Text('Change Color'),
//                     ],
//                   ),
//                   onTap: () {},
//                 ),
//                 PopupMenuItem(
//                   child: Row(
//                     children: [
//                       Icon(Icons.merge, size: 18.sp),
//                       SizedBox(width: 8.w),
//                       Text('Merge'),
//                     ],
//                   ),
//                   onTap: () {},
//                 ),
//                 PopupMenuDivider(),
//                 PopupMenuItem(
//                   child: Row(
//                     children: [
//                       Icon(Icons.delete, size: 18.sp, color: Colors.red),
//                       SizedBox(width: 8.w),
//                       Text('Delete', style: TextStyle(color: Colors.red)),
//                     ],
//                   ),
//                   onTap: () {},
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOrganizeTab(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return SingleChildScrollView(
//       padding: EdgeInsets.all(16.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Tag Organization',
//             style: AppTypography.heading3().copyWith(
//               color: isDark ? AppColors.lightText : AppColors.darkText,
//             ),
//           ),
//           SizedBox(height: 16.h),
//           _buildOrganizeSection(
//             'Favorite Tags',
//             tags.take(3).toList(),
//             context,
//           ),
//           SizedBox(height: 16.h),
//           _buildOrganizeSection(
//             'Recent Tags',
//             tags.skip(1).take(3).toList(),
//             context,
//           ),
//           SizedBox(height: 16.h),
//           Container(
//             padding: EdgeInsets.all(16.w),
//             decoration: BoxDecoration(
//               color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
//               borderRadius: BorderRadius.circular(12.r),
//               border: Border.all(color: AppColors.divider(context), width: 0.5),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Bulk Actions',
//                   style: AppTypography.heading4().copyWith(
//                     color: isDark ? AppColors.lightText : AppColors.darkText,
//                   ),
//                 ),
//                 SizedBox(height: 12.h),
//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton(
//                     onPressed: () {},
//                     child: Text('Merge Tags'),
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton(
//                     onPressed: () {},
//                     child: Text('Rename Tags'),
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton(
//                     onPressed: () {},
//                     child: Text('Delete Unused Tags'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOrganizeSection(
//     String title,
//     List<Map<String, dynamic>> tagsList,
//     BuildContext context,
//   ) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: AppTypography.body2().copyWith(
//             fontWeight: FontWeight.w600,
//             color: isDark ? AppColors.lightText : AppColors.darkText,
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Wrap(
//           spacing: 8.w,
//           runSpacing: 8.h,
//           children: tagsList.map((tag) {
//             return Container(
//               padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//               decoration: BoxDecoration(
//                 color: (tag['color'] as Color).withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(20.r),
//                 border: Border.all(color: tag['color'] as Color, width: 1),
//               ),
//               child: Text(
//                 tag['name'] as String,
//                 style: AppTypography.body3().copyWith(
//                   color: tag['color'] as Color,
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatsTab(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final totalItems = tags.fold<int>(
//       0,
//       (sum, tag) => sum + (tag['count'] as int),
//     );

//     return SingleChildScrollView(
//       padding: EdgeInsets.all(16.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Tag Statistics',
//             style: AppTypography.heading3().copyWith(
//               color: isDark ? AppColors.lightText : AppColors.darkText,
//             ),
//           ),
//           SizedBox(height: 16.h),
//           Container(
//             padding: EdgeInsets.all(16.w),
//             decoration: BoxDecoration(
//               color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
//               borderRadius: BorderRadius.circular(12.r),
//               border: Border.all(color: AppColors.divider(context), width: 0.5),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildStatItem(
//                   'Total Tags',
//                   '${tags.length}',
//                   Icons.label,
//                   context,
//                 ),
//                 _buildStatItem(
//                   'Total Items',
//                   '$totalItems',
//                   Icons.insert_drive_file,
//                   context,
//                 ),
//                 _buildStatItem(
//                   'Avg per Tag',
//                   (totalItems / tags.length).toStringAsFixed(1),
//                   Icons.trending_up,
//                   context,
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 24.h),
//           Text(
//             'Tag Distribution',
//             style: AppTypography.heading4().copyWith(
//               color: isDark ? AppColors.lightText : AppColors.darkText,
//             ),
//           ),
//           SizedBox(height: 12.h),
//           ListView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             itemCount: tags.length,
//             itemBuilder: (context, index) {
//               final tag = tags[index];
//               final percentage = ((tag['count'] as int) / totalItems * 100)
//                   .toStringAsFixed(1);

//               return Padding(
//                 padding: EdgeInsets.only(bottom: 16.h),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               width: 12.w,
//                               height: 12.w,
//                               decoration: BoxDecoration(
//                                 color: tag['color'] as Color,
//                                 borderRadius: BorderRadius.circular(3.r),
//                               ),
//                             ),
//                             SizedBox(width: 8.w),
//                             Text(
//                               tag['name'] as String,
//                               style: AppTypography.body2().copyWith(
//                                 color: isDark
//                                     ? AppColors.lightText
//                                     : AppColors.darkText,
//                               ),
//                             ),
//                           ],
//                         ),
//                         Text(
//                           '$percentage%',
//                           style: AppTypography.body3().copyWith(
//                             color: isDark
//                                 ? AppColors.lightTextSecondary
//                                 : AppColors.darkTextSecondary,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 8.h),
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(4.r),
//                       child: LinearProgressIndicator(
//                         value: (tag['count'] as int) / totalItems,
//                         backgroundColor: isDark
//                             ? AppColors.darkBg
//                             : AppColors.lightBg,
//                         valueColor: AlwaysStoppedAnimation(
//                           tag['color'] as Color,
//                         ),
//                         minHeight: 8.h,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatItem(
//     String label,
//     String value,
//     IconData icon,
//     BuildContext context,
//   ) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Column(
//       children: [
//         Icon(
//           icon,
//           size: 24.sp,
//           color: isDark
//               ? AppColors.lightTextSecondary
//               : AppColors.darkTextSecondary,
//         ),
//         SizedBox(height: 8.h),
//         Text(
//           value,
//           style: AppTypography.heading3().copyWith(
//             color: isDark ? AppColors.lightText : AppColors.darkText,
//           ),
//         ),
//         SizedBox(height: 4.h),
//         Text(
//           label,
//           style: AppTypography.caption().copyWith(
//             color: isDark
//                 ? AppColors.lightTextSecondary
//                 : AppColors.darkTextSecondary,
//           ),
//         ),
//       ],
//     );
//   }

//   void _showCreateTagDialog(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: isDark
//             ? AppColors.darkSurface
//             : AppColors.lightSurface,
//         title: Text(
//           'Create New Tag',
//           style: AppTypography.heading3().copyWith(
//             color: isDark ? AppColors.lightText : AppColors.darkText,
//           ),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               decoration: InputDecoration(
//                 hintText: 'Tag name',
//                 hintStyle: AppTypography.body2().copyWith(
//                   color: isDark
//                       ? AppColors.lightTextSecondary
//                       : AppColors.darkTextSecondary,
//                 ),
//               ),
//             ),
//             SizedBox(height: 16.h),
//             Text(
//               'Tag Color',
//               style: AppTypography.body2().copyWith(
//                 fontWeight: FontWeight.w600,
//                 color: isDark ? AppColors.lightText : AppColors.darkText,
//               ),
//             ),
//             SizedBox(height: 8.h),
//             Wrap(
//               spacing: 12.w,
//               children:
//                   [
//                     Colors.blue,
//                     Colors.pink,
//                     Colors.red,
//                     Colors.purple,
//                     Colors.orange,
//                     Colors.green,
//                   ].map((color) {
//                     return GestureDetector(
//                       onTap: () {},
//                       child: Container(
//                         width: 40.w,
//                         height: 40.w,
//                         decoration: BoxDecoration(
//                           color: color,
//                           borderRadius: BorderRadius.circular(20.r),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Create'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showEditTagDialog(Map<String, dynamic> tag, BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: isDark
//             ? AppColors.darkSurface
//             : AppColors.lightSurface,
//         title: Text(
//           'Edit Tag',
//           style: AppTypography.heading3().copyWith(
//             color: isDark ? AppColors.lightText : AppColors.darkText,
//           ),
//         ),
//         content: TextField(
//           controller: TextEditingController(text: tag['name'] as String),
//           decoration: InputDecoration(
//             hintText: 'Tag name',
//             hintStyle: AppTypography.body2().copyWith(
//               color: isDark
//                   ? AppColors.lightTextSecondary
//                   : AppColors.darkTextSecondary,
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }
// }
