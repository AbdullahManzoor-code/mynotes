import 'package:flutter/material.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'dart:ui' as ui;
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/presentation/widgets/analytics/analytics_card.dart';

class EnhancedAnalyticsDashboardScreenRefactored extends StatelessWidget {
  const EnhancedAnalyticsDashboardScreenRefactored({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.i('Building EnhancedAnalyticsDashboardScreenRefactored');

    return Scaffold(
      backgroundColor: AppColors.background(context),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildBackgroundGlow(context),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 48.h),
                  Text(
                    'Analytics Dashboard',
                    style: AppTypography.heading1(context),
                  ),
                  SizedBox(height: 24.h),
                  _buildDateRangeSelector(context),
                  SizedBox(height: 28.h),
                  _buildKeyMetrics(context),
                  SizedBox(height: 28.h),
                  _buildDetailedStats(context),
                  SizedBox(height: 28.h),
                  _buildActivityBreakdown(context),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['Week', 'Month', 'Year', 'All Time']
            .map(
              (range) => Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: FilterChip(
                  label: Text(range),
                  onSelected: (_) => AppLogger.i('Filter by $range'),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildKeyMetrics(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12.w,
      crossAxisSpacing: 12.w,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        AnalyticsCard(
          title: 'Total Notes',
          value: '47',
          subtitle: '+5 this week',
          icon: Icons.note_outlined,
          valueColor: Colors.blue,
          trend: 'up',
          trendPercent: 12,
        ),
        AnalyticsCard(
          title: 'Todos Done',
          value: '156',
          subtitle: 'Completion: 78%',
          icon: Icons.check_circle_outline,
          valueColor: Colors.green,
          percentage: 0.78,
          trend: 'up',
          trendPercent: 8,
        ),
        AnalyticsCard(
          title: 'Focus Time',
          value: '12h 30m',
          subtitle: 'This week',
          icon: Icons.timer_outlined,
          valueColor: Colors.red,
          trend: 'up',
          trendPercent: 15,
        ),
        AnalyticsCard(
          title: 'Storage Used',
          value: '2.4 GB',
          subtitle: 'of 5 GB',
          icon: Icons.storage_outlined,
          valueColor: Colors.orange,
          percentage: 0.48,
          trend: 'down',
          trendPercent: 5,
        ),
      ],
    );
  }

  Widget _buildDetailedStats(BuildContext context) {
    return AnalyticsSummaryCard(
      title: 'Detailed Statistics',
      stats: [
        AnalyticsStat(label: 'Reflections Created', value: '12'),
        AnalyticsStat(label: 'Average Session Length', value: '32m'),
        AnalyticsStat(label: 'Most Productive Day', value: 'Tuesday'),
        AnalyticsStat(label: 'Avg Daily Activity', value: '2.4 hours'),
        AnalyticsStat(label: 'Longest Streak', value: '18 days'),
      ],
    );
  }

  Widget _buildActivityBreakdown(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.theme.dividerColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity By Type',
            style: AppTypography.bodyMedium(
              context,
            ).copyWith(fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          _buildActivityBar(context, 'Notes', 35, Colors.blue),
          SizedBox(height: 8.h),
          _buildActivityBar(context, 'Todos', 25, Colors.green),
          SizedBox(height: 8.h),
          _buildActivityBar(context, 'Alarms', 20, Colors.orange),
          SizedBox(height: 8.h),
          _buildActivityBar(context, 'Media', 15, Colors.purple),
          SizedBox(height: 8.h),
          _buildActivityBar(context, 'Reflections', 5, Colors.pink),
        ],
      ),
    );
  }

  Widget _buildActivityBar(
    BuildContext context,
    String label,
    double percentage,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.bodySmall(context).copyWith(fontSize: 11.sp),
            ),
            Text(
              '${percentage.toInt()}%',
              style: AppTypography.bodySmall(context).copyWith(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 4.h,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundGlow(BuildContext context) {
    return Positioned(
      top: -100.h,
      right: -100.w,
      child: Container(
        width: 300.w,
        height: 300.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(0.08),
        ),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}
