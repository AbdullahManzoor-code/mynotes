import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart' as app_date;
import '../../domain/entities/alarm.dart';
import '../../domain/entities/note.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_state.dart';
import '../bloc/note_event.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming', icon: Icon(Icons.schedule)),
            Tab(text: 'Calendar', icon: Icon(Icons.calendar_month)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildUpcomingView(), _buildCalendarView()],
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
    final isOverdue = alarm.alarmTime.isBefore(DateTime.now());
    final timeUntil = app_date.AppDateUtils.getRelativeTime(alarm.alarmTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openNote(note),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Note title
              Row(
                children: [
                  Icon(
                    Icons.note,
                    size: 20,
                    color: Color(note.color.lightColor),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Active indicator
                  if (alarm.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          color: AppColors.successColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 12.h),

              // Alarm time
              Row(
                children: [
                  Icon(
                    isOverdue ? Icons.error_outline : Icons.access_time,
                    size: 18,
                    color: isOverdue
                        ? AppColors.errorColor
                        : AppColors.infoColor,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    app_date.AppDateUtils.formatDateTime(alarm.alarmTime),
                    style: TextStyle(
                      color: isOverdue ? AppColors.errorColor : null,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    timeUntil,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),

              // Repeat type
              if (alarm.repeatType != AlarmRepeatType.none) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    const Icon(
                      Icons.repeat,
                      size: 16,
                      color: AppColors.infoColor,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _getRepeatLabel(alarm.repeatType),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],

              SizedBox(height: 12.h),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _snoozeAlarm(alarm, note),
                    icon: const Icon(Icons.snooze, size: 18),
                    label: const Text('Snooze'),
                  ),
                  SizedBox(width: 8.w),
                  TextButton.icon(
                    onPressed: () => _editAlarm(alarm, note),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                  ),
                  SizedBox(width: 8.w),
                  TextButton.icon(
                    onPressed: () => _deleteAlarm(alarm, note),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.errorColor,
                    ),
                  ),
                ],
              ),
            ],
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
                  // Navigate to previous month
                  setState(() {
                    _currentDate = DateTime(
                      _currentDate.year,
                      _currentDate.month - 1,
                    );
                  });
                },
              ),
              Text(
                app_date.AppDateUtils.formatDate(now),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  // Navigate to next month
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

        SizedBox(height: 8.h),

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
                return SizedBox(); // Empty cell
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
              SizedBox(width: 24.w),
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
        SizedBox(width: 8.w),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'No reminders set',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add reminders to your notes',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
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
        }
      }
    }
    return false;
  }

  String _getRepeatLabel(AlarmRepeatType type) {
    switch (type) {
      case AlarmRepeatType.none:
        return 'Once';
      case AlarmRepeatType.daily:
        return 'Daily';
      case AlarmRepeatType.weekly:
        return 'Weekly';
      case AlarmRepeatType.monthly:
        return 'Monthly';
    }
  }

  void _openNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorPage(note: note)),
    );
  }

  void _snoozeAlarm(Alarm alarm, Note note) {
    // Snooze for 10 minutes by updating alarm time
    final snoozedTime = DateTime.now().add(const Duration(minutes: 10));
    final updatedAlarm = alarm.copyWith(alarmTime: snoozedTime);

    // Update alarms list in note
    final updatedAlarms = [...(note.alarms ?? [])];
    final index = updatedAlarms.indexWhere((a) => a.id == alarm.id);
    if (index >= 0) {
      updatedAlarms[index] = updatedAlarm;
    }

    final updatedNote = note.copyWith(alarms: updatedAlarms);
    context.read<NotesBloc>().add(UpdateNoteEvent(updatedNote));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reminder snoozed for 10 minutes')),
    );
  }

  void _editAlarm(Alarm alarm, Note note) {
    // Show edit alarm dialog with date and time picker
    DateTime selectedDate = alarm.alarmTime;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current: ${app_date.AppDateUtils.formatDateTime(alarm.alarmTime)}',
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(selectedDate),
                  );
                  if (time != null) {
                    selectedDate = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  }
                }
              },
              child: const Text('Pick Date & Time'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedAlarm = alarm.copyWith(alarmTime: selectedDate);

              // Update alarms list in note
              final updatedAlarms = [...(note.alarms ?? [])];
              final index = updatedAlarms.indexWhere((a) => a.id == alarm.id);
              if (index >= 0) {
                updatedAlarms[index] = updatedAlarm;
              }

              final updatedNote = note.copyWith(alarms: updatedAlarms);
              context.read<NotesBloc>().add(UpdateNoteEvent(updatedNote));

              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Reminder updated')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteAlarm(Alarm alarm, Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<NotesBloc>().add(
                RemoveAlarmFromNoteEvent(note.id, alarm.id),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Reminder deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
