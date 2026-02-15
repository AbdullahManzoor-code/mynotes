import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/smart_reminders/smart_reminders_bloc.dart';
import 'package:mynotes/core/design_system/app_colors.dart';
import 'package:mynotes/core/design_system/app_typography.dart';
import 'package:mynotes/core/design_system/app_spacing.dart';
import '../../core/services/global_ui_service.dart';
import '../../injection_container.dart';
import '../../core/utils/app_logger.dart';

/// Suggestion Recommendations - Batch 6, Screen 1
/// Refactored to use Design System and Global UI Services
class SuggestionRecommendationsScreen extends StatelessWidget {
  const SuggestionRecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Smart Suggestions',
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
              AppLogger.i(
                'SuggestionRecommendationsScreen: Refreshing suggestions',
              );
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

          if (state is SmartRemindersError) {
            AppLogger.e(
              'SuggestionRecommendationsScreen: Error state: ${state.message}',
            );
            return Center(
              child: Padding(
                padding: AppSpacing.paddingAllL,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.error,
                      size: 48,
                    ),
                    AppSpacing.gapM,
                    Text(
                      state.message,
                      style: AppTypography.bodyMedium(context),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.gapL,
                    ElevatedButton(
                      onPressed: () {
                        AppLogger.i(
                          'SuggestionRecommendationsScreen: Retrying load',
                        );
                        context.read<SmartRemindersBloc>().add(
                          const LoadSuggestionsEvent(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is SmartRemindersLoaded) {
            final suggestions = state.params.suggestions;

            if (suggestions.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.separated(
              padding: AppSpacing.paddingAllM,
              itemCount: suggestions.length,
              separatorBuilder: (context, index) => AppSpacing.gapM,
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return _buildSuggestionCard(context, suggestion);
              },
            );
          }

          // Initial state should also load suggestions
          if (state is SmartRemindersInitial) {
            context.read<SmartRemindersBloc>().add(
              const LoadSuggestionsEvent(),
            );
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingAllL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                color: AppColors.primary10,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lightbulb_outline_rounded,
                size: 64,
                color: AppColors.primaryColor,
              ),
            ),
            AppSpacing.gapL,
            Text(
              'No recommendations yet',
              style: AppTypography.heading1(context),
            ),
            AppSpacing.gapS,
            Text(
              'Our AI assistant will analyze your habits to provide personalized reminders here.',
              style: AppTypography.bodyMedium(context, AppColors.secondaryText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(
    BuildContext context,
    Map<String, dynamic> suggestion,
  ) {
    final type = suggestion['type'] as String? ?? 'unknown';
    final confidence = suggestion['confidence'] as int? ?? 0;
    final color = _getTypeColor(type);

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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  type.toUpperCase(),
                  style: AppTypography.labelSmall(
                    context,
                    color,
                    FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    size: 18,
                    color: Colors.orangeAccent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$confidence%',
                    style: AppTypography.bodySmall(
                      context,
                      AppColors.darkText,
                      FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.gapM,
          Text(
            suggestion['description'] ?? '',
            style: AppTypography.heading2(context, AppColors.darkText),
          ),
          AppSpacing.gapS,
          Container(
            padding: AppSpacing.paddingAllS,
            decoration: BoxDecoration(
              color: AppColors.lightBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_fix_high_rounded, size: 18, color: color),
                AppSpacing.gapS,
                Expanded(
                  child: Text(
                    suggestion['recommendation'] ?? '',
                    style: AppTypography.bodySmall(
                      context,
                      AppColors.secondaryText,
                    ).copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapM,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    final sid = suggestion['id'];
                    AppLogger.i(
                      'SuggestionRecommendationsScreen: Dismissing suggestion $sid',
                    );
                    context.read<SmartRemindersBloc>().add(
                      RejectSuggestionEvent(suggestionId: sid),
                    );
                    getIt<GlobalUiService>().hapticFeedback();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.tertiaryText),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Dismiss',
                    style: AppTypography.button(
                      context,
                      AppColors.secondaryText,
                    ),
                  ),
                ),
              ),
              AppSpacing.gapM,
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final sid = suggestion['id'];
                    AppLogger.i(
                      'SuggestionRecommendationsScreen: Applying suggestion $sid',
                    );
                    context.read<SmartRemindersBloc>().add(
                      AcceptSuggestionEvent(suggestionId: sid),
                    );
                    getIt<GlobalUiService>().showSuccess('Suggestion accepted');
                    getIt<GlobalUiService>().hapticFeedback();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Apply',
                    style: AppTypography.button(context, Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'timing':
        return AppColors.primaryColor;
      case 'content':
        return AppColors.successGreen;
      case 'frequency':
        return Colors.orangeAccent;
      case 'media':
        return Colors.purpleAccent;
      case 'engagement':
        return Colors.pinkAccent;
      default:
        return AppColors.tertiaryText;
    }
  }
}
