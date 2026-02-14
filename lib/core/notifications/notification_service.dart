// lib/core/notifications/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

/// Enum for alarm recurrence patterns
enum AlarmRecurrence { none, daily, weekdays, weekends, weekly, custom }

/// Extension to convert List<int> to AlarmRecurrence
extension AlarmRecurrenceHelper on List<int> {
  AlarmRecurrence toAlarmRecurrence() {
    if (isEmpty) return AlarmRecurrence.none;
    if (length == 7) return AlarmRecurrence.daily;

    // Check for weekdays (Mon-Fri = 1,2,3,4,5)
    final weekdays = [1, 2, 3, 4, 5];
    if (length == 5 && weekdays.every((d) => contains(d))) {
      return AlarmRecurrence.weekdays;
    }

    // Check for weekends (Sat-Sun = 0,6)
    final weekends = [0, 6];
    if (length == 2 && weekends.every((d) => contains(d))) {
      return AlarmRecurrence.weekends;
    }

    if (length == 1) return AlarmRecurrence.weekly;

    return AlarmRecurrence.custom;
  }
}

/// Extension to convert AlarmRecurrence to List<int>
extension AlarmRecurrenceToList on AlarmRecurrence {
  List<int> toRepeatDays() {
    switch (this) {
      case AlarmRecurrence.none:
        return [];
      case AlarmRecurrence.daily:
        return [0, 1, 2, 3, 4, 5, 6]; // All days
      case AlarmRecurrence.weekdays:
        return [1, 2, 3, 4, 5]; // Mon-Fri
      case AlarmRecurrence.weekends:
        return [0, 6]; // Sat-Sun
      case AlarmRecurrence.weekly:
        // For weekly, we need the day of week from the scheduled time
        // But since we don't have that here, return empty for now
        // This should be handled by the caller
        return [];
      case AlarmRecurrence.custom:
        // Custom should be handled by weekDays field
        return [];
    }
  }
}

/// Abstract notification service interface
/// Implement this for actual platform notifications
abstract class NotificationService {
  /// Schedule a notification
  ///
  /// [id] - Unique notification ID
  /// [title] - Notification title
  /// [body] - Notification body text
  /// [scheduledTime] - When to show the notification
  /// [repeatDays] - Days to repeat (0=Sun, 1=Mon, ..., 6=Sat), empty for one-time
  /// [payload] - Optional data to pass when notification is tapped
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    List<int>? repeatDays,
    String? payload,
  });

  /// Cancel a scheduled notification
  Future<void> cancel(int id);

  /// Cancel all notifications
  Future<void> cancelAll();

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled();

  /// Request notification permission
  Future<bool> requestPermission();

  /// Get all pending notifications
  Future<List<PendingNotification>> getPendingNotifications();
}

/// Pending notification info
class PendingNotification {
  final int id;
  final String? title;
  final String? body;
  final DateTime? scheduledTime;

  PendingNotification({
    required this.id,
    this.title,
    this.body,
    this.scheduledTime,
  });
}

/// Mock implementation for testing
class MockNotificationService implements NotificationService {
  final List<Map<String, dynamic>> scheduledNotifications = [];

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    List<int>? repeatDays,
    String? payload,
  }) async {
    // Remove existing notification with same ID
    scheduledNotifications.removeWhere((n) => n['id'] == id);

    scheduledNotifications.add({
      'id': id,
      'title': title,
      'body': body,
      'scheduledTime': scheduledTime,
      'repeatDays': repeatDays ?? [],
      'payload': payload,
    });
  }

  @override
  Future<void> cancel(int id) async {
    scheduledNotifications.removeWhere((n) => n['id'] == id);
  }

  @override
  Future<void> cancelAll() async {
    scheduledNotifications.clear();
  }

  @override
  Future<bool> areNotificationsEnabled() async => true;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<List<PendingNotification>> getPendingNotifications() async {
    return scheduledNotifications
        .map(
          (n) => PendingNotification(
            id: n['id'] as int,
            title: n['title'] as String?,
            body: n['body'] as String?,
            scheduledTime: n['scheduledTime'] as DateTime?,
          ),
        )
        .toList();
  }
}

/// Concrete implementation using flutter_local_notifications
class LocalNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
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

    await _plugin.initialize(settings);
  }

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    List<int>? repeatDays,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'reminders',
      'Reminders',
      channelDescription: 'Reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    final details = NotificationDetails(android: androidDetails);

    final scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

    if (repeatDays != null && repeatDays.isNotEmpty) {
      // For repeating notifications, use matchDateTimeComponents
      DateTimeComponents? matchDateTimeComponents;
      if (repeatDays.length == 7) {
        // Daily
        matchDateTimeComponents = DateTimeComponents.time;
      } else if (repeatDays.length == 1) {
        // Weekly
        matchDateTimeComponents = DateTimeComponents.dayOfWeekAndTime;
      } else {
        // Custom - for now, treat as daily if not empty
        matchDateTimeComponents = DateTimeComponents.time;
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
        payload: payload,
      );
    } else {
      // One-time notification
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    }
  }

  @override
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  @override
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    return await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.areNotificationsEnabled() ??
        false;
  }

  @override
  Future<bool> requestPermission() async {
    // For Android, permissions are usually handled at install time
    // For iOS, use the main plugin
    final iosImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (iosImplementation != null) {
      return await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    // For Android, assume permission is granted (handled at install time)
    return true;
  }

  @override
  Future<List<PendingNotification>> getPendingNotifications() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending
        .map(
          (p) => PendingNotification(
            id: p.id,
            title: p.title,
            body: p.body,
            // Note: flutter_local_notifications doesn't provide scheduled time in pending requests
          ),
        )
        .toList();
  }
}
