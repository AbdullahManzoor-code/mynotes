import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/mood.dart';

/// Mood Selector Widget
/// Allows users to select their current mood
class MoodSelectorWidget extends StatelessWidget {
  final MoodType? selectedMood;
  final Function(MoodType) onMoodSelected;

  const MoodSelectorWidget({
    super.key,
    this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling?',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 16.h),

          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: MoodType.values.map((mood) {
              final isSelected = selectedMood == mood;
              return GestureDetector(
                onTap: () => onMoodSelected(mood),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryColor.withOpacity(0.2)
                        : (isDark
                              ? AppColors.darkBackground
                              : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(mood.emoji, style: TextStyle(fontSize: 20.sp)),
                      SizedBox(width: 6.w),
                      Text(
                        mood.displayName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
