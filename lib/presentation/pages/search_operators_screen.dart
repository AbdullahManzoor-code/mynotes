import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/presentation/design_system/app_colors.dart';
import 'package:mynotes/presentation/design_system/app_typography.dart';

/// Search Operators Screen (ORG-006)
/// Advanced query syntax support (tag:work, color:blue, etc.)
class SearchOperatorsScreen extends StatefulWidget {
  const SearchOperatorsScreen({Key? key}) : super(key: key);

  @override
  State<SearchOperatorsScreen> createState() => _SearchOperatorsScreenState();
}

class _SearchOperatorsScreenState extends State<SearchOperatorsScreen> {
  final TextEditingController searchController = TextEditingController();
  List<String> searchHistory = [
    'tag:work color:blue',
    'before:2024-01-01',
    '"exact phrase" -tag:personal',
  ];
  List<String> appliedOperators = [];

  final operatorDefinitions = [
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(context),
            if (appliedOperators.isNotEmpty) ...[
              _buildAppliedOperators(context),
            ],
            _buildOperatorsGrid(context),
            _buildSearchHistory(context),
            _buildHelpSection(context),
          ],
        ),
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

  Widget _buildSearchBar(BuildContext context) {
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
            controller: searchController,
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
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        setState(() {});
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
              setState(() {});
              _parseSearchQuery(value);
            },
            onSubmitted: (value) {
              // Execute search
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Search: $value'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            children: [
              _buildQuickOperatorChip('tag:', context),
              _buildQuickOperatorChip('color:', context),
              _buildQuickOperatorChip('before:', context),
              _buildQuickOperatorChip('is:', context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickOperatorChip(String operator, BuildContext context) {
    return GestureDetector(
      onTap: () {
        searchController.text += '$operator ';
        setState(() {});
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

  Widget _buildAppliedOperators(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            children: appliedOperators.map((op) {
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
                        setState(() => appliedOperators.remove(op));
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

  Widget _buildOperatorsGrid(BuildContext context) {
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
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 0.8,
            ),
            itemCount: operatorDefinitions.length,
            itemBuilder: (context, index) {
              final opDef = operatorDefinitions[index];
              return _buildOperatorCard(opDef, context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorCard(Map<String, dynamic> opDef, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = opDef['color'] as Color;

    return GestureDetector(
      onTap: () {
        searchController.text += '${opDef['example']} ';
        setState(() {});
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.divider(context), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                opDef['operator'] as String,
                style: AppTypography.heading4().copyWith(
                  color: color,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              opDef['description'] as String,
              style: AppTypography.body3().copyWith(
                color: isDark ? AppColors.lightText : AppColors.darkText,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBg : AppColors.lightBg,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                opDef['example'] as String,
                style: AppTypography.caption().copyWith(
                  color: isDark
                      ? AppColors.lightTextSecondary
                      : AppColors.darkTextSecondary,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHistory(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: AppTypography.heading4().copyWith(
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => searchHistory.clear()),
                child: Text('Clear', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: searchHistory.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  searchController.text = searchHistory[index];
                  setState(() {});
                },
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  margin: EdgeInsets.only(bottom: 8.h),
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
                      Icon(
                        Icons.history,
                        size: 18.sp,
                        color: isDark
                            ? AppColors.lightTextSecondary
                            : AppColors.darkTextSecondary,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          searchHistory[index],
                          style: AppTypography.body3().copyWith(
                            color: isDark
                                ? AppColors.lightText
                                : AppColors.darkText,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 16.sp,
                          color: isDark
                              ? AppColors.lightTextSecondary
                              : AppColors.darkTextSecondary,
                        ),
                        onPressed: () {
                          setState(() => searchHistory.removeAt(index));
                        },
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(minWidth: 24.w),
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

  Widget _buildHelpSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Examples',
            style: AppTypography.heading4().copyWith(
              color: isDark ? AppColors.lightText : AppColors.darkText,
            ),
          ),
          SizedBox(height: 12.h),
          _buildHelpExample(
            'tag:work color:blue',
            'Find notes tagged "work" AND colored blue',
            context,
          ),
          _buildHelpExample(
            'tag:personal before:2024-01-01',
            'Find personal notes created before date',
            context,
          ),
          _buildHelpExample(
            '"exact phrase" -tag:archive',
            'Find exact phrase excluding archived notes',
            context,
          ),
          _buildHelpExample(
            'is:pinned type:text',
            'Find pinned text-type notes',
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildHelpExample(
    String query,
    String description,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.divider(context), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBg : AppColors.lightBg,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              query,
              style: AppTypography.body3().copyWith(
                color: AppColors.primaryColor,
                fontFamily: 'monospace',
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            description,
            style: AppTypography.caption().copyWith(
              color: isDark
                  ? AppColors.lightTextSecondary
                  : AppColors.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _parseSearchQuery(String query) {
    final regex = RegExp(r'(\w+):(\S+)');
    final matches = regex.allMatches(query);
    final ops = matches.map((m) => '${m.group(1)}:${m.group(2)}').toList();
    setState(() => appliedOperators = ops);
  }

  void _showSearchHelp(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        title: Text(
          'Search Help',
          style: AppTypography.heading3().copyWith(
            color: isDark ? AppColors.lightText : AppColors.darkText,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Operators:',
                style: AppTypography.body2().copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                ),
              ),
              SizedBox(height: 8.h),
              ...[
                'tag:name - Filter by tag',
                'color:blue - Filter by color',
                'type:text - Filter by type',
                'before:2024 - Created before date',
                'after:2024 - Created after date',
                'is:pinned - Filter by status',
                '"text" - Exact phrase match',
                '-tag:x - Exclude term',
              ].map(
                (e) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Text(
                    e,
                    style: AppTypography.body3().copyWith(
                      color: isDark ? AppColors.lightText : AppColors.darkText,
                    ),
                  ),
                ),
              ),
            ],
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
