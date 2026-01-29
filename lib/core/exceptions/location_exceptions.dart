import 'package:mynotes/core/exceptions/app_exceptions.dart';

/// Location Reminders Exception Classes
/// Provides specific, typed exceptions for better error handling

class LocationRemindersException extends AppException {
  LocationRemindersException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'LOCATION_REMINDERS_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class LocationPermissionException extends LocationRemindersException {
  LocationPermissionException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'PERMISSION_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class GeofenceException extends LocationRemindersException {
  GeofenceException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'GEOFENCE_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class NotificationException extends LocationRemindersException {
  NotificationException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'NOTIFICATION_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class LocationServiceException extends LocationRemindersException {
  LocationServiceException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'LOCATION_SERVICE_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class DatabaseException extends LocationRemindersException {
  DatabaseException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'DATABASE_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}
