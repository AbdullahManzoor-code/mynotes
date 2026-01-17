import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

/// Service to handle runtime permissions
class PermissionService {
  PermissionService._();

  /// Check and request storage permission
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true; // iOS doesn't need storage permission with scoped storage
  }

  /// Check and request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Check and request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Check and request photos permission (iOS)
  static Future<bool> requestPhotosPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted || status.isLimited;
  }

  /// Check and request notification permission
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Check if storage permission is granted
  static Future<bool> isStorageGranted() async {
    if (Platform.isAndroid) {
      return await Permission.storage.isGranted;
    }
    return true;
  }

  /// Check if camera permission is granted
  static Future<bool> isCameraGranted() async {
    return await Permission.camera.isGranted;
  }

  /// Check if microphone permission is granted
  static Future<bool> isMicrophoneGranted() async {
    return await Permission.microphone.isGranted;
  }

  /// Open app settings
  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
