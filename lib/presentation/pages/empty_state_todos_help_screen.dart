import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../widgets/lottie_animation_widget.dart';

/// Empty State Todos Help Screen
/// Provides guidance when user has no todos created yet
class EmptyStateTodosHelpScreen extends StatelessWidget {
  const EmptyStateTodosHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      safeAreaTop: false,
      appBar: _buildTopAppBar(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 32.h),
              _buildIllustration(context),
              SizedBox(height: 32.h),
              _buildEmptyStateContent(context),
              SizedBox(height: 40.h),
              _buildTemplateSection(context),
              SizedBox(height: 32.h),
              _buildActionButtons(context),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTopAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Tasks',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),
      backgroundColor: Theme.of(
        context,
      ).scaffoldBackgroundColor.withOpacity(0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 56,
      leading: Container(
        margin: EdgeInsets.only(left: 16.w),
        child: IconButton(
          onPressed: () {
            // Handle menu action
          },
          icon: const Icon(Icons.menu),
          iconSize: 24,
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 16.w),
          child: IconButton(
            onPressed: () {
              // Handle settings action
            },
            icon: const Icon(Icons.settings_outlined),
            iconSize: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildIllustration(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 280.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background glow
          Container(
            width: 240.w,
            height: 240.w,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
              ),
              borderRadius: BorderRadius.circular(120.w),
            ),
          ),
          // Lottie Animation
          SizedBox(
            width: 200.w,
            height: 200.h,
            child: LottieAnimationWidget(
              'loading',
              width: 200.w,
              height: 200.h,
              repeat: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateContent(BuildContext context) {
    return Column(
      children: [
        Text(
          'Ready to get things done?',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12.h),
        Text(
          'Create your first task or choose from our productivity templates to get started.',
          style: TextStyle(
            fontSize: 16.sp,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.7),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTemplateSection(BuildContext context) {
    return Column(
      children: [
        Text(
          'PRODUCTIVITY TEMPLATES',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.5),
          ),
        ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          alignment: WrapAlignment.center,
          children: [
            _buildTemplateChip('Daily Goals', Icons.today_outlined),
            _buildTemplateChip('Project Tasks', Icons.folder_outlined),
            _buildTemplateChip('Quick Capture', Icons.bolt_outlined),
            _buildTemplateChip('Weekly Plan', Icons.view_week_outlined),
          ],
        ),
      ],
    );
  }

  Widget _buildTemplateChip(String label, IconData icon) {
    return Builder(
      builder: (context) => Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20.sp, color: AppColors.primary),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Primary Create Task Button
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton.icon(
            onPressed: () {
              // Navigate to todo editor
              Navigator.pushNamed(context, '/todos/advanced');
            },
            icon: const Icon(Icons.add),
            label: const Text(
              'Create Your First Task',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 8,
              shadowColor: AppColors.primary.withOpacity(0.3),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        // Secondary Quick Add Button
        TextButton.icon(
          onPressed: () {
            // Handle quick add action
            Navigator.pushNamed(context, '/quick-add');
          },
          icon: const Icon(Icons.bolt_outlined),
          label: Text(
            'Quick Add Task',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
}

