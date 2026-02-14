import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

/// Home Widgets Showcase Screen
/// Displays iOS-style widget previews for the app
/// Based on template: home_screen_widgets_ui
class HomeWidgetsScreen extends StatelessWidget {
  const HomeWidgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.background(context) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'MyNotes Widgets',
          style: AppTypography.bodyLarge(
            context,
            AppColors.textPrimary(context),
            FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Small Widget Section
            _buildWidgetSection(
              context,
              title: 'Small Widget (2x2)',
              subtitle: 'Next Reminder',
              child: _buildSmallWidget(context, isDark),
            ),
            SizedBox(height: 48.h),

            // Medium Widget Section
            _buildWidgetSection(
              context,
              title: 'Medium Widget (4x2)',
              subtitle: "Today's Tasks",
              child: _buildMediumWidget(context, isDark),
            ),
            SizedBox(height: 48.h),

            // Large Widget Section
            _buildWidgetSection(
              context,
              title: 'Large Widget (4x4)',
              subtitle: 'Daily Hub',
              child: _buildLargeWidget(context, isDark),
            ),
            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.bodyLarge(
                  context,
                  AppColors.textPrimary(context),
                  FontWeight.bold,
                ),
              ),
              Text(
                subtitle.toUpperCase(),
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        // Widget preview
        Center(child: child),
      ],
    );
  }

  Widget _buildSmallWidget(BuildContext context, bool isDark) {
    return Container(
      width: 169.w,
      height: 169.w,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2A30) : Colors.white,
        borderRadius: BorderRadius.circular(36.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'REMINDER',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                '10:30 AM',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Call Team about Project X',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary(context),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          // Snooze button
          Container(
            width: double.infinity,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.snooze, color: Colors.white, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  'Snooze',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediumWidget(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 340.w),
      height: 169.w,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2A30) : Colors.white,
        borderRadius: BorderRadius.circular(36.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Tasks",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '3 tasks remaining',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Icon(Icons.add, color: AppColors.primary, size: 20.sp),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Task items
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTaskItem(context, 'Review Budget Q3', false, isDark),
                _buildTaskItem(context, 'Email New Client', false, isDark),
                _buildTaskItem(context, 'Update Trello Board', true, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(
    BuildContext context,
    String title,
    bool isCompleted,
    bool isDark,
  ) {
    return Row(
      children: [
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.primary : Colors.transparent,
            border: Border.all(
              color: isCompleted
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.3),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: isCompleted
              ? Icon(Icons.check, color: Colors.white, size: 14.sp)
              : null,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: isCompleted
                  ? AppColors.textSecondary(context)
                  : AppColors.textPrimary(context),
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLargeWidget(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 340.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2A30) : Colors.white,
        borderRadius: BorderRadius.circular(36.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Next Tasks Section
          Text(
            'NEXT TASKS',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: AppColors.textSecondary(context),
            ),
          ),
          SizedBox(height: 12.h),
          _buildLargeTaskItem(
            context,
            'Review Project Proposal',
            'Due at 2:00 PM',
            isDark,
          ),
          SizedBox(height: 12.h),
          _buildLargeTaskItem(context, 'Call Mom', 'Due at 6:30 PM', isDark),
          SizedBox(height: 24.h),

          // Latest Reminder Section
          Text(
            'LATEST REMINDER',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: AppColors.textSecondary(context),
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.alarm, color: AppColors.primary, size: 24.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Refill Prescription',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        'In 45 minutes',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Quick Note Section
          Text(
            'QUICK NOTE',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: AppColors.textSecondary(context),
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.background(context).withOpacity(0.5)
                  : const Color(0xFFF6F7F8),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.sticky_note_2_outlined,
                  color: AppColors.textSecondary(context),
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Ask Mike about the API deadline...',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary(context),
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeTaskItem(
    BuildContext context,
    String title,
    String dueTime,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.background(context).withOpacity(0.5)
            : const Color(0xFFF6F7F8),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 2),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                Text(
                  dueTime,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
