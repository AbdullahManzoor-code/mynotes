import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:mynotes/core/services/app_logger.dart';
import 'package:mynotes/domain/entities/alarm.dart';

/// Service to show system notifications for upcoming alarms
/// Works even when app is completely killed
class UpcomingAlarmsNotificationService {
  static const String _tag = 'UpcomingAlarmsNotificationService';
  static const int _upcomingAlarmNotificationBaseId = 1000;

  // Top-level callback for AndroidAlarmManager - MUST be top-level with @pragma
  static Future<void> _showUpcomingAlarmNotification(String alarmId) async {
    AppLogger.i('═' * 70);
    AppLogger.i('[UPCOMING-ALARM-NOTIFICATION] 📢 Background task triggered!');
    AppLogger.i('Time: ${DateTime.now().toIso8601String()}');
    AppLogger.i('═' * 70);

    try {
      // Initialize AwesomeNotifications in this isolate
      AppLogger.i(
        '[UPCOMING-ALARM-NOTIFICATION] Initializing AwesomeNotifications...',
      );
      AwesomeNotifications().initialize(null, [
        NotificationChannel(
          channelKey: 'upcoming_alarms_channel',
          channelName: 'Upcoming Alarms',
          channelDescription: 'Notifications for upcoming alarms',
          defaultColor: const Color(0xFF2196F3),
          ledColor: Colors.blue,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
      ]);
      AppLogger.i(
        '[UPCOMING-ALARM-NOTIFICATION] ✅ AwesomeNotifications initialized',
      );

      // Show notification
      AppLogger.i(
        '[UPCOMING-ALARM-NOTIFICATION] Creating upcoming alarm notification...',
      );
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: _upcomingAlarmNotificationBaseId + alarmId.hashCode.abs(),
          channelKey: 'upcoming_alarms_channel',
          title: '⏰ Upcoming Alarm',
          body: 'You have an alarm coming up. Tap to view details.',
          wakeUpScreen: false,
          category: NotificationCategory.Alarm,
          autoDismissible: true,
          locked: false,
          payload: {'alarmId': alarmId.toString()},
        ),
      );
      AppLogger.i(
        '[UPCOMING-ALARM-NOTIFICATION] ✅ Notification created and sent to device',
      );
    } catch (e, stack) {
      AppLogger.e('[UPCOMING-ALARM-NOTIFICATION] ❌ Error: $e');
      AppLogger.e('Stack: $stack');
    }
  }

  /// Schedule notifications for all upcoming alarms
  /// Call this when alarms load or are added
  static Future<void> scheduleUpcomingAlarmsNotifications(
    List<Alarm> alarms,
  ) async {
    AppLogger.i('$_tag: Scheduling notifications for ${alarms.length} alarms');

    try {
      final now = DateTime.now();

      for (final alarm in alarms) {
        // Only schedule notification for alarms in the future
        if (alarm.scheduledTime.isAfter(now)) {
          final minutesUntilAlarm = alarm.scheduledTime
              .difference(now)
              .inMinutes;

          // Schedule notification 5 minutes before alarm
          if (minutesUntilAlarm > 5) {
            final notificationTime = alarm.scheduledTime.subtract(
              const Duration(minutes: 5),
            );

            final delayInSeconds = notificationTime.difference(now).inSeconds;

            if (delayInSeconds > 0) {
              AppLogger.i(
                '$_tag: Scheduling notification for alarm ${alarm.id} '
                'in $delayInSeconds seconds at ${notificationTime.toIso8601String()}',
              );

              try {
                // Cancel any existing scheduled notification for this alarm
                await AndroidAlarmManager.cancel(
                  _upcomingAlarmNotificationBaseId + alarm.id.hashCode.abs(),
                );
              } catch (e) {
                AppLogger.i('$_tag: Could not cancel existing alarm: $e');
              }

              // Schedule new notification via AndroidAlarmManager
              // Use closure to capture alarm.id from enclosing scope
              await AndroidAlarmManager.oneShot(
                Duration(seconds: delayInSeconds.toInt()),
                _upcomingAlarmNotificationBaseId + alarm.id.hashCode.abs(),
                () => _showUpcomingAlarmNotification(alarm.id),
              );

              AppLogger.i(
                '$_tag: ✅ Notification scheduled for alarm ${alarm.id}',
              );
            }
          } else {
            AppLogger.i(
              '$_tag: Alarm ${alarm.id} is within 5 minutes, not scheduling notification',
            );
          }
        }
      }

      AppLogger.i('$_tag: ✅ All upcoming alarm notifications scheduled');
    } catch (e, stack) {
      AppLogger.e('$_tag: Error scheduling notifications: $e');
      AppLogger.e('Stack: $stack');
    }
  }

  /// Cancel notification for a specific alarm
  static Future<void> cancelUpcomingAlarmNotification(String alarmId) async {
    try {
      AppLogger.i('$_tag: Cancelling notification for alarm $alarmId');
      await AndroidAlarmManager.cancel(
        _upcomingAlarmNotificationBaseId + alarmId.hashCode.abs(),
      );

      await AwesomeNotifications().dismiss(
        _upcomingAlarmNotificationBaseId + alarmId.hashCode.abs(),
      );

      AppLogger.i('$_tag: ✅ Notification cancelled for alarm $alarmId');
    } catch (e) {
      AppLogger.e('$_tag: Error cancelling notification: $e');
    }
  }

  /// Cancel all upcoming alarm notifications
  static Future<void> cancelAllUpcomingAlarmNotifications() async {
    try {
      AppLogger.i('$_tag: Cancelling all upcoming alarm notifications');

      // Cancel all notifications in the base ID range
      for (int i = 0; i < 1000; i++) {
        try {
          await AndroidAlarmManager.cancel(
            _upcomingAlarmNotificationBaseId + i,
          );
        } catch (e) {
          // Continue on error
        }
      }

      AppLogger.i('$_tag: ✅ All upcoming alarm notifications cancelled');
    } catch (e) {
      AppLogger.e('$_tag: Error cancelling all notifications: $e');
    }
  }
}
