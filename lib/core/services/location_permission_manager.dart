import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mynotes/core/exceptions/location_exceptions.dart';

/// Event for permission status changes
class PermissionEvent {
  final String permissionType;
  final PermissionStatus status;
  final DateTime timestamp;

  PermissionEvent({
    required this.permissionType,
    required this.status,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => '[PermissionEvent] $permissionType=$status';
}

/// Location Permission Manager
/// Handles permission requests and status checks for location-based features
/// Supports dependency injection for testability
class LocationPermissionManager {
  static final LocationPermissionManager _instance =
      LocationPermissionManager._internal();

  factory LocationPermissionManager({
    Stream<Map<String, PermissionStatus>>? statusStream,
  }) => _instance;

  LocationPermissionManager._internal({
    Stream<Map<String, PermissionStatus>>? statusStream,
  }) {
    if (statusStream == null) {
      _permissionStatusController =
          StreamController<Map<String, PermissionStatus>>.broadcast();
    }
  }

  late StreamController<Map<String, PermissionStatus>>
  _permissionStatusController;

  Stream<Map<String, PermissionStatus>> get permissionStatusStream =>
      _permissionStatusController.stream;

  // Callbacks for interactivity and testing
  void Function(PermissionEvent)? onPermissionEvent;
  void Function(String)? onError;

  /// Request location permissions
  /// Returns true if both background and foreground permissions are granted
  Future<bool> requestLocationPermissions() async {
    try {
      // Check and request foreground permission
      final foregroundStatus = await _requestForegroundLocation();
      if (foregroundStatus != PermissionStatus.granted) {
        final error = LocationPermissionException(
          message: 'Foreground location permission denied',
          code: 'FOREGROUND_PERMISSION_DENIED',
        );
        onError?.call(error.message);
        debugPrint('[PermissionManager] ${error.message}');
        return false;
      }

      onPermissionEvent?.call(
        PermissionEvent(
          permissionType: 'foreground_location',
          status: foregroundStatus,
        ),
      );

      // Check and request background permission
      final backgroundStatus = await _requestBackgroundLocation();
      if (backgroundStatus != PermissionStatus.granted) {
        final error = LocationPermissionException(
          message: 'Background location permission denied',
          code: 'BACKGROUND_PERMISSION_DENIED',
        );
        onError?.call(error.message);
        debugPrint('[PermissionManager] ${error.message}');
        return false;
      }

      onPermissionEvent?.call(
        PermissionEvent(
          permissionType: 'background_location',
          status: backgroundStatus,
        ),
      );

      debugPrint('[PermissionManager] All location permissions granted');
      await _emitPermissionStatus();
      return true;
    } catch (e, stackTrace) {
      final error = LocationPermissionException(
        message: 'Error requesting location permissions',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[PermissionManager] Request error: ${error.message}');
      return false;
    }
  }

  /// Request foreground location permission
  Future<PermissionStatus> _requestForegroundLocation() async {
    try {
      final status = await Permission.location.request();
      debugPrint('[PermissionManager] Foreground location permission: $status');
      return status;
    } catch (e, stackTrace) {
      final error = LocationPermissionException(
        message: 'Failed to request foreground location permission',
        code: 'FOREGROUND_REQUEST_FAILED',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[PermissionManager] Foreground error: ${error.message}');
      return PermissionStatus.denied;
    }
  }

  /// Request background location permission
  Future<PermissionStatus> _requestBackgroundLocation() async {
    try {
      final status = await Permission.locationAlways.request();
      debugPrint('[PermissionManager] Background location permission: $status');
      return status;
    } catch (e, stackTrace) {
      final error = LocationPermissionException(
        message: 'Failed to request background location permission',
        code: 'BACKGROUND_REQUEST_FAILED',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[PermissionManager] Background error: ${error.message}');
      return PermissionStatus.denied;
    }
  }

  /// Request notification permission (for notification display)
  Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      onPermissionEvent?.call(
        PermissionEvent(permissionType: 'notification', status: status),
      );
      debugPrint('[PermissionManager] Notification permission: $status');
      return status.isGranted;
    } on LocationPermissionException {
      rethrow;
    } catch (e, stackTrace) {
      final error = LocationPermissionException(
        message: 'Failed to request notification permission',
        code: 'NOTIFICATION_REQUEST_FAILED',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[PermissionManager] Notification error: ${error.message}');
      return false;
    }
  }

  /// Check if location permission is granted
  Future<bool> isLocationPermissionGranted() async {
    try {
      final status = await Permission.location.status;
      return status.isGranted;
    } catch (e, stackTrace) {
      final error = LocationPermissionException(
        message: 'Error checking location permission',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[PermissionManager] Check location error: ${error.message}');
      return false;
    }
  }

  /// Check if background location permission is granted
  Future<bool> isBackgroundLocationPermissionGranted() async {
    try {
      final status = await Permission.locationAlways.status;
      return status.isGranted;
    } catch (e, stackTrace) {
      final error = LocationPermissionException(
        message: 'Error checking background location permission',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint(
        '[PermissionManager] Check background error: ${error.message}',
      );
      return false;
    }
  }

  /// Check if notification permission is granted
  Future<bool> isNotificationPermissionGranted() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e, stackTrace) {
      final error = LocationPermissionException(
        message: 'Error checking notification permission',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint(
        '[PermissionManager] Check notification error: ${error.message}',
      );
      return false;
    }
  }

  /// Check location service availability
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e, stackTrace) {
      final error = LocationServiceException(
        message: 'Error checking location service availability',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[PermissionManager] Service check error: ${error.message}');
      return false;
    }
  }

  /// Get all permission statuses
  Future<Map<String, PermissionStatus>> getAllPermissionStatus() async {
    try {
      final statuses = {
        'location': await Permission.location.status,
        'locationAlways': await Permission.locationAlways.status,
        'notification': await Permission.notification.status,
      };
      return statuses;
    } catch (e, stackTrace) {
      final error = LocationPermissionException(
        message: 'Error getting all permission statuses',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[PermissionManager] Get all error: ${error.message}');
      return {};
    }
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    try {
      await openAppSettings();
      debugPrint('[PermissionManager] Opened app settings');
    } catch (e, stackTrace) {
      final error = LocationPermissionException(
        message: 'Error opening app settings',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[PermissionManager] Settings error: ${error.message}');
    }
  }

  /// Check if all required permissions are granted
  Future<bool> areAllPermissionsGranted() async {
    try {
      final locationGranted = await isLocationPermissionGranted();
      final backgroundGranted = await isBackgroundLocationPermissionGranted();
      final notificationGranted = await isNotificationPermissionGranted();

      return locationGranted && backgroundGranted && notificationGranted;
    } catch (e, stackTrace) {
      final error = LocationPermissionException(
        message: 'Error checking all permissions',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[PermissionManager] Check all error: ${error.message}');
      return false;
    }
  }

  /// Emit current permission status
  Future<void> _emitPermissionStatus() async {
    try {
      final statuses = await getAllPermissionStatus();
      if (statuses.isNotEmpty) {
        _permissionStatusController.add(statuses);
      }
    } catch (e, stackTrace) {
      final error = LocationPermissionException(
        message: 'Error emitting permission status',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[PermissionManager] Emit error: ${error.message}');
    }
  }

  /// Get permission description
  static String getPermissionDescription(String permission) {
    switch (permission) {
      case 'location':
        return 'This app needs access to your location to create location-based reminders.';
      case 'locationAlways':
        return 'This app needs always-on location access to trigger reminders even when the app is closed.';
      case 'notification':
        return 'This app needs permission to send you notifications when you enter or leave a location.';
      default:
        return 'This app needs additional permissions.';
    }
  }

  /// Dispose resources
  void dispose() {
    try {
      _permissionStatusController.close();
      debugPrint('[PermissionManager] Disposed');
    } catch (e, stackTrace) {
      final error = LocationPermissionException(
        message: 'Error disposing permission manager',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      debugPrint('[PermissionManager] Dispose error: ${error.message}');
    }
  }
}
