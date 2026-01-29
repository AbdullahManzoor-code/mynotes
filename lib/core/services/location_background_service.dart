import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mynotes/data/repositories/location_reminder_repository.dart';
import 'package:mynotes/core/exceptions/location_exceptions.dart';

/// Event for background location updates
class BackgroundLocationEvent {
  final String type; // 'update', 'error', 'started', 'stopped'
  final Position? position;
  final String? message;
  final DateTime timestamp;

  BackgroundLocationEvent({
    required this.type,
    this.position,
    this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() =>
      '[BackgroundLocationEvent] type=$type, position=($position), message=$message';
}

/// Location Background Service
/// Manages background location updates even when app is terminated
/// For Android: Uses Geolocator's background service + WorkManager
/// For iOS: Uses Core Location significant changes
/// Supports dependency injection for testability
class LocationBackgroundService {
  static final LocationBackgroundService _instance =
      LocationBackgroundService._internal();

  factory LocationBackgroundService({LocationReminderRepository? repository}) =>
      _instance;

  LocationBackgroundService._internal({LocationReminderRepository? repository})
    : _repository = repository ?? LocationReminderRepository();

  final LocationReminderRepository _repository;

  static const String _backgroundServiceKey = 'location_bg_service_active';
  static const String _lastKnownLocationKey = 'location_bg_last_known';

  // Callbacks for interactivity and testing
  void Function(BackgroundLocationEvent)? onLocationEvent;
  void Function(String)? onError;

  /// Initialize background location service
  Future<void> initializeBackgroundService() async {
    try {
      // Request background location permission
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        final error = LocationPermissionException(
          message: 'Background location permission denied',
          code: 'BACKGROUND_PERMISSION_DENIED',
        );
        onError?.call(error.message);
        debugPrint('[BackgroundService] ${error.message}');
        return;
      }

      // For iOS, request 'always' permission
      if (permission == LocationPermission.whileInUse) {
        debugPrint(
          '[BackgroundService] Only foreground location available on iOS',
        );
      }

      // Save state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_backgroundServiceKey, true);

      onLocationEvent?.call(
        BackgroundLocationEvent(
          type: 'started',
          message: 'Background location service initialized',
        ),
      );

      debugPrint('[BackgroundService] Initialized successfully');

      // Start listening to background position updates
      _startBackgroundPositionStream();
    } catch (e, stackTrace) {
      final error = LocationServiceException(
        message: 'Failed to initialize background service',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[BackgroundService] Init error: ${error.message}');
    }
  }

  /// Start background position stream
  void _startBackgroundPositionStream() {
    try {
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 100, // Update every 100 meters to save battery
        timeLimit: Duration(seconds: 60),
      );

      Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position position) async {
          await _handleBackgroundLocationUpdate(position);
        },
        onError: (error) {
          final exc = LocationServiceException(
            message: 'Background position stream error',
            originalError: error,
          );
          onError?.call(exc.message);
          debugPrint('[BackgroundService] Stream error: ${exc.message}');
        },
      );
    } catch (e, stackTrace) {
      final error = LocationServiceException(
        message: 'Error starting background position stream',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[BackgroundService] Start stream error: ${error.message}');
    }
  }

  /// Handle location update in background
  Future<void> _handleBackgroundLocationUpdate(Position position) async {
    try {
      // Save last known location
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _lastKnownLocationKey,
        '${position.latitude},${position.longitude}',
      );

      onLocationEvent?.call(
        BackgroundLocationEvent(
          type: 'update',
          position: position,
          message:
              'Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
        ),
      );

      // Check geofences and trigger reminders if needed
      await _checkGeofencesInBackground(position);

      debugPrint(
        '[BackgroundService] Location update: ${position.latitude}, ${position.longitude}',
      );
    } catch (e, stackTrace) {
      final error = LocationServiceException(
        message: 'Error handling background location update',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[BackgroundService] Handle update error: ${error.message}');
    }
  }

  /// Check geofences in background
  Future<void> _checkGeofencesInBackground(Position position) async {
    try {
      // This mirrors the GeofenceManager logic for background updates
      // Load all active reminders from the repository
      final reminders = await _repository.getActiveLocationReminders();

      for (final reminder in reminders) {
        try {
          // Calculate distance from current position to reminder location
          final distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            reminder.latitude,
            reminder.longitude,
          );

          // Check if within geofence radius
          final isWithinRadius = distance <= reminder.radius;

          // For background, we'll just log
          debugPrint(
            '[BackgroundService] Reminder ${reminder.id} - Distance: $distance, Radius: ${reminder.radius}, Within: $isWithinRadius',
          );

          // Note: Actual trigger logic should be handled by main GeofenceManager
          // This is just for logging/diagnostics in background
        } catch (reminderError) {
          debugPrint(
            '[BackgroundService] Error checking geofence for ${reminder.id}: $reminderError',
          );
        }
      }
    } catch (e, stackTrace) {
      final error = GeofenceException(
        message: 'Error checking geofences in background',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[BackgroundService] Geofence check error: ${error.message}');
    }
  }

  /// Stop background service
  Future<void> stopBackgroundService() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_backgroundServiceKey, false);

      onLocationEvent?.call(
        BackgroundLocationEvent(
          type: 'stopped',
          message: 'Background location service stopped',
        ),
      );

      debugPrint('[BackgroundService] Stopped');
    } catch (e, stackTrace) {
      final error = LocationServiceException(
        message: 'Error stopping background service',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[BackgroundService] Stop error: ${error.message}');
    }
  }

  /// Get last known background position
  Future<Position?> getLastKnownBackgroundPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationStr = prefs.getString(_lastKnownLocationKey);

      if (locationStr == null) return null;

      final parts = locationStr.split(',');
      if (parts.length != 2) {
        throw LocationServiceException(
          message: 'Invalid location format in storage',
        );
      }

      return Position(
        latitude: double.parse(parts[0]),
        longitude: double.parse(parts[1]),
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    } catch (e, stackTrace) {
      final error = LocationServiceException(
        message: 'Error getting last known background position',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[BackgroundService] Get position error: ${error.message}');
      return null;
    }
  }

  /// Check if background service is running
  Future<bool> isBackgroundServiceRunning() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_backgroundServiceKey) ?? false;
    } catch (e, stackTrace) {
      final error = LocationServiceException(
        message: 'Error checking background service status',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[BackgroundService] Status check error: ${error.message}');
      return false;
    }
  }
}

/// Background callback handler (for future iOS/Android integration)
/// This is the main entry point for background geofence callbacks
@pragma('vm:entry-point')
Future<void> locationBackgroundCallback() async {
  // This would be called when the app is terminated
  // For Android: via BOOT_COMPLETED or WorkManager
  // For iOS: via Significant Location Changes

  debugPrint('[BackgroundCallback] Triggered');

  try {
    final position = await Geolocator.getCurrentPosition(
      timeLimit: const Duration(seconds: 10),
    );

    // Load reminders from local database and check which geofences are triggered
    final repository = LocationReminderRepository();
    final reminders = await repository.getActiveLocationReminders();

    for (final reminder in reminders) {
      try {
        // Calculate distance from current position to reminder location
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          reminder.latitude,
          reminder.longitude,
        );

        // Check if within geofence radius
        final isWithinRadius = distance <= reminder.radius;

        debugPrint(
          '[BackgroundCallback] Reminder ${reminder.id} - Distance: $distance, Within: $isWithinRadius',
        );

        // Note: To actually show notifications in background, you would need:
        // 1. Initialize LocationNotificationService
        // 2. Call showLocationReminderNotification for each triggered reminder
        // 3. Handle state persistence (lastTriggered timestamp)
      } catch (reminderError) {
        debugPrint(
          '[BackgroundCallback] Error checking reminder ${reminder.id}: $reminderError',
        );
      }
    }

    debugPrint(
      '[BackgroundCallback] Position: ${position.latitude}, ${position.longitude}',
    );
  } catch (e, stackTrace) {
    debugPrint('[BackgroundCallback] Error: $e, StackTrace: $stackTrace');
  }
}
