import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/note.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_state.dart';
import '../bloc/alarm_bloc.dart';
import '../bloc/alarm_state.dart';
import '../bloc/reflection_bloc.dart';
import '../bloc/reflection_state.dart';
import '../design_system/design_system.dart';
import 'reflection_home_screen.dart';
import 'notes_list_screen.dart';
import 'reminders_screen.dart';

/// Today Dashboard Screen
/// Main overview showing stats, daily reflection prompt, and upcoming items
/// Based on template: today_dashboard_home_1/2
class TodayDashboardScreen extends StatefulWidget {
  const TodayDashboardScreen({Key? key}) : super(key: key);

  @override
  State<TodayDashboardScreen> createState() => _TodayDashboardScreenState();
}

class _TodayDashboardScreenState extends State<TodayDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return AppScaffold(
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
                            null,
                            FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Here's your focus for today.",
                          style: AppTypography.bodySmall(
                            AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Profile Avatar
                  _buildProfileAvatar(),
                ],
              ),
            ),
          ),

          // Stats Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingHorizontal,
                vertical: AppSpacing.lg,
              ),
              child: _buildStatsSection(),
            ),
          ),

          // Daily Reflection Prompt
          BlocBuilder<ReflectionBloc, ReflectionState>(
            builder: (context, state) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPaddingHorizontal,
                    vertical: AppSpacing.lg,
                  ),
                  child: _buildDailyReflection(state),
                ),
              );
            },
          ),

          // Section: Your Day
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.screenPaddingHorizontal,
                right: AppSpacing.screenPaddingHorizontal,
                top: AppSpacing.lg,
                bottom: AppSpacing.md,
              ),
              child: Text(
                'Your Day',
                style: AppTypography.heading2(
                  context,
                  null,
                  FontWeight.w700,
                ),
              ),
            ),
          ),

          // Next Reminders Card
          BlocBuilder<AlarmBloc, AlarmState>(
            builder: (context, state) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPaddingHorizontal,
                    vertical: AppSpacing.md,
                  ),
                  child: _buildRemindersCard(state),
                ),
              );
            },
          ),

          // Recent Notes Preview
          BlocBuilder<NotesBloc, NotesState>(
            builder: (context, state) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPaddingHorizontal,
                    vertical: AppSpacing.md,
                  ),
                  child: _buildRecentNotesCard(state),
                ),
              );
            },
          ),

          // Bottom Spacing
          SliverToBoxAdapter(
            child: SizedBox(height: 80.h),
          ),
        ],
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withOpacity(0.2),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.person,
        size: 24.sp,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildStatsSection() {
    // In a real implementation, fetch stats from BLoCs
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'Reflection Streak',
            value: '7 Days',
            trend: '+2%',
            trendColor: AppColors.successGreen,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: StatCard(
            label: 'Todos Done',
            value: '4/10',
            trend: '40%',
            trendColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyReflection(ReflectionState state) {
    // Fetch today's question from the state
    final question = "What is one thing you want to achieve today that will make you feel proud?";

    return PromptCard(
      icon: Icons.self_improvement,
      title: 'Daily Reflection',
      description: question,
      buttonText: 'Answer',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ReflectionHomeScreen(),
          ),
        );
      },
      accentColor: AppColors.primary,
    );
  }

  Widget _buildRemindersCard(AlarmState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get upcoming reminders (for demo, using placeholder)
    final upcomingReminders = state is AlarmLoaded
        ? state.alarms.where((a) => a.isEnabled).take(3).toList()
        : [];

    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Next Reminders',
                  style: AppTypography.bodySmall(
                    AppColors.textMuted,
                    FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RemindersScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'See all',
                    style: AppTypography.caption(
                      AppColors.primary,
                      FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Reminders List
          if (upcomingReminders.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Center(
                child: Text(
                  'No upcoming reminders',
                  style: AppTypography.bodySmall(
                    AppColors.textMuted,
                  ),
                ),
              ),
            )
          else
            ...upcomingReminders.map((reminder) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? AppColors.borderDark.withOpacity(0.2)
                          : AppColors.borderLight,
                    ),
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
                            style: AppTypography.bodyMedium(
                              context,
                              FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            DateFormat('h:mm a').format(reminder.dateTime),
                            style: AppTypography.caption(
                              AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildRecentNotesCard(NotesState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final recentNotes = state is NotesLoaded
        ? state.notes.take(3).toList()
        : <Note>[];

    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Notes',
                  style: AppTypography.bodySmall(
                    AppColors.textMuted,
                    FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotesListScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'See all',
                    style: AppTypography.caption(
                      AppColors.primary,
                      FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Notes List
          if (recentNotes.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Center(
                child: Text(
                  'No notes yet',
                  style: AppTypography.bodySmall(
                    AppColors.textMuted,
                  ),
                ),
              ),
            )
          else
            ...recentNotes.map((note) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? AppColors.borderDark.withOpacity(0.2)
                          : AppColors.borderLight,
                    ),
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
                        Icons.description,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Title & Preview
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title,
                            style: AppTypography.bodyMedium(
                              context,
                              FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (note.content.isNotEmpty) ...[
                            SizedBox(height: 2.h),
                            Text(
                              note.content,
                              style: AppTypography.caption(
                                AppColors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
