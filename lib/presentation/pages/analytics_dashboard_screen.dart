import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import '../design_system/design_system.dart';
import '../widgets/universal_item_card.dart';
import '../../data/repositories/unified_repository.dart';

/// Analytics Dashboard Screen
/// Unified productivity insights across Notes, Todos, and Reminders
/// Shows the power of integrated data analytics
class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen>
    with TickerProviderStateMixin {
  final _repository = UnifiedRepository.instance;

  late AnimationController _chartController;
  late AnimationController _statsController;
  late Animation<double> _chartAnimation;
  late Animation<double> _statsAnimation;

  Map<String, int> _itemCounts = {};
  Map<String, dynamic> _insights = {};
  List<UniversalItem> _recentItems = [];
  List<UniversalItem> _overdueItems = [];
  bool _isLoading = true;

  // Analytics data
  Map<String, double> _weeklyProgress = {};
  List<Map<String, dynamic>> _categoryBreakdown = [];
  double _completionRate = 0.0;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAnalyticsData();
  }

  void _initializeAnimations() {
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _statsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _chartController, curve: Curves.easeOutCubic),
    );

    _statsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _statsController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _chartController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);

    try {
      await _repository.initialize();

      final futures = await Future.wait([
        _repository.getItemCounts(),
        _repository.getProductivityInsights(),
        _repository.getAllItems(),
        _repository.getOverdueReminders(),
      ]);

      _itemCounts = futures[0] as Map<String, int>;
      _insights = futures[1] as Map<String, dynamic>;
      final allItems = futures[2] as List<UniversalItem>;
      _overdueItems = futures[3] as List<UniversalItem>;

      // Calculate analytics
      _calculateWeeklyProgress(allItems);
      _calculateCategoryBreakdown(allItems);
      _calculateCompletionRate();
      _calculateStreak(allItems);

      _recentItems = allItems.take(5).toList();

      setState(() => _isLoading = false);

      // Start animations
      _statsController.forward();
      await Future.delayed(const Duration(milliseconds: 300));
      _chartController.forward();
    } catch (error) {
      setState(() => _isLoading = false);
      debugPrint('Analytics loading error: $error');
    }
  }

  void _calculateWeeklyProgress(List<UniversalItem> items) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    _weeklyProgress = {};
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final dayKey = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i];

      final dayItems = items.where((item) {
        return item.createdAt.year == day.year &&
            item.createdAt.month == day.month &&
            item.createdAt.day == day.day;
      }).length;

      _weeklyProgress[dayKey] = dayItems.toDouble();
    }
  }

  void _calculateCategoryBreakdown(List<UniversalItem> items) {
    final categoryMap = <String, int>{};

    for (final item in items) {
      final category = item.category.isEmpty ? 'General' : item.category;
      categoryMap[category] = (categoryMap[category] ?? 0) + 1;
    }

    final total = items.length;
    _categoryBreakdown =
        categoryMap.entries.map((entry) {
            return {
              'name': entry.key,
              'count': entry.value,
              'percentage': total > 0 ? (entry.value / total) * 100 : 0.0,
              'color': _getCategoryColor(entry.key),
            };
          }).toList()
          ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
  }

  void _calculateCompletionRate() {
    final totalTodos = _itemCounts['todos'] ?? 0;
    final completedTodos = _itemCounts['completed_todos'] ?? 0;
    _completionRate = totalTodos > 0
        ? (completedTodos / totalTodos) * 100
        : 0.0;
  }

  void _calculateStreak(List<UniversalItem> items) {
    final now = DateTime.now();
    _streak = 0;

    for (int i = 0; i < 30; i++) {
      final day = now.subtract(Duration(days: i));
      final hasActivity = items.any(
        (item) =>
            item.createdAt.year == day.year &&
            item.createdAt.month == day.month &&
            item.createdAt.day == day.day,
      );

      if (hasActivity) {
        _streak++;
      } else {
        break;
      }
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return AppColors.accentBlue;
      case 'personal':
        return AppColors.accentGreen;
      case 'health':
        return AppColors.accentPurple;
      case 'shopping':
        return Colors.orange;
      case 'finance':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: _isLoading ? _buildLoadingState() : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverPadding(
          padding: EdgeInsets.all(24.w),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildOverviewCards(),
              SizedBox(height: 24.h),
              _buildWeeklyChart(),
              SizedBox(height: 24.h),
              _buildCategoryBreakdown(),
              SizedBox(height: 24.h),
              _buildInsightsSection(),
              SizedBox(height: 24.h),
              _buildRecentActivity(),
              if (_overdueItems.isNotEmpty) ...[
                SizedBox(height: 24.h),
                _buildOverdueSection(),
              ],
              SizedBox(height: 100.h), // Bottom padding
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120.h,
      pinned: true,
      backgroundColor: AppColors.darkBackground,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Analytics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        titlePadding: EdgeInsets.only(left: 24.w, bottom: 16.h),
      ),
      actions: [
        IconButton(
          onPressed: _loadAnalyticsData,
          icon: Icon(Icons.refresh, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildOverviewCards() {
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _statsAnimation.value,
          child: Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Completion Rate',
                  '${_completionRate.round()}%',
                  Icons.trending_up,
                  AppColors.accentGreen,
                  subtitle: 'Todos completed',
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildMetricCard(
                  'Daily Streak',
                  '$_streak',
                  Icons.local_fire_department,
                  Colors.orange,
                  subtitle: _streak == 1 ? 'day' : 'days',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              const Spacer(),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10.sp,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Weekly Activity',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Last 7 Days',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          AnimatedBuilder(
            animation: _chartAnimation,
            builder: (context, child) {
              return _buildBarChart();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    if (_weeklyProgress.isEmpty) return const SizedBox.shrink();

    final maxValue = _weeklyProgress.values.reduce(math.max);
    if (maxValue == 0) return const SizedBox.shrink();

    return SizedBox(
      height: 120.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _weeklyProgress.entries.map((entry) {
          final height =
              (entry.value / maxValue) * 80.h * _chartAnimation.value;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 24.w,
                height: height,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                entry.key,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Breakdown',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20.h),
          ..._categoryBreakdown.map((category) => _buildCategoryItem(category)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: category['color'],
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              category['name'],
              style: TextStyle(fontSize: 14.sp, color: Colors.white),
            ),
          ),
          Text(
            '${category['percentage'].round()}%',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            '${category['count']}',
            style: TextStyle(
              fontSize: 14.sp,
              color: category['color'],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: AppColors.primary, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Smart Insights',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildInsightItem(
            'Most Productive Time',
            '${_insights['most_productive_hour'] ?? 9}:00 AM',
            Icons.schedule,
          ),
          _buildInsightItem(
            'Top Category',
            _insights['top_category'] ?? 'General',
            Icons.category,
          ),
          _buildInsightItem(
            'Total Items',
            '${_insights['total_items'] ?? 0}',
            Icons.inventory,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String title, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 16.sp),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          if (_recentItems.isEmpty)
            Center(
              child: Text(
                'No recent activity',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
              ),
            )
          else
            ..._recentItems.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: UniversalItemCard(item: item, showActions: false),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverdueSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Overdue Items',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${_overdueItems.length}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ..._overdueItems
              .take(3)
              .map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: UniversalItemCard(item: item, showActions: false),
                ),
              ),
        ],
      ),
    );
  }
}
