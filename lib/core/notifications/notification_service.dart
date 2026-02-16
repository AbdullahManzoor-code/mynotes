// lib/core/notifications/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mynotes/core/services/app_logger.dart' show AppLogger;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:mynotes/core/notifications/alarm_service.dart';
import 'package:mynotes/domain/entities/alarm.dart' show AlarmRecurrence;

/// Extension to convert List<int> to AlarmRecurrence
extension AlarmRecurrenceHelper on List<int> {
  AlarmRecurrence toAlarmRecurrence() {
    if (isEmpty) return AlarmRecurrence.none;
    if (length == 7) return AlarmRecurrence.daily;

    // Check for weekdays (Mon-Fri = 1,2,3,4,5)
    final weekdays = [1, 2, 3, 4, 5];
    if (length == 5 && weekdays.every((d) => contains(d))) {
      return AlarmRecurrence.weekly;
    }

    // Check for weekends (Sat-Sun = 0,6)
    final weekends = [0, 6];
    if (length == 2 && weekends.every((d) => contains(d))) {
      return AlarmRecurrence.weekly;
    }

    // Any other combination of days = custom
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
      case AlarmRecurrence.weekly:
        return [1, 2, 3, 4, 5]; // Mon-Fri
      case AlarmRecurrence.monthly:
        return [0, 6]; // Sat-Sun
      case AlarmRecurrence.yearly:
        // For yearly, return single day (not directly applicable)
        return [];
      case AlarmRecurrence.custom:
        // Custom should be handled by caller with weekDays field
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

/// Concrete implementation using flutter_local_notifications + AlarmService
/// This delegates to AlarmService for background execution support
class LocalNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  late AlarmService _alarmService;

  Future<void> init({AlarmService? alarmService}) async {
    _alarmService = alarmService ?? AlarmService();

    try {
      AppLogger.i(
        '[NOTIFICATION-SERVICE] Initializing LocalNotificationService...',
      );
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
      AppLogger.i(
        '[NOTIFICATION-SERVICE] ✅ LocalNotificationService initialized',
      );
    } catch (e) {
      AppLogger.e('[NOTIFICATION-SERVICE-ERROR] Initialization failed: $e');
      rethrow;
    }
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
    try {
      AppLogger.i(
        '[NOTIFICATION-SERVICE] Scheduling notification via AlarmService...',
      );

      // Determine recurrence from repeatDays
      AlarmRecurrence recurrence = AlarmRecurrence.none;
      if (repeatDays != null && repeatDays.isNotEmpty) {
        if (repeatDays.length == 7) {
          recurrence = AlarmRecurrence.daily;
        } else if (repeatDays.length == 1) {
          recurrence = AlarmRecurrence.weekly;
        } else if (repeatDays.length == 5 &&
            [1, 2, 3, 4, 5].every((d) => repeatDays.contains(d))) {
          recurrence = AlarmRecurrence.weekly;
        } else {
          recurrence = AlarmRecurrence.none;
        }
      }

      // Initialize AlarmService if needed
      try {
        await _alarmService.init();
      } catch (e) {
        AppLogger.w('[NOTIFICATION-SERVICE] AlarmService init error: $e');
      }

      // Delegate to AlarmService for background-capable scheduling
      await _alarmService.scheduleAlarm(
        id: 'notification_$id',
        dateTime: scheduledTime,
        title: title,
        payload: payload,
        vibrate: true,
        recurrence: recurrence,
      );

      AppLogger.i(
        '[NOTIFICATION-SERVICE] ✅ Notification scheduled via AlarmService',
      );
    } catch (e) {
      AppLogger.e('[NOTIFICATION-SERVICE-ERROR] Failed to schedule: $e');
      rethrow;
    }
  }

  @override
  Future<void> cancel(int id) async {
    try {
      AppLogger.i('[NOTIFICATION-SERVICE] Cancelling notification ID: $id');
      await _alarmService.cancelAlarm('notification_$id');
      await _plugin.cancel(id);
      AppLogger.i('[NOTIFICATION-SERVICE] ✅ Notification cancelled');
    } catch (e) {
      AppLogger.e('[NOTIFICATION-SERVICE-ERROR] Failed to cancel: $e');
    }
  }

  @override
  Future<void> cancelAll() async {
    try {
      AppLogger.i('[NOTIFICATION-SERVICE] Cancelling all notifications...');
      await _alarmService.cancelAllAlarms();
      await _plugin.cancelAll();
      AppLogger.i('[NOTIFICATION-SERVICE] ✅ All notifications cancelled');
    } catch (e) {
      AppLogger.e('[NOTIFICATION-SERVICE-ERROR] Failed to cancel all: $e');
    }
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    try {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.areNotificationsEnabled() ??
          false;
    } catch (e) {
      AppLogger.w('[NOTIFICATION-SERVICE] Error checking notifications: $e');
      return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
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
      return true;
    } catch (e) {
      AppLogger.w('[NOTIFICATION-SERVICE] Error requesting permission: $e');
      return false;
    }
  }

  @override
  Future<List<PendingNotification>> getPendingNotifications() async {
    try {
      final pending = await _plugin.pendingNotificationRequests();
      return pending
          .map(
            (p) => PendingNotification(id: p.id, title: p.title, body: p.body),
          )
          .toList();
    } catch (e) {
      AppLogger.e('[NOTIFICATION-SERVICE-ERROR] Failed to get pending: $e');
      return [];
    }
  }
}
