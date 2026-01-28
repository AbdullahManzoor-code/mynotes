import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../design_system/design_system.dart';
import '../widgets/quick_add_bottom_sheet.dart';

/// Empty State for Todos/Tasks List
/// Educational guidance for voice and manual task creation
class EmptyStateTodos extends StatelessWidget {
  const EmptyStateTodos({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            _buildIllustration(isDark),

            SizedBox(height: 32.h),

            // Heading
            Text(
              'No tasks for today yet.',
              textAlign: TextAlign.center,
              style: AppTypography.titleLarge(
                null,
                null,
                FontWeight.bold,
              ).copyWith(fontSize: 24.sp),
            ),

            SizedBox(height: 24.h),

            // Pro Tip Card
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Text(
                    'PRO TIP',
                    style: AppTypography.captionSmall(null).copyWith(
                      color: AppColors.primary.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: AppTypography.bodySmall(null).copyWith(
                        fontStyle: FontStyle.italic,
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                      ),
                      children: [
                        const TextSpan(text: 'Try saying: '),
                        TextSpan(
                          text: '"Remind me to drink water at 4"',
                          style: AppTypography.bodySmall(
                            null,
                            AppColors.primary,
                            FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Action Buttons
            SizedBox(
              width: 280.w,
              child: Column(
                children: [
                  // Primary CTA - Voice Add
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () {
                        // Open voice input
                        QuickAddBottomSheet.show(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 8,
                        shadowColor: AppColors.primary.withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mic_rounded, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'Try Voice Add',
                            style: AppTypography.bodyLarge(
                              null,
                              Colors.white,
                              FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Secondary CTA - Manual Add
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: OutlinedButton(
                      onPressed: () {
                        QuickAddBottomSheet.show(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                        side: BorderSide(
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                        ),
                        backgroundColor: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Add Task Manually',
                        style: AppTypography.bodyMedium(
                          null,
                          null,
                          FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(bool isDark) {
    return Container(
      width: 192.w,
      height: 192.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withOpacity(0.1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dashed border
          Container(
            width: 220.w,
            height: 220.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            ),
          ),

          // Icon
          Icon(
            Icons.checklist_rounded,
            size: 72.sp,
            color: AppColors.primary,
            weight: 200,
          ),
        ],
      ),
    );
  }
}
