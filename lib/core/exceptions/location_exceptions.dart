import 'package:mynotes/core/exceptions/app_exceptions.dart';

/// Location Reminders Exception Classes
/// Provides specific, typed exceptions for better error handling

class LocationRemindersException extends AppException {
  LocationRemindersException({
    required super.message,
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(code: code ?? 'LOCATION_REMINDERS_ERROR');
}

class LocationPermissionException extends LocationRemindersException {
  LocationPermissionException({
    required super.message,
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(code: code ?? 'PERMISSION_ERROR');
}

class GeofenceException extends LocationRemindersException {
  GeofenceException({
    required super.message,
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(code: code ?? 'GEOFENCE_ERROR');
}

class NotificationException extends LocationRemindersException {
  NotificationException({
    required super.message,
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(code: code ?? 'NOTIFICATION_ERROR');
}

class LocationServiceException extends LocationRemindersException {
  LocationServiceException({
    required super.message,
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(code: code ?? 'LOCATION_SERVICE_ERROR');
}

class DatabaseException extends LocationRemindersException {
  DatabaseException({
    required super.message,
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(code: code ?? 'DATABASE_ERROR');
}
