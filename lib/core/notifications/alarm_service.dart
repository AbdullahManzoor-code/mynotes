import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'dart:typed_data';
import '../../domain/entities/alarm.dart';

class AlarmService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

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
        onDidReceiveNotificationResponse: _onNotificationTap,
      );
    } catch (e) {
      throw Exception('Failed to initialize alarm service: $e');
    }
  }

  Future<void> _onNotificationTap(NotificationResponse response) async {
    // Handle notification tap - navigate to note if linked
    // This can be extended to handle deep linking
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<void> scheduleAlarm({
    required DateTime dateTime,
    required String id,
    String? title,
    String? soundPath,
    bool vibrate = true,
    AlarmRecurrence recurrence = AlarmRecurrence.none,
  }) async {
    try {
      // Build notification details with sound
      UriAndroidNotificationSound? sound;
      if (soundPath != null && soundPath.isNotEmpty) {
        sound = UriAndroidNotificationSound(soundPath);
      }

      final androidDetails = AndroidNotificationDetails(
        id,
        'Alarm Reminders',
        channelDescription: 'Alarm reminder notifications',
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: true,
        sound: sound,
        enableVibration: vibrate,
        vibrationPattern: vibrate ? Int64List.fromList([0, 250, 250, 250]) : null,
        playSound: true,
      );

      final details = NotificationDetails(android: androidDetails);

      // Convert DateTime to TZDateTime
      final scheduledDate = tz.TZDateTime.from(dateTime, tz.local);

      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        throw Exception('Cannot schedule alarm for past time');
      }

      // Handle recurrence
      DateTimeComponents? matchDateTimeComponents;
      switch (recurrence) {
        case AlarmRecurrence.daily:
          matchDateTimeComponents = DateTimeComponents.time;
          break;
        case AlarmRecurrence.weekly:
          matchDateTimeComponents = DateTimeComponents.dayOfWeekAndTime;
          break;
        case AlarmRecurrence.monthly:
        case AlarmRecurrence.yearly:
          matchDateTimeComponents = DateTimeComponents.dayOfMonthAndTime;
          break;
        case AlarmRecurrence.none:
          break;
      }

      final idHash =
          int.parse(id.hashCode.toString().replaceAll('-', '')) % 2147483647;

      if (recurrence == AlarmRecurrence.none) {
        await _plugin.zonedSchedule(
          idHash,
          title ?? 'Reminder',
          'Alarm notification',
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } else {
        await _plugin.zonedSchedule(
          idHash,
          title ?? 'Reminder',
          'Recurring alarm notification',
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: matchDateTimeComponents,
        );
      }

      debugPrint('Alarm scheduled: $id at ${dateTime.toString()}');
    } catch (e) {
      throw Exception('Failed to schedule alarm: $e');
    }
  }

  Future<void> cancelAlarm(String id) async {
    try {
      final idHash =
          int.parse(id.hashCode.toString().replaceAll('-', '')) % 2147483647;
      await _plugin.cancel(idHash);
      debugPrint('Alarm cancelled: $id');
    } catch (e) {
      throw Exception('Failed to cancel alarm: $e');
    }
  }

  Future<void> cancelAllAlarms() async {
    try {
      await _plugin.cancelAll();
      debugPrint('All alarms cancelled');
    } catch (e) {
      throw Exception('Failed to cancel all alarms: $e');
    }
  }
}
