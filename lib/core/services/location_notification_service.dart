import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:mynotes/domain/entities/location_reminder_model.dart';
import 'package:mynotes/core/exceptions/location_exceptions.dart';

/// Event fired when notification is shown
class NotificationEvent {
  final String type; // 'shown', 'tapped', 'cancelled'
  final int notificationId;
  final String reminderId;
  final String message;
  final DateTime timestamp;

  NotificationEvent({
    required this.type,
    required this.notificationId,
    required this.reminderId,
    required this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() =>
      '[NotificationEvent] type=$type, reminderId=$reminderId, message=$message';
}

/// Location Reminder Notification Service
/// Handles notification display for location-based reminders
/// Supports dependency injection for testability
class LocationNotificationService {
  static final LocationNotificationService _instance =
      LocationNotificationService._internal();

  factory LocationNotificationService({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) => _instance;

  LocationNotificationService._internal({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) : _notificationsPlugin =
           notificationsPlugin ?? FlutterLocalNotificationsPlugin() {
    _initializeFlutterLocalNotifications();
  }

  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;

  // Callbacks for interactivity and testing
  void Function(NotificationEvent)? onNotificationEvent;
  void Function(String)? onError;

  /// Initialize Flutter Local Notifications
  Future<void> _initializeFlutterLocalNotifications() async {
    try {
      // Initialize timezone
      tz_data.initializeTimeZones();

      // Android initialization
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      final DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      final InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
            _onDidReceiveBackgroundNotificationResponse,
      );

      _isInitialized = true;
      debugPrint('[NotificationService] Initialized successfully');
    } catch (e, stackTrace) {
      final error = NotificationException(
        message: 'Failed to initialize notifications',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[NotificationService] Init error: ${error.message}');
    }
  }

  /// Initialize notification channels for Android
  Future<void> initializeNotificationChannels() async {
    try {
      if (!_isInitialized) {
        await _initializeFlutterLocalNotifications();
      }

      const AndroidNotificationChannel locationChannel =
          AndroidNotificationChannel(
            'location_reminders',
            'Location Reminders',
            description: 'Notifications for location-based reminders',
            importance: Importance.high,
            enableVibration: true,
            playSound: true,
          );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(locationChannel);

      debugPrint('[NotificationService] Channels initialized');
    } catch (e, stackTrace) {
      final error = NotificationException(
        message: 'Failed to initialize notification channels',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[NotificationService] Channel error: ${error.message}');
    }
  }

  /// Show location reminder notification
  Future<void> showLocationReminderNotification({
    required LocationReminder reminder,
  }) async {
    try {
      if (!_isInitialized) {
        await _initializeFlutterLocalNotifications();
      }

      final String title = reminder.triggerType == LocationTriggerType.arrive
          ? 'Arrived at ${reminder.placeName ?? "location"}'
          : 'Left ${reminder.placeName ?? "location"}';

      final int notificationId = reminder.id.hashCode.abs();

      // Android-specific settings
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'location_reminders',
            'Location Reminders',
            channelDescription: 'Notifications for location-based reminders',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
            autoCancel: true,
            showWhen: true,
          );

      // iOS-specific settings
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        notificationId,
        title,
        reminder.message,
        details,
        payload: 'location_reminder:${reminder.id}',
      );

      onNotificationEvent?.call(
        NotificationEvent(
          type: 'shown',
          notificationId: notificationId,
          reminderId: reminder.id,
          message: title,
        ),
      );

      debugPrint('[NotificationService] Notification shown: $title');
    } on NotificationException {
      rethrow;
    } catch (e, stackTrace) {
      final error = NotificationException(
        message: 'Failed to show notification for ${reminder.id}',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[NotificationService] Show error: ${error.message}');
    }
  }

  /// Schedule a location reminder notification
  Future<void> scheduleLocationReminderNotification({
    required LocationReminder reminder,
    required DateTime scheduledTime,
  }) async {
    try {
      if (!_isInitialized) {
        await _initializeFlutterLocalNotifications();
      }

      final String title = reminder.triggerType == LocationTriggerType.arrive
          ? 'Arrived at ${reminder.placeName ?? "location"}'
          : 'Left ${reminder.placeName ?? "location"}';

      final int notificationId = reminder.id.hashCode.abs();

      // Android-specific settings
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'location_reminders',
            'Location Reminders',
            channelDescription: 'Notifications for location-based reminders',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
            autoCancel: true,
            showWhen: true,
          );

      // iOS-specific settings
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Use timezone to schedule
      final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
        scheduledTime,
        tz.local,
      );

      if (tzScheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
        final error = NotificationException(
          message: 'Cannot schedule notification for past time',
          code: 'INVALID_SCHEDULED_TIME',
        );
        onError?.call(error.message);
        debugPrint('[NotificationService] Schedule error: ${error.message}');
        return;
      }

      await _notificationsPlugin.zonedSchedule(
        notificationId,
        title,
        reminder.message,
        tzScheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'location_reminder:${reminder.id}',
      );

      onNotificationEvent?.call(
        NotificationEvent(
          type: 'scheduled',
          notificationId: notificationId,
          reminderId: reminder.id,
          message: title,
        ),
      );

      debugPrint(
        '[NotificationService] Notification scheduled for $scheduledTime',
      );
    } on NotificationException {
      rethrow;
    } catch (e, stackTrace) {
      final error = NotificationException(
        message: 'Failed to schedule notification for ${reminder.id}',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[NotificationService] Schedule error: ${error.message}');
    }
  }

  /// Cancel a notification
  Future<void> cancelNotification(LocationReminder reminder) async {
    try {
      final int notificationId = reminder.id.hashCode.abs();
      await _notificationsPlugin.cancel(notificationId);

      onNotificationEvent?.call(
        NotificationEvent(
          type: 'cancelled',
          notificationId: notificationId,
          reminderId: reminder.id,
          message: 'Notification cancelled',
        ),
      );

      debugPrint(
        '[NotificationService] Notification cancelled: ${reminder.id}',
      );
    } catch (e, stackTrace) {
      final error = NotificationException(
        message: 'Failed to cancel notification',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[NotificationService] Cancel error: ${error.message}');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('[NotificationService] All notifications cancelled');
    } catch (e, stackTrace) {
      final error = NotificationException(
        message: 'Failed to cancel all notifications',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[NotificationService] Cancel all error: ${error.message}');
    }
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notificationsPlugin.pendingNotificationRequests();
    } catch (e, stackTrace) {
      final error = NotificationException(
        message: 'Failed to get pending notifications',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[NotificationService] Get pending error: ${error.message}');
      return [];
    }
  }

  // Callback for when notification is received while app is in foreground
  static void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    debugPrint(
      'onDidReceiveLocalNotification: id=$id, title=$title, body=$body, payload=$payload',
    );
  }

  // Callback for when user taps notification
  static void _onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) {
    debugPrint(
      'onDidReceiveNotificationResponse: payload=${notificationResponse.payload}',
    );
    // Handle notification tap - can navigate to specific screen
  }

  // Callback for background notification response
  static void _onDidReceiveBackgroundNotificationResponse(
    NotificationResponse notificationResponse,
  ) {
    debugPrint(
      'onDidReceiveBackgroundNotificationResponse: payload=${notificationResponse.payload}',
    );
  }

  /// Dispose resources
  Future<void> dispose() async {
    try {
      await cancelAllNotifications();
      debugPrint('[NotificationService] Disposed');
    } catch (e, stackTrace) {
      final error = NotificationException(
        message: 'Error disposing notification service',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[NotificationService] Dispose error: ${error.message}');
    }
  }
}
