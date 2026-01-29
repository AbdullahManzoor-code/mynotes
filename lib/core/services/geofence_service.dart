import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mynotes/domain/entities/location_reminder_model.dart';
import 'package:mynotes/data/repositories/location_reminder_repository.dart';
import 'package:mynotes/core/services/location_notification_service.dart';
import 'package:mynotes/core/exceptions/location_exceptions.dart';

/// Geofence Manager
/// Handles geofencing logic with comprehensive error handling
/// Testable with injected dependencies
class GeofenceManager {
  static final GeofenceManager _instance = GeofenceManager._internal();
  factory GeofenceManager({
    LocationReminderRepository? repository,
    LocationNotificationService? notificationService,
  }) => _instance;

  static GeofenceManager get instance => _instance;

  GeofenceManager._internal({
    LocationReminderRepository? repository,
    LocationNotificationService? notificationService,
  }) : _repository = repository ?? LocationReminderRepository(),
       _notificationService =
           notificationService ?? LocationNotificationService();

  final LocationReminderRepository _repository;
  final LocationNotificationService _notificationService;
  StreamSubscription<Position>? _positionSubscription;
  final Map<String, GeofenceState> _geofenceStates = {};
  bool _isInitialized = false;
  bool _isMonitoring = false;

  // Callbacks for testing and interactivity
  void Function(GeofenceEvent)? onGeofenceEvent;
  void Function(String)? onError;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _isInitialized = true;
      debugPrint('[GeofenceManager] Initialized');
    } catch (e, stackTrace) {
      final error = GeofenceException(
        message: 'Failed to initialize GeofenceManager',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      rethrow;
    }
  }

  // Register a geofence for a location reminder
  Future<void> registerGeofence(LocationReminder reminder) async {
    try {
      if (!reminder.isActive) {
        debugPrint(
          '[GeofenceManager] Skipping inactive reminder: ${reminder.id}',
        );
        return;
      }

      _geofenceStates[reminder.id] = GeofenceState.exit;
      onGeofenceEvent?.call(
        GeofenceEvent(
          type: 'registered',
          reminderId: reminder.id,
          message:
              'Geofence registered at (${reminder.latitude}, ${reminder.longitude})',
        ),
      );
      debugPrint(
        '[GeofenceManager] Registered: ${reminder.id} at (${reminder.latitude}, ${reminder.longitude}) radius ${reminder.radius}m',
      );
    } catch (e, stackTrace) {
      final error = GeofenceException(
        message: 'Failed to register geofence for reminder ${reminder.id}',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[GeofenceManager] Error: ${error.message}');
    }
  }

  // Unregister a geofence
  Future<void> unregisterGeofence(String reminderId) async {
    try {
      if (!_geofenceStates.containsKey(reminderId)) {
        debugPrint('[GeofenceManager] Reminder not found: $reminderId');
        return;
      }

      _geofenceStates.remove(reminderId);
      onGeofenceEvent?.call(
        GeofenceEvent(
          type: 'unregistered',
          reminderId: reminderId,
          message: 'Geofence unregistered',
        ),
      );
      debugPrint('[GeofenceManager] Unregistered: $reminderId');
    } catch (e, stackTrace) {
      final error = GeofenceException(
        message: 'Failed to unregister geofence $reminderId',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
    }
  }

  // Start geofence monitoring
  Future<void> startMonitoring() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isMonitoring) {
      debugPrint('[GeofenceManager] Already monitoring');
      return;
    }

    if (_isMonitoring) {
      debugPrint('[GeofenceManager] Already monitoring');
      return;
    }

    _isMonitoring = true;

    try {
      // Get initial position
      try {
        final position = await Geolocator.getCurrentPosition();
        await _checkGeofences(position);
      } on LocationServiceDisabledException {
        final error = LocationServiceException(
          message: 'Location service is disabled',
          code: 'LOCATION_DISABLED',
        );
        onError?.call(error.message);
        debugPrint('[GeofenceManager] Location service disabled');
        _isMonitoring = false;
        return;
      } on LocationPermission {
        final error = LocationPermissionException(
          message: 'Location permission denied',
          code: 'PERMISSION_DENIED',
        );
        onError?.call(error.message);
        debugPrint('[GeofenceManager] Location permission denied');
        _isMonitoring = false;
        return;
      }

      // Start listening to position updates
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50, // Check every 50 meters
        timeLimit: Duration(seconds: 30),
      );

      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen(
            (Position position) async {
              try {
                await _checkGeofences(position);
              } catch (e, stackTrace) {
                final error = GeofenceException(
                  message: 'Error checking geofences',
                  originalError: e,
                  stackTrace: stackTrace,
                );
                onError?.call(error.message);
                debugPrint('[GeofenceManager] Check error: ${error.message}');
              }
            },
            onError: (error, stackTrace) {
              final posError = LocationServiceException(
                message: 'Position stream error',
                originalError: error,
                stackTrace: stackTrace,
              );
              onError?.call(posError.message);
              debugPrint('[GeofenceManager] Stream error: ${posError.message}');
              _isMonitoring = false;
            },
          );

      onGeofenceEvent?.call(
        GeofenceEvent(
          type: 'started',
          message:
              'Monitoring started - ${_geofenceStates.length} geofences active',
        ),
      );
      debugPrint('[GeofenceManager] Monitoring started');
    } catch (e, stackTrace) {
      _isMonitoring = false;
      final error = GeofenceException(
        message: 'Failed to start monitoring',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[GeofenceManager] Start error: ${error.message}');
    }
  }

  // Stop geofence monitoring
  Future<void> stopMonitoring() async {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isMonitoring = false;
    debugPrint('Stopped geofence monitoring');
  }

  // Check all geofences against current position
  Future<void> _checkGeofences(Position position) async {
    final reminders = await _repository.getActiveLocationReminders();

    for (final reminder in reminders) {
      final previousState = _geofenceStates[reminder.id] ?? GeofenceState.exit;
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        reminder.latitude,
        reminder.longitude,
      );

      final isWithinRadius = distance <= reminder.radius;
      final currentState = isWithinRadius
          ? GeofenceState.enter
          : GeofenceState.exit;

      _geofenceStates[reminder.id] = currentState;

      bool shouldTrigger = false;

      // Check if we should trigger based on reminder type
      if (reminder.triggerType == LocationTriggerType.arrive) {
        // Trigger when entering
        if (previousState == GeofenceState.exit &&
            currentState == GeofenceState.enter) {
          shouldTrigger = true;
        }
      } else if (reminder.triggerType == LocationTriggerType.leave) {
        // Trigger when exiting
        if (previousState == GeofenceState.enter &&
            currentState == GeofenceState.exit) {
          shouldTrigger = true;
        }
      }

      if (shouldTrigger) {
        await _triggerReminder(reminder);
      }
    }
  }

  // Trigger the reminder notification
  Future<void> _triggerReminder(LocationReminder reminder) async {
    try {
      debugPrint('[GeofenceManager] Triggering: ${reminder.message}');

      // Update last triggered
      final updatedReminder = reminder.copyWith(lastTriggered: DateTime.now());
      await _repository.updateLocationReminder(updatedReminder);

      // Show notification
      try {
        await _notificationService.showLocationReminderNotification(
          reminder: reminder,
        );
      } catch (e, stackTrace) {
        final error = NotificationException(
          message: 'Failed to show notification',
          originalError: e,
          stackTrace: stackTrace,
        );
        onError?.call(error.message);
        debugPrint('[GeofenceManager] Notification error: ${error.message}');
      }

      onGeofenceEvent?.call(
        GeofenceEvent(
          type: 'triggered',
          reminderId: reminder.id,
          message: 'Reminder triggered: ${reminder.message}',
        ),
      );
    } catch (e, stackTrace) {
      final error = GeofenceException(
        message: 'Failed to trigger reminder ${reminder.id}',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[GeofenceManager] Trigger error: ${error.message}');
    }
  }

  // Refresh all geofences (call after adding/removing/updating reminders)
  Future<void> refreshGeofences() async {
    try {
      await stopMonitoring();
      _geofenceStates.clear();

      final reminders = await _repository.getActiveLocationReminders();
      for (final reminder in reminders) {
        await registerGeofence(reminder);
      }

      await startMonitoring();
      debugPrint(
        '[GeofenceManager] Geofences refreshed: ${reminders.length} active',
      );
    } catch (e, stackTrace) {
      final error = GeofenceException(
        message: 'Failed to refresh geofences',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[GeofenceManager] Refresh error: ${error.message}');
    }
  }

  void dispose() {
    try {
      stopMonitoring();
      debugPrint('[GeofenceManager] Disposed');
    } catch (e) {
      debugPrint('[GeofenceManager] Error during dispose: $e');
    }
  }
}

enum GeofenceState { enter, exit }

class GeofenceEvent {
  final String type; // 'registered', 'unregistered', 'triggered', 'started'
  final String? reminderId;
  final String message;
  final DateTime timestamp;

  GeofenceEvent({
    required this.type,
    this.reminderId,
    required this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => 'GeofenceEvent($type): $message';
}
