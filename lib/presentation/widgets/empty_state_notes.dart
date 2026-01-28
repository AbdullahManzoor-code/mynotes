import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/presentation/pages/enhanced_note_editor_screen.dart';
import '../design_system/design_system.dart';

/// Empty State for Notes List
/// Helps users get started with templates and guidance
class EmptyStateNotes extends StatelessWidget {
  const EmptyStateNotes({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            _buildIllustration(isDark),

            SizedBox(height: 32.h),

            // Heading and subtitle
            Text(
              'Your digital brain is empty.',
              textAlign: TextAlign.center,
              style: AppTypography.titleLarge(
                null,
                null,
                FontWeight.bold,
              ).copyWith(fontSize: 24.sp),
            ),

            SizedBox(height: 12.h),

            Text(
              'Start with a template to structure your thoughts or begin with a blank canvas.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium(null).copyWith(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),

            SizedBox(height: 40.h),

            // Section header
            Text(
              'QUICK-START TEMPLATES',
              style: AppTypography.captionSmall(null).copyWith(
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 11.sp,
              ),
            ),

            SizedBox(height: 16.h),

            // Template chips
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              alignment: WrapAlignment.center,
              children: [
                _buildTemplateChip(
                  context,
                  'Meeting Notes',
                  Icons.calendar_today_outlined,
                  isDark,
                ),
                _buildTemplateChip(
                  context,
                  'Daily Journal',
                  Icons.edit_note_outlined,
                  isDark,
                ),
                _buildTemplateChip(
                  context,
                  'Brainstorm',
                  Icons.lightbulb_outline_rounded,
                  isDark,
                ),
                _buildTemplateChip(
                  context,
                  'To-do List',
                  Icons.checklist_outlined,
                  isDark,
                ),
              ],
            ),

            SizedBox(height: 32.h),

            // Primary CTA
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EnhancedNoteEditorScreen(),
                    ),
                  );
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
                    Icon(Icons.add_rounded, size: 24.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Create New Note',
                      style: AppTypography.bodyLarge(
                        null,
                        Colors.white,
                        FontWeight.bold,
                      ).copyWith(fontSize: 18.sp),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Secondary action
            TextButton(
              onPressed: () {},
              child: Text(
                'Import existing notes',
                style: AppTypography.bodySmall(null).copyWith(
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(bool isDark) {
    return SizedBox(
      width: 280.w,
      height: 280.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow effect
          Container(
            width: 280.w,
            height: 280.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.0),
                ],
              ),
            ),
          ),

          // Paper behind
          Transform.translate(
            offset: Offset(16.w, -8.h),
            child: Transform.rotate(
              angle: 0.05,
              child: Container(
                width: 176.w,
                height: 240.w,
                decoration: BoxDecoration(
                  color: (isDark ? Colors.grey.shade800 : Colors.white)
                      .withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color:
                        (isDark ? Colors.grey.shade700 : Colors.grey.shade200)
                            .withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),

          // Main paper
          Transform.rotate(
            angle: -0.035,
            child: Container(
              width: 192.w,
              height: 256.w,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 8.h,
                    width: 144.w,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 8.h,
                    width: 96.w,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(
                      Icons.edit_note_rounded,
                      size: 36.sp,
                      color: AppColors.primary.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateChip(
    BuildContext context,
    String label,
    IconData icon,
    bool isDark,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnhancedNoteEditorScreen(
              initialContent: _getTemplateContent(label),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          ),
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
              style: AppTypography.bodySmall(null, null, FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  String _getTemplateContent(String template) {
    switch (template) {
      case 'Meeting Notes':
        return '# Meeting Notes\n\n**Date:** \n**Attendees:** \n\n## Agenda\n- \n\n## Discussion\n\n## Action Items\n- [ ] \n';
      case 'Daily Journal':
        return '# Daily Journal - ${DateTime.now().toString().split(' ')[0]}\n\n## Morning\n\n## Afternoon\n\n## Evening\n\n## Gratitude\n- ';
      case 'Brainstorm':
        return '# Brainstorm Session\n\n## Main Topic\n\n## Ideas\n- \n\n## Next Steps\n';
      case 'To-do List':
        return '# To-do List\n\n- [ ] \n- [ ] \n- [ ] \n';
      default:
        return '';
    }
  }
}
