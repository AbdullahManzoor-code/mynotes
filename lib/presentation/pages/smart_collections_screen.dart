import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/core/design_system/app_colors.dart';
import 'package:mynotes/core/design_system/app_typography.dart';

/// Smart Collections Screen (ORG-003)
/// AI-powered, rule-based collections that auto-organize notes
class SmartCollectionsScreen extends StatefulWidget {
  const SmartCollectionsScreen({Key? key}) : super(key: key);

  @override
  State<SmartCollectionsScreen> createState() => _SmartCollectionsScreenState();
}

class _SmartCollectionsScreenState extends State<SmartCollectionsScreen> {
  // Sample smart collections data
  final List<Map<String, dynamic>> smartCollections = [
    {
      'id': '1',
      'name': 'Work Projects',
      'description': 'Notes tagged with "work"',
      'itemCount': 24,
      'icon': Icons.work,
      'color': Colors.blue,
      'ruleCount': 3,
      'lastUpdated': 'Today',
    },
    {
      'id': '2',
      'name': 'Personal Goals',
      'description': 'High-priority personal items',
      'itemCount': 18,
      'icon': Icons.track_changes,
      'color': Colors.orange,
      'ruleCount': 2,
      'lastUpdated': 'Yesterday',
    },
    {
      'id': '3',
      'name': 'Urgent Tasks',
      'description': 'Red-colored notes from past week',
      'itemCount': 7,
      'icon': Icons.priority_high,
      'color': Colors.red,
      'ruleCount': 2,
      'lastUpdated': '2 days ago',
    },
  ];

  String selectedFilter = 'all'; // all, active, archived

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildFilterChips(context),
          Expanded(child: _buildCollectionsList(context)),
        ],
      ),
      floatingActionButton: _buildCreateButton(context),
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
        'Smart Collections',
        style: AppTypography.heading2().copyWith(
          color: isDark ? AppColors.lightText : AppColors.darkText,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.info_outline,
            color: isDark ? AppColors.lightText : AppColors.darkText,
          ),
          onPressed: () => _showInfoDialog(context),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider(context), width: 0.5),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All Collections', 'all', Icons.apps, context),
            SizedBox(width: 8.w),
            _buildFilterChip('Active', 'active', Icons.check_circle, context),
            SizedBox(width: 8.w),
            _buildFilterChip('Archived', 'archived', Icons.archive, context),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    IconData icon,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = selectedFilter == value;

    return GestureDetector(
      onTap: () => setState(() => selectedFilter = value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.2)
              : isDark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.divider(context),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: isSelected
                  ? AppColors.primaryColor
                  : isDark
                  ? AppColors.lightText
                  : AppColors.darkText,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: AppTypography.body2().copyWith(
                color: isSelected
                    ? AppColors.primaryColor
                    : isDark
                    ? AppColors.lightText
                    : AppColors.darkText,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionsList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: smartCollections.length,
      itemBuilder: (context, index) {
        return _buildCollectionCard(smartCollections[index], context);
      },
    );
  }

  Widget _buildCollectionCard(
    Map<String, dynamic> collection,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showCollectionDetails(collection, context),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.divider(context), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: (collection['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    collection['icon'] as IconData,
                    color: collection['color'] as Color,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        collection['name'] as String,
                        style: AppTypography.heading3().copyWith(
                          color: isDark
                              ? AppColors.lightText
                              : AppColors.darkText,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        collection['description'] as String,
                        style: AppTypography.body3().copyWith(
                          color: isDark
                              ? AppColors.lightTextSecondary
                              : AppColors.darkTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: isDark ? AppColors.lightText : AppColors.darkText,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18.sp),
                          SizedBox(width: 8.w),
                          Text('Edit Rules'),
                        ],
                      ),
                      onTap: () => _showRuleBuilder(collection, context),
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.archive, size: 18.sp),
                          SizedBox(width: 8.w),
                          Text('Archive'),
                        ],
                      ),
                      onTap: () {},
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18.sp, color: Colors.red),
                          SizedBox(width: 8.w),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.insert_drive_file,
                        size: 16.sp,
                        color: isDark
                            ? AppColors.lightTextSecondary
                            : AppColors.darkTextSecondary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '${collection['itemCount']} items',
                        style: AppTypography.body3().copyWith(
                          color: isDark
                              ? AppColors.lightTextSecondary
                              : AppColors.darkTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: AppColors.divider(context),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    '${collection['ruleCount']} rules',
                    style: AppTypography.caption().copyWith(
                      color: isDark
                          ? AppColors.lightTextSecondary
                          : AppColors.darkTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Updated ${collection['lastUpdated']}',
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
  }

  Widget _buildCreateButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showCreateDialog(context),
      label: Text('New Collection'),
      icon: Icon(Icons.add),
      backgroundColor: AppColors.primaryColor,
    );
  }

  void _showCreateDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        title: Text(
          'Create Smart Collection',
          style: AppTypography.heading3().copyWith(
            color: isDark ? AppColors.lightText : AppColors.darkText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Collection name',
                hintStyle: AppTypography.body2().copyWith(
                  color: isDark
                      ? AppColors.lightTextSecondary
                      : AppColors.darkTextSecondary,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              decoration: InputDecoration(
                hintText: 'Description (optional)',
                hintStyle: AppTypography.body2().copyWith(
                  color: isDark
                      ? AppColors.lightTextSecondary
                      : AppColors.darkTextSecondary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showCollectionDetails(
    Map<String, dynamic> collection,
    BuildContext context,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _CollectionDetailsScreen(collection: collection),
      ),
    );
  }

  void _showRuleBuilder(Map<String, dynamic> collection, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      builder: (context) => _RuleBuilderSheet(collection: collection),
    );
  }

  void _showInfoDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        title: Text(
          'About Smart Collections',
          style: AppTypography.heading3().copyWith(
            color: isDark ? AppColors.lightText : AppColors.darkText,
          ),
        ),
        content: Text(
          'Smart Collections use rules to automatically organize your notes. Set conditions like tags, colors, and dates, and notes matching all rules are automatically grouped.',
          style: AppTypography.body2().copyWith(
            color: isDark ? AppColors.lightText : AppColors.darkText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _CollectionDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> collection;

  const _CollectionDetailsScreen({Key? key, required this.collection})
    : super(key: key);

  @override
  State<_CollectionDetailsScreen> createState() =>
      _CollectionDetailsScreenState();
}

class _CollectionDetailsScreenState extends State<_CollectionDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.lightText : AppColors.darkText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.collection['name'] as String,
          style: AppTypography.heading2().copyWith(
            color: isDark ? AppColors.lightText : AppColors.darkText,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection(context),
            SizedBox(height: 24.h),
            _buildRulesSection(context),
            SizedBox(height: 24.h),
            _buildItemsPreview(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
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
          Row(
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: (widget.collection['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  widget.collection['icon'] as IconData,
                  color: widget.collection['color'] as Color,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.collection['name'] as String,
                      style: AppTypography.heading3().copyWith(
                        color: isDark
                            ? AppColors.lightText
                            : AppColors.darkText,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      widget.collection['description'] as String,
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
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                'Items',
                '${widget.collection['itemCount']}',
                Icons.insert_drive_file,
                context,
              ),
              _buildStatCard(
                'Rules',
                '${widget.collection['ruleCount']}',
                Icons.rule,
                context,
              ),
              _buildStatCard(
                'Updated',
                widget.collection['lastUpdated'] as String,
                Icons.access_time,
                context,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBg : AppColors.lightBg,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: isDark
                  ? AppColors.lightTextSecondary
                  : AppColors.darkTextSecondary,
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: AppTypography.heading4().copyWith(
                color: isDark ? AppColors.lightText : AppColors.darkText,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
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
  }

  Widget _buildRulesSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Collection Rules',
          style: AppTypography.heading4().copyWith(
            color: isDark ? AppColors.lightText : AppColors.darkText,
          ),
        ),
        SizedBox(height: 12.h),
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
              _buildRuleItem('Tag', 'contains "work"', context),
              SizedBox(height: 12.h),
              _buildRuleItem('Date Range', 'Last 30 days', context),
              SizedBox(height: 12.h),
              _buildRuleItem('Priority', 'High or Medium', context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRuleItem(String label, String value, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          Icons.rule,
          size: 16.sp,
          color: isDark
              ? AppColors.lightTextSecondary
              : AppColors.darkTextSecondary,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.body3().copyWith(
                  color: isDark
                      ? AppColors.lightTextSecondary
                      : AppColors.darkTextSecondary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: AppTypography.body2().copyWith(
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsPreview(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Items in this Collection',
              style: AppTypography.heading4().copyWith(
                color: isDark ? AppColors.lightText : AppColors.darkText,
              ),
            ),
            Text(
              '${widget.collection['itemCount']}',
              style: AppTypography.heading4().copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        // Item preview list
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.divider(context),
                  width: 0.5,
                ),
              ),
              child: Text(
                'Item ${index + 1}',
                style: AppTypography.body2().copyWith(
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RuleBuilderSheet extends StatefulWidget {
  final Map<String, dynamic> collection;

  const _RuleBuilderSheet({Key? key, required this.collection})
    : super(key: key);

  @override
  State<_RuleBuilderSheet> createState() => _RuleBuilderSheetState();
}

class _RuleBuilderSheetState extends State<_RuleBuilderSheet> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edit Rules',
                style: AppTypography.heading3().copyWith(
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildRuleBuilder(context),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Save Changes'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRuleBuilder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      shrinkWrap: true,
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBg : AppColors.lightBg,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.divider(context), width: 0.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rule ${index + 1}',
                      style: AppTypography.body2().copyWith(
                        color: isDark
                            ? AppColors.lightText
                            : AppColors.darkText,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Tag contains "example"',
                      style: AppTypography.body3().copyWith(
                        color: isDark
                            ? AppColors.lightTextSecondary
                            : AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit,
                  size: 18.sp,
                  color: isDark
                      ? AppColors.lightTextSecondary
                      : AppColors.darkTextSecondary,
                ),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}
