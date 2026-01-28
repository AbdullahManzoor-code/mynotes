import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class AlarmService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize plugin if needed
  }

  Future<void> scheduleAlarm({
    required DateTime dateTime,
    required String id,
    String? title,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      id,
      'Alarm',
      channelDescription: 'Alarm reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    final details = NotificationDetails(android: androidDetails);

    // Convert DateTime to TZDateTime
    final scheduledDate = tz.TZDateTime.from(dateTime, tz.local);

    await _plugin.zonedSchedule(
      int.tryParse(id.hashCode.toString()) ?? 0,
      title ?? 'Reminder',
      'Alarm for note',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAlarm(String id) async {
    await _plugin.cancel(int.tryParse(id.hashCode.toString()) ?? 0);
  }
}

