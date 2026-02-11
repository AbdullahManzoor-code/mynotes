import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/presentation/bloc/smart_reminders_bloc.dart';
import 'package:mynotes/presentation/bloc/params/smart_reminders_params.dart';

class SmartRemindersScreen extends StatelessWidget {
  const SmartRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          backgroundColor: AppColors.surface(context),
          elevation: 0,
          title: Text(
            'Smart Reminders',
            style: AppTypography.displayMedium(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showAIInfoDialog(context),
            ),
          ],
          bottom: TabBar(
            indicatorColor: AppColors.primaryColor,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.secondaryText,
            labelStyle: AppTypography.labelSmall(
              context,
              null,
              FontWeight.bold,
            ),
            tabs: const [
              Tab(text: 'Suggestions'),
              Tab(text: 'Patterns'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: BlocBuilder<SmartRemindersBloc, SmartRemindersState>(
          builder: (context, state) {
            if (state is SmartRemindersInitial ||
                state is SmartRemindersLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SmartRemindersLoaded) {
              return TabBarView(
                children: [
                  _buildSuggestionsTab(context, state),
                  _buildPatternsTab(context, state),
                  _buildSettingsTab(context, state),
                ],
              );
            }

            if (state is SmartRemindersError) {
              return Center(child: Text(state.message));
            }

            return const Center(child: Text('Initialize Smart Reminders'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.read<SmartRemindersBloc>().add(
              const LoadSuggestionsEvent(),
            );
          },
          backgroundColor: AppColors.primaryColor,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSuggestionsTab(
    BuildContext context,
    SmartRemindersLoaded state,
  ) {
    final suggestions = state.params.suggestions;

    if (suggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 64.sp,
              color: AppColors.primaryColor.withOpacity(0.3),
            ),
            AppSpacing.gapL,
            Text(
              'No smart suggestions yet',
              style: AppTypography.heading3(context),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Text(
                'AI will suggest reminders based on your note content and behavior.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall(
                  context,
                  AppColors.secondaryText,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: AppSpacing.paddingAllM,
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return _buildSuggestionCard(context, suggestion);
      },
    );
  }

  Widget _buildSuggestionCard(
    BuildContext context,
    Map<String, dynamic> suggestion,
  ) {
    final confidence = suggestion['confidence'] as int? ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: AppSpacing.paddingAllM,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '$confidence% Match',
                  style: AppTypography.labelSmall(
                    context,
                    AppColors.primaryColor,
                    FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  context.read<SmartRemindersBloc>().add(
                    RejectSuggestionEvent(
                      suggestionId: suggestion['id'] as String,
                    ),
                  );
                },
              ),
            ],
          ),
          AppSpacing.gapS,
          Text(
            suggestion['title'] as String,
            style: AppTypography.heading3(context),
          ),
          SizedBox(height: 4.h),
          Text(
            suggestion['description'] as String,
            style: AppTypography.bodySmall(context, AppColors.secondaryText),
          ),
          AppSpacing.gapM,
          Row(
            children: [
              const Icon(Icons.event, size: 16, color: AppColors.secondaryText),
              SizedBox(width: 4.w),
              Text(
                suggestion['suggestedTime'] as String,
                style: AppTypography.labelSmall(
                  context,
                  AppColors.secondaryText,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  context.read<SmartRemindersBloc>().add(
                    AcceptSuggestionEvent(
                      suggestionId: suggestion['id'] as String,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: const Text('Add Reminder'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatternsTab(BuildContext context, SmartRemindersLoaded state) {
    final patterns = state.params.patterns;

    if (patterns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up,
              size: 64.sp,
              color: AppColors.primaryColor.withOpacity(0.3),
            ),
            AppSpacing.gapL,
            Text(
              'Learning your habits',
              style: AppTypography.heading3(context),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Text(
                'Patterns will appear here as the AI learns how you manage your reminders.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall(
                  context,
                  AppColors.secondaryText,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: AppSpacing.paddingAllM,
      itemCount: patterns.length,
      itemBuilder: (context, index) {
        final pattern = patterns[index];
        return _buildPatternCard(context, pattern);
      },
    );
  }

  Widget _buildPatternCard(BuildContext context, Map<String, dynamic> pattern) {
    final completionRate = pattern['completionRate'] as double? ?? 0.0;
    final color = completionRate > 0.8
        ? Colors.green
        : (completionRate > 0.5 ? Colors.orange : Colors.red);
    final icon = pattern['type'] == 'time'
        ? Icons.access_time
        : Icons.calendar_today;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: AppSpacing.paddingAllM,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderLight, width: 0.5.w),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: color, size: 24.sp),
              ),
              AppSpacing.gapM,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pattern['title'] as String,
                      style: AppTypography.heading3(context),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${pattern['time']} • ${pattern['frequency']}',
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
          AppSpacing.gapM,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Completion Rate',
                style: AppTypography.labelSmall(
                  context,
                  AppColors.secondaryText,
                ),
              ),
              Text(
                '${(completionRate * 100).toStringAsFixed(0)}%',
                style: AppTypography.labelSmall(
                  context,
                  color,
                  FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: completionRate,
              backgroundColor: AppColors.lightBackground,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(BuildContext context, SmartRemindersLoaded state) {
    final settings = state.params.learningSettings;

    return SingleChildScrollView(
      padding: AppSpacing.paddingAllM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI Settings', style: AppTypography.heading2(context)),
          AppSpacing.gapM,
          _buildSettingsTile(
            context,
            'Enable Pattern Learning',
            'AI learns from your reminder completion behavior',
            settings['time_based_patterns'] ?? true,
            (value) => context.read<SmartRemindersBloc>().add(
              ToggleLearningEvent(
                settingKey: 'time_based_patterns',
                isEnabled: value,
              ),
            ),
          ),
          _buildSettingsTile(
            context,
            'Smart Time Suggestions',
            'Suggest optimal times for reminders',
            settings['note_content_analysis'] ?? true,
            (value) => context.read<SmartRemindersBloc>().add(
              ToggleLearningEvent(
                settingKey: 'note_content_analysis',
                isEnabled: value,
              ),
            ),
          ),
          _buildSettingsTile(
            context,
            'Snooze Analysis',
            'Learn your preferred snooze patterns',
            settings['urgency_detection'] ?? true,
            (value) => context.read<SmartRemindersBloc>().add(
              ToggleLearningEvent(
                settingKey: 'urgency_detection',
                isEnabled: value,
              ),
            ),
          ),
          _buildSettingsTile(
            context,
            'Frequency Detection',
            'Automatically detect reminder frequency',
            settings['location_context'] ?? true,
            (value) => context.read<SmartRemindersBloc>().add(
              ToggleLearningEvent(
                settingKey: 'location_context',
                isEnabled: value,
              ),
            ),
          ),
          AppSpacing.gapL,
          Container(
            padding: AppSpacing.paddingAllM,
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.borderLight, width: 0.5.w),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primaryColor),
                AppSpacing.gapM,
                Expanded(
                  child: Text(
                    'AI processing happens strictly on-device to ensure your data remains private.',
                    style: AppTypography.bodySmall(
                      context,
                      AppColors.secondaryText,
                    ),
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
    BuildContext context,
    String title,
    String subtitle,
    bool initialValue,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: AppSpacing.paddingAllM,
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderLight, width: 0.5.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium(
                    context,
                    AppColors.darkText,
                    FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall(
                    context,
                    AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: initialValue,
            onChanged: onChanged,
            activeColor: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  void _showAIInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        title: Text(
          'About Smart Reminders',
          style: AppTypography.heading2(context),
        ),
        content: Text(
          'Our AI engine analyzes your reminder patterns, completion times, and snoozes to suggest the optimal time for your reminders. This helps reduce cognitive load and ensures you see reminders when you are most likely to act on them.',
          style: AppTypography.bodyMedium(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }
}
