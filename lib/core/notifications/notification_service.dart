import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:typed_data';
import '../../domain/entities/alarm.dart'; // Ensure AlarmRepeatType is available

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      tz.initializeTimeZones(); // Initialize time zones

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS/macOS settings if needed in future
      final DarwinInitializationSettings darwinSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      final InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _plugin.initialize(
        settings,
        onDidReceiveNotificationResponse:
            (NotificationResponse response) async {
              // Handle notification tap
              // TODO: Implement navigation to note
            },
      );
    } catch (e) {
      throw Exception(
        'Failed to initialize notifications. Please check notification permissions: $e',
      );
    }
  }

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    AlarmRecurrence repeatType = AlarmRecurrence.none,
    String? soundPath,
  }) async {
    try {
      // Map sound paths to UriAndroidNotificationSound
      UriAndroidNotificationSound? sound;
      if (soundPath != null && soundPath.isNotEmpty) {
        sound = UriAndroidNotificationSound(soundPath);
      }

      final android = AndroidNotificationDetails(
        'notes_channel',
        'Notes & Reminders',
        channelDescription: 'Notifications for notes and reminders',
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: true, // For critical reminders
        category: AndroidNotificationCategory.reminder,
        sound: sound,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
        playSound: true,
      );
      final details = NotificationDetails(android: android);

      final scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        // If time passed, don't schedule (or handle accordingly)
        throw Exception(
          'Cannot schedule reminder for a past time. Please choose a future time',
        );
      }

      if (repeatType == AlarmRecurrence.none) {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } else {
        // Handle recurrence
        DateTimeComponents? matchDateTimeComponents;

        switch (repeatType) {
          case AlarmRecurrence.daily:
            matchDateTimeComponents = DateTimeComponents.time;
            break;
          case AlarmRecurrence.weekly:
            matchDateTimeComponents = DateTimeComponents.dayOfWeekAndTime;
            break;
          case AlarmRecurrence.monthly:
          case AlarmRecurrence.yearly:
            matchDateTimeComponents = DateTimeComponents.dayOfMonthAndTime;
            // Note: FlutterLocalNotificationsPlugin might not support monthly directly with DateTimeComponents.
            // For monthly, we might need manual rescheduling or use 'dayOfMonthAndTime' if avail.
            // 'dayOfMonthAndTime' is consistent with day of month + time.
            matchDateTimeComponents = DateTimeComponents.dayOfMonthAndTime;
            break;
          default:
            break;
        }

        await _plugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: matchDateTimeComponents,
        );
      }
    } catch (e) {
      if (e.toString().contains('Cannot schedule')) {
        rethrow; // Re-throw our custom message
      }
      throw Exception(
        'Could not schedule reminder. Please check notification settings: $e',
      );
    }
  }

  Future<void> cancel(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (e) {
      throw Exception('Could not cancel reminder notification: $e');
    }
  }

  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      throw Exception('Could not cancel all notifications: $e');
    }
  }
}
