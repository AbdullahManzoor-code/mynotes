import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// PHASE 6: ANALYTICS & INSIGHTS
/// Analytics Card - Statistics and insights display
/// ════════════════════════════════════════════════════════════════════════════

class AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? valueColor;
  final double? percentage;
  final String? trend; // 'up', 'down', 'stable'
  final int? trendPercent;

  const AnalyticsCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.valueColor,
    this.percentage,
    this.trend,
    this.trendPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.theme.dividerColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, size: 16.r, color: AppColors.primary),
              ),
              if (trend != null)
                Row(
                  children: [
                    Icon(
                      trend == 'up'
                          ? Icons.trending_up
                          : trend == 'down'
                          ? Icons.trending_down
                          : Icons.trending_flat,
                      size: 12.r,
                      color: trend == 'up'
                          ? Colors.green
                          : trend == 'down'
                          ? Colors.red
                          : Colors.grey,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '$trendPercent%',
                      style: AppTypography.caption(context).copyWith(
                        fontSize: 9.sp,
                        color: trend == 'up'
                            ? Colors.green
                            : trend == 'down'
                            ? Colors.red
                            : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 12.h),
          // Title
          Text(
            title,
            style: AppTypography.caption(context).copyWith(
              fontSize: 10.sp,
              color: context.theme.disabledColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          // Value
          Text(
            value,
            style: AppTypography.heading2(context).copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.primary,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4.h),
            Text(
              subtitle!,
              style: AppTypography.caption(context).copyWith(
                fontSize: 9.sp,
                color: context.theme.disabledColor.withOpacity(0.7),
              ),
            ),
          ],
          // Progress bar if percentage provided
          if (percentage != null) ...[
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: percentage!,
                minHeight: 3.h,
                backgroundColor: context.theme.dividerColor.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  valueColor ?? AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Analytics Summary Card - Multi-stat summary
class AnalyticsSummaryCard extends StatelessWidget {
  final String title;
  final List<AnalyticsStat> stats;

  const AnalyticsSummaryCard({
    super.key,
    required this.title,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
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
            title,
            style: AppTypography.body1(
              context,
            ).copyWith(fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          ...stats.map((stat) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    stat.label,
                    style: AppTypography.body2(context).copyWith(
                      fontSize: 11.sp,
                      color: context.theme.disabledColor,
                    ),
                  ),
                  Text(
                    stat.value,
                    style: AppTypography.body2(
                      context,
                    ).copyWith(fontSize: 11.sp, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class AnalyticsStat {
  final String label;
  final String value;

  AnalyticsStat({required this.label, required this.value});
}
