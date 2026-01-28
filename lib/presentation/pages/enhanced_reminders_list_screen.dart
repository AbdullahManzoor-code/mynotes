import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../design_system/design_system.dart';

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

  List<Reminder> _todayReminders = [];
  List<Reminder> _upcomingReminders = [];
  List<Reminder> _overdueReminders = [];

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

    _loadReminders();
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

  void _loadReminders() {
    // Mock data - replace with actual data loading
    final now = DateTime.now();

    setState(() {
      _overdueReminders = [
        Reminder(
          id: '1',
          title: 'Call client about project updates',
          scheduledTime: now.subtract(const Duration(hours: 2)),
          isCompleted: false,
          priority: ReminderPriority.high,
          context: 'Work',
        ),
        Reminder(
          id: '2',
          title: 'Submit expense report',
          scheduledTime: now.subtract(const Duration(days: 1)),
          isCompleted: false,
          priority: ReminderPriority.medium,
          context: 'Work',
        ),
      ];

      _todayReminders = [
        Reminder(
          id: '3',
          title: 'Team meeting at 3 PM',
          scheduledTime: now.add(const Duration(hours: 2)),
          isCompleted: false,
          priority: ReminderPriority.high,
          context: 'Work',
        ),
        Reminder(
          id: '4',
          title: 'Pick up groceries',
          scheduledTime: now.add(const Duration(hours: 4)),
          isCompleted: false,
          priority: ReminderPriority.low,
          context: 'Personal',
        ),
        Reminder(
          id: '5',
          title: 'Call mom',
          scheduledTime: now.add(const Duration(hours: 6)),
          isCompleted: false,
          priority: ReminderPriority.medium,
          context: 'Personal',
        ),
      ];

      _upcomingReminders = [
        Reminder(
          id: '6',
          title: 'Doctor appointment',
          scheduledTime: now.add(const Duration(days: 1)),
          isCompleted: false,
          priority: ReminderPriority.high,
          context: 'Health',
        ),
        Reminder(
          id: '7',
          title: 'Review quarterly goals',
          scheduledTime: now.add(const Duration(days: 3)),
          isCompleted: false,
          priority: ReminderPriority.medium,
          context: 'Work',
        ),
      ];
    });
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
    final now = DateTime.now();
    bool needsUpdate = false;

    // Check if any reminders have become overdue
    for (final reminder in _todayReminders) {
      if (reminder.scheduledTime.isBefore(now) && !reminder.isCompleted) {
        needsUpdate = true;
        break;
      }
    }

    if (needsUpdate) {
      setState(() {
        _loadReminders();
      });
    }
  }

  void _onScroll() {
    final shouldShow = _scrollController.offset > 100;
    if (shouldShow != _showFloatingButton) {
      setState(() {
        _showFloatingButton = shouldShow;
      });
    }
  }

  void _completeReminder(Reminder reminder) {
    HapticFeedback.lightImpact();

    setState(() {
      reminder.isCompleted = true;
    });

    // Remove from lists after animation
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _overdueReminders.removeWhere((r) => r.id == reminder.id);
        _todayReminders.removeWhere((r) => r.id == reminder.id);
        _upcomingReminders.removeWhere((r) => r.id == reminder.id);
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder completed'),
        backgroundColor: AppColors.primary,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              reminder.isCompleted = false;
            });
          },
        ),
      ),
    );
  }

  void _snoozeReminder(Reminder reminder) {
    _showEnhancedSnoozeOptions(reminder);
  }

  void _showEnhancedSnoozeOptions(Reminder reminder) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildEnhancedSnoozeBottomSheet(reminder),
    );
  }

  void _applySnooze(
    Reminder reminder,
    Duration snoozeDuration,
    String snoozeLabel,
  ) {
    final newTime = DateTime.now().add(snoozeDuration);

    HapticFeedback.lightImpact();

    setState(() {
      reminder.scheduledTime = newTime;
      reminder.snoozeCount = (reminder.snoozeCount ?? 0) + 1;

      // Move to appropriate list based on new time
      _overdueReminders.removeWhere((r) => r.id == reminder.id);
      _todayReminders.removeWhere((r) => r.id == reminder.id);
      _upcomingReminders.removeWhere((r) => r.id == reminder.id);

      final now = DateTime.now();
      if (_isSameDay(newTime, now)) {
        _todayReminders.add(reminder);
        _todayReminders.sort(
          (a, b) => a.scheduledTime.compareTo(b.scheduledTime),
        );
      } else {
        _upcomingReminders.add(reminder);
        _upcomingReminders.sort(
          (a, b) => a.scheduledTime.compareTo(b.scheduledTime),
        );
      }
    });

    Navigator.pop(context);

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder snoozed $snoozeLabel'),
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
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildRemindersList()),
        ],
      ),
      floatingActionButton: _showFloatingButton
          ? _buildFloatingActionButton()
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
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
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        // TODO: Open reminder settings
                      },
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                Text(
                  'Smart Reminders',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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
              style: TextStyle(
                fontSize: 12.sp,
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
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),

        if ((overdue > 0 || today > 0) && upcoming > 0) SizedBox(width: 8.w),

        if (upcoming > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Text(
              '$upcoming upcoming',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
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
                Colors.red.shade300,
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
                Colors.grey.shade400,
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

  Widget _buildSection(
    String title,
    List<Reminder> reminders,
    Color accentColor,
  ) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: accentColor,
            ),
          ),

          SizedBox(height: 12.h),

          ...reminders.map(
            (reminder) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _buildReminderCard(reminder, accentColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder, Color accentColor) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: reminder.isCompleted ? 0.5 : 1.0,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.darkCardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: reminder.isCompleted
                ? Colors.grey.shade800
                : accentColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Priority indicator
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(reminder.priority),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),

                SizedBox(width: 12.w),

                // Title
                Expanded(
                  child: Text(
                    reminder.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: reminder.isCompleted
                          ? Colors.grey.shade600
                          : Colors.white,
                      decoration: reminder.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),

                // Complete button
                GestureDetector(
                  onTap: () => _completeReminder(reminder),
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: reminder.isCompleted
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: reminder.isCompleted
                            ? AppColors.primary
                            : Colors.grey.shade600,
                        width: 2,
                      ),
                    ),
                    child: reminder.isCompleted
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
                  color: Colors.grey.shade500,
                ),
                SizedBox(width: 4.w),
                Text(
                  _formatTime(reminder.scheduledTime),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade500,
                  ),
                ),

                if (reminder.context.isNotEmpty) ...[
                  SizedBox(width: 12.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      reminder.context,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ],

                const Spacer(),

                // Snooze button
                if (!reminder.isCompleted)
                  GestureDetector(
                    onTap: () => _snoozeReminder(reminder),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'Snooze',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade400,
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

  Color _getPriorityColor(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.high:
        return Colors.red;
      case ReminderPriority.medium:
        return Colors.orange;
      case ReminderPriority.low:
        return Colors.green;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.isNegative) {
      final pastDifference = now.difference(dateTime);
      if (pastDifference.inHours < 24) {
        return '${pastDifference.inHours}h ago';
      } else {
        return '${pastDifference.inDays}d ago';
      }
    } else {
      if (difference.inHours < 24) {
        return 'in ${difference.inHours}h';
      } else {
        return 'in ${difference.inDays}d';
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80.sp,
            color: Colors.grey.shade700,
          ),
          SizedBox(height: 16.h),
          Text(
            'No reminders',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Create your first reminder to get started',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, '/quick-add');
      },
      backgroundColor: AppColors.primary,
      child: Icon(Icons.add, color: Colors.white, size: 24.sp),
    );
  }

  Widget _buildEnhancedSnoozeBottomSheet(Reminder reminder) {
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
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
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
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header with reminder preview
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
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
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            reminder.title,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade400,
                            ),
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
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.grey.shade400,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),

                // Snooze count indicator
                if ((reminder.snoozeCount ?? 0) > 0) ...[
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.snooze, color: Colors.orange, size: 14.sp),
                        SizedBox(width: 4.w),
                        Text(
                          'Snoozed ${reminder.snoozeCount} time${(reminder.snoozeCount ?? 0) > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                  return _buildCustomSnoozeOption(reminder);
                }

                final option = snoozeOptions[index];
                return _buildEnhancedSnoozeOption(
                  option['label'] as String,
                  option['duration'] as Duration?,
                  option['icon'] as IconData,
                  reminder,
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
    Reminder reminder,
  ) {
    final isRecommended =
        title.contains('15 minutes') || title.contains('1 hour');

    return GestureDetector(
      onTap: () =>
          duration != null ? _applySnooze(reminder, duration, title) : null,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isRecommended
              ? AppColors.primary.withOpacity(0.1)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isRecommended
                ? AppColors.primary.withOpacity(0.3)
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isRecommended
                    ? AppColors.primary.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: isRecommended ? AppColors.primary : Colors.grey.shade400,
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
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
                            style: TextStyle(
                              fontSize: 10.sp,
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
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade600,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomSnoozeOption(Reminder reminder) {
    return GestureDetector(
      onTap: () => _showCustomSnoozeDialog(reminder),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.edit_calendar,
                color: Colors.grey.shade400,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                'Custom time...',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade600,
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

  void _showCustomSnoozeDialog(Reminder reminder) {
    Navigator.pop(context); // Close bottom sheet

    // TODO: Implement custom date/time picker dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Custom Snooze', style: TextStyle(color: Colors.white)),
        content: Text(
          'Custom time picker coming soon!',
          style: TextStyle(color: Colors.grey.shade300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

// Models
class Reminder {
  final String id;
  final String title;
  DateTime scheduledTime; // Changed from final to allow snoozing
  bool isCompleted;
  final ReminderPriority priority;
  final String context;
  int? snoozeCount; // Track how many times it's been snoozed

  Reminder({
    required this.id,
    required this.title,
    required this.scheduledTime,
    this.isCompleted = false,
    required this.priority,
    this.context = '',
    this.snoozeCount,
  });
}

enum ReminderPriority { high, medium, low }
