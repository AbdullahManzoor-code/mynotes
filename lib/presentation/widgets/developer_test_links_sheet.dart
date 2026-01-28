import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/routes/app_routes.dart';
import '../design_system/design_system.dart';

/// Developer Test Links Sheet
/// Quick navigation to all 25+ screens for testing
/// Only visible in developer mode (Settings page)
class DeveloperTestLinksSheet extends StatelessWidget {
  const DeveloperTestLinksSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final testRoutes = [
      // ===== MAIN NAVIGATION (5) =====
      _TestRoute('🏠 Home / Today Dashboard', AppRoutes.todayDashboard),
      _TestRoute('📝 Notes List', AppRoutes.notesList),
      _TestRoute('✅ Todos List', AppRoutes.todosList),
      _TestRoute('⏰ Reminders', AppRoutes.remindersList),
      _TestRoute('⚙️ Settings', AppRoutes.settings),

      // ===== EDITORS (4) =====
      _TestRoute('✏️ Note Editor (New)', AppRoutes.noteEditor),
      _TestRoute('📄 Advanced Note Editor', AppRoutes.advancedNoteEditor),
      _TestRoute('🎯 Todo Focus Mode', AppRoutes.todoFocus),
      _TestRoute('📊 Advanced Todo View', AppRoutes.advancedTodo),

      // ===== FOCUS & PRODUCTIVITY (5) =====
      _TestRoute('⏱️ Focus Session', AppRoutes.focusSession),
      _TestRoute('🎉 Focus Celebration', AppRoutes.focusCelebration),
      _TestRoute('📈 Analytics Dashboard', AppRoutes.analytics),
      _TestRoute('⭐ Daily Highlights', AppRoutes.dailyHighlightSummary),
      _TestRoute('🔄 Recurring Todo Schedule', AppRoutes.recurringTodoSchedule),

      // ===== REFLECTION & INSIGHTS (2) =====
      _TestRoute('🧠 Reflection Home', AppRoutes.reflectionHome),
      _TestRoute('📝 Reflection Editor', AppRoutes.reflectionEditor),

      // ===== CALENDAR & ORGANIZATION (2) =====
      _TestRoute('📅 Calendar Integration', AppRoutes.calendarIntegration),
      _TestRoute('🔍 Global Search', AppRoutes.globalSearch),

      // ===== UTILITIES & TOOLS (4) =====
      _TestRoute('🎤 Command Palette (Cmd+K)', AppRoutes.commandPalette),
      _TestRoute('📸 Document Scan', AppRoutes.documentScan),
      _TestRoute('✨ OCR Extraction', AppRoutes.ocrExtraction),
      _TestRoute('🚀 Quick Add Universal', AppRoutes.universalQuickAdd),

      // ===== SETTINGS SUB-PAGES (5) =====
      _TestRoute('🎨 App Settings', AppRoutes.appSettings),
      _TestRoute('🎤 Voice Settings', AppRoutes.voiceSettings),
      _TestRoute('🔒 Security (Biometric Lock)', AppRoutes.biometricLock),
      _TestRoute('💾 Backup & Export', AppRoutes.backupExport),
      _TestRoute('📄 Daily Highlight Editor', AppRoutes.editDailyHighlight),

      // ===== HELP & ONBOARDING (3) =====
      _TestRoute('❓ Notes Help (Empty State)', AppRoutes.emptyStateNotesHelp),
      _TestRoute('❓ Todos Help (Empty State)', AppRoutes.emptyStateTodosHelp),
      _TestRoute(
        '🗺️ Location Reminder (Coming Soon)',
        AppRoutes.locationReminderComingSoon,
      ),
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXL),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🛠️ Developer Test Links',
                          style: AppTypography.heading3(
                            context,
                            AppColors.textPrimary(context),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Navigate to any screen instantly (${testRoutes.length} screens)',
                          style: AppTypography.captionSmall(context),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.background(context),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMD,
                          ),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 20.sp,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: AppColors.divider(context), height: 1),
          // List of routes
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              itemCount: testRoutes.length,
              itemBuilder: (context, index) {
                final route = testRoutes[index];
                return _buildTestLinkTile(context, route, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestLinkTile(BuildContext context, _TestRoute route, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, route.routePath);
          },
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.label,
                        style: AppTypography.bodyMedium(
                          context,
                          AppColors.textPrimary(context),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        route.routePath,
                        style: AppTypography.captionSmall(
                          context,
                        ).copyWith(color: AppColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Test Route Data Model
class _TestRoute {
  final String label;
  final String routePath;

  _TestRoute(this.label, this.routePath);
}
