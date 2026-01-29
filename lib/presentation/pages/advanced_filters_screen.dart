import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/core/design_system/app_colors.dart';
import 'package:mynotes/core/design_system/app_typography.dart';
import 'package:mynotes/core/design_system/app_spacing.dart';

/// Advanced Filters Screen (ORG-005)
/// Complex visual filter builder with multiple conditions
class AdvancedFiltersScreen extends StatefulWidget {
  const AdvancedFiltersScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedFiltersScreen> createState() => _AdvancedFiltersScreenState();
}

class _AdvancedFiltersScreenState extends State<AdvancedFiltersScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  List<Map<String, dynamic>> filterConditions = [];
  String filterLogic = 'AND'; // AND or OR
  bool useNot = false;

  final savedFilters = [
    {
      'name': 'High Priority Work',
      'conditions': 3,
      'color': Colors.blue,
      'icon': Icons.priority_high,
    },
    {
      'name': 'Personal Goals',
      'conditions': 2,
      'color': Colors.orange,
      'icon': Icons.track_changes,
    },
    {
      'name': 'Recent Changes',
      'conditions': 1,
      'color': Colors.green,
      'icon': Icons.update,
    },
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    // Add default empty condition
    filterConditions.add({'type': 'tag', 'operator': 'contains', 'value': ''});
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
          _buildBuilderTab(context),
          _buildPresetsTab(context),
          _buildSavedFiltersTab(context),
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
        'Advanced Filters',
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
          Tab(text: 'Builder'),
          Tab(text: 'Presets'),
          Tab(text: 'Saved'),
        ],
      ),
    );
  }

  Widget _buildBuilderTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogicSelector(context),
          SizedBox(height: 16.h),
          _buildConditionsBuilder(context),
          SizedBox(height: 16.h),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildLogicSelector(BuildContext context) {
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
            'Filter Logic',
            style: AppTypography.body2().copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.lightText : AppColors.darkText,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildLogicButton(
                  'AND',
                  filterLogic == 'AND',
                  () => setState(() => filterLogic = 'AND'),
                  context,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildLogicButton(
                  'OR',
                  filterLogic == 'OR',
                  () => setState(() => filterLogic = 'OR'),
                  context,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16.sp,
                color: isDark
                    ? AppColors.lightTextSecondary
                    : AppColors.darkTextSecondary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  filterLogic == 'AND'
                      ? 'All conditions must match'
                      : 'Any condition can match',
                  style: AppTypography.caption().copyWith(
                    color: isDark
                        ? AppColors.lightTextSecondary
                        : AppColors.darkTextSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogicButton(
    String label,
    bool isSelected,
    VoidCallback onTap,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.2)
              : isDark
              ? AppColors.darkBg
              : AppColors.lightBg,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.divider(context),
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.body2().copyWith(
            color: isSelected
                ? AppColors.primaryColor
                : isDark
                ? AppColors.lightText
                : AppColors.darkText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildConditionsBuilder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Conditions',
              style: AppTypography.body2().copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.lightText : AppColors.darkText,
              ),
            ),
            Text(
              '${filterConditions.length}',
              style: AppTypography.body2().copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: filterConditions.length,
          itemBuilder: (context, index) {
            return _buildConditionRow(index, context);
          },
        ),
        SizedBox(height: 12.h),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              filterConditions.add({
                'type': 'tag',
                'operator': 'contains',
                'value': '',
              });
            });
          },
          icon: Icon(Icons.add),
          label: Text('Add Condition'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor.withOpacity(0.2),
            foregroundColor: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildConditionRow(int index, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final condition = filterConditions[index];

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.divider(context), width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildDropdown(
                  'Type',
                  condition['type'] as String,
                  ['tag', 'date', 'color', 'status'],
                  (value) {
                    setState(() => filterConditions[index]['type'] = value);
                  },
                  context,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                flex: 1,
                child: _buildDropdown(
                  'Op',
                  condition['operator'] as String,
                  ['contains', 'equals', 'before', 'after'],
                  (value) {
                    setState(() => filterConditions[index]['operator'] = value);
                  },
                  context,
                ),
              ),
              SizedBox(width: 8.w),
              if (filterConditions.length > 1)
                IconButton(
                  icon: Icon(Icons.delete, size: 20.sp, color: Colors.red),
                  onPressed: () {
                    setState(() => filterConditions.removeAt(index));
                  },
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          SizedBox(height: 8.h),
          TextField(
            decoration: InputDecoration(
              hintText: 'Value',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
            onChanged: (value) {
              setState(() => filterConditions[index]['value'] = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> options,
    Function(String) onChanged,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption().copyWith(
            color: isDark
                ? AppColors.lightTextSecondary
                : AppColors.darkTextSecondary,
          ),
        ),
        SizedBox(height: 4.h),
        DropdownButton<String>(
          value: value,
          isExpanded: true,
          isDense: true,
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(
                option,
                style: AppTypography.body3().copyWith(
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                filterConditions.clear();
                filterConditions.add({
                  'type': 'tag',
                  'operator': 'contains',
                  'value': '',
                });
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Filter applied')));
            },
            icon: Icon(Icons.check),
            label: Text('Apply'),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetsTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Filter Presets',
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
            itemCount: 6,
            itemBuilder: (context, index) {
              final presets = [
                {'name': 'This Week', 'icon': Icons.calendar_today},
                {'name': 'High Priority', 'icon': Icons.priority_high},
                {'name': 'Unread', 'icon': Icons.mail_outline},
                {'name': 'Pinned', 'icon': Icons.push_pin},
                {'name': 'Archived', 'icon': Icons.archive},
                {'name': 'Shared', 'icon': Icons.share},
              ];

              final preset = presets[index];

              return GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Applied: ${preset['name']}')),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.divider(context),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        preset['icon'] as IconData,
                        size: 32.sp,
                        color: AppColors.primaryColor,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        preset['name'] as String,
                        textAlign: TextAlign.center,
                        style: AppTypography.body3().copyWith(
                          color: isDark
                              ? AppColors.lightText
                              : AppColors.darkText,
                          fontWeight: FontWeight.w600,
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

  Widget _buildSavedFiltersTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saved Filters',
                style: AppTypography.heading3().copyWith(
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                ),
              ),
              IconButton(icon: Icon(Icons.add_circle), onPressed: () {}),
            ],
          ),
          SizedBox(height: 12.h),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: savedFilters.length,
            itemBuilder: (context, index) {
              final filter = savedFilters[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.divider(context),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: (filter['color'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        filter['icon'] as IconData,
                        color: filter['color'] as Color,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            filter['name'] as String,
                            style: AppTypography.heading4().copyWith(
                              color: isDark
                                  ? AppColors.lightText
                                  : AppColors.darkText,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${filter['conditions']} conditions',
                            style: AppTypography.caption().copyWith(
                              color: isDark
                                  ? AppColors.lightTextSecondary
                                  : AppColors.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
