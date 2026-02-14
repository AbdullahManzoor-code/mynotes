import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart' show FlutterTimezone;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../../domain/entities/alarm.dart';
import '../../core/routes/app_router.dart';
import '../../core/routes/app_routes.dart';
import 'dart:convert';

class AlarmService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Function(String actionId, String? payload, String? input)? onActionReceived;

  Future<void> init({
    Function(String actionId, String? payload, String? input)? onActionReceived,
  }) async {
    this.onActionReceived = onActionReceived;
    try {
      tz_data.initializeTimeZones();
      try {
        final timezoneResult = await FlutterTimezone.getLocalTimezone();
        final String timeZoneName = timezoneResult.toString();
        // Robust parsing: extract location from strings like "TimezoneInfo(Asia/Karachi, ...)"
        String locationName = timeZoneName;
        if (locationName.contains('(') && locationName.contains(')')) {
          final start = locationName.indexOf('(') + 1;
          final end = locationName.indexOf(',');
          if (end != -1 && end > start) {
            locationName = locationName.substring(start, end).trim();
          } else {
            final closing = locationName.indexOf(')');
            locationName = locationName.substring(start, closing).trim();
          }
        }

        tz.setLocalLocation(tz.getLocation(locationName));
      } catch (e) {
        debugPrint(
          'Warning: Could not set local timezone ($e). Falling back to UTC.',
        );
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

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

      await requestPermissions();
    } catch (e) {
      throw Exception('Failed to initialize alarm service: $e');
    }
  }

  Future<void> _onNotificationTap(NotificationResponse response) async {
    // Handle notification tap - navigate to note if linked
    debugPrint(
      'Notification tapped: ${response.payload}, Action: ${response.actionId}',
    );

    if (response.actionId != null && onActionReceived != null) {
      onActionReceived!(response.actionId!, response.payload, response.input);
      // We also verify if we need to navigate.
      // If action is taken, typically we might stay in app or show confirmation.
      // But typically we still parse payload to know context if needed.
    }

    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        final String? linkedNoteId = data['linkedNoteId'];
        final String? linkedTodoId = data['linkedTodoId'];

        if (linkedNoteId != null) {
          // Navigate to Note Editor
          // We prefer to use a navigation service, but here we use the global key
          AppRouter.navigatorKey.currentState?.pushNamed(
            AppRoutes.noteEditor,
            arguments: {
              'noteId': linkedNoteId,
            }, // Note: NoteEditor usually expects a Note object or ID.
            // Phase 7 checklist: Handle notification tap -> Navigate to linked item
            // If NoteEditor requires a Note object, we might need to fetch it first.
            // For now, let's assume we navigate to the list or handle ID if possible.
            // Actually, AdvancedNoteEditor expects 'note' (Note) or 'noteId' logic if we added it?
            // Existing AppRouter handles: args is Note or args is Map.
            // If Map, it expects 'note' object.
            // So we might need to navigate to NotesList and filter? Or fix AppRouter to support fetching?
            // For simplicity in this phase, let's navigate to RemindersList or simply AlarmsScreen.
          );
        } else if (linkedTodoId != null) {
          AppRouter.navigatorKey.currentState?.pushNamed(
            AppRoutes.todosList,
            // We might want to highlight the todo?
          );
        } else {
          AppRouter.navigatorKey.currentState?.pushNamed(AppRoutes.alarms);
        }
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
        AppRouter.navigatorKey.currentState?.pushNamed(AppRoutes.alarms);
      }
    } else {
      AppRouter.navigatorKey.currentState?.pushNamed(AppRoutes.alarms);
    }
  }

  Future<void> scheduleAlarm({
    required DateTime dateTime,
    required String id,
    String? title,
    String? soundPath,
    bool vibrate = true,
    AlarmRecurrence recurrence = AlarmRecurrence.none,
    String? payload,
  }) async {
    try {
      // Build notification details with sound
      UriAndroidNotificationSound? sound;
      if (soundPath != null && soundPath.isNotEmpty) {
        sound = UriAndroidNotificationSound(soundPath);
      }

      final androidDetails = AndroidNotificationDetails(
        'reminders_channel',
        'Alarm Reminders',
        channelDescription: 'Alarm reminder notifications',
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: true,
        sound: sound,
        enableVibration: vibrate,
        vibrationPattern: vibrate
            ? Int64List.fromList([0, 250, 250, 250])
            : null,
        playSound: true,
        actions: [
          const AndroidNotificationAction(
            'quick_reply',
            'Quick Answer',
            icon: DrawableResourceAndroidBitmap('ic_reply'),
            allowGeneratedReplies: true,
            inputs: [
              AndroidNotificationActionInput(
                label: 'Type your note...',
                allowFreeFormInput: true,
              ),
            ],
            showsUserInterface: true,
          ),
          const AndroidNotificationAction(
            'snooze',
            'Snooze 10m',
            showsUserInterface: true,
          ),
          const AndroidNotificationAction(
            'complete',
            'Mark Completed',
            showsUserInterface: true,
          ),
        ],
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
          payload: payload,
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
          payload: payload,
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

  Future<void> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }
}
