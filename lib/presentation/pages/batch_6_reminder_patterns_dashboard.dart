import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/smart_reminders/smart_reminders_bloc.dart';
import 'package:mynotes/domain/services/ai_suggestion_engine.dart';
import 'package:mynotes/core/design_system/app_colors.dart';
import 'package:mynotes/core/design_system/app_typography.dart';
import 'package:mynotes/core/design_system/app_spacing.dart';
import '../../injection_container.dart';
import '../../core/services/global_ui_service.dart';
import '../../core/utils/app_logger.dart';

/// Reminder Patterns Dashboard - Batch 6, Screen 2
/// Refactored to use Design System and BLoC integration
class ReminderPatternsDashboard extends StatelessWidget {
  const ReminderPatternsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Reminder Patterns',
          style: AppTypography.displayMedium(context, AppColors.darkText),
        ),
        centerTitle: true,
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkText),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.primaryColor,
            ),
            onPressed: () {
              AppLogger.i('ReminderPatternsDashboard: Refreshing patterns');
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

          if (state is! SmartRemindersLoaded) {
            return Center(
              child: Text(
                'Load reminders to see patterns',
                style: AppTypography.bodyMedium(
                  context,
                  AppColors.secondaryText,
                ),
              ),
            );
          }

          // Use AISuggestionEngine to analyze patterns from the BLoC's state
          final aiEngine = AISuggestionEngine();

          return FutureBuilder<Map<String, dynamic>>(
            future: aiEngine.getPersonalizedRecommendationStrength(
              reminderHistory: state.params.reminders,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }

              final data = snapshot.data ?? {};
              final reminders = state.params.reminders;

              return ListView(
                padding: AppSpacing.paddingAllM,
                children: [
                  // Engagement Overview
                  _buildEngagementOverview(context, data),
                  AppSpacing.gapL,

                  // Time Patterns
                  _buildTimePatternsSection(context, aiEngine, reminders),
                  AppSpacing.gapL,

                  // Frequency Analysis
                  _buildFrequencyAnalysis(context, data),
                  AppSpacing.gapL,

                  // Activity Trend
                  _buildTrendAnalysis(context, data),
                  AppSpacing.gapXXL,
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEngagementOverview(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final strength = data['strength'] as String? ?? 'low';
    final score = data['score'] as int? ?? 0;
    final color = _getStrengthColor(strength);

    return Container(
      padding: AppSpacing.paddingAllL,
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Engagement Strength', style: AppTypography.heading2(context)),
          AppSpacing.gapL,
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 10,
                      backgroundColor: AppColors.lightBackground,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                    Text(
                      '$score%',
                      style: AppTypography.heading1(
                        context,
                        AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapXL,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        strength.toUpperCase().replaceAll('_', ' '),
                        style: AppTypography.labelSmall(
                          context,
                          color,
                          FontWeight.bold,
                        ),
                      ),
                    ),
                    AppSpacing.gapS,
                    Text(
                      'Based on your consistent reminder usage and task completion rate.',
                      style: AppTypography.bodySmall(
                        context,
                        AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePatternsSection(
    BuildContext context,
    AISuggestionEngine aiEngine,
    List<dynamic> reminders,
  ) {
    if (reminders.isEmpty) return const SizedBox.shrink();

    final timePatterns = aiEngine.detectTimePatterns(reminders);
    final total = reminders.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Time-Based Activity',
            style: AppTypography.heading3(context),
          ),
        ),
        Container(
          padding: AppSpacing.paddingAllM,
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: timePatterns.entries.map((entry) {
              final percentage = (entry.value / total * 100).toStringAsFixed(0);
              return _buildPatternRow(context, entry.key, percentage);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPatternRow(
    BuildContext context,
    String label,
    String percentage,
  ) {
    final percent = double.tryParse(percentage) ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.bodyMedium(context, AppColors.darkText),
              ),
              Text(
                '$percentage%',
                style: AppTypography.bodySmall(
                  context,
                  AppColors.primaryColor,
                  FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSpacing.gapS,
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 8,
              backgroundColor: AppColors.lightBackground,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyAnalysis(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final patterns = data['patterns'] as Map<String, dynamic>? ?? {};
    final avgPerDay = patterns['avgPerDay'] as double? ?? 0;
    final avgPerWeek = patterns['avgPerWeek'] as double? ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            'Avg / Day',
            avgPerDay.toStringAsFixed(1),
            Icons.today_rounded,
          ),
        ),
        AppSpacing.gapM,
        Expanded(
          child: _buildMetricCard(
            context,
            'Avg / Week',
            avgPerWeek.toStringAsFixed(1),
            Icons.calendar_view_week_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: AppSpacing.paddingAllM,
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryColor.withOpacity(0.6), size: 24),
          AppSpacing.gapS,
          Text(
            label,
            style: AppTypography.bodySmall(context, AppColors.secondaryText),
          ),
          AppSpacing.gapS,
          Text(
            value,
            style: AppTypography.heading1(context, AppColors.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendAnalysis(BuildContext context, Map<String, dynamic> data) {
    final patterns = data['patterns'] as Map<String, dynamic>? ?? {};
    final trend = patterns['trend'] as String? ?? 'stable';
    final isIncreasing = trend == 'increasing';

    return Container(
      padding: AppSpacing.paddingAllM,
      decoration: BoxDecoration(
        color: isIncreasing
            ? AppColors.successGreen.withOpacity(0.05)
            : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isIncreasing
              ? AppColors.successGreen.withOpacity(0.3)
              : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isIncreasing
                  ? AppColors.successGreen
                  : AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncreasing
                  ? Icons.trending_up_rounded
                  : Icons.trending_flat_rounded,
              color: isIncreasing ? Colors.white : AppColors.primaryColor,
            ),
          ),
          AppSpacing.gapM,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isIncreasing ? 'Activity Increasing' : 'Activity Stable',
                  style: AppTypography.heading3(context, AppColors.darkText),
                ),
                Text(
                  isIncreasing
                      ? 'Your reminder engagement is scaling up!'
                      : 'Your productivity levels remain consistent.',
                  style: AppTypography.bodySmall(
                    context,
                    AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStrengthColor(String strength) {
    switch (strength.toLowerCase()) {
      case 'very_high':
        return AppColors.successGreen;
      case 'high':
        return const Color(0xFF66BB6A);
      case 'medium':
        return Colors.orangeAccent;
      case 'low':
        return AppColors.error;
      default:
        return AppColors.tertiaryText;
    }
  }
}
