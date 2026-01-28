import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../design_system/design_system.dart';

/// Empty State Notes Help Screen
/// Provides guidance when user has no notes created yet
class EmptyStateNotesHelpScreen extends StatelessWidget {
  const EmptyStateNotesHelpScreen({super.key});

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
        'Notes',
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
          // Main paper sheet
          Transform.rotate(
            angle: -2 * math.pi / 180,
            child: Container(
              width: 192.w,
              height: 256.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header line
                    Container(
                      width: 120.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Second line
                    Container(
                      width: 80.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    const Spacer(),
                    // Edit icon
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(
                        Icons.edit_note_outlined,
                        size: 32.sp,
                        color: AppColors.primary.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Background paper sheet
          Positioned(
            right: 50.w,
            bottom: 30.h,
            child: Transform.rotate(
              angle: 3 * math.pi / 180,
              child: Container(
                width: 176.w,
                height: 240.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
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
          'Your digital brain is empty.',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12.h),
        Text(
          'Start with a template to structure your thoughts or begin with a blank canvas.',
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
          'QUICK-START TEMPLATES',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          alignment: WrapAlignment.center,
          children: [
            _buildTemplateChip('Meeting Notes', Icons.calendar_today),
            _buildTemplateChip('Daily Journal', Icons.edit_square),
            _buildTemplateChip('Brainstorm', Icons.lightbulb_outline),
            _buildTemplateChip('To-do List', Icons.checklist),
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
        // Primary Create Note Button
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton.icon(
            onPressed: () {
              // Navigate to note editor
              Navigator.pushNamed(context, '/notes/editor');
            },
            icon: const Icon(Icons.add),
            label: const Text(
              'Create New Note',
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
        // Secondary Import Button
        TextButton(
          onPressed: () {
            // Handle import action
          },
          child: Text(
            'Import existing notes',
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
