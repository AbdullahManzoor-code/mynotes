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
import '../widgets/empty_state_widget.dart';
import '../widgets/alarm_bottom_sheet.dart';
import 'note_editor_page.dart';

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
      child: AppScaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(AppSpacing.appBarHeight + 48.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlassAppBar(title: 'Reminders'),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Upcoming', icon: Icon(Icons.schedule)),
                  Tab(text: 'Calendar', icon: Icon(Icons.calendar_month)),
                ],
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary(context),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildUpcomingView(), _buildCalendarView()],
        ),
      ),
    );
  }

  Widget _buildUpcomingView() {
    return BlocBuilder<NotesBloc, NoteState>(
      builder: (context, state) {
        if (state is NoteLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is NotesLoaded) {
          final notesWithAlarms = state.notes
              .where((note) => note.alarms != null && note.alarms!.isNotEmpty)
              .toList();

          if (notesWithAlarms.isEmpty) {
            return _buildEmptyState();
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alarmsWithNotes.length,
            itemBuilder: (context, index) {
              final item = alarmsWithNotes[index];
              return _buildAlarmCard(item.alarm, item.note);
            },
          );
        }

        return const Center(child: Text('Failed to load reminders'));
      },
    );
  }

  Widget _buildCalendarView() {
    return BlocBuilder<NotesBloc, NoteState>(
      builder: (context, state) {
        if (state is NotesLoaded) {
          return _buildCalendarGrid(state.notes);
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildAlarmCard(Alarm alarm, Note note) {
    final isOverdue =
        alarm.alarmTime.isBefore(DateTime.now()) &&
        alarm.repeatType == AlarmRepeatType.none;
    final timeUntil = app_date.AppDateUtils.getRelativeTime(alarm.alarmTime);

    return Dismissible(
      key: Key(alarm.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.errorColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Reminder?'),
            content: const Text('This will remove the reminder from the note.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        context.read<AlarmBloc>().add(
          DeleteAlarmEvent(noteId: note.id, alarmId: alarm.id),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.md),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openNote(note),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceColor(
                      Theme.of(context).brightness,
                    ).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.getBorderColor(
                        Theme.of(context).brightness,
                      ),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Note title
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: AppColors.getNoteColor(
                                note.color,
                                context,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm,
                              ),
                            ),
                            child: Icon(
                              Icons.note,
                              size: 16,
                              color: AppColors.getNoteColor(
                                note.color,
                                context,
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              note.title.isNotEmpty
                                  ? note.title
                                  : 'Untitled Note',
                              style: AppTypography.bodyLarge(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Active indicator
                          if (alarm.isActive)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.successColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMedium,
                                ),
                              ),
                              child: Text(
                                'Active',
                                style: AppTypography.captionSmall(
                                  color: AppColors.successColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: AppSpacing.sm),

                      // Alarm Message (if any)
                      if (alarm.message != null &&
                          alarm.message!.isNotEmpty &&
                          alarm.message != note.title)
                        Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Text(
                            alarm.message!,
                            style: AppTypography.bodyMedium(
                              color: AppColors.getSecondaryTextColor(
                                Theme.of(context).brightness,
                              ),
                            ).copyWith(fontStyle: FontStyle.italic),
                          ),
                        ),

                      // Alarm time
                      Row(
                        children: [
                          Icon(
                            isOverdue ? Icons.error_outline : Icons.access_time,
                            size: 16,
                            color: isOverdue
                                ? AppColors.errorColor
                                : AppColors.infoColor,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            app_date.AppDateUtils.formatDateTime(
                              alarm.alarmTime,
                            ),
                            style: AppTypography.bodyMedium(
                              color: isOverdue ? AppColors.errorColor : null,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            timeUntil,
                            style: AppTypography.captionSmall(
                              color: AppColors.getSecondaryTextColor(
                                Theme.of(context).brightness,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Repeat type
                      if (alarm.repeatType != AlarmRepeatType.none) ...[
                        SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Text(
                              alarm.repeatType.icon,
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text(
                              alarm.repeatType.displayName,
                              style: AppTypography.captionSmall(
                                color: AppColors.getSecondaryTextColor(
                                  Theme.of(context).brightness,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      SizedBox(height: AppSpacing.sm),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _snoozeAlarm(alarm, note),
                            icon: const Icon(Icons.snooze, size: 18),
                            label: const Text('Snooze'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryColor,
                              textStyle: AppTypography.buttonMedium(),
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          TextButton.icon(
                            onPressed: () => _editAlarm(alarm, note),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryColor,
                              textStyle: AppTypography.buttonMedium(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
      subtitle:
          'You haven\'t set any reminders yet. Tap the + button to create your first reminder.',
      actionLabel: 'Create Reminder',
      onAction: () => _showAddReminderDialog(context),
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
}
