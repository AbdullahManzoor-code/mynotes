import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/alarm/alarm_bloc.dart';
import 'package:mynotes/presentation/bloc/alarm/alarm_event.dart';
import 'package:mynotes/core/services/app_logger.dart';
import 'package:intl/intl.dart';
import 'package:mynotes/presentation/bloc/alarm/alarm_state.dart';

/// Screen for rescheduling an alarm
/// Fully Stateless widget with BLoC integration
class AlarmRescheduleScreen extends StatelessWidget {
  final dynamic alarm;

  const AlarmRescheduleScreen({super.key, required this.alarm});

  @override
  Widget build(BuildContext context) {
    final alarmTitle = alarm.title ?? 'Alarm';

    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 Reschedule Alarm'),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocListener<AlarmsBloc, AlarmState>(
        listener: (context, state) {
          if (state is AlarmSuccess) {
            AppLogger.i(
              '✅ [RESCHEDULE-LISTENER] Alarm rescheduled: ${state.message}',
            );
          } else if (state is AlarmError) {
            AppLogger.e('❌ [RESCHEDULE-LISTENER] Error: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current alarm info
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Alarm',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          alarmTitle,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '⏰ Originally scheduled for ${DateFormat('hh:mm a').format(alarm.alarmTime)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Date selection header
                Text(
                  'Select New Date & Time',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Date/Time picker with StatefulBuilder
                _DateTimePickerWidget(alarm: alarm),
                const SizedBox(height: 32),

                // Info box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    border: Border.all(color: Colors.amber.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info, color: Colors.amber[900]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'The alarm notification will be rescheduled for the new time. Make sure you select a future date.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper widget for date/time picker
/// Uses StatefulBuilder only for picker state, all actions use BLoC
class _DateTimePickerWidget extends StatelessWidget {
  final dynamic alarm;

  const _DateTimePickerWidget({required this.alarm});

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        DateTime selectedDateTime = alarm.alarmTime ?? DateTime.now();

        Future<void> selectDateTime() async {
          // Select date
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: selectedDateTime,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );

          if (pickedDate == null) return;

          // Select time
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(selectedDateTime),
          );

          if (pickedTime == null) return;

          setState(() {
            selectedDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
          });

          AppLogger.i(
            '📅 [RESCHEDULE] New alarm time selected: $selectedDateTime',
          );
        }

        void confirmReschedule() {
          if (selectedDateTime.isBefore(DateTime.now())) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('⚠️ Please select a future date and time'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          AppLogger.i('✅ [RESCHEDULE] Rescheduling alarm to $selectedDateTime');

          // Dispatch reschedule event to BLoC
          context.read<AlarmsBloc>().add(
            RescheduleAlarmEvent(
              alarmId: alarm.alarmId,
              newTime: selectedDateTime,
            ),
          );

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Alarm rescheduled successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Pop the screen
          Navigator.of(context).pop();
        }

        final dateFormat = DateFormat('EEE, MMM d, yyyy');
        final timeFormat = DateFormat('hh:mm a');

        return Column(
          children: [
            // Date/Time display
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormat.format(selectedDateTime),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Time',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timeFormat.format(selectedDateTime),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: selectDateTime,
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Pick Date & Time'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: confirmReschedule,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Confirm Reschedule'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}


