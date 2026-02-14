import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/core/routes/app_routes.dart';
import 'package:mynotes/domain/entities/alarm.dart';
import 'package:mynotes/presentation/bloc/params/alarm_params.dart';
import 'package:mynotes/presentation/bloc/alarm/alarms_bloc.dart';
import 'package:mynotes/presentation/bloc/alarm/alarm_event.dart';
import 'package:mynotes/presentation/bloc/alarm/alarm_state.dart';
import 'package:mynotes/presentation/widgets/add_reminder_bottom_sheet.dart';

/// Enhanced Smart Reminders List Screen
/// Advanced reminders management with smart snooze and context awareness
/// Based on reminders_list_with_smart_snooze template
class EnhancedRemindersListScreen extends StatelessWidget {
  const EnhancedRemindersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initial data load and timer start
    _initScreen(context);

    return BlocBuilder<AlarmsBloc, AlarmsState>(
      builder: (context, state) {
        List<AlarmParams> alarms = [];
        bool showFab = false;

        if (state is AlarmLoaded) {
          alarms = state.alarms;
          showFab = state.showFab;
        }

        // Categorize alarms locally for display sections
        final now = DateTime.now();
        final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

        final overdueReminders = alarms
            .where(
              (alarm) =>
                  alarm.isOverdue && alarm.status != AlarmStatus.completed,
            )
            .toList();

        final todayReminders = alarms
            .where(
              (alarm) =>
                  !alarm.isOverdue &&
                  alarm.scheduledTime.isBefore(todayEnd) &&
                  alarm.status != AlarmStatus.completed,
            )
            .toList();

        final upcomingReminders = alarms
            .where(
              (alarm) =>
                  alarm.scheduledTime.isAfter(todayEnd) &&
                  alarm.status != AlarmStatus.completed,
            )
            .toList();

        return Scaffold(
          backgroundColor: AppColors.background(context),
          body: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              final shouldShow = notification.metrics.pixels > 100;
              if (state is AlarmLoaded && state.showFab != shouldShow) {
                context.read<AlarmsBloc>().add(
                  UpdateAlarmUiConfigEvent(showFab: shouldShow),
                );
              }
              return false;
            },
            child: Column(
              children: [
                _buildHeader(
                  context,
                  overdueReminders.length,
                  todayReminders.length,
                  upcomingReminders.length,
                ),
                Expanded(
                  child: _buildRemindersList(
                    context,
                    overdueReminders,
                    todayReminders,
                    upcomingReminders,
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: AnimatedScale(
            scale: showFab ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: _buildFloatingActionButton(context),
          ),
        );
      },
    );
  }

  void _initScreen(BuildContext context) {
    // We use a small delay or postFrameCallback to avoid dispatching events during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlarmsBloc>().add(const LoadAlarmsEvent());
      context.read<AlarmsBloc>().add(const StartPeriodicRefreshEvent());
    });
  }

  void _completeReminder(BuildContext context, AlarmParams alarm) {
    HapticFeedback.lightImpact();

    if (alarm.alarmId != null) {
      context.read<AlarmsBloc>().add(
        CompleteAlarmEvent(alarmId: alarm.alarmId!),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reminder completed',
          style: AppTypography.bodySmall(context, Colors.white),
        ),
        backgroundColor: AppColors.primary,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            context.read<AlarmsBloc>().add(
              UpdateAlarmEvent(
                alarm.copyWith(status: AlarmStatus.scheduled, isEnabled: true),
              ),
            );
          },
        ),
      ),
    );
  }

  void _snoozeReminder(BuildContext context, AlarmParams alarm) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildEnhancedSnoozeBottomSheet(context, alarm),
    );
  }

  void _applySnooze(
    BuildContext context,
    AlarmParams alarm,
    Duration snoozeDuration,
    String snoozeLabel,
  ) {
    HapticFeedback.lightImpact();

    final newTime = DateTime.now().add(snoozeDuration);
    if (alarm.alarmId != null) {
      context.read<AlarmsBloc>().add(
        RescheduleAlarmEvent(alarmId: alarm.alarmId!, newTime: newTime),
      );
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reminder snoozed $snoozeLabel',
          style: AppTypography.bodySmall(context, Colors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    int overdue,
    int today,
    int upcoming,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary(context),
                        size: 24.sp,
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.integratedFeatures,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: AppColors.primary,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'AI Insights',
                                  style: AppTypography.labelSmall(context)
                                      .copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        GestureDetector(
                          onTap: () {},
                          child: Icon(
                            Icons.more_vert,
                            color: AppColors.textPrimary(context),
                            size: 24.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Text(
                  'Smart Reminders',
                  style: AppTypography.heading2().copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                _buildQuickStats(context, overdue, today, upcoming),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    int overdue,
    int today,
    int upcoming,
  ) {
    return Row(
      children: [
        if (overdue > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Text(
              '$overdue overdue',
              style: AppTypography.captionSmall(context).copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.red.shade300,
              ),
            ),
          ),
        if (overdue > 0 && today > 0) SizedBox(width: 8.w),
        if (today > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Text(
              '$today today',
              style: AppTypography.captionSmall(
                context,
              ).copyWith(fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ),
        if ((overdue > 0 || today > 0) && upcoming > 0) SizedBox(width: 8.w),
        if (upcoming > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.textSecondary(context).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.textSecondary(context).withOpacity(0.3),
              ),
            ),
            child: Text(
              '$upcoming upcoming',
              style: AppTypography.captionSmall(context).copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRemindersList(
    BuildContext context,
    List<AlarmParams> overdue,
    List<AlarmParams> today,
    List<AlarmParams> upcoming,
  ) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero),
      duration: const Duration(milliseconds: 500),
      builder: (context, offset, child) {
        return Transform.translate(offset: offset * 500, child: child);
      },
      child: CustomScrollView(
        slivers: [
          if (overdue.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildSection(
                context,
                'Overdue',
                overdue,
                AppColors.errorColor,
              ),
            ),
          if (today.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildSection(context, 'Today', today, AppColors.primary),
            ),
          if (upcoming.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildSection(
                context,
                'Upcoming',
                upcoming,
                AppColors.textSecondary(context),
              ),
            ),
          if (overdue.isEmpty && today.isEmpty && upcoming.isEmpty)
            const SliverFillRemaining(child: _EmptyRemindersState()),
          SliverToBoxAdapter(child: SizedBox(height: 100.h)),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<AlarmParams> alarms,
    Color accentColor,
  ) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTypography.label(context).copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: accentColor,
            ),
          ),
          SizedBox(height: 12.h),
          ...alarms.map(
            (alarm) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _ReminderCard(
                alarm: alarm,
                accentColor: accentColor,
                onComplete: () => _completeReminder(context, alarm),
                onSnooze: () => _snoozeReminder(context, alarm),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const AddReminderBottomSheet(),
        );
      },
      backgroundColor: AppColors.primary,
      child: Icon(Icons.add, color: Colors.white, size: 24.sp),
    );
  }

  Widget _buildEnhancedSnoozeBottomSheet(
    BuildContext context,
    AlarmParams alarm,
  ) {
    final snoozeOptions = [
      {
        'label': '5 minutes',
        'duration': const Duration(minutes: 5),
        'icon': Icons.schedule,
      },
      {
        'label': '15 minutes',
        'duration': const Duration(minutes: 15),
        'icon': Icons.access_time,
      },
      {
        'label': '30 minutes',
        'duration': const Duration(minutes: 30),
        'icon': Icons.timer,
      },
      {
        'label': '1 hour',
        'duration': const Duration(hours: 1),
        'icon': Icons.hourglass_empty,
      },
      {
        'label': 'This evening (6 PM)',
        'duration': _getEveningDuration(),
        'icon': Icons.wb_twilight,
      },
      {
        'label': 'Tomorrow morning (9 AM)',
        'duration': _getTomorrowMorningDuration(),
        'icon': Icons.wb_sunny,
      },
      {
        'label': 'Next weekend',
        'duration': _getNextWeekendDuration(),
        'icon': Icons.weekend,
      },
      {
        'label': 'Next week',
        'duration': const Duration(days: 7),
        'icon': Icons.date_range,
      },
    ];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.textTertiary(context),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.divider(context)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart Snooze',
                        style: AppTypography.heading3().copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        alarm.message,
                        style: AppTypography.body2(
                          context,
                        ).copyWith(color: AppColors.textSecondary(context)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.close,
                      color: AppColors.textSecondary(context),
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: snoozeOptions.length + 1,
              itemBuilder: (context, index) {
                if (index == snoozeOptions.length) {
                  return _buildCustomSnoozeOption(context, alarm);
                }
                final option = snoozeOptions[index];
                return _EnhancedSnoozeOptionWidget(
                  title: option['label'] as String,
                  duration: option['duration'] as Duration?,
                  icon: option['icon'] as IconData,
                  onTap: (dur) => _applySnooze(
                    context,
                    alarm,
                    dur,
                    option['label'] as String,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 16.h),
        ],
      ),
    );
  }

  Widget _buildCustomSnoozeOption(BuildContext context, AlarmParams alarm) {
    return GestureDetector(
      onTap: () => _showCustomSnoozeDialog(context, alarm),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.textSecondary(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.edit_calendar,
                color: AppColors.textSecondary(context),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                'Custom time...',
                style: AppTypography.body1(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textTertiary(context),
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Duration _getEveningDuration() {
    final now = DateTime.now();
    final thisEvening = DateTime(now.year, now.month, now.day, 18, 0);
    return thisEvening.isAfter(now)
        ? thisEvening.difference(now)
        : thisEvening.add(const Duration(days: 1)).difference(now);
  }

  Duration _getTomorrowMorningDuration() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1, 9, 0).difference(now);
  }

  Duration _getNextWeekendDuration() {
    final now = DateTime.now();
    final daysUntilSaturday = (6 - now.weekday) % 7;
    final nextSaturday = DateTime(
      now.year,
      now.month,
      now.day + daysUntilSaturday,
      10,
      0,
    );
    return nextSaturday.isBefore(now)
        ? nextSaturday.add(const Duration(days: 7)).difference(now)
        : nextSaturday.difference(now);
  }

  Future<void> _showCustomSnoozeDialog(
    BuildContext context,
    AlarmParams alarm,
  ) async {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Custom Snooze',
          style: AppTypography.heading3().copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
        content: Text(
          'Custom time picker coming soon!',
          style: AppTypography.body1(
            context,
          ).copyWith(color: AppColors.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTypography.body2(
                context,
              ).copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final AlarmParams alarm;
  final Color accentColor;
  final VoidCallback onComplete;
  final VoidCallback onSnooze;

  const _ReminderCard({
    required this.alarm,
    required this.accentColor,
    required this.onComplete,
    required this.onSnooze,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = alarm.status == AlarmStatus.completed;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isCompleted ? 0.5 : 1.0,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isCompleted
                ? AppColors.border(context)
                : accentColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: alarm.isOverdue
                        ? AppColors.errorColor
                        : (alarm.isDueSoon
                              ? AppColors.warning
                              : AppColors.success),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    alarm.message,
                    style: AppTypography.body1(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? AppColors.textSecondary(context)
                          : AppColors.textPrimary(context),
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onComplete,
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isCompleted
                            ? AppColors.primary
                            : AppColors.textSecondary(context),
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                        : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14.sp,
                  color: AppColors.textSecondary(context),
                ),
                SizedBox(width: 4.w),
                Text(
                  alarm.timeRemaining,
                  style: AppTypography.body2(
                    context,
                  ).copyWith(color: AppColors.textSecondary(context)),
                ),
                if (alarm.linkedNoteId != null) ...[
                  SizedBox(width: 12.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.link,
                      size: 12.sp,
                      color: AppColors.textTertiary(context),
                    ),
                  ),
                ],
                const Spacer(),
                if (!isCompleted)
                  GestureDetector(
                    onTap: onSnooze,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary(
                          context,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'Snooze',
                        style: AppTypography.bodySmall(context).copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRemindersState extends StatelessWidget {
  const _EmptyRemindersState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80.sp,
            color: AppColors.textSecondary(context),
          ),
          SizedBox(height: 16.h),
          Text(
            'No reminders',
            style: AppTypography.heading3().copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Create your first reminder to get started',
            style: AppTypography.body1(
              context,
            ).copyWith(color: AppColors.textSecondary(context)),
          ),
        ],
      ),
    );
  }
}

class _EnhancedSnoozeOptionWidget extends StatelessWidget {
  final String title;
  final Duration? duration;
  final IconData icon;
  final Function(Duration) onTap;

  const _EnhancedSnoozeOptionWidget({
    required this.title,
    required this.duration,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRecommended =
        title.contains('15 minutes') || title.contains('1 hour');

    return GestureDetector(
      onTap: () {
        if (duration != null) onTap(duration!);
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isRecommended
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.card(context),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isRecommended
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.border(context),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isRecommended
                    ? AppColors.primary.withOpacity(0.2)
                    : AppColors.textSecondary(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: isRecommended
                    ? AppColors.primary
                    : AppColors.textSecondary(context),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTypography.body1(context).copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      if (isRecommended) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'SMART',
                            style: AppTypography.captionSmall(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (duration != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      _getSnoozeDescription(duration!),
                      style: AppTypography.captionSmall(
                        context,
                      ).copyWith(color: AppColors.textSecondary(context)),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textTertiary(context),
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  String _getSnoozeDescription(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours == 0) return 'In $minutes minute${minutes != 1 ? 's' : ''}';
    if (minutes == 0) return 'In $hours hour${hours != 1 ? 's' : ''}';
    return 'In ${hours}h ${minutes}m';
  }
}

// No longer needed - using Alarm entity from domain layer
