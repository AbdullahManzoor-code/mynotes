import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/domain/models/do_not_disturb_settings.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import '../bloc/reminder_actions/do_not_disturb_bloc.dart';

/// Quick reschedule options
enum QuickRescheduleOption {
  today('Today', Duration.zero),
  tomorrow('Tomorrow', Duration(days: 1)),
  in3Days('In 3 Days', Duration(days: 3)),
  nextWeek('Next Week', Duration(days: 7)),
  nextMonth('Next Month', Duration(days: 30));

  final String label;
  final Duration offset;

  const QuickRescheduleOption(this.label, this.offset);

  DateTime getScheduledTime(DateTime baseTime) {
    return baseTime.add(offset);
  }
}

/// Smart snooze suggestion engine
class SmartSnoozeEngine {
  static List<Duration> getSuggestedSnoozeTimes() {
    return [
      Duration(minutes: 5),
      Duration(minutes: 15),
      Duration(minutes: 30),
      Duration(hours: 1),
      Duration(hours: 2),
      Duration(hours: 4),
    ];
  }

  static String formatDuration(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h';
    } else {
      return '${(duration.inHours / 24).toStringAsFixed(1)}d';
    }
  }

  static String getSnoozeDescription(Duration duration) {
    final now = DateTime.now();
    final snoozeTime = now.add(duration);

    if (duration.inMinutes < 60) {
      return 'Snooze for ${duration.inMinutes} minutes';
    } else if (duration.inHours < 24) {
      return 'Snooze until ${snoozeTime.hour}:${snoozeTime.minute.toString().padLeft(2, '0')}';
    } else {
      return 'Snooze until ${snoozeTime.month}/${snoozeTime.day}';
    }
  }
}

/// Quick reschedule bottom sheet
class QuickRescheduleSheet extends StatelessWidget {
  final Function(DateTime) onReschedule;
  final DateTime currentScheduleTime;

  const QuickRescheduleSheet({
    super.key,
    required this.onReschedule,
    required this.currentScheduleTime,
  });

  static void show(
    BuildContext context,
    DateTime currentScheduleTime,
    Function(DateTime) onReschedule,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => QuickRescheduleSheet(
        onReschedule: onReschedule,
        currentScheduleTime: currentScheduleTime,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Quick Reschedule',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 16.h),
          ...QuickRescheduleOption.values.map((option) {
            final newTime = option.getScheduledTime(DateTime.now());
            return ListTile(
              title: Text(option.label),
              subtitle: Text(
                '${newTime.month}/${newTime.day}/${newTime.year} at ${newTime.hour}:${newTime.minute.toString().padLeft(2, '0')}',
              ),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                onReschedule(newTime);
                Navigator.pop(context);
              },
            );
          }),
          SizedBox(height: 12.h),
          Divider(),
          SizedBox(height: 12.h),
          ListTile(
            title: Text('Custom Time'),
            trailing: Icon(Icons.edit),
            onTap: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 365)),
              );

              if (selectedDate != null && context.mounted) {
                final selectedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (selectedTime != null) {
                  final customDateTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );

                  onReschedule(customDateTime);
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Smart snooze suggestions widget
class SmartSnoozeWidget extends StatelessWidget {
  final Function(Duration) onSnooze;
  final Function()? onDismiss;

  const SmartSnoozeWidget({super.key, required this.onSnooze, this.onDismiss});

  static void show(
    BuildContext context,
    Function(Duration) onSnooze,
    Function()? onDismiss,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) =>
          SmartSnoozeWidget(onSnooze: onSnooze, onDismiss: onDismiss),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suggestedTimes = SmartSnoozeEngine.getSuggestedSnoozeTimes();

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Snooze Reminder',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 16.h),
          Text(
            'Smart Suggestions',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestedTimes.map((duration) {
              return FilledButton(
                onPressed: () {
                  onSnooze(duration);
                  Navigator.pop(context);
                },
                child: Text(SmartSnoozeEngine.formatDuration(duration)),
              );
            }).toList(),
          ),
          SizedBox(height: 16.h),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Custom Duration'),
            trailing: Icon(Icons.edit),
            onTap: () {
              // Show custom snooze dialog
              _showCustomSnoozeDialog(context);
            },
          ),
          SizedBox(height: 12.h),
          if (onDismiss != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  onDismiss!();
                  Navigator.pop(context);
                },
                child: Text('Dismiss'),
              ),
            ),
        ],
      ),
    );
  }

  void _showCustomSnoozeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Custom Snooze Duration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Minutes'),
              trailing: SizedBox(
                width: 100,
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '15',
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Set'),
          ),
        ],
      ),
    );
  }
}

/// Do Not Disturb settings panel
class DoNotDisturbPanel extends StatefulWidget {
  final DoNotDisturbSettings settings;
  final Function(DoNotDisturbSettings) onSettingsChanged;

  const DoNotDisturbPanel({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<DoNotDisturbPanel> createState() => _DoNotDisturbPanelState();
}

class _DoNotDisturbPanelState extends State<DoNotDisturbPanel> {
  late final DoNotDisturbBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = DoNotDisturbBloc(widget.settings);
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _updateStartTime(TimeOfDay time) {
    _bloc.add(UpdateDoNotDisturbStartTime(time));
  }

  void _updateEndTime(TimeOfDay time) {
    _bloc.add(UpdateDoNotDisturbEndTime(time));
  }

  void _toggleEnabled(bool value) {
    _bloc.add(ToggleDoNotDisturbEnabled(value));
  }

  void _toggleAllowUrgent(bool value) {
    _bloc.add(ToggleDoNotDisturbUrgent(value));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<DoNotDisturbBloc, DoNotDisturbSettings>(
        listenWhen: (previous, current) => previous != current,
        listener: (context, settings) {
          widget.onSettingsChanged(settings);
        },
        child: BlocBuilder<DoNotDisturbBloc, DoNotDisturbSettings>(
          builder: (context, settings) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Do Not Disturb',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (settings.enabled)
                          Text(
                            'Active from ${settings.startTime.format(context)} to ${settings.endTime.format(context)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.green),
                          ),
                      ],
                    ),
                    Switch(value: settings.enabled, onChanged: _toggleEnabled),
                  ],
                ),

                if (settings.enabled) ...[
                  SizedBox(height: 16.h),

                  // Time range
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('Start Time'),
                            trailing: Text(settings.startTime.format(context)),
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: settings.startTime,
                              );
                              if (time != null) {
                                _updateStartTime(time);
                              }
                            },
                          ),
                          Divider(height: 0),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('End Time'),
                            trailing: Text(settings.endTime.format(context)),
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: settings.endTime,
                              );
                              if (time != null) {
                                _updateEndTime(time);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Options
                  CheckboxListTile(
                    title: Text('Allow Urgent Reminders'),
                    subtitle: Text('High priority reminders will still notify'),
                    value: settings.allowUrgent,
                    onChanged: (value) => _toggleAllowUrgent(value ?? false),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Reminder action sheet with snooze options
class ReminderActionSheet extends StatelessWidget {
  final String reminderTitle;
  final DateTime scheduledTime;
  final VoidCallback onDismiss;
  final Function(DateTime) onReschedule;
  final Function(Duration) onSnooze;
  final bool isUrgent;

  const ReminderActionSheet({
    super.key,
    required this.reminderTitle,
    required this.scheduledTime,
    required this.onDismiss,
    required this.onReschedule,
    required this.onSnooze,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(reminderTitle, style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8.h),
          Text(
            'Scheduled: ${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      onDismiss();
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    'Dismiss',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.schedule),
                    onPressed: () {
                      QuickRescheduleSheet.show(context, scheduledTime, (
                        newTime,
                      ) {
                        onReschedule(newTime);
                        Navigator.pop(context);
                      });
                    },
                  ),
                  Text(
                    'Reschedule',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_active),
                    onPressed: () {
                      SmartSnoozeWidget.show(context, (duration) {
                        onSnooze(duration);
                      }, null);
                    },
                  ),
                  Text('Snooze', style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}




