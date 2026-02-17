import 'dart:async';
import 'package:mynotes/core/services/app_logger.dart' show AppLogger;
import 'package:mynotes/core/services/geofence_service.dart';
import 'package:mynotes/core/services/location_notification_service.dart';
import 'package:mynotes/core/services/location_background_service.dart';
import 'package:mynotes/core/services/location_permission_manager.dart';
import 'package:mynotes/core/exceptions/location_exceptions.dart';

/// Manager status event
class ManagerStatusEvent {
  final String
  status; // 'initialized', 'monitoring_started', 'monitoring_stopped', 'error'
  final String? message;
  final DateTime timestamp;

  ManagerStatusEvent({required this.status, this.message, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => '[ManagerStatusEvent] status=$status, message=$message';
}

/// Location Reminders Integration Manager
/// Orchestrates all location reminder services:
/// - Permission management
/// - Geofencing
/// - Notifications
/// - Background monitoring
/// Provides unified error handling and status updates
class LocationRemindersManager {
  static final LocationRemindersManager _instance =
      LocationRemindersManager._internal();

  factory LocationRemindersManager({
    GeofenceManager? geofenceManager,
    LocationNotificationService? notificationService,
    LocationBackgroundService? backgroundService,
    LocationPermissionManager? permissionManager,
  }) => _instance;

  LocationRemindersManager._internal({
    GeofenceManager? geofenceManager,
    LocationNotificationService? notificationService,
    LocationBackgroundService? backgroundService,
    LocationPermissionManager? permissionManager,
  }) : _geofenceManager = geofenceManager ?? GeofenceManager.instance,
       _notificationService =
           notificationService ?? LocationNotificationService(),
       _backgroundService = backgroundService ?? LocationBackgroundService(),
       _permissionManager = permissionManager ?? LocationPermissionManager();

  final GeofenceManager _geofenceManager;
  final LocationNotificationService _notificationService;
  final LocationBackgroundService _backgroundService;
  final LocationPermissionManager _permissionManager;

  bool _isInitialized = false;
  bool _isMonitoring = false;

  // Callbacks for interactivity and testing
  void Function(ManagerStatusEvent)? onStatusChanged;
  void Function(String)? onError;

  /// Initialize all location reminder services
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      AppLogger.i('Initializing RemindersManager...');

      // Initialize notification channels
      await _notificationService.initializeNotificationChannels();

      // Initialize geofence service
      await _geofenceManager.initialize();

      // Check and initialize background service
      final bgServiceRunning = await _backgroundService
          .isBackgroundServiceRunning();
      if (!bgServiceRunning) {
        await _backgroundService.initializeBackgroundService();
      }

      _isInitialized = true;

      onStatusChanged?.call(
        ManagerStatusEvent(
          status: 'initialized',
          message: 'All services initialized successfully',
        ),
      );

      AppLogger.i('RemindersManager initialized successfully');
    } on LocationRemindersException {
      rethrow;
    } catch (e, stackTrace) {
      final error = LocationServiceException(
        message: 'Failed to initialize reminders manager',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      AppLogger.e('Init error: ${error.message}', e, stackTrace);
    }
  }

  /// Request all necessary permissions
  Future<bool> requestAllPermissions() async {
    try {
      AppLogger.i('Requesting permissions...');

      final allPermissionsGranted = await _permissionManager
          .requestLocationPermissions();

      if (!allPermissionsGranted) {
        final error = LocationPermissionException(
          message: 'Location permissions not granted',
          code: 'LOCATION_PERMISSIONS_DENIED',
        );
        onError?.call(error.message);
        AppLogger.w('Location permissions denied');
        return false;
      }

      // Request notification permission
      final notificationGranted = await _permissionManager
          .requestNotificationPermission();

      if (!notificationGranted) {
        AppLogger.w('Notification permission not granted');
      }

      AppLogger.i('All permissions requested');
      return allPermissionsGranted;
    } on LocationRemindersException {
      rethrow;
    } catch (e, stackTrace) {
      final error = LocationPermissionException(
        message: 'Error requesting permissions',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      AppLogger.e('Permission error: ${error.message}', e, stackTrace);
      return false;
    }
  }

  /// Check if all permissions are granted
  Future<bool> arePermissionsGranted() async {
    try {
      return await _permissionManager.areAllPermissionsGranted();
    } catch (e, stackTrace) {
      final error = LocationPermissionException(
        message: 'Error checking permissions',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      AppLogger.e('Check permissions error: ${error.message}', e, stackTrace);
      return false;
    }
  }

  /// Start monitoring geofences
  Future<void> startMonitoring() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isMonitoring) return;

    try {
      AppLogger.i('Starting monitoring...');

      // Check permissions
      final permissionsGranted = await arePermissionsGranted();
      if (!permissionsGranted) {
        final error = LocationPermissionException(
          message: 'Permissions not granted, cannot start monitoring',
          code: 'PERMISSIONS_REQUIRED',
        );
        onError?.call(error.message);
        AppLogger.w(error.message);
        return;
      }

      // Refresh geofences and start monitoring
      await _geofenceManager.refreshGeofences();
      _isMonitoring = true;

      onStatusChanged?.call(
        ManagerStatusEvent(
          status: 'monitoring_started',
          message: 'Location monitoring started',
        ),
      );

      AppLogger.i('Monitoring started');
    } on LocationRemindersException {
      rethrow;
    } catch (e, stackTrace) {
      final error = LocationServiceException(
        message: 'Error starting monitoring',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      AppLogger.e('Start monitoring error: ${error.message}', e, stackTrace);
    }
  }

  /// Stop monitoring geofences
  Future<void> stopMonitoring() async {
    try {
      AppLogger.i('Stopping monitoring...');
      await _geofenceManager.stopMonitoring();
      _isMonitoring = false;

      onStatusChanged?.call(
        ManagerStatusEvent(
          status: 'monitoring_stopped',
          message: 'Location monitoring stopped',
        ),
      );

      AppLogger.i('Monitoring stopped');
    } catch (e, stackTrace) {
      final error = LocationServiceException(
        message: 'Error stopping monitoring',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      AppLogger.e('Stop monitoring error: ${error.message}', e, stackTrace);
    }
  }

  /// Refresh geofences (call after adding/updating/deleting reminders)
  Future<void> refreshGeofences() async {
    try {
      AppLogger.i('Refreshing geofences...');
      await _geofenceManager.refreshGeofences();
      AppLogger.i('Geofences refreshed');
    } catch (e, stackTrace) {
      final error = GeofenceException(
        message: 'Error refreshing geofences',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      AppLogger.e('Refresh error: ${error.message}', e, stackTrace);
    }
  }

  /// Check if monitoring is active
  bool get isMonitoring => _isMonitoring;

  /// Check if initialized
  bool get isInitialized => _isInitialized;

  /// Dispose all resources
  Future<void> dispose() async {
    try {
      AppLogger.i('Disposing RemindersManager...');
      await stopMonitoring();
      await _notificationService.cancelAllNotifications();
      await _backgroundService.stopBackgroundService();
      _permissionManager.dispose();
      AppLogger.i('RemindersManager disposed');
    } catch (e, stackTrace) {
      final error = LocationServiceException(
        message: 'Error disposing reminders manager',
        originalError: e,
        stackTrace: stackTrace,
      );
      onError?.call(error.message);
      AppLogger.e('Dispose error: ${error.message}', e, stackTrace);
    }
  }
}
