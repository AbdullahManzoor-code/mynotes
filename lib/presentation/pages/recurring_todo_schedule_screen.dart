import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

/// Recurring Todo Schedule Screen
/// Allows users to set up recurring schedules for todos
class RecurringTodoScheduleScreen extends StatefulWidget {
  const RecurringTodoScheduleScreen({super.key});

  @override
  State<RecurringTodoScheduleScreen> createState() =>
      _RecurringTodoScheduleScreenState();
}

class _RecurringTodoScheduleScreenState
    extends State<RecurringTodoScheduleScreen> {
  String _selectedFrequency = 'weekly';
  final Set<int> _selectedDays = {1, 3, 5}; // Mon, Wed, Fri (0=Mon, 6=Sun)

  final List<String> _weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final List<String> _weekdayNames = [
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
    return AppScaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(children: [_buildBackgroundPreview(), _buildBottomSheet()]),
    );
  }

  Widget _buildBackgroundPreview() {
    return Expanded(
      flex: 2,
      child: Container(
        padding: EdgeInsets.all(24.w),
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
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Icon(Icons.more_horiz),
                ],
              ),
              SizedBox(height: 32.h),
              _buildPreviewOption(Icons.calendar_today, 'Due Today'),
              SizedBox(height: 16.h),
              _buildPreviewOption(Icons.notifications_outlined, 'Reminder'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewOption(IconData icon, String placeholder) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade800.withOpacity(0.1)
            : Colors.grey.shade100.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade700.withOpacity(0.3)
              : Colors.grey.shade300.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24.sp),
          SizedBox(width: 12.w),
          Container(
            width: 100.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade700.withOpacity(0.3)
                  : Colors.grey.shade200.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Expanded(
      flex: 3,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40.r),
            topRight: Radius.circular(40.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildBottomSheetHeader(),
            _buildSectionHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFrequencyHeader(),
                    SizedBox(height: 16.h),
                    _buildFrequencyOptions(),
                    SizedBox(height: 24.h),
                    _buildSummary(context),
                    SizedBox(height: 32.h),
                  ],
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
        SizedBox(height: 12.h),
        Container(
          width: 40.w,
          height: 6.h,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.3),
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            'REPEAT',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          TextButton(
            onPressed: () {
              // Handle save
              Navigator.pop(context, {
                'frequency': _selectedFrequency,
                'days': _selectedDays.toList(),
              });
            },
            child: Text(
              'Done',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequency',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Choose how often this task repeats',
          style: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyOptions() {
    return Column(
      children: [
        _buildFrequencyOption('none', 'Does not repeat'),
        SizedBox(height: 8.h),
        _buildFrequencyOption('daily', 'Daily'),
        SizedBox(height: 8.h),
        _buildWeeklyOption(),
        SizedBox(height: 8.h),
        _buildFrequencyOption('monthly', 'Monthly'),
        SizedBox(height: 8.h),
        _buildCustomOption(),
      ],
    );
  }

  Widget _buildFrequencyOption(String value, String label) {
    final isSelected = _selectedFrequency == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFrequency = value;
        });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.5)
                : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade700
                      : Colors.grey.shade300),
          ),
          borderRadius: BorderRadius.circular(12.r),
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade700
                      : Colors.grey.shade300,
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
                          color: AppColors.primary,
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

  Widget _buildWeeklyOption() {
    final isSelected = _selectedFrequency == 'weekly';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected
              ? AppColors.primary.withOpacity(0.5)
              : Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade700
              : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12.r),
        color: isSelected
            ? AppColors.primary.withOpacity(0.05)
            : Colors.transparent,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedFrequency = 'weekly';
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Weekly',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
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
                          ? AppColors.primary
                          : (Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade600
                                : Colors.grey.shade400),
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
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
          if (isSelected) ...[
            SizedBox(height: 16.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REPEAT ON THESE DAYS',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildDayPicker(),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDayPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isSelected = _selectedDays.contains(index);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDays.remove(index);
              } else {
                _selectedDays.add(index);
              }
            });
          },
          child: Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Center(
              child: Text(
                _weekdayLabels[index],
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCustomOption() {
    return GestureDetector(
      onTap: () {
        // Handle custom option
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade700
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Custom...',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    if (_selectedFrequency != 'weekly' || _selectedDays.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedDayNames =
        _selectedDays.map((index) => _weekdayNames[index]).toList()..sort(
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

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade800.withOpacity(0.1)
            : Colors.grey.shade100.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              summaryText,
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(
                  context,
                ).textTheme.bodyLarge?.color?.withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
