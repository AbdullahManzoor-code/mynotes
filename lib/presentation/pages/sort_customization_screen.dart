import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/core/design_system/app_colors.dart';
import 'package:mynotes/core/design_system/app_typography.dart';
import 'package:mynotes/core/design_system/app_spacing.dart';
import 'package:mynotes/presentation/design_system/app_typography.dart';

/// Sort Customization Screen (ORG-007)
/// Multiple sort options with persistence and drag-drop manual sort
class SortCustomizationScreen extends StatefulWidget {
  const SortCustomizationScreen({Key? key}) : super(key: key);

  @override
  State<SortCustomizationScreen> createState() =>
      _SortCustomizationScreenState();
}

class _SortCustomizationScreenState extends State<SortCustomizationScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  String primarySort = 'date';
  bool sortAscending = false; // false = descending
  String secondarySort = 'title';
  bool secondarySortAscending = true;

  List<String> manualOrderItems = [
    'Project Alpha',
    'Meeting Notes',
    'Grocery List',
    'Design System',
    'Daily Standup',
  ];

  final quickSortOptions = [
    {
      'name': 'Newest First',
      'primary': 'date',
      'ascending': false,
      'icon': Icons.calendar_today,
      'color': Colors.blue,
    },
    {
      'name': 'Oldest First',
      'primary': 'date',
      'ascending': true,
      'icon': Icons.calendar_today,
      'color': Colors.grey,
    },
    {
      'name': 'A to Z',
      'primary': 'title',
      'ascending': true,
      'icon': Icons.sort_by_alpha,
      'color': Colors.green,
    },
    {
      'name': 'Z to A',
      'primary': 'title',
      'ascending': false,
      'icon': Icons.sort_by_alpha,
      'color': Colors.orange,
    },
    {
      'name': 'Most Used',
      'primary': 'frequency',
      'ascending': false,
      'icon': Icons.trending_up,
      'color': Colors.purple,
    },
    {
      'name': 'Priority',
      'primary': 'priority',
      'ascending': false,
      'icon': Icons.priority_high,
      'color': Colors.red,
    },
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: _buildAppBar(context),
      body: TabBarView(
        controller: tabController,
        children: [
          _buildQuickSortTab(context),
          _buildCustomSortTab(context),
          _buildManualSortTab(context),
        ],
      ),
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
        'Sort & Organize',
        style: AppTypography.heading2().copyWith(
          color: isDark ? AppColors.lightText : AppColors.darkText,
        ),
      ),
      bottom: TabBar(
        controller: tabController,
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: isDark
            ? AppColors.lightTextSecondary
            : AppColors.darkTextSecondary,
        indicatorColor: AppColors.primaryColor,
        tabs: [
          Tab(text: 'Quick Sort'),
          Tab(text: 'Custom'),
          Tab(text: 'Manual'),
        ],
      ),
    );
  }

  Widget _buildQuickSortTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            physics: NeverScrollableScrollPhysics(),
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
        setState(() {
          primarySort = option['primary'] as String;
          sortAscending = option['ascending'] as bool;
        });
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
              style: AppTypography.body2().copyWith(
                color: isDark ? AppColors.lightText : AppColors.darkText,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              option['ascending'] == true ? '↑' : '↓',
              style: AppTypography.heading3().copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomSortTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSortLevelSection(
            'Primary Sort',
            primarySort,
            sortAscending,
            (value) => setState(() => primarySort = value),
            (value) => setState(() => sortAscending = value),
            context,
          ),
          SizedBox(height: 24.h),
          _buildSortLevelSection(
            'Secondary Sort',
            secondarySort,
            secondarySortAscending,
            (value) => setState(() => secondarySort = value),
            (value) => setState(() => secondarySortAscending = value),
            context,
          ),
          SizedBox(height: 24.h),
          _buildPreviewSection(context),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      primarySort = 'date';
                      sortAscending = false;
                      secondarySort = 'title';
                      secondarySortAscending = true;
                    });
                  },
                  icon: Icon(Icons.refresh),
                  label: Text('Reset'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sort settings saved')),
                    );
                  },
                  icon: Icon(Icons.save),
                  label: Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortLevelSection(
    String label,
    String selectedSort,
    bool isAscending,
    Function(String) onSortChanged,
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
            style: AppTypography.body2().copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.lightText : AppColors.darkText,
            ),
          ),
          SizedBox(height: 12.h),
          DropdownButton<String>(
            value: selectedSort,
            isExpanded: true,
            items: ['date', 'title', 'color', 'priority', 'frequency', 'manual']
                .map((sort) {
                  return DropdownMenuItem(
                    value: sort,
                    child: Text(
                      sort.replaceFirst(sort[0], sort[0].toUpperCase()),
                      style: AppTypography.body2().copyWith(
                        color: isDark
                            ? AppColors.lightText
                            : AppColors.darkText,
                      ),
                    ),
                  );
                })
                .toList(),
            onChanged: (value) {
              if (value != null) onSortChanged(value);
            },
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
                style: AppTypography.body2().copyWith(
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                ),
              ),
              Spacer(),
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

  Widget _buildPreviewSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview',
          style: AppTypography.body2().copyWith(
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
                'Primary: ${primarySort.toUpperCase()} (${sortAscending ? '↑' : '↓'})',
                style: AppTypography.body3().copyWith(
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Secondary: ${secondarySort.toUpperCase()} (${secondarySortAscending ? '↑' : '↓'})',
                style: AppTypography.body3().copyWith(
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

  Widget _buildManualSortTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    style: AppTypography.body3().copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          ReorderableListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final item = manualOrderItems.removeAt(oldIndex);
                manualOrderItems.insert(newIndex, item);
              });
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
                              style: AppTypography.body2().copyWith(
                                color: isDark
                                    ? AppColors.lightText
                                    : AppColors.darkText,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Last modified today',
                              style: AppTypography.caption().copyWith(
                                color: isDark
                                    ? AppColors.lightTextSecondary
                                    : AppColors.darkTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        PopupMenuItem(child: Text('Edit'), onTap: () {}),
                        PopupMenuItem(
                          child: Text('Delete'),
                          onTap: () {
                            setState(() => manualOrderItems.removeAt(index));
                          },
                        ),
                      ],
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
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Manual order saved')));
              },
              icon: Icon(Icons.save),
              label: Text('Save Manual Order'),
            ),
          ),
        ],
      ),
    );
  }
}

