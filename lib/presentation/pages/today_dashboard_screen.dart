import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mynotes/core/routes/app_routes.dart';
import '../../domain/entities/note.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_state.dart';
import '../bloc/alarm_bloc.dart';
import '../bloc/alarm_state.dart';
import '../bloc/reflection_bloc.dart';
import '../bloc/reflection_state.dart';
import '../design_system/design_system.dart';
import '../screens/reflection_home_screen.dart';
import 'enhanced_reminders_list_screen.dart';
import 'focus_session_screen.dart';
import 'daily_highlight_summary_screen.dart';
import 'analytics_dashboard_screen.dart';
import 'settings_screen.dart';
import '../widgets/quick_add_bottom_sheet.dart';
import '../widgets/global_command_palette.dart';

/// Today Dashboard Screen
/// Main overview showing stats, daily reflection prompt, and upcoming items
/// Based on template: today_dashboard_home_1/2
class TodayDashboardScreen extends StatefulWidget {
  const TodayDashboardScreen({super.key});

  @override
  State<TodayDashboardScreen> createState() => _TodayDashboardScreenState();
}

class _TodayDashboardScreenState extends State<TodayDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyK):
            const _ShowCommandPaletteIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK):
            const _ShowCommandPaletteIntent(),
      },
      child: Actions(
        actions: {
          _ShowCommandPaletteIntent: CallbackAction<_ShowCommandPaletteIntent>(
            onInvoke: (_) {
              showGlobalCommandPalette(context);
              return null;
            },
          ),
        },
        child: Scaffold(
          backgroundColor: AppColors.background(context),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top App Bar / Greeting Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screenPaddingHorizontal,
                    AppSpacing.screenPaddingVertical * 2,
                    AppSpacing.screenPaddingHorizontal,
                    AppSpacing.lg,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Greeting
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting,
                              style: AppTypography.heading1(
                                context,
                                AppColors.textPrimary(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Here's your focus for today.",
                              style: AppTypography.bodyMedium(
                                context,
                                AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Profile Avatar + Command Palette Button
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => showGlobalCommandPalette(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.search,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert,
                              color: AppColors.primary,
                            ),
                            onSelected: (value) => _handleTodayMenu(value),
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem(
                                value: 'analytics',
                                child: Row(
                                  children: [
                                    Icon(Icons.analytics, size: 20),
                                    SizedBox(width: 12),
                                    Text('Analytics'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'reminders',
                                child: Row(
                                  children: [
                                    Icon(Icons.notifications, size: 20),
                                    SizedBox(width: 12),
                                    Text('Reminders'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'highlights',
                                child: Row(
                                  children: [
                                    Icon(Icons.star, size: 20),
                                    SizedBox(width: 12),
                                    Text('Daily Highlights'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'reflection',
                                child: Row(
                                  children: [
                                    Icon(Icons.psychology, size: 20),
                                    SizedBox(width: 12),
                                    Text('Daily Reflection'),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              const PopupMenuItem(
                                value: 'settings',
                                child: Row(
                                  children: [
                                    Icon(Icons.settings, size: 20),
                                    SizedBox(width: 12),
                                    Text('Settings'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          _buildProfileAvatar(context),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Stats Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPaddingHorizontal,
                  ).copyWith(bottom: AppSpacing.lg),
                  child: _buildStatsSection(context),
                ),
              ),

              // Quick Actions Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPaddingHorizontal,
                  ).copyWith(bottom: AppSpacing.lg),
                  child: _buildQuickActionsSection(context),
                ),
              ),

              // Daily Highlight Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPaddingHorizontal,
                  ).copyWith(bottom: AppSpacing.lg),
                  child: _buildDailyHighlight(context),
                ),
              ),

              // Daily Reflection Prompt
              BlocBuilder<ReflectionBloc, ReflectionState>(
                builder: (context, state) {
                  // Handle different reflection states appropriately
                  // For the dashboard, we always show the reflection prompt regardless of state
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPaddingHorizontal,
                      ).copyWith(bottom: AppSpacing.lg),
                      child: _buildDailyReflection(context, state),
                    ),
                  );
                },
              ),

              // Section: Your Day
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPaddingHorizontal,
                  ).copyWith(bottom: AppSpacing.md),
                  child: Text(
                    'Your Day',
                    style: AppTypography.heading2(
                      context,
                      AppColors.textPrimary(context),
                    ),
                  ),
                ),
              ),

              // Next Reminders Card
              BlocBuilder<AlarmBloc, AlarmState>(
                builder: (context, state) {
                  // Handle different alarm states appropriately
                  // For the dashboard, we show a simplified view regardless of state
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPaddingHorizontal,
                      ).copyWith(bottom: AppSpacing.md),
                      child: _buildRemindersCard(context, state),
                    ),
                  );
                },
              ),

              // Todos Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPaddingHorizontal,
                  ).copyWith(bottom: AppSpacing.lg),
                  child: _buildTodosCard(context),
                ),
              ),

              // Continue Writing (Recent Notes)
              BlocBuilder<NotesBloc, NoteState>(
                builder: (context, state) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPaddingHorizontal,
                      ).copyWith(bottom: AppSpacing.lg),
                      child: _buildContinueWriting(context, state),
                    ),
                  );
                },
              ),

              // Bottom Spacing
              SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildProfileAvatar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withOpacity(0.2),
        border: Border.all(
          color: isDark ? AppColors.surface(context) : Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.person,
        size: 24,
        color: isDark ? AppColors.surface(context) : Colors.white,
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Column(
      children: [
        // Progress Ring Card
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.borderDark.withOpacity(0.2)
                  : AppColors.borderLight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05,
                ),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Today\'s Progress',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Notes Ring
                  _buildProgressRing(
                    context,
                    title: 'Notes',
                    progress: 0.85,
                    color: AppColors.primary,
                    icon: Icons.note,
                  ),
                  // Todos Ring
                  _buildProgressRing(
                    context,
                    title: 'Todos',
                    progress: 0.67,
                    color: AppColors.accentGreen,
                    icon: Icons.check_circle,
                  ),
                  // Reflections Ring
                  _buildProgressRing(
                    context,
                    title: 'Reflections',
                    progress: 0.43,
                    color: AppColors.accentPurple,
                    icon: Icons.psychology,
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        // Stats Cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                label: 'REFLECTION STREAK',
                value: '7 Days',
                trend: '+2%',
                trendColor: AppColors.successGreen,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                context,
                label: 'TODOS DONE',
                value: '4/6',
                trend: '67% complete',
                trendColor: AppColors.successGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressRing(
    BuildContext context, {
    required String title,
    required double progress,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 80.sp,
          height: 80.sp,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background ring
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 4.sp,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  color.withOpacity(0.3),
                ),
              ),
              // Progress ring
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 4.sp,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              // Icon in center
              Icon(icon, color: color, size: 28.sp),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '${(progress * 100).toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            context,
            icon: Icons.add,
            label: 'Quick Note',
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const QuickAddBottomSheet(),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionButton(
            context,
            icon: Icons.timer,
            label: 'Focus',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FocusSessionScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionButton(
            context,
            icon: Icons.auto_awesome,
            label: 'Highlights',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DailyHighlightSummaryScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
          border: Border.all(
            color: isDark
                ? AppColors.borderDark.withOpacity(0.2)
                : AppColors.borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.captionLarge(
                context,
                AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required String trend,
    required Color trendColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall(
              context,
              AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.numberMedium(
              context,
              AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(trend, style: AppTypography.captionLarge(context, trendColor)),
        ],
      ),
    );
  }

  Widget _buildDailyReflection(BuildContext context, ReflectionState state) {
    final question =
        "What is one thing you want to achieve today that will make you feel proud?";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                ),
                child: Icon(
                  Icons.self_improvement,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Daily Reflection',
                style: AppTypography.heading3(
                  context,
                  AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question,
            style: AppTypography.bodyLarge(
              context,
              AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReflectionHomeScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                ),
                elevation: 0,
              ),
              child: Text(
                'Answer',
                style: AppTypography.buttonMedium(context, Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersCard(BuildContext context, AlarmState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final upcomingReminders = [];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(color: AppColors.border(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Next Reminders',
                  style: AppTypography.labelLarge(
                    context,
                    AppColors.textSecondary(context),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const EnhancedRemindersListScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'See all',
                    style: AppTypography.labelMedium(
                      context,
                      AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Reminders List
          if (upcomingReminders.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.border(context)),
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 32,
                      color: AppColors.textSecondary(context).withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No upcoming reminders',
                      style: AppTypography.bodyMedium(
                        context,
                        AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...upcomingReminders.map((reminder) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.border(context)),
                  ),
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLG,
                        ),
                      ),
                      child: Icon(
                        Icons.schedule,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Title & Time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reminder.title,
                            style: AppTypography.labelLarge(
                              context,
                              AppColors.textPrimary(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            DateFormat('h:mm a').format(reminder.dateTime),
                            style: AppTypography.captionLarge(
                              context,
                              AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Snooze button
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.notifications_paused,
                        size: 20.sp,
                        color: AppColors.textPrimary(context),
                      ),
                      padding: EdgeInsets.all(8.w),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildContinueWriting(BuildContext context, NoteState state) {
    final recentNotes = state is NotesLoaded
        ? state.notes.take(5).toList()
        : <Note>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'CONTINUE WRITING',
            style: AppTypography.labelSmall(
              context,
              AppColors.textSecondary(context),
            ),
          ),
        ),

        // Horizontal scrolling cards
        if (recentNotes.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 32,
                    color: AppColors.textSecondary(context).withOpacity(0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No notes yet',
                    style: AppTypography.bodyMedium(
                      context,
                      AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: recentNotes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final note = recentNotes[index];
                return _buildNoteCard(context, note);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildNoteCard(BuildContext context, Note note) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeDiff = DateTime.now().difference(note.createdAt);
    final timeAgo = timeDiff.inHours < 24
        ? '${timeDiff.inHours}h ago'
        : timeDiff.inDays == 1
        ? 'Yesterday'
        : DateFormat('MMM d').format(note.createdAt);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(color: AppColors.border(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and time
          Row(
            children: [
              Icon(Icons.description, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                timeAgo,
                style: AppTypography.captionSmall(context, AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            note.title.isEmpty ? 'Untitled' : note.title,
            style: AppTypography.labelLarge(
              context,
              AppColors.textPrimary(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Content preview
          Expanded(
            child: Text(
              note.content.isEmpty ? 'No content' : note.content,
              style: AppTypography.bodySmall(
                context,
                AppColors.textSecondary(context),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _handleTodayMenu(String value) {
    switch (value) {
      case 'analytics':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AnalyticsDashboardScreen()),
        );
        break;
      case 'reminders':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const EnhancedRemindersListScreen(),
          ),
        );
        break;
      case 'highlights':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const DailyHighlightSummaryScreen(),
          ),
        );
        break;
      case 'reflection':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReflectionHomeScreen()),
        );
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        break;
    }
  }

  Widget _buildTodosCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todos = [
      {'title': 'Draft project proposal', 'completed': false},
      {'title': 'Morning workout', 'completed': true},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(color: AppColors.border(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Todos",
                  style: AppTypography.labelLarge(
                    context,
                    AppColors.textSecondary(context),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to add todo
                  },
                  child: Text(
                    '+ Add',
                    style: AppTypography.labelMedium(
                      context,
                      AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Todo List
          ...todos.map((todo) {
            final isCompleted = todo['completed'] as bool;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.border(context)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppColors.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: isCompleted
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    todo['title'] as String,
                    style: isCompleted
                        ? AppTypography.bodyMedium(
                            context,
                            AppColors.textPrimary(context),
                          ).copyWith(
                            decoration: TextDecoration.lineThrough,
                            // opacity: 0.5,
                          )
                        : AppTypography.bodyMedium(
                            context,
                            AppColors.textPrimary(context),
                          ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDailyHighlight(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayHighlight =
        "Complete project proposal and send to stakeholders"; // This would come from storage
    final hasHighlight = todayHighlight.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.star_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Highlight",
                      style: AppTypography.labelLarge(
                        context,
                        AppColors.textPrimary(context),
                      ),
                    ),
                    Text(
                      "Your main focus for today",
                      style: AppTypography.captionLarge(
                        context,
                        AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.editDailyHighlight);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    hasHighlight ? Icons.edit_outlined : Icons.add,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (hasHighlight) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? AppColors.borderDark.withOpacity(0.3)
                      : AppColors.borderLight,
                ),
              ),
              child: Text(
                todayHighlight,
                style: AppTypography.bodyMedium(
                  context,
                  AppColors.textPrimary(context),
                ),
              ),
            ),
          ] else ...[
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.editDailyHighlight);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark.withOpacity(0.3)
                        : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add,
                      color: AppColors.textSecondary(context),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Set your daily highlight",
                      style: AppTypography.bodyMedium(
                        context,
                        AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Intent for keyboard shortcut
class _ShowCommandPaletteIntent extends Intent {
  const _ShowCommandPaletteIntent();
}
