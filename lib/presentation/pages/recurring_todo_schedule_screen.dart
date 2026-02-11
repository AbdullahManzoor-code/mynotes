import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../design_system/design_system.dart';
import '../bloc/recurrence_bloc.dart';

/// Recurring Todo Schedule Screen
/// Refactored to StatelessWidget using RecurrenceBloc and Design System
class RecurringTodoScheduleScreen extends StatelessWidget {
  const RecurringTodoScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecurrenceBloc(),
      child: const _RecurrenceView(),
    );
  }
}

class _RecurrenceView extends StatelessWidget {
  const _RecurrenceView();

  final List<String> _weekdayLabels = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final List<String> _weekdayNames = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Column(
        children: [
          _buildBackgroundPreview(context),
          _buildBottomSheet(context),
        ],
      ),
    );
  }

  Widget _buildBackgroundPreview(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Container(
        padding: AppSpacing.paddingAllL,
        child: Opacity(
          opacity: 0.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Morning Yoga',
                    style: AppTypography.displayMedium(context),
                  ),
                  const Icon(Icons.more_horiz),
                ],
              ),
              AppSpacing.gapXXXL,
              _buildPreviewOption(context, Icons.calendar_today, 'Due Today'),
              AppSpacing.gapL,
              _buildPreviewOption(
                context,
                Icons.notifications_outlined,
                'Reminder',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewOption(
    BuildContext context,
    IconData icon,
    String placeholder,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade800.withOpacity(0.1)
            : Colors.grey.shade100.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark
              ? Colors.grey.shade700.withOpacity(0.3)
              : Colors.grey.shade300.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 24.sp),
          AppSpacing.gapM,
          Container(
            width: 100.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey.shade700.withOpacity(0.3)
                  : Colors.grey.shade200.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40.r),
            topRight: Radius.circular(40.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildBottomSheetHeader(),
            _buildSectionHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: BlocBuilder<RecurrenceBloc, RecurrenceState>(
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFrequencyHeader(context),
                        AppSpacing.gapL,
                        _buildFrequencyOptions(context, state),
                        AppSpacing.gapXXXL,
                        _buildSummary(context, state),
                        AppSpacing.gapXXXL,
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetHeader() {
    return Column(
      children: [
        AppSpacing.gapM,
        Container(
          width: 40.w,
          height: 6.h,
          decoration: BoxDecoration(
            color: AppColors.borderLight,
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
        AppSpacing.gapS,
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.button(context, AppColors.primaryColor),
            ),
          ),
          Text(
            'REPEAT',
            style: AppTypography.labelSmall(
              context,
              AppColors.secondaryText,
              FontWeight.bold,
            ).copyWith(letterSpacing: 1.2),
          ),
          BlocBuilder<RecurrenceBloc, RecurrenceState>(
            builder: (context, state) {
              return TextButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'frequency': state.frequency,
                    'days': state.selectedDays.toList(),
                  });
                },
                child: Text(
                  'Done',
                  style: AppTypography.button(
                    context,
                    AppColors.primaryColor,
                    FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Frequency', style: AppTypography.displaySmall(context)),
        AppSpacing.gapXS,
        Text(
          'Choose how often this task repeats',
          style: AppTypography.bodySmall(context, AppColors.secondaryText),
        ),
      ],
    );
  }

  Widget _buildFrequencyOptions(BuildContext context, RecurrenceState state) {
    return Column(
      children: [
        _buildFrequencyOption(context, state, 'none', 'Does not repeat'),
        AppSpacing.gapM,
        _buildFrequencyOption(context, state, 'daily', 'Daily'),
        AppSpacing.gapM,
        _buildWeeklyOption(context, state),
        AppSpacing.gapM,
        _buildFrequencyOption(context, state, 'monthly', 'Monthly'),
        AppSpacing.gapM,
        _buildCustomOption(context),
      ],
    );
  }

  Widget _buildFrequencyOption(
    BuildContext context,
    RecurrenceState state,
    String value,
    String label,
  ) {
    final isSelected = state.frequency == value;

    return GestureDetector(
      onTap: () =>
          context.read<RecurrenceBloc>().add(UpdateFrequencyEvent(value)),
      child: Container(
        width: double.infinity,
        padding: AppSpacing.paddingAllM,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
          color: isSelected ? AppColors.primary10 : Colors.transparent,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium(context, null, FontWeight.w500),
              ),
            ),
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.borderLight,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyOption(BuildContext context, RecurrenceState state) {
    final isSelected = state.frequency == 'weekly';

    return Container(
      padding: AppSpacing.paddingAllM,
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppColors.primaryColor : AppColors.borderLight,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12.r),
        color: isSelected ? AppColors.primary10 : Colors.transparent,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => context.read<RecurrenceBloc>().add(
              const UpdateFrequencyEvent('weekly'),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Weekly',
                    style: AppTypography.bodyMedium(
                      context,
                      null,
                      FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  width: 20.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.borderLight,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
          if (isSelected) ...[
            AppSpacing.gapL,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REPEAT ON THESE DAYS',
                  style: AppTypography.labelSmall(
                    context,
                    AppColors.primaryColor,
                    FontWeight.bold,
                  ).copyWith(letterSpacing: 1.2),
                ),
                AppSpacing.gapM,
                _buildDayPicker(context, state),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDayPicker(BuildContext context, RecurrenceState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isSelected = state.selectedDays.contains(index);

        return GestureDetector(
          onTap: () =>
              context.read<RecurrenceBloc>().add(ToggleDayEvent(index)),
          child: Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.primaryColor : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryColor
                    : AppColors.borderLight,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Center(
              child: Text(
                _weekdayLabels[index],
                style: AppTypography.bodySmall(
                  context,
                  isSelected ? Colors.white : AppColors.secondaryText,
                  FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCustomOption(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle custom option
      },
      child: Container(
        width: double.infinity,
        padding: AppSpacing.paddingAllM,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Custom...',
                style: AppTypography.bodyMedium(context, null, FontWeight.w500),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.secondaryText,
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, RecurrenceState state) {
    if (state.frequency != 'weekly' || state.selectedDays.isEmpty) {
      if (state.frequency == 'daily') {
        return _renderSummaryCard(context, 'This task will repeat every day.');
      }
      if (state.frequency == 'monthly') {
        return _renderSummaryCard(
          context,
          'This task will repeat once a month.',
        );
      }
      return const SizedBox.shrink();
    }

    final selectedDayNames =
        state.selectedDays.map((index) => _weekdayNames[index]).toList()..sort(
          (a, b) =>
              _weekdayNames.indexOf(a).compareTo(_weekdayNames.indexOf(b)),
        );

    String summaryText;
    if (selectedDayNames.length == 1) {
      summaryText = 'This task will repeat every ${selectedDayNames.first}.';
    } else if (selectedDayNames.length == 2) {
      summaryText =
          'This task will repeat every ${selectedDayNames.join(' and ')}.';
    } else {
      final lastDay = selectedDayNames.removeLast();
      summaryText =
          'This task will repeat every ${selectedDayNames.join(', ')}, and $lastDay.';
    }

    return _renderSummaryCard(context, summaryText);
  }

  Widget _renderSummaryCard(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingAllM,
      decoration: BoxDecoration(
        color: AppColors.primary10,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.primaryColor,
            size: 20.sp,
          ),
          AppSpacing.gapM,
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall(
                context,
                AppColors.darkText,
              ).copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
