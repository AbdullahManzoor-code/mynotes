import 'package:permission_handler/permission_handler.dart';

/// Comprehensive permission handler service for the app
class PermissionHandlerService {
  /// Check if all critical permissions are granted
  Future<Map<Permission, PermissionStatus>> checkAllPermissions() async {
    final permissions = {
      Permission.camera: await Permission.camera.status,
      Permission.microphone: await Permission.microphone.status,
      Permission.storage: await Permission.storage.status,
      Permission.photos: await Permission.photos.status,
      Permission.notification: await Permission.notification.status,
    };

    return permissions;
  }

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request microphone permission (for voice input)
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Request speech recognition permission
  Future<bool> requestSpeechPermission() async {
    final status = await Permission.speech.request();
    return status.isGranted;
  }

  /// Request storage permission (for media files)
  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  /// Request photos permission (Android 13+)
  Future<bool> requestPhotosPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  /// Request notification permission
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Request all essential permissions at once
  Future<Map<Permission, PermissionStatus>>
  requestEssentialPermissions() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
      Permission.photos,
      Permission.notification,
    ].request();

    return statuses;
  }

  /// Request media-related permissions (camera, storage, photos)
  Future<bool> requestMediaPermissions() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
      Permission.photos,
    ].request();

    // Return true if all are granted
    return statuses.values.every((status) => status.isGranted);
  }

  /// Request voice-related permissions (microphone, speech)
  Future<bool> requestVoicePermissions() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.speech,
    ].request();

    // Return true if all are granted
    return statuses.values.every((status) => status.isGranted);
  }

  /// Check if permission is permanently denied
  Future<bool> isPermissionPermanentlyDenied(Permission permission) async {
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }

  /// Open app settings if permission is permanently denied
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// Get user-friendly permission status message
  String getPermissionStatusMessage(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Permission granted';
      case PermissionStatus.denied:
        return 'Permission denied';
      case PermissionStatus.restricted:
        return 'Permission restricted';
      case PermissionStatus.limited:
        return 'Permission limited';
      case PermissionStatus.permanentlyDenied:
        return 'Permission permanently denied. Please enable it in settings.';
      case PermissionStatus.provisional:
        return 'Permission provisional';
    }
  }

  /// Get user-friendly permission name
  String getPermissionName(Permission permission) {
    if (permission == Permission.camera) {
      return 'Camera';
    } else if (permission == Permission.microphone) {
      return 'Microphone';
    } else if (permission == Permission.storage) {
      return 'Storage';
    } else if (permission == Permission.photos) {
      return 'Photos';
    } else if (permission == Permission.notification) {
      return 'Notifications';
    } else if (permission == Permission.speech) {
      return 'Speech Recognition';
    }
    return permission.toString();
  }

  /// Show dialog explaining why permission is needed
  String getPermissionRationale(Permission permission) {
    if (permission == Permission.camera) {
      return 'Camera access is needed to capture photos for your notes.';
    } else if (permission == Permission.microphone) {
      return 'Microphone access is needed for voice-to-text input and audio recordings.';
    } else if (permission == Permission.storage) {
      return 'Storage access is needed to save and load your media files.';
    } else if (permission == Permission.photos) {
      return 'Photos access is needed to attach images from your gallery to notes.';
    } else if (permission == Permission.notification) {
      return 'Notification permission is needed to send you reminders and alarms.';
    } else if (permission == Permission.speech) {
      return 'Speech recognition is needed to convert your voice into text.';
    }
    return 'This permission is required for the app to function properly.';
  }

  /// Check and request permission with custom handling
  Future<bool> checkAndRequestPermission(
    Permission permission, {
    Function()? onGranted,
    Function()? onDenied,
    Function()? onPermanentlyDenied,
  }) async {
    final status = await permission.status;

    if (status.isGranted) {
      onGranted?.call();
      return true;
    } else if (status.isPermanentlyDenied) {
      onPermanentlyDenied?.call();
      return false;
    } else {
      final result = await permission.request();

      if (result.isGranted) {
        onGranted?.call();
        return true;
      } else if (result.isPermanentlyDenied) {
        onPermanentlyDenied?.call();
        return false;
      } else {
        onDenied?.call();
        return false;
      }
    }
  }
}
