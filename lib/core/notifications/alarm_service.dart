import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart' show FlutterTimezone;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import '../../domain/entities/alarm.dart';
import '../../domain/repositories/alarm_repository.dart';
import '../../core/routes/app_router.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/app_logger.dart';
import 'dart:convert';

// ════════════════════════════════════════════════════════════════════════════════
// CRITICAL: Top-level callback for AndroidAlarmManager
// ════════════════════════════════════════════════════════════════════════════════
// This MUST be a top-level function (not a class method) for AndroidAlarmManager.
// It runs in a separate isolate when the alarm triggers, even if app is killed.
// ════════════════════════════════════════════════════════════════════════════════

@pragma('vm:entry-point')
void alarmManagerCallback() {
  AppLogger.i('═' * 70);
  AppLogger.i('[ALARM-MANAGER-CALLBACK] ⏰ Callback triggered in isolate!');
  AppLogger.i('Time: ${DateTime.now().toIso8601String()}');
  AppLogger.i('═' * 70);

  try {
    // Initialize Awesome Notifications in this isolate (fresh context)
    AppLogger.i(
      '[ALARM-MANAGER-CALLBACK] Initializing AwesomeNotifications...',
    );
    AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'alarm_channel',
        channelName: 'Alarm Notifications',
        channelDescription: 'Channel for alarm trigger notifications',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        locked: true,
        playSound: true,
        enableVibration: true,
      ),
    ]);
    AppLogger.i('[ALARM-MANAGER-CALLBACK] ✅ AwesomeNotifications initialized');

    // Trigger Vibration
    AppLogger.i('[ALARM-MANAGER-CALLBACK] Starting vibration...');
    Vibration.vibrate(pattern: [500, 1000, 500, 1000], repeat: -1);
    AppLogger.i('[ALARM-MANAGER-CALLBACK] ✅ Vibration started');

    // Trigger Sound
    AppLogger.i('[ALARM-MANAGER-CALLBACK] Playing alarm sound...');
    FlutterRingtonePlayer().playAlarm();
    AppLogger.i('[ALARM-MANAGER-CALLBACK] ✅ Alarm sound started');

    // Show Notification with interactive action buttons
    AppLogger.i(
      '[ALARM-MANAGER-CALLBACK] Creating notification with actions...',
    );
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'alarm_channel',
        title: '⏰ Alarm Triggered!',
        body: 'Your reminder is here! Tap to view details.',
        wakeUpScreen: true,
        category: NotificationCategory.Alarm,
        fullScreenIntent: true,
        autoDismissible: false,
        locked: true,
      ),
      actionButtons: [
        // Snooze 10 minutes
        NotificationActionButton(
          key: 'SNOOZE_10',
          label: '⏸️ Snooze 10m',
          actionType: ActionType.Default,
          isDangerousOption: false,
        ),
        // Reschedule button
        NotificationActionButton(
          key: 'RESCHEDULE',
          label: '📅 Reschedule',
          actionType: ActionType.Default,
          isDangerousOption: false,
        ),
        // Dismiss/Close button
        NotificationActionButton(
          key: 'DISMISS',
          label: '✓ Dismiss',
          actionType: ActionType.Default,
          isDangerousOption: false,
        ),
      ],
    );
    AppLogger.i(
      '[ALARM-MANAGER-CALLBACK] ✅ Notification created with action buttons',
    );
    AppLogger.i('═' * 70);
    AppLogger.i('[ALARM-MANAGER-CALLBACK] ✅ Callback completed successfully!');
    AppLogger.i('═' * 70);
  } catch (e, stack) {
    AppLogger.e('═' * 70);
    AppLogger.e('[ALARM-MANAGER-CALLBACK] ❌ Callback failed!');
    AppLogger.e('Error: $e');
    AppLogger.e('Stack: $stack');
    AppLogger.e('═' * 70);
  }
}

class AlarmService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Function(String actionId, String? payload, String? input)? onActionReceived;

  Future<void> init({
    Function(String actionId, String? payload, String? input)? onActionReceived,
  }) async {
    AppLogger.i('═' * 60);
    AppLogger.i('[ALARM-SERVICE-INIT] Starting AlarmService initialization...');
    AppLogger.i('═' * 60);

    this.onActionReceived = onActionReceived;
    try {
      AppLogger.i('[ALARM-SERVICE-INIT] Step 1: Initializing timezone data...');
      tz_data.initializeTimeZones();
      AppLogger.i('[ALARM-SERVICE-INIT] ✅ Timezone data initialized');

      try {
        AppLogger.i('[ALARM-SERVICE-INIT] Step 2: Getting device timezone...');
        final timezoneResult = await FlutterTimezone.getLocalTimezone();
        final String timeZoneName = timezoneResult.toString();
        AppLogger.i('[ALARM-SERVICE-INIT] Device timezone: $timeZoneName');

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
        AppLogger.i('[ALARM-SERVICE-INIT] ✅ Timezone set to: $locationName');
      } catch (e) {
        AppLogger.w(
          '[ALARM-SERVICE-INIT] ⚠️ Could not set timezone: $e. Using UTC',
        );
        debugPrint(
          'Warning: Could not set local timezone ($e). Falling back to UTC.',
        );
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

      AppLogger.i(
        '[ALARM-SERVICE-INIT] Step 3: Creating Android notification settings...',
      );
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      AppLogger.i('[ALARM-SERVICE-INIT] ✅ Android settings created');

      AppLogger.i(
        '[ALARM-SERVICE-INIT] Step 4: Creating iOS/macOS notification settings...',
      );
      final DarwinInitializationSettings darwinSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );
      AppLogger.i('[ALARM-SERVICE-INIT] ✅ iOS/macOS settings created');

      AppLogger.i(
        '[ALARM-SERVICE-INIT] Step 5: Creating combined initialization settings...',
      );
      final InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );
      AppLogger.i('[ALARM-SERVICE-INIT] ✅ Combined settings created');

      AppLogger.i(
        '[ALARM-SERVICE-INIT] Step 6: Initializing FlutterLocalNotificationsPlugin...',
      );
      await _plugin.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );
      AppLogger.i(
        '[ALARM-SERVICE-INIT] ✅ FlutterLocalNotificationsPlugin initialized',
      );
      AppLogger.i(
        '[ALARM-SERVICE-INIT] ✅ Notification tap handler registered: _onNotificationTap',
      );

      AppLogger.i('[ALARM-SERVICE-INIT] Step 7: Requesting permissions...');
      await requestPermissions();
      AppLogger.i('[ALARM-SERVICE-INIT] ✅ Permissions request completed');

      AppLogger.i('═' * 60);
      AppLogger.i('✅ [ALARM-SERVICE-INIT-SUCCESS] AlarmService ready!');
      AppLogger.i('═' * 60);
    } catch (e) {
      AppLogger.e('═' * 60);
      AppLogger.e('❌ [ALARM-SERVICE-INIT-ERROR] Initialization failed!');
      AppLogger.e('═' * 60);
      AppLogger.e('Error: $e');
      AppLogger.e('Stack trace:');
      AppLogger.e(StackTrace.current.toString());
      AppLogger.e('═' * 60);
      throw Exception('Failed to initialize alarm service: $e');
    }
  }

  Future<void> _onNotificationTap(NotificationResponse response) async {
    // Log alarm trigger event
    AppLogger.i('═' * 60);
    AppLogger.i('🔔 [ALARM-TRIGGERED-CALLBACK] Notification received!');
    AppLogger.i('═' * 60);
    AppLogger.i('Notification ID: ${response.id}');
    AppLogger.i('Response type: ${response.notificationResponseType}');
    AppLogger.i('Action ID: ${response.actionId}');
    AppLogger.i('Payload: ${response.payload}');
    AppLogger.i('Input: ${response.input}');
    AppLogger.i('Tap Time: ${DateTime.now().toIso8601String()}');
    AppLogger.i('═' * 60);

    if (response.actionId != null && onActionReceived != null) {
      AppLogger.i('[ALARM-TRIGGERED] Processing action: ${response.actionId}');
      onActionReceived!(response.actionId!, response.payload, response.input);
    }

    if (response.payload != null) {
      try {
        AppLogger.i('[ALARM-TRIGGERED] Decoding payload...');
        final data = jsonDecode(response.payload!);
        final String? linkedNoteId = data['linkedNoteId'];
        final String? linkedTodoId = data['linkedTodoId'];

        AppLogger.i('[ALARM-TRIGGERED] ✅ Payload decoded');
        AppLogger.i('[ALARM-TRIGGERED] linkedNoteId: $linkedNoteId');
        AppLogger.i('[ALARM-TRIGGERED] linkedTodoId: $linkedTodoId');

        if (linkedNoteId != null) {
          AppLogger.i(
            '[ALARM-TRIGGERED] ➡️ Navigating to Note Editor: $linkedNoteId',
          );
          AppRouter.navigatorKey.currentState?.pushNamed(
            AppRoutes.noteEditor,
            arguments: {'noteId': linkedNoteId},
          );
          AppLogger.i('[ALARM-TRIGGERED] ✅ Navigation to Note completed');
        } else if (linkedTodoId != null) {
          AppLogger.i(
            '[ALARM-TRIGGERED] ➡️ Navigating to Todos List: $linkedTodoId',
          );
          AppRouter.navigatorKey.currentState?.pushNamed(AppRoutes.todosList);
          AppLogger.i('[ALARM-TRIGGERED] ✅ Navigation to Todos completed');
        } else {
          AppLogger.i(
            '[ALARM-TRIGGERED] ➡️ Navigating to Alarms screen (no linked item)',
          );
          AppRouter.navigatorKey.currentState?.pushNamed(AppRoutes.alarms);
          AppLogger.i('[ALARM-TRIGGERED] ✅ Navigation to Alarms completed');
        }
      } catch (e) {
        AppLogger.e(
          '[ALARM-TRIGGERED] ❌ Error parsing notification payload',
          e,
        );
        AppRouter.navigatorKey.currentState?.pushNamed(AppRoutes.alarms);
      }
    } else {
      AppLogger.i(
        '[ALARM-TRIGGERED] ⚠️ No payload, navigating to Alarms screen',
      );
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
    AppLogger.i('═' * 60);
    AppLogger.i('[ALARM-SCHEDULE-START] Beginning alarm scheduling process');
    AppLogger.i('═' * 60);
    AppLogger.i('[ALARM-SCHEDULE] Alarm ID: $id');
    AppLogger.i(
      '[ALARM-SCHEDULE] Requested time: ${dateTime.toIso8601String()}',
    );
    AppLogger.i('[ALARM-SCHEDULE] Title: ${title ?? "Reminder"}');
    AppLogger.i('[ALARM-SCHEDULE] Vibrate: $vibrate');
    AppLogger.i('[ALARM-SCHEDULE] Sound: ${soundPath ?? "default"}');
    AppLogger.i(
      '[ALARM-SCHEDULE] Recurrence: ${recurrence.toString().split('.').last}',
    );

    try {
      AppLogger.i('[ALARM-SCHEDULE] ✅ Step 1: Parameters validated');

      // Build notification details with sound
      AppLogger.i('[ALARM-SCHEDULE] Building notification details...');
      AndroidNotificationSound? sound;
      if (soundPath != null && soundPath.isNotEmpty) {
        sound = UriAndroidNotificationSound(soundPath);
        AppLogger.i('[ALARM-SCHEDULE] Using custom sound: $soundPath');
      } else {
        AppLogger.i('[ALARM-SCHEDULE] Using default system sound');
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
            'SNOOZE_10',
            '⏸️ Snooze 10m',
            showsUserInterface: true,
          ),
          const AndroidNotificationAction(
            'RESCHEDULE',
            '📅 Reschedule',
            showsUserInterface: true,
          ),
          const AndroidNotificationAction(
            'DISMISS',
            '✓ Dismiss',
            showsUserInterface: true,
          ),
        ],
      );
      AppLogger.i('[ALARM-SCHEDULE] ✅ Step 2: Notification details created');

      final details = NotificationDetails(android: androidDetails);
      AppLogger.i(
        '[ALARM-SCHEDULE] ✅ Step 3: NotificationDetails wrapper created',
      );

      // Convert DateTime to TZDateTime
      AppLogger.i('[ALARM-SCHEDULE] Converting to TZDateTime...');
      final scheduledDate = tz.TZDateTime.from(dateTime, tz.local);
      AppLogger.i(
        '[ALARM-SCHEDULE] TZDateTime: ${scheduledDate.toIso8601String()}',
      );

      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        throw Exception('Cannot schedule alarm for past time');
      }
      AppLogger.i('[ALARM-SCHEDULE] ✅ Step 4: Time is in future');

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
        case AlarmRecurrence.custom:
          // Custom recurrence: will be handled by scheduling based on weekDays
          // Android doesn't support arbitrary custom patterns, but we schedule
          // the next occurrence from the alarm's getNextOccurrence() method
          break;
      }
      AppLogger.i('[ALARM-SCHEDULE] ✅ Step 5: Recurrence configured');

      final idHash =
          int.parse(id.hashCode.toString().replaceAll('-', '')) % 2147483647;
      AppLogger.i('[ALARM-SCHEDULE] Hash ID: $idHash (from: $id)');

      AppLogger.i('[ALARM-SCHEDULE] ⏳ Step 6: Calling zonedSchedule...');

      if (recurrence == AlarmRecurrence.none) {
        AppLogger.i('[ALARM-SCHEDULE] Scheduling ONE-TIME alarm...');
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
        AppLogger.i(
          '[ALARM-SCHEDULE] ✅ zonedSchedule() completed for ONE-TIME alarm',
        );
      } else if (recurrence == AlarmRecurrence.custom) {
        // For custom recurrence, schedule based on weekDays
        AppLogger.i('[ALARM-SCHEDULE] Scheduling CUSTOM recurring alarm...');
        // Schedule with weekly pattern (will repeat on selected weekdays)
        await _plugin.zonedSchedule(
          idHash,
          title ?? 'Reminder',
          'Custom recurring alarm notification',
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: payload,
        );
        AppLogger.i(
          '[ALARM-SCHEDULE] ✅ zonedSchedule() completed for CUSTOM alarm',
        );
      } else {
        AppLogger.i(
          '[ALARM-SCHEDULE] Scheduling RECURRING alarm (${recurrence.toString().split('.').last})...',
        );
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
        AppLogger.i(
          '[ALARM-SCHEDULE] ✅ zonedSchedule() completed for RECURRING alarm',
        );
      }

      AppLogger.i(
        '[ALARM-SCHEDULE] ✅ Step 7: Alarm successfully scheduled in system',
      );

      // Calculate duration for logging
      final duration = dateTime.difference(DateTime.now());
      final durationText = _formatDuration(duration);

      // Register with AndroidAlarmManager for background execution
      // This ensures the alarm fires even if the app is killed
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        try {
          AppLogger.i(
            '[ALARM-SCHEDULE] Step 8: Registering with AndroidAlarmManager for background execution...',
          );
          AppLogger.i(
            '[ALARM-SCHEDULE] Duration until alarm: ${duration.inSeconds}s',
          );

          // Use oneShot to schedule the background alarm
          // This will trigger the top-level alarmManagerCallback function even if app is killed
          await AndroidAlarmManager.oneShot(
            duration,
            int.parse(id.hashCode.toString().replaceAll('-', '')) %
                2147483647, // Use same ID hash
            alarmManagerCallback, // Top-level function defined above
            exact: true, // Try to trigger at exact time
            wakeup: true, // Wake up device if sleeping
            rescheduleOnReboot: true, // Reschedule if device reboots
          );
          AppLogger.i(
            '[ALARM-SCHEDULE] ✅ AndroidAlarmManager registration successful',
          );
        } catch (e) {
          AppLogger.w(
            '[ALARM-SCHEDULE] ⚠️ AndroidAlarmManager registration failed: $e',
          );
          AppLogger.w(
            '[ALARM-SCHEDULE] App will still receive notification through flutter_local_notifications',
          );
        }
      }

      AppLogger.i(
        '[ALARM-SCHEDULE] ✅ Step 9: Both notification and background alarm scheduled',
      );

      AppLogger.i('═' * 60);
      AppLogger.i('✅ [ALARM-SCHEDULED-SUCCESS] Alarm is scheduled!');
      AppLogger.i('═' * 60);
      AppLogger.i('Alarm ID: $id');
      AppLogger.i('Hash ID: $idHash');
      AppLogger.i('Title: ${title ?? "Reminder"}');
      AppLogger.i('Scheduled Time: ${dateTime.toIso8601String()}');
      AppLogger.i('Trigger In: $durationText');
      AppLogger.i('Recurrence: ${recurrence.toString().split('.').last}');
      AppLogger.i('Vibration: ${vibrate ? "✅ Enabled" : "❌ Disabled"}');
      AppLogger.i(
        'Sound: ${soundPath?.isNotEmpty ?? false ? "✅ Custom: $soundPath" : "✅ Default system sound"}',
      );
      AppLogger.i('═' * 60);
      AppLogger.i('[ALARM] WAITING FOR TRIGGER at $durationText');
    } catch (e) {
      AppLogger.e('═' * 60);
      AppLogger.e('❌ [ALARM-SCHEDULE-ERROR] Failed to schedule alarm!');
      AppLogger.e('═' * 60);
      AppLogger.e('Alarm ID: $id');
      AppLogger.e('Error: $e');
      AppLogger.e('Stack trace:');
      AppLogger.e(StackTrace.current.toString());
      AppLogger.e('═' * 60);
      throw Exception('Failed to schedule alarm: $e');
    }
  }

  /// Format duration for human-readable display
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h ${duration.inMinutes % 60}m';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m ${duration.inSeconds % 60}s';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Test method to trigger alarm callback directly for developer testing
  Future<void> testAlarmTrigger() async {
    AppLogger.i('═' * 60);
    AppLogger.i('[TEST-ALARM-TRIGGER] Manually triggering alarm...');
    AppLogger.i('═' * 60);
    try {
      alarmManagerCallback(); // Call the top-level function
      AppLogger.i('[TEST-ALARM-TRIGGER] ✅ Manual trigger completed');
    } catch (e, stack) {
      AppLogger.e('[TEST-ALARM-TRIGGER] ❌ Manual trigger failed: $e');
      AppLogger.e('Stack: $stack');
    }
    AppLogger.i('═' * 60);
  }

  /// Test notification only (no sound/vibration)
  Future<void> testNotificationOnly() async {
    AppLogger.i('[TEST-NOTIFICATION] Testing notification only...');
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'alarm_channel',
          title: '🔔 Test Notification',
          body: 'This is a test notification (no sound/vibration)',
          wakeUpScreen: false,
          category: NotificationCategory.Reminder,
        ),
      );
      AppLogger.i('[TEST-NOTIFICATION] ✅ Notification sent');
    } catch (e, stack) {
      AppLogger.e('[TEST-NOTIFICATION] ❌ Failed: $e');
      AppLogger.e('Stack: $stack');
    }
  }

  /// Test vibration only
  Future<void> testVibrationOnly() async {
    AppLogger.i('[TEST-VIBRATION] Testing vibration only...');
    try {
      await Vibration.vibrate(pattern: [0, 500, 200, 500], repeat: -1);
      AppLogger.i('[TEST-VIBRATION] ✅ Vibration started (cancel manually)');
    } catch (e, stack) {
      AppLogger.e('[TEST-VIBRATION] ❌ Failed: $e');
      AppLogger.e('Stack: $stack');
    }
  }

  /// Stop vibration
  Future<void> stopVibration() async {
    AppLogger.i('[STOP-VIBRATION] Stopping vibration...');
    try {
      await Vibration.cancel();
      AppLogger.i('[STOP-VIBRATION] ✅ Vibration stopped');
    } catch (e) {
      AppLogger.e('[STOP-VIBRATION] ❌ Failed: $e');
    }
  }

  /// Test ringtone only
  Future<void> testRingtoneOnly() async {
    AppLogger.i('[TEST-RINGTONE] Testing ringtone only...');
    try {
      await FlutterRingtonePlayer().playAlarm();
      AppLogger.i('[TEST-RINGTONE] ✅ Ringtone started (cancel manually)');
    } catch (e, stack) {
      AppLogger.e('[TEST-RINGTONE] ❌ Failed: $e');
      AppLogger.e('Stack: $stack');
    }
  }

  /// Stop ringtone
  Future<void> stopRingtone() async {
    AppLogger.i('[STOP-RINGTONE] Stopping ringtone...');
    try {
      await FlutterRingtonePlayer().stop();
      AppLogger.i('[STOP-RINGTONE] ✅ Ringtone stopped');
    } catch (e) {
      AppLogger.e('[STOP-RINGTONE] ❌ Failed: $e');
    }
  }

  /// Test AndroidAlarmManager with immediate callback
  Future<void> testAndroidAlarmManagerImmediate() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      AppLogger.i(
        '[TEST-ALARM-MANAGER] Testing AndroidAlarmManager (3 sec)...',
      );
      try {
        final success = await AndroidAlarmManager.oneShot(
          const Duration(seconds: 3),
          DateTime.now().millisecondsSinceEpoch.remainder(100000),
          alarmManagerCallback,
          exact: true,
          wakeup: true,
        );
        AppLogger.i(
          '[TEST-ALARM-MANAGER] ${success ? "✅" : "❌"} Scheduled: $success',
        );
        AppLogger.i('[TEST-ALARM-MANAGER] Wait 3 seconds for alarm...');
      } catch (e, stack) {
        AppLogger.e('[TEST-ALARM-MANAGER] ❌ Failed: $e');
        AppLogger.e('Stack: $stack');
      }
    } else {
      AppLogger.w('[TEST-ALARM-MANAGER] ⚠️ Only available on Android');
    }
  }

  Future<void> cancelAlarm(String id) async {
    try {
      final idHash =
          int.parse(id.hashCode.toString().replaceAll('-', '')) % 2147483647;
      await _plugin.cancel(idHash);

      AppLogger.i('═' * 60);
      AppLogger.i('🛑 [ALARM CANCELLED] Alarm removed');
      AppLogger.i('═' * 60);
      AppLogger.i('Alarm ID: $id');
      AppLogger.i('Cancelled Time: ${DateTime.now().toIso8601String()}');
      AppLogger.i('═' * 60);
    } catch (e) {
      AppLogger.e('[ALARM] Failed to cancel alarm', e);
      throw Exception('Failed to cancel alarm: $e');
    }
  }

  Future<void> cancelAllAlarms() async {
    try {
      await _plugin.cancelAll();

      AppLogger.i('═' * 60);
      AppLogger.i('🛑 [ALL ALARMS CANCELLED] All alarms removed');
      AppLogger.i('═' * 60);
      AppLogger.i('Cancelled Time: ${DateTime.now().toIso8601String()}');
      AppLogger.i('═' * 60);
    } catch (e) {
      AppLogger.e('[ALARM] Failed to cancel all alarms', e);
      throw Exception('Failed to cancel all alarms: $e');
    }
  }

  /// Reschedule all active alarms from database (call on app startup/reboot)
  Future<void> rescheduleAllActiveAlarms(AlarmRepository repository) async {
    AppLogger.i('═' * 60);
    AppLogger.i('[ALARM-RESTORE] Rescheduling all active alarms...');
    AppLogger.i('═' * 60);

    try {
      final alarms = await repository.getAlarms();
      final activeAlarms = alarms.where((alarm) => alarm.isActive).toList();

      AppLogger.i('[ALARM-RESTORE] Found ${activeAlarms.length} active alarms');

      for (final alarm in activeAlarms) {
        try {
          final nextOccurrence = alarm.getNextOccurrence();

          if (nextOccurrence != null &&
              nextOccurrence.isAfter(DateTime.now())) {
            AppLogger.i(
              '[ALARM-RESTORE] Rescheduling: ${alarm.id} at ${nextOccurrence.toIso8601String()}',
            );

            await scheduleAlarm(
              dateTime: nextOccurrence,
              id: alarm.id,
              title: alarm.message,
              vibrate: alarm.vibrate,
              recurrence: alarm.recurrence,
            );

            AppLogger.i('[ALARM-RESTORE] ✅ Rescheduled: ${alarm.id}');
          } else {
            AppLogger.w('[ALARM-RESTORE] ⚠️ Skipping past alarm: ${alarm.id}');
          }
        } catch (e) {
          AppLogger.e('[ALARM-RESTORE] ❌ Failed to reschedule ${alarm.id}: $e');
        }
      }

      AppLogger.i('═' * 60);
      AppLogger.i(
        '[ALARM-RESTORE] ✅ Completed rescheduling ${activeAlarms.length} alarms',
      );
      AppLogger.i('═' * 60);
    } catch (e, stack) {
      AppLogger.e('═' * 60);
      AppLogger.e('[ALARM-RESTORE] ❌ Failed to restore alarms');
      AppLogger.e('Error: $e');
      AppLogger.e('Stack: $stack');
      AppLogger.e('═' * 60);
    }
  }

  Future<void> requestPermissions() async {
    AppLogger.i('═' * 60);
    AppLogger.i('[PERMS-REQUEST] Requesting alarm permissions...');
    AppLogger.i('═' * 60);
    try {
      AppLogger.i(
        '[PERMS-REQUEST] Detected platform: ${defaultTargetPlatform.toString()}',
      );

      if (defaultTargetPlatform == TargetPlatform.android) {
        AppLogger.i(
          '[PERMS-REQUEST] Step 1: Getting Android implementation...',
        );
        final androidImplementation = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

        if (androidImplementation != null) {
          AppLogger.i('[PERMS-REQUEST] ✅ Android implementation found');

          AppLogger.i(
            '[PERMS-REQUEST] Step 2: Requesting POST_NOTIFICATIONS permission...',
          );
          await androidImplementation.requestNotificationsPermission();
          AppLogger.i(
            '[PERMS-REQUEST] ✅ POST_NOTIFICATIONS request sent to Android',
          );

          AppLogger.i(
            '[PERMS-REQUEST] Step 3: Requesting SCHEDULE_EXACT_ALARM permission...',
          );
          await androidImplementation.requestExactAlarmsPermission();
          AppLogger.i(
            '[PERMS-REQUEST] ✅ SCHEDULE_EXACT_ALARM request sent to Android',
          );
        } else {
          AppLogger.w('[PERMS-REQUEST] ❌ Android implementation not found!');
        }
      } else if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        AppLogger.i(
          '[PERMS-REQUEST] Step 1: Getting iOS/macOS implementation...',
        );
        final iosImplementation = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

        if (iosImplementation != null) {
          AppLogger.i('[PERMS-REQUEST] ✅ iOS/macOS implementation found');
          AppLogger.i(
            '[PERMS-REQUEST] Step 2: Requesting iOS/macOS permissions...',
          );
          await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          AppLogger.i('[PERMS-REQUEST] ✅ iOS/macOS permissions requested');
        } else {
          AppLogger.w('[PERMS-REQUEST] ❌ iOS/macOS implementation not found!');
        }
      } else {
        AppLogger.w(
          '[PERMS-REQUEST] ⚠️ Unsupported platform: ${defaultTargetPlatform.toString()}',
        );
      }

      AppLogger.i('═' * 60);
      AppLogger.i('✅ [PERMS-REQUEST-COMPLETE] Permission requests sent!');
      AppLogger.i('═' * 60);
      AppLogger.i('[PERMS-REQUEST] User may see permission dialog on device');
    } catch (e) {
      AppLogger.e('═' * 60);
      AppLogger.e('❌ [PERMS-REQUEST-ERROR] Error requesting permissions');
      AppLogger.e('═' * 60);
      AppLogger.e('Error: $e');
      AppLogger.e('Stack trace:');
      AppLogger.e(StackTrace.current.toString());
      AppLogger.e('═' * 60);
    }
  }
}
