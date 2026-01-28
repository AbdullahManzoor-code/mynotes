import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../design_system.dart';

/// Stat Card Widget - Displays key metrics with icon, label, value, and trend
/// Based on template: today_dashboard_home_1/2
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? trend;
  final Color? trendColor;
  final IconData? icon;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.trend,
    this.trendColor,
    this.icon,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardBackground : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          border: Border.all(
            color: isDark
                ? AppColors.borderDark.withOpacity(0.3)
                : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label (uppercase, small, muted)
            Text(
              label.toUpperCase(),
              style: AppTypography.caption(
                null,
                AppColors.textMuted,
                FontWeight.w600,
              ).copyWith(letterSpacing: 0.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),

            // Value + Trend Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                // Value
                Expanded(
                  child: Text(
                    value,
                    style: AppTypography.heading1(
                      context,
                      null,
                      FontWeight.w700,
                    ).copyWith(fontSize: 24.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Trend (if provided)
                if (trend != null)
                  Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: Text(
                      trend!,
                      style: AppTypography.caption(
                        null,
                        trendColor ?? AppColors.successGreen,
                        FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Stats Grid - Layout for multiple stat cards in a row
class StatsGrid extends StatelessWidget {
  final List<StatCard> cards;
  final int crossAxisCount;
  final double spacing;

  const StatsGrid({
    super.key,
    required this.cards,
    this.crossAxisCount = 2,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing.h,
        crossAxisSpacing: spacing.w,
        childAspectRatio: 1.5,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => cards[index],
    );
  }
}

/// Prompt Card - Highlighted card with icon, title, description, and action
/// Used for daily reflections, suggestions, or important prompts
class PromptCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onPressed;
  final Color? accentColor;
  final Color? backgroundColor;

  const PromptCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
    this.accentColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = accentColor ?? AppColors.primary;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon + Title Row
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                ),
                child: Icon(icon, size: 20.sp, color: Colors.white),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.heading3(context, null, FontWeight.w700),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Description
          Text(
            description,
            style: AppTypography.bodyMedium(
              isDark ? AppColors.textPrimary(context) : AppColors.darkText,
            ).copyWith(height: 1.5),
          ),
          SizedBox(height: 16.h),

          // Action Button
          PrimaryButton(
            text: buttonText,
            onPressed: onPressed,
            backgroundColor: color,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}

/// Section Header - Title with optional action link
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPaddingHorizontal,
            vertical: 8.h,
          ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTypography.caption(
              AppColors.textMuted,
              null,
              FontWeight.w600,
            ).copyWith(letterSpacing: 0.5),
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionText!,
                style: AppTypography.caption(
                  AppColors.primary,
                  null,
                  FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
