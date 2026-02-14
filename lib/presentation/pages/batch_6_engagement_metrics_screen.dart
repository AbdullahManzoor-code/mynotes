import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/smart_reminders/smart_reminders_bloc.dart';
import 'package:mynotes/domain/services/ai_suggestion_engine.dart';
import 'package:mynotes/core/design_system/app_colors.dart';
import 'package:mynotes/core/design_system/app_typography.dart';
import 'package:mynotes/core/design_system/app_spacing.dart';
import '../../injection_container.dart';
import '../../core/services/global_ui_service.dart';

/// Engagement Metrics - Batch 6, Screen 4
/// Refactored to use Design System and Stateless BLoC pattern
class EngagementMetricsScreen extends StatelessWidget {
  const EngagementMetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Engagement Metrics',
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
                'Load reminders to see your metrics',
                style: AppTypography.bodyMedium(
                  context,
                  AppColors.secondaryText,
                ),
              ),
            );
          }

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
                  // Overall Engagement
                  _buildOverallEngagement(context, data),
                  AppSpacing.gapL,

                  // Score Breakdown
                  _buildScoreBreakdown(context, data),
                  AppSpacing.gapL,

                  // Activity Overview
                  _buildActivityMetrics(context, reminders),
                  AppSpacing.gapL,

                  // Improvement Suggestions
                  _buildRecommendations(context, data),
                  AppSpacing.gapXXL,
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOverallEngagement(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final score = data['score'] as int? ?? 0;
    final strength = data['strength'] as String? ?? 'low';
    final color = _getEngagementColor(score);

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
        children: [
          Text(
            'Your Productivity Score',
            style: AppTypography.heading2(context),
          ),
          AppSpacing.gapL,
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 14,
                  backgroundColor: AppColors.lightBackground,
                  valueColor: AlwaysStoppedAnimation(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score%',
                    style: AppTypography.displayLarge(
                      context,
                      AppColors.darkText,
                    ),
                  ),
                  Text(
                    strength.toUpperCase().replaceAll('_', ' '),
                    style: AppTypography.labelSmall(
                      context,
                      color,
                      FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.gapL,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _getEngagementMessage(score),
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall(context, color, FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBreakdown(BuildContext context, Map<String, dynamic> data) {
    final patterns = data['patterns'] as Map<String, dynamic>? ?? {};
    final completionRate = patterns['completionRate'] as double? ?? 0;
    final responseTime = patterns['responseTime'] as double? ?? 0;
    final consistency = patterns['consistency'] as double? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Factor Analysis',
            style: AppTypography.heading3(context),
          ),
        ),
        _buildScoreItem(
          context,
          'Completion Rate',
          completionRate,
          Icons.verified_rounded,
        ),
        AppSpacing.gapM,
        _buildScoreItem(
          context,
          'Response Speed',
          responseTime,
          Icons.bolt_rounded,
        ),
        AppSpacing.gapM,
        _buildScoreItem(
          context,
          'Habit Consistency',
          consistency,
          Icons.calendar_today_rounded,
        ),
      ],
    );
  }

  Widget _buildScoreItem(
    BuildContext context,
    String label,
    double percentage,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primaryColor, size: 20),
              ),
              AppSpacing.gapM,
              Expanded(
                child: Text(label, style: AppTypography.bodyMedium(context)),
              ),
              Text(
                '${(percentage * 100).toStringAsFixed(0)}%',
                style: AppTypography.bodyMedium(
                  context,
                  AppColors.darkText,
                  FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSpacing.gapM,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: AppColors.lightBackground,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityMetrics(BuildContext context, List<dynamic> reminders) {
    final totalReminders = reminders.length;
    // In a production app, these would come from the database/state
    final completedCount = totalReminders;
    final missedCount = 0;

    return Row(
      children: [
        Expanded(
          child: _buildMetricMiniCard(
            context,
            'Done',
            completedCount.toString(),
            AppColors.successGreen,
            Icons.done_all_rounded,
          ),
        ),
        AppSpacing.gapM,
        Expanded(
          child: _buildMetricMiniCard(
            context,
            'Skipped',
            missedCount.toString(),
            AppColors.error,
            Icons.close_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricMiniCard(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: AppSpacing.paddingAllM,
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          AppSpacing.gapM,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall(
                  context,
                  color.withOpacity(0.7),
                ),
              ),
              Text(value, style: AppTypography.heading2(context, color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final score = data['score'] as int? ?? 0;
    final recommendations = _getRecommendations(score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text('AI Insights', style: AppTypography.heading3(context)),
        ),
        ...recommendations.map(
          (rec) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: AppSpacing.paddingAllM,
              decoration: BoxDecoration(
                color: AppColors.primary10.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                  AppSpacing.gapM,
                  Expanded(
                    child: Text(
                      rec,
                      style: AppTypography.bodySmall(
                        context,
                        AppColors.darkText,
                      ).copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<String> _getRecommendations(int score) {
    if (score < 40) {
      return [
        'Sync reminders with your peak activity hours.',
        'Start with 3 essential daily habits.',
        'Weekly reviews will help you stay on track.',
      ];
    } else if (score < 70) {
      return [
        'Try diversifying your reminder types.',
        'Set up habit loops for consistent actions.',
        'Collaborate on shared reminders for accountability.',
      ];
    } else {
      return [
        'Maintain your current streak - you\'re optimized!',
        'Consider sharing your workflows with the community.',
        'Explore experimental AI-driven pattern matching.',
      ];
    }
  }

  Color _getEngagementColor(int score) {
    if (score >= 80) return AppColors.successGreen;
    if (score >= 60) return AppColors.primaryColor;
    if (score >= 40) return Colors.orangeAccent;
    return AppColors.error;
  }

  String _getEngagementMessage(int score) {
    if (score >= 80) {
      return 'Peak productivity! You are mastering your schedule.';
    }
    if (score >= 60) return 'Solid consistency. You are on the right path.';
    if (score >= 40) {
      return 'Moderate engagement. Small habit tweaks will help.';
    }
    return 'Low activity. We recommend setting simpler goals.';
  }
}

