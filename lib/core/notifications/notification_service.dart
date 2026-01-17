import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );
    await _plugin.initialize(settings);
  }

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    DateTime? scheduledTime,
  }) async {
    final android = AndroidNotificationDetails(
      'notes_channel',
      'Notes',
      channelDescription: 'Notifications for notes',
      importance: Importance.max,
      priority: Priority.high,
    );
    final details = NotificationDetails(android: android);

    // Convert DateTime to TZDateTime
    final finalScheduledTime = scheduledTime ?? DateTime.now();
    final scheduledDate = tz.TZDateTime.from(finalScheduledTime, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
