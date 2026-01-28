import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/date_utils.dart' as app_date;
import '../../domain/entities/alarm.dart';
import '../../domain/entities/note.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_state.dart';
import '../bloc/note_event.dart';
import '../bloc/alarm_bloc.dart';
import '../bloc/alarm_event.dart';
import '../bloc/alarm_state.dart';
import '../design_system/design_system.dart';
import '../widgets/alarm_bottom_sheet.dart';
import 'note_editor_page.dart';
import 'enhanced_reminders_list_screen.dart';
import 'settings_screen.dart';

/// Reminders Screen
/// Shows all upcoming alarms across notes
/// Supports editing, deleting, and snoozing reminders
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({Key? key}) : super(key: key);

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentDate = DateTime.now();
    // Load notes to get alarms
    context.read<NotesBloc>().add(const LoadNotesEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AlarmBloc, AlarmState>(
      listener: (context, state) {
        if (state is AlarmSuccess) {
          AppSnackbar.show(
            context,
            message: state.message,
            type: SnackbarType.success,
          );
          // Reload notes to reflect changes
          context.read<NotesBloc>().add(const LoadNotesEvent());
        } else if (state is AlarmError) {
          AppSnackbar.show(
            context,
            message: state.message,
            type: SnackbarType.error,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: CustomScrollView(
          slivers: [
            // Glassmorphic Sticky Header
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppColors.background(context).withOpacity(0.8),
              flexibleSpace: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(color: Colors.transparent),
                ),
              ),
              title: Text(
                'Reminders',
                style: AppTypography.heading1(null, null, FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, size: 24),
                  onPressed: () {
                    // Search functionality
                  },
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: AppColors.primary),
                  onSelected: (value) => _handleRemindersMenu(value),
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'enhanced',
                      child: Row(
                        children: [
                          Icon(Icons.view_agenda, size: 20),
                          SizedBox(width: 12),
                          Text('Enhanced View'),
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
              ],
              elevation: 0,
            ),

            // Segmented Control for filters
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPaddingHorizontal,
                  vertical: 12,
                ),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface(context).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tabController.index = 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _tabController.index == 0
                                  ? AppColors.surface(context)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusLG,
                              ),
                              boxShadow: _tabController.index == 0
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Upcoming',
                              style: AppTypography.bodySmall(
                                null,
                                _tabController.index == 0
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                                FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tabController.index = 1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _tabController.index == 1
                                  ? AppColors.surface(context)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusLG,
                              ),
                              boxShadow: _tabController.index == 1
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Completed',
                              style: AppTypography.bodySmall(
                                null,
                                _tabController.index == 1
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                                FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content based on selected tab
            _tabController.index == 0
                ? _buildUpcomingList()
                : _buildCompletedList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingList() {
    return BlocBuilder<NotesBloc, NoteState>(
      builder: (context, state) {
        if (state is NoteLoading) {
          return const SliverFillRemaining(
            child: Padding(
              padding: EdgeInsets.all(48.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (state is NotesLoaded) {
          final notesWithAlarms = state.notes
              .where((note) => note.alarms != null && note.alarms!.isNotEmpty)
              .toList();

          if (notesWithAlarms.isEmpty) {
            return SliverFillRemaining(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 48,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon Container
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.accentOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.accentOrange.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        size: 56,
                        color: AppColors.accentOrange,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'No reminders yet',
                      style: AppTypography.heading2(
                        context,
                        null,
                        FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      'Never forget important tasks. Set your first reminder now.',
                      style: AppTypography.bodyMedium(
                        context,
                        AppColors.textSecondary(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // Collect all alarms with their notes
          final alarmsWithNotes = <({Alarm alarm, Note note})>[];
          for (final note in notesWithAlarms) {
            for (final alarm in note.alarms!) {
              alarmsWithNotes.add((alarm: alarm, note: note));
            }
          }

          // Sort by alarm time
          alarmsWithNotes.sort(
            (a, b) => a.alarm.alarmTime.compareTo(b.alarm.alarmTime),
          );

          // Group by date categories
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final tomorrow = today.add(const Duration(days: 1));
          final nextWeek = today.add(const Duration(days: 7));

          final todayAlarms = alarmsWithNotes.where((item) {
            final alarmDate = DateTime(
              item.alarm.alarmTime.year,
              item.alarm.alarmTime.month,
              item.alarm.alarmTime.day,
            );
            return alarmDate == today;
          }).toList();

          final tomorrowAlarms = alarmsWithNotes.where((item) {
            final alarmDate = DateTime(
              item.alarm.alarmTime.year,
              item.alarm.alarmTime.month,
              item.alarm.alarmTime.day,
            );
            return alarmDate == tomorrow;
          }).toList();

          final upcomingAlarms = alarmsWithNotes.where((item) {
            final alarmDate = DateTime(
              item.alarm.alarmTime.year,
              item.alarm.alarmTime.month,
              item.alarm.alarmTime.day,
            );
            return alarmDate.isAfter(tomorrow) && alarmDate.isBefore(nextWeek);
          }).toList();

          final laterAlarms = alarmsWithNotes.where((item) {
            final alarmDate = DateTime(
              item.alarm.alarmTime.year,
              item.alarm.alarmTime.month,
              item.alarm.alarmTime.day,
            );
            return alarmDate.isAfter(nextWeek) || alarmDate == nextWeek;
          }).toList();

          return SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPaddingHorizontal,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // Build sections
                  int currentIndex = 0;

                  if (todayAlarms.isNotEmpty) {
                    if (index == currentIndex) {
                      return SectionHeader(
                        title: 'Today',
                        padding: const EdgeInsets.only(top: 24, bottom: 8),
                      );
                    }
                    currentIndex++;

                    if (index < currentIndex + todayAlarms.length) {
                      final item = todayAlarms[index - currentIndex];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildAlarmCard(item.alarm, item.note),
                      );
                    }
                    currentIndex += todayAlarms.length;
                  }

                  if (tomorrowAlarms.isNotEmpty) {
                    if (index == currentIndex) {
                      return SectionHeader(
                        title: 'Tomorrow',
                        padding: const EdgeInsets.only(top: 24, bottom: 8),
                      );
                    }
                    currentIndex++;

                    if (index < currentIndex + tomorrowAlarms.length) {
                      final item = tomorrowAlarms[index - currentIndex];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildAlarmCard(item.alarm, item.note),
                      );
                    }
                    currentIndex += tomorrowAlarms.length;
                  }

                  if (upcomingAlarms.isNotEmpty) {
                    if (index == currentIndex) {
                      return SectionHeader(
                        title: 'This Week',
                        padding: const EdgeInsets.only(top: 24, bottom: 8),
                      );
                    }
                    currentIndex++;

                    if (index < currentIndex + upcomingAlarms.length) {
                      final item = upcomingAlarms[index - currentIndex];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildAlarmCard(item.alarm, item.note),
                      );
                    }
                    currentIndex += upcomingAlarms.length;
                  }

                  if (laterAlarms.isNotEmpty) {
                    if (index == currentIndex) {
                      return SectionHeader(
                        title: 'Later',
                        padding: const EdgeInsets.only(top: 24, bottom: 8),
                      );
                    }
                    currentIndex++;

                    if (index < currentIndex + laterAlarms.length) {
                      final item = laterAlarms[index - currentIndex];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildAlarmCard(item.alarm, item.note),
                      );
                    }
                  }

                  return const SizedBox.shrink();
                },
                childCount:
                    (todayAlarms.isNotEmpty ? todayAlarms.length + 1 : 0) +
                    (tomorrowAlarms.isNotEmpty
                        ? tomorrowAlarms.length + 1
                        : 0) +
                    (upcomingAlarms.isNotEmpty
                        ? upcomingAlarms.length + 1
                        : 0) +
                    (laterAlarms.isNotEmpty ? laterAlarms.length + 1 : 0),
              ),
            ),
          );
        }

        return SliverFillRemaining(
          child: Padding(
            padding: const EdgeInsets.all(48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.errorColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load reminders',
                  style: AppTypography.bodyLarge(
                    context,
                    AppColors.textPrimary(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarView() {
    return BlocBuilder<NotesBloc, NoteState>(
      builder: (context, state) {
        if (state is NotesLoaded) {
          return _buildCalendarGrid(state.notes);
        }

        return const SliverFillRemaining(
          child: Padding(
            padding: EdgeInsets.all(48.0),
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildCompletedList() {
    // For now, show empty state for completed reminders
    return SliverFillRemaining(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.successGreen.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 56,
                color: AppColors.successGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Completed Reminders',
              style: AppTypography.heading2(context, null, FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Complete some reminders and they\'ll appear here.',
              style: AppTypography.bodyMedium(
                context,
                AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlarmCard(Alarm alarm, Note note) {
    final timeStr = app_date.AppDateUtils.formatTime(alarm.alarmTime);

    return GestureDetector(
      onTap: () => _openNote(note),

      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        margin: EdgeInsets.zero,
        child: Row(
          children: [
            // Left content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title.isNotEmpty ? note.title : 'Untitled Note',
                    style: AppTypography.bodyLarge(null, null, FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        timeStr,
                        style: AppTypography.caption(
                          null,
                          AppColors.textMuted,
                          FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Snooze button
            GestureDetector(
              onTap: () => _snoozeAlarm(alarm, note),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface(context).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                ),
                child: Icon(
                  Icons.notifications_paused,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(List<Note> notes) {
    final now = _currentDate;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final startingWeekday = firstDayOfMonth.weekday % 7;

    return Column(
      children: [
        // Month header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _currentDate = DateTime(
                      _currentDate.year,
                      _currentDate.month - 1,
                    );
                  });
                },
              ),
              Text(
                app_date.AppDateUtils.formatDate(now).split(',')[0] +
                    ' ${now.year}', // Simple month year
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _currentDate = DateTime(
                      _currentDate.year,
                      _currentDate.month + 1,
                    );
                  });
                },
              ),
            ],
          ),
        ),

        // Weekday headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),

        SizedBox(height: AppSpacing.sm),

        // Calendar grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: 42, // 6 weeks
            itemBuilder: (context, index) {
              final dayNumber = index - startingWeekday + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox(); // Empty cell
              }

              final date = DateTime(now.year, now.month, dayNumber);
              final hasReminder = _hasReminderOnDate(notes, date);

              return Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: app_date.AppDateUtils.isToday(date)
                      ? AppColors.primaryColor
                      : hasReminder
                      ? AppColors.accentColor.withOpacity(0.2)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  border: hasReminder
                      ? Border.all(color: AppColors.accentColor)
                      : null,
                ),
                child: Center(
                  child: Text(
                    dayNumber.toString(),
                    style: TextStyle(
                      color: app_date.AppDateUtils.isToday(date)
                          ? Colors.white
                          : null,
                      fontWeight: hasReminder
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Legend
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(AppColors.primaryColor, 'Today'),
              SizedBox(width: AppSpacing.xxl),
              _buildLegendItem(AppColors.accentColor, 'Has Reminder'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: Icons.notifications_none,
      title: 'No Reminders',
      description:
          'You haven\'t set any reminders yet. Tap the + button to create your first reminder.',
      // actionLabel: 'Create Reminder',
      // onAction: () => _showAddReminderDialog(context),
    );
  }

  bool _hasReminderOnDate(List<Note> notes, DateTime date) {
    for (final note in notes) {
      if (note.alarms != null) {
        for (final alarm in note.alarms!) {
          if (app_date.AppDateUtils.isToday(alarm.alarmTime) &&
              alarm.alarmTime.year == date.year &&
              alarm.alarmTime.month == date.month &&
              alarm.alarmTime.day == date.day) {
            return true;
          }
          // Also check recurrence if needed, but for calendar visualization simple is okay for now
        }
      }
    }
    return false;
  }

  void _openNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorPage(note: note)),
    );
  }

  void _snoozeAlarm(Alarm alarm, Note note) {
    // Snooze for 10 minutes
    final snoozedTime = DateTime.now().add(const Duration(minutes: 10));
    final updatedAlarm = alarm.copyWith(alarmTime: snoozedTime);

    context.read<AlarmBloc>().add(UpdateAlarmEvent(updatedAlarm));
  }

  void _editAlarm(Alarm alarm, Note note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AlarmBottomSheet(note: note, existingAlarm: alarm),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Reminder'),
        content: const Text('Reminder creation UI not implemented.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleRemindersMenu(String value) {
    switch (value) {
      case 'enhanced':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const EnhancedRemindersListScreen(),
          ),
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
}
