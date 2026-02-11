import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../design_system/design_system.dart';
import '../widgets/universal_item_card.dart';
import '../bloc/analytics_bloc.dart';

/// Analytics Dashboard Screen
/// Unified productivity insights across Notes, Todos, and Reminders
/// Implements G3: Overview, Focus, Tasks, Notes, Reflection tabs
class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _chartController;
  late AnimationController _statsController;
  late Animation<double> _chartAnimation;
  late Animation<double> _statsAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initializeAnimations();
    _startAnimations();
    // derived from user's request to load analytics
    context.read<AnalyticsBloc>().add(const LoadAnalyticsEvent());
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

  void _startAnimations() async {
    _statsController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _chartController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chartController.dispose();
    _statsController.dispose();
    super.dispose();
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
      case 'focus':
        return AppColors.primary;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(
          'Analytics Dashboard',
          style: AppTypography.heading3(context).copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<AnalyticsBloc>().add(
              const RefreshAnalyticsEvent(),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Focus'),
            Tab(text: 'Tasks'),
            Tab(text: 'Notes'),
            Tab(text: 'Reflection'),
          ],
        ),
      ),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return _buildLoadingState();
          } else if (state is AnalyticsLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(state),
                _buildFocusTab(state),
                _buildTasksTab(state),
                _buildNotesTab(state),
                _buildReflectionTab(state),
              ],
            );
          } else if (state is AnalyticsError) {
            return _buildErrorState(state.message);
          }
          return _buildLoadingState();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 64.sp),
          SizedBox(height: 16.h),
          Text(
            'Error loading analytics',
            style: TextStyle(color: Colors.white, fontSize: 18.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () =>
                context.read<AnalyticsBloc>().add(const LoadAnalyticsEvent()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // --- TAB BUILDERS ---

  Widget _buildOverviewTab(AnalyticsLoaded state) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCards(state),
          SizedBox(height: 24.h),
          _buildWeeklyChart(state.weeklyActivity),
          SizedBox(height: 24.h),
          _buildRecentActivity(
            state.recentItems.take(3).toList(),
          ), // Show top 3 recent
        ],
      ),
    );
  }

  Widget _buildFocusTab(AnalyticsLoaded state) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInsightsSection(state.productivityInsights),
          SizedBox(height: 24.h),
          _buildMetricCard(
            'Focus Sessions',
            '${state.productivityInsights['total_sessions'] ?? 0}', // Assuming this key exists or defaulting
            Icons.psychology,
            AppColors.primary,
            subtitle: 'Total sessions completed',
          ),
        ],
      ),
    );
  }

  Widget _buildTasksTab(AnalyticsLoaded state) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryBreakdown(state.categoryBreakdown),
          SizedBox(height: 24.h),
          if (state.overdueItems.isNotEmpty)
            _buildOverdueSection(state.overdueItems),
          if (state.overdueItems.isEmpty)
            Center(
              child: Text(
                "No overdue tasks!",
                style: TextStyle(color: Colors.white60, fontSize: 14.sp),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotesTab(AnalyticsLoaded state) {
    final notes = state.recentItems.where((i) => i.isNote).toList();
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricCard(
            'Notes Created',
            '${state.itemCounts['notes'] ?? 0}',
            Icons.edit_note,
            Colors.blue,
          ),
          SizedBox(height: 24.h),
          Text(
            'Recent Notes',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          if (notes.isEmpty)
            Center(
              child: Text(
                "No notes created yet.",
                style: TextStyle(color: Colors.white60, fontSize: 14.sp),
              ),
            )
          else
            ...notes
                .take(10)
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

  Widget _buildReflectionTab(AnalyticsLoaded state) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricCard(
            'Reflection Streak',
            '${state.streak} days', // Reusing streak for now
            Icons.self_improvement,
            Colors.purple,
          ),
          SizedBox(height: 24.h),
          Text(
            'Recent Insights',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          if (state.dailyHighlights.isNotEmpty)
            ...state.dailyHighlights.map(
              (h) => Card(
                color: AppColors.darkCardBackground,
                margin: EdgeInsets.only(bottom: 8.h),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(h, style: const TextStyle(color: Colors.white)),
                ),
              ),
            )
          else
            const Center(
              child: Text(
                'No recent insights recorded.',
                style: TextStyle(color: Colors.white54),
              ),
            ),
        ],
      ),
    );
  }

  // --- REUSED WIDGETS ---

  Widget _buildOverviewCards(AnalyticsLoaded state) {
    final completionRate = state.productivityInsights['completion_rate'] ?? 0;
    final focusMinutes = state.productivityInsights['focus_minutes'] ?? 0;

    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _statsAnimation.value,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Completion Rate',
                      '$completionRate%',
                      Icons.trending_up,
                      AppColors.accentGreen,
                      subtitle: 'Todos completed',
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildMetricCard(
                      'Daily Streak',
                      '${state.streak}',
                      Icons.local_fire_department,
                      Colors.orange,
                      subtitle: state.streak == 1 ? 'day' : 'days',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildMetricCard(
                'Deep Focus Time',
                '$focusMinutes min',
                Icons.timer,
                AppColors.primary,
                subtitle: 'Total minutes focused',
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

  Widget _buildWeeklyChart(Map<String, double> weeklyActivity) {
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
              return _buildBarChart(weeklyActivity);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(Map<String, double> weeklyActivity) {
    if (weeklyActivity.isEmpty) return const SizedBox.shrink();

    final maxValue = weeklyActivity.values.reduce(math.max);
    if (maxValue == 0) {
      // Show empty state for chart
      return SizedBox(
        height: 120.h,
        child: Center(
          child: Text(
            'No activity yet',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
          ),
        ),
      );
    }

    return SizedBox(
      height: 120.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: weeklyActivity.entries.map((entry) {
          final height =
              (entry.value / maxValue) * 80.h * _chartAnimation.value;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 24.w,
                height: height.clamped(4.h, 80.h),
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

  Widget _buildCategoryBreakdown(List<Map<String, dynamic>> categoryBreakdown) {
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
          if (categoryBreakdown.isEmpty)
            Center(
              child: Text(
                'No data recorded',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
              ),
            )
          else
            ...categoryBreakdown.map(
              (category) => _buildCategoryItem(category),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    final color = _getCategoryColor(category['name']);
    final percentage = category['percentage'] as double;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: color,
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
            '${percentage.round()}%',
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
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(Map<String, dynamic> insights) {
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
            '${insights['most_productive_hour'] ?? 9}:00 AM', // Default or real
            Icons.schedule,
          ),
          _buildInsightItem(
            'Top Category',
            insights['top_category'] ?? 'N/A',
            Icons.category,
          ),
          _buildInsightItem(
            'Total Items',
            '${insights['total_items'] ?? 0}',
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

  Widget _buildRecentActivity(List<UniversalItem> recentItems) {
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
          if (recentItems.isEmpty)
            Center(
              child: Text(
                'No recent activity',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
              ),
            )
          else
            ...recentItems.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: UniversalItemCard(item: item, showActions: false),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverdueSection(List<UniversalItem> overdueItems) {
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
                  '${overdueItems.length}',
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
          ...overdueItems
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

extension DoubleClamped on double {
  double clamped(double min, double max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }
}
