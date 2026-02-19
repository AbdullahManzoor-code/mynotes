import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/alarm/alarm_bloc.dart';
import 'package:mynotes/core/services/app_logger.dart';
import 'package:intl/intl.dart';
import 'package:mynotes/presentation/bloc/alarm/alarm_state.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';

/// Screen shown when alarm is snoozed
/// Stateless widget with BLoC integration
class SnoozeConfirmationScreen extends StatelessWidget {
  final dynamic alarm;
  final DateTime snoozeUntil;
  final int snoozeMinutes;

  const SnoozeConfirmationScreen({
    super.key,
    required this.alarm,
    required this.snoozeUntil,
    required this.snoozeMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');
    final alarmTitle = alarm.title ?? 'Alarm';
    final nowTime = timeFormat.format(DateTime.now());
    final snoozeTime = timeFormat.format(snoozeUntil);

    return Scaffold(
      appBar: AppBar(
        title: const Text('⏸️ Alarm Snoozed'),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: BlocListener<AlarmsBloc, AlarmState>(
        listener: (context, state) {
          if (state is AlarmError) {
            AppLogger.e('❌ [SNOOZE-LISTENER] Error: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success icon with animation
                  Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.snooze,
                      size: 64,
                      color: Colors.orange.shade600,
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Title
                  Text(
                    '✅ Alarm Snoozed',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Alarm details
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alarm Details',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Alarm',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                alarmTitle,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Current Time',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                nowTime,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Snoozed For',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[700],
                                    ),
                              ),
                              Text(
                                '$snoozeMinutes minutes',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[700],
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Will Trigger At',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  snoozeTime,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange[900],
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Info box
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border.all(color: Colors.blue.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info, color: Colors.blue[900]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'The alarm will notify you again after $snoozeMinutes minute${snoozeMinutes > 1 ? 's' : ''}. '
                            'You will receive a system notification and in-app popup.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        AppLogger.i(
                          '✅ [SNOOZE-SCREEN] User closed snooze confirmation',
                        );
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: const Text('Got it'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
