import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/core/design_system/app_colors.dart';
import 'package:mynotes/core/design_system/app_typography.dart';

/// Smart Reminders Screen (ALM-003)
/// AI-powered intelligent reminder scheduling based on user patterns
class SmartRemindersScreen extends StatefulWidget {
  const SmartRemindersScreen({Key? key}) : super(key: key);

  @override
  State<SmartRemindersScreen> createState() => _SmartRemindersScreenState();
}

class _SmartRemindersScreenState extends State<SmartRemindersScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  final suggestedReminders = [
    {
      'title': 'Team Meeting',
      'suggestedTime': '2:00 PM',
      'confidence': 0.92,
      'frequency': 'Weekly on Tuesday',
      'icon': Icons.people,
      'color': Colors.blue,
    },
    {
      'title': 'Project Review',
      'suggestedTime': '4:30 PM',
      'confidence': 0.85,
      'frequency': 'Weekly on Friday',
      'icon': Icons.task_alt,
      'color': Colors.purple,
    },
    {
      'title': 'Grocery Shopping',
      'suggestedTime': '6:00 PM',
      'confidence': 0.78,
      'frequency': 'Every Saturday',
      'icon': Icons.shopping_cart,
      'color': Colors.orange,
    },
  ];

  final patterns = [
    {
      'title': 'Morning Routine',
      'time': '8:00 AM',
      'frequency': 'Daily',
      'completed': 94,
      'total': 100,
      'icon': Icons.wb_sunny,
      'color': Colors.amber,
    },
    {
      'title': 'Work Check-in',
      'time': '10:00 AM',
      'frequency': 'Weekdays',
      'completed': 87,
      'total': 100,
      'icon': Icons.work,
      'color': Colors.blue,
    },
    {
      'title': 'Evening Review',
      'time': '9:00 PM',
      'frequency': 'Daily',
      'completed': 76,
      'total': 100,
      'icon': Icons.nightlight_round,
      'color': Colors.indigo,
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
          _buildSuggestionsTab(context),
          _buildPatternsTab(context),
          _buildSettingsTab(context),
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
        'Smart Reminders',
        style: AppTypography.heading2().copyWith(
          color: isDark ? AppColors.lightText : AppColors.darkText,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.psychology,
            color: isDark ? AppColors.lightText : AppColors.darkText,
          ),
          onPressed: () => _showAIInfoDialog(context),
        ),
        SizedBox(width: 8.w),
      ],
      bottom: TabBar(
        controller: tabController,
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: isDark
            ? AppColors.lightTextSecondary
            : AppColors.darkTextSecondary,
        indicatorColor: AppColors.primaryColor,
        tabs: [
          Tab(text: 'Suggestions'),
          Tab(text: 'Patterns'),
          Tab(text: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildSuggestionsTab(BuildContext context) {
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
                  Icons.auto_awesome,
                  size: 18.sp,
                  color: AppColors.primaryColor,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'AI suggests reminders based on your patterns',
                    style: AppTypography.body3().copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Recommended for You',
            style: AppTypography.heading3().copyWith(
              color: isDark ? AppColors.lightText : AppColors.darkText,
            ),
          ),
          SizedBox(height: 12.h),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: suggestedReminders.length,
            itemBuilder: (context, index) {
              return _buildSuggestionCard(suggestedReminders[index], context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(
    Map<String, dynamic> suggestion,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confidence = suggestion['confidence'] as double;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.divider(context), width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: (suggestion['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  suggestion['icon'] as IconData,
                  color: suggestion['color'] as Color,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion['title'] as String,
                      style: AppTypography.heading4().copyWith(
                        color: isDark
                            ? AppColors.lightText
                            : AppColors.darkText,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${suggestion['suggestedTime']} • ${suggestion['frequency']}',
                      style: AppTypography.caption().copyWith(
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
          SizedBox(height: 12.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Confidence',
                    style: AppTypography.body3().copyWith(
                      color: isDark
                          ? AppColors.lightTextSecondary
                          : AppColors.darkTextSecondary,
                    ),
                  ),
                  Text(
                    '${(confidence * 100).toStringAsFixed(0)}%',
                    style: AppTypography.body3().copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: confidence,
                  backgroundColor: isDark
                      ? AppColors.darkBg
                      : AppColors.lightBg,
                  valueColor: AlwaysStoppedAnimation(AppColors.primaryColor),
                  minHeight: 6.h,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(onPressed: () {}, child: Text('Ignore')),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added: ${suggestion['title']}')),
                    );
                  },
                  child: Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatternsTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detected Patterns',
            style: AppTypography.heading3().copyWith(
              color: isDark ? AppColors.lightText : AppColors.darkText,
            ),
          ),
          SizedBox(height: 16.h),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: patterns.length,
            itemBuilder: (context, index) {
              return _buildPatternCard(patterns[index], context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPatternCard(Map<String, dynamic> pattern, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double completionRate = (pattern['total'] as int) > 0
        ? (pattern['completed'] as int) / (pattern['total'] as int)
        : 0.0;

    return Container(
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
                  color: (pattern['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  pattern['icon'] as IconData,
                  color: pattern['color'] as Color,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pattern['title'] as String,
                      style: AppTypography.heading4().copyWith(
                        color: isDark
                            ? AppColors.lightText
                            : AppColors.darkText,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${pattern['time']} • ${pattern['frequency']}',
                      style: AppTypography.caption().copyWith(
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
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Completion Rate',
                style: AppTypography.body3().copyWith(
                  color: isDark
                      ? AppColors.lightTextSecondary
                      : AppColors.darkTextSecondary,
                ),
              ),
              Text(
                '${(completionRate * 100).toStringAsFixed(0)}%',
                style: AppTypography.body3().copyWith(
                  color: pattern['color'] as Color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: completionRate.toDouble(),
              backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
              valueColor: AlwaysStoppedAnimation(pattern['color'] as Color),
              minHeight: 8.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Settings',
            style: AppTypography.heading3().copyWith(
              color: isDark ? AppColors.lightText : AppColors.darkText,
            ),
          ),
          SizedBox(height: 16.h),
          _buildSettingsTile(
            'Enable Pattern Learning',
            'AI learns from your reminder completion behavior',
            true,
            (value) {},
            context,
          ),
          _buildSettingsTile(
            'Smart Time Suggestions',
            'Suggest optimal times for reminders',
            true,
            (value) {},
            context,
          ),
          _buildSettingsTile(
            'Snooze Analysis',
            'Learn your preferred snooze patterns',
            true,
            (value) {},
            context,
          ),
          _buildSettingsTile(
            'Frequency Detection',
            'Automatically detect reminder frequency',
            true,
            (value) {},
            context,
          ),
          SizedBox(height: 24.h),
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
                  'AI Model',
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
                        'Version: 2.1.0',
                        style: AppTypography.body3().copyWith(
                          color: isDark
                              ? AppColors.lightText
                              : AppColors.darkText,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Updated: Jan 2026',
                        style: AppTypography.caption().copyWith(
                          color: isDark
                              ? AppColors.lightTextSecondary
                              : AppColors.darkTextSecondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Data used: 127 reminders analyzed',
                        style: AppTypography.caption().copyWith(
                          color: isDark
                              ? AppColors.lightTextSecondary
                              : AppColors.darkTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    child: Text('Reset AI Data'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    String description,
    bool isEnabled,
    Function(bool) onChanged,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.divider(context), width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body2().copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.lightText : AppColors.darkText,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: AppTypography.caption().copyWith(
                    color: isDark
                        ? AppColors.lightTextSecondary
                        : AppColors.darkTextSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onChanged,
            activeColor: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  void _showAIInfoDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        title: Text(
          'How Smart Reminders Work',
          style: AppTypography.heading3().copyWith(
            color: isDark ? AppColors.lightText : AppColors.darkText,
          ),
        ),
        content: Text(
          'Smart Reminders analyze your reminder patterns to:\n\n'
          '• Suggest optimal times for reminders\n'
          '• Detect recurring patterns\n'
          '• Learn your completion habits\n'
          '• Predict future reminder needs\n\n'
          'All learning happens on your device - your data stays private.',
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
