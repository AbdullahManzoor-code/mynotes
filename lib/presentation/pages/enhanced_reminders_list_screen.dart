import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../design_system/design_system.dart';
import '../../core/routes/app_routes.dart';
import '../../domain/entities/alarm.dart';
import '../bloc/alarms_bloc.dart';
import '../../core/design_system/app_typography.dart';
import '../../core/design_system/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/add_reminder_bottom_sheet.dart';

/// Enhanced Smart Reminders List Screen
/// Advanced reminders management with smart snooze and context awareness
/// Based on reminders_list_with_smart_snooze template
class EnhancedRemindersListScreen extends StatefulWidget {
  const EnhancedRemindersListScreen({super.key});

  @override
  State<EnhancedRemindersListScreen> createState() =>
      _EnhancedRemindersListScreenState();
}

class _EnhancedRemindersListScreenState
    extends State<EnhancedRemindersListScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _listController;
  late AnimationController _fabController;
  late Animation<double> _headerAnimation;
  late Animation<Offset> _listSlideAnimation;

  List<Alarm> _todayReminders = [];
  List<Alarm> _upcomingReminders = [];
  List<Alarm> _overdueReminders = [];

  // Enhanced state management
  final TextEditingController _searchController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  bool _showFloatingButton = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _listController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    _listSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _listController, curve: Curves.easeOut));

    _scrollController.addListener(_onScroll);

    // Load alarms from database
    context.read<AlarmsBloc>().add(LoadAlarms());
    _startAnimations();
    _startRefreshTimer();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _listController.dispose();
    _fabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _categorizeAlarms(List<Alarm> alarms) {
    // Categorize alarms by time
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    _overdueReminders = alarms
        .where(
          (alarm) => alarm.isOverdue && alarm.status != AlarmStatus.completed,
        )
        .toList();

    _todayReminders = alarms
        .where(
          (alarm) =>
              !alarm.isOverdue &&
              alarm.scheduledTime.isBefore(todayEnd) &&
              alarm.status != AlarmStatus.completed,
        )
        .toList();

    _upcomingReminders = alarms
        .where(
          (alarm) =>
              alarm.scheduledTime.isAfter(todayEnd) &&
              alarm.status != AlarmStatus.completed,
        )
        .toList();
  }

  void _startAnimations() async {
    await _headerController.forward();
    _listController.forward();
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateReminderStatus();
    });
  }

  void _updateReminderStatus() {
    // Reload alarms from database to refresh status
    context.read<AlarmsBloc>().add(LoadAlarms());
  }

  void _onScroll() {
    final shouldShow = _scrollController.offset > 100;
    if (shouldShow != _showFloatingButton) {
      setState(() {
        _showFloatingButton = shouldShow;
      });
    }
  }

  void _completeReminder(Alarm alarm) {
    HapticFeedback.lightImpact();

    // Mark alarm as completed in database
    context.read<AlarmsBloc>().add(MarkAlarmCompleted(alarm.id));

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
            // Re-activate the alarm
            context.read<AlarmsBloc>().add(
              UpdateAlarm(
                alarm.copyWith(status: AlarmStatus.scheduled, isActive: true),
              ),
            );
          },
        ),
      ),
    );
  }

  void _snoozeReminder(Alarm alarm) {
    _showEnhancedSnoozeOptions(alarm);
  }

  void _showEnhancedSnoozeOptions(Alarm alarm) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildEnhancedSnoozeBottomSheet(alarm),
    );
  }

  void _applySnooze(Alarm alarm, Duration snoozeDuration, String snoozeLabel) {
    HapticFeedback.lightImpact();

    // Snooze alarm in database
    final newTime = DateTime.now().add(snoozeDuration);
    context.read<AlarmsBloc>().add(RescheduleAlarm(alarm.id, newTime));

    Navigator.pop(context);

    // Show confirmation
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

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AlarmsBloc, AlarmsState>(
      listener: (context, state) {
        if (state is AlarmsLoaded) {
          setState(() {
            _categorizeAlarms(state.alarms);
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildRemindersList()),
          ],
        ),
        floatingActionButton: _showFloatingButton
            ? _buildFloatingActionButton()
            : null,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
        child: FadeTransition(
          opacity: _headerAnimation,
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
                          onTap: () {
                            // TODO: Open reminder settings
                          },
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

                _buildQuickStats(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final overdue = _overdueReminders.length;
    final today = _todayReminders.length;
    final upcoming = _upcomingReminders.length;

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

  Widget _buildRemindersList() {
    return SlideTransition(
      position: _listSlideAnimation,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          if (_overdueReminders.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildSection(
                'Overdue',
                _overdueReminders,
                AppColors.errorColor,
              ),
            ),

          if (_todayReminders.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildSection('Today', _todayReminders, AppColors.primary),
            ),

          if (_upcomingReminders.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildSection(
                'Upcoming',
                _upcomingReminders,
                AppColors.textSecondary(context),
              ),
            ),

          if (_overdueReminders.isEmpty &&
              _todayReminders.isEmpty &&
              _upcomingReminders.isEmpty)
            SliverFillRemaining(child: _buildEmptyState()),

          SliverToBoxAdapter(
            child: SizedBox(height: 100.h), // Bottom padding
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Alarm> alarms, Color accentColor) {
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
              child: _buildReminderCard(alarm, accentColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(Alarm alarm, Color accentColor) {
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
                // Priority indicator (using isOverdue status)
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

                // Title
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

                // Complete button
                GestureDetector(
                  onTap: () => _completeReminder(alarm),
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

            // Time and context
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

                // Snooze button
                if (!isCompleted)
                  GestureDetector(
                    onTap: () => _snoozeReminder(alarm),
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

  Widget _buildEmptyState() {
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

  Widget _buildFloatingActionButton() {
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

  Widget _buildEnhancedSnoozeBottomSheet(Alarm alarm) {
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
          // Handle
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.textTertiary(context),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header with reminder preview
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.divider(context)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                          color: AppColors.textSecondary(
                            context,
                          ).withOpacity(0.1),
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
              ],
            ),
          ),

          // Snooze options
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: snoozeOptions.length + 1, // +1 for custom option
              itemBuilder: (context, index) {
                if (index == snoozeOptions.length) {
                  // Custom option
                  return _buildCustomSnoozeOption(alarm);
                }

                final option = snoozeOptions[index];
                return _buildEnhancedSnoozeOption(
                  option['label'] as String,
                  option['duration'] as Duration?,
                  option['icon'] as IconData,
                  alarm,
                );
              },
            ),
          ),

          SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 16.h),
        ],
      ),
    );
  }

  Widget _buildEnhancedSnoozeOption(
    String title,
    Duration? duration,
    IconData icon,
    Alarm alarm,
  ) {
    final isRecommended =
        title.contains('15 minutes') || title.contains('1 hour');

    return GestureDetector(
      onTap: () =>
          duration != null ? _applySnooze(alarm, duration, title) : null,
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
                      _getSnoozeDescription(duration),
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

  Widget _buildCustomSnoozeOption(Alarm alarm) {
    return GestureDetector(
      onTap: () => _showCustomSnoozeDialog(alarm),
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
    final thisEvening = DateTime(now.year, now.month, now.day, 18, 0); // 6 PM

    if (thisEvening.isAfter(now)) {
      return thisEvening.difference(now);
    } else {
      // Next day at 6 PM
      final tomorrowEvening = thisEvening.add(const Duration(days: 1));
      return tomorrowEvening.difference(now);
    }
  }

  Duration _getTomorrowMorningDuration() {
    final now = DateTime.now();
    final tomorrowMorning = DateTime(
      now.year,
      now.month,
      now.day + 1,
      9,
      0,
    ); // 9 AM tomorrow
    return tomorrowMorning.difference(now);
  }

  Duration _getNextWeekendDuration() {
    final now = DateTime.now();
    final daysUntilSaturday = (6 - now.weekday) % 7; // Saturday is 6
    final nextSaturday = DateTime(
      now.year,
      now.month,
      now.day + daysUntilSaturday,
      10,
      0,
    );

    if (nextSaturday.isBefore(now)) {
      // Add a week if we're past this Saturday
      return nextSaturday.add(const Duration(days: 7)).difference(now);
    }
    return nextSaturday.difference(now);
  }

  String _getSnoozeDescription(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours == 0) {
      return 'In $minutes minute${minutes != 1 ? 's' : ''}';
    } else if (minutes == 0) {
      return 'In $hours hour${hours != 1 ? 's' : ''}';
    } else {
      return 'In ${hours}h ${minutes}m';
    }
  }

  void _showCustomSnoozeDialog(Alarm alarm) {
    Navigator.pop(context); // Close bottom sheet

    // TODO: Implement custom date/time picker dialog
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

// No longer needed - using Alarm entity from domain layer
