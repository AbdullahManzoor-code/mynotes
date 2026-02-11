import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/smart_reminders_bloc.dart';
import 'package:mynotes/core/design_system/app_colors.dart';
import 'package:mynotes/core/design_system/app_typography.dart';
import 'package:mynotes/core/design_system/app_spacing.dart';
import '../../injection_container.dart';
import '../../core/services/global_ui_service.dart';

/// Frequency Analytics - Batch 6, Screen 3
/// Modernized to use Design System and converted to StatelessWidget
class FrequencyAnalyticsScreen extends StatelessWidget {
  const FrequencyAnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Frequency Analytics',
          style: AppTypography.displayMedium(context, AppColors.darkText),
        ),
        centerTitle: true,
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkText),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded, color: AppColors.primaryColor),
            onPressed: () {
              context.read<SmartRemindersBloc>().add(
                const LoadSuggestionsEvent(),
              );
              getIt<GlobalUiService>().hapticFeedback();
            },
          ),
        ],
      ),
      body: BlocBuilder<SmartRemindersBloc, SmartRemindersState>(
        builder: (context, state) {
          if (state is SmartRemindersLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          if (state is SmartRemindersInitial) {
            context.read<SmartRemindersBloc>().add(
              const LoadSuggestionsEvent(),
            );
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          if (state is! SmartRemindersLoaded) {
            return Center(
              child: Text(
                'Connect reminders to view analytics',
                style: AppTypography.bodyMedium(
                  context,
                  AppColors.secondaryText,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: AppSpacing.paddingAllM,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPeriodSelector(context, state.params.selectedPeriod),
                AppSpacing.gapL,

                // Main Metrics
                _buildMainMetrics(context, state),
                AppSpacing.gapL,

                // Daily Distribution
                _buildDailyDistribution(context),
                AppSpacing.gapL,

                // Comparison Card
                _buildComparisonCard(context, state),
                AppSpacing.gapL,

                // Projection
                _buildProjection(context),
                AppSpacing.gapXXL,
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, String selectedPeriod) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          _buildSegmentButton(context, 'Week', 'week', selectedPeriod),
          _buildSegmentButton(context, 'Month', 'month', selectedPeriod),
          _buildSegmentButton(context, 'Year', 'year', selectedPeriod),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(
    BuildContext context,
    String label,
    String value,
    String selectedPeriod,
  ) {
    final isSelected = selectedPeriod == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<SmartRemindersBloc>().add(
            ChangePeriodEvent(period: value),
          );
          getIt<GlobalUiService>().hapticFeedback();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.labelSmall(
              context,
              isSelected ? Colors.white : AppColors.secondaryText,
              isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainMetrics(BuildContext context, SmartRemindersLoaded state) {
    final totalReminders = state.params.reminders.length;
    final avgPerDay = totalReminders / 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text('Core Metrics', style: AppTypography.heading3(context)),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _buildStatCard(
              context,
              'Total Events',
              totalReminders.toString(),
              Icons.analytics_rounded,
            ),
            _buildStatCard(
              context,
              'Daily Average',
              avgPerDay.toStringAsFixed(1),
              Icons.today_rounded,
            ),
            _buildStatCard(
              context,
              'Best Streak',
              '12 Days',
              Icons.local_fire_department_rounded,
            ),
            _buildStatCard(context, 'Efficiency', '94%', Icons.speed_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: AppSpacing.paddingAllM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primaryColor),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTypography.heading1(context, AppColors.darkText),
              ),
              Text(
                label,
                style: AppTypography.labelSmall(
                  context,
                  AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyDistribution(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text('Weekly Heatmap', style: AppTypography.heading3(context)),
        ),
        Container(
          padding: AppSpacing.paddingAllM,
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: [
              _buildDayRow(context, 'Mon', 0.5),
              _buildDayRow(context, 'Tue', 0.8),
              _buildDayRow(context, 'Wed', 0.3),
              _buildDayRow(context, 'Thu', 0.7),
              _buildDayRow(context, 'Fri', 0.9),
              _buildDayRow(context, 'Sat', 0.2),
              _buildDayRow(context, 'Sun', 0.1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayRow(BuildContext context, String day, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              day,
              style: AppTypography.bodySmall(
                context,
                AppColors.darkText,
                FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: AppColors.lightBackground,
                valueColor: AlwaysStoppedAnimation(
                  progress > 0.7
                      ? AppColors.successGreen
                      : AppColors.primaryColor,
                ),
              ),
            ),
          ),
          AppSpacing.gapM,
          Text(
            '${(progress * 10).toInt()}',
            style: AppTypography.labelSmall(context, AppColors.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(
    BuildContext context,
    SmartRemindersLoaded state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Performance Trend',
            style: AppTypography.heading3(context),
          ),
        ),
        Container(
          padding: AppSpacing.paddingAllL,
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: [
              _buildComparisonMetric(
                context,
                'Current Cycle',
                state.params.reminders.length.toString(),
                AppColors.primaryColor,
              ),
              AppSpacing.gapM,
              _buildComparisonMetric(
                context,
                'Previous Cycle',
                (state.params.reminders.length * 0.8).toInt().toString(),
                AppColors.tertiaryText,
              ),
              const Divider(
                height: 32,
                thickness: 1,
                color: AppColors.borderLight,
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.successGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.trending_up_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  AppSpacing.gapM,
                  Expanded(
                    child: Text(
                      'You performed 20% better than the last cycle!',
                      style: AppTypography.bodySmall(
                        context,
                        AppColors.successGreen,
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonMetric(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium(context, AppColors.secondaryText),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(value, style: AppTypography.heading3(context, color)),
        ),
      ],
    );
  }

  Widget _buildProjection(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingAllL,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 24,
              ),
              AppSpacing.gapM,
              Text(
                'Smart Projections',
                style: AppTypography.heading2(context, Colors.white),
              ),
            ],
          ),
          AppSpacing.gapL,
          _buildProjectionItem(context, 'Estimated Reach', '52 Reminders'),
          _buildProjectionItem(context, 'Peak Intensity', 'Tuesday 14:00'),
          _buildProjectionItem(
            context,
            'Goal Progress',
            '82% of Monthly Target',
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionItem(
    BuildContext context,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall(
              context,
              Colors.white.withOpacity(0.8),
            ),
          ),
          Text(
            value,
            style: AppTypography.bodySmall(
              context,
              Colors.white,
              FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
