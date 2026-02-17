import 'dart:io';

import 'package:flutter/services.dart';

/// Supported DND modes mapped to Android interruption filters.
enum DndMode {
  all(1),
  priorityOnly(2),
  totalSilence(3),
  alarmsOnly(4);

  const DndMode(this.androidValue);
  final int androidValue;
}

/// Wrapper for platform DND controls.
class DndService {
  static const MethodChannel _channel = MethodChannel(
    'com.abdullahmanzoor.mynotes/dnd',
  );

  static bool get isPlatformSupported => Platform.isAndroid;

  /// Returns true when DND permission is granted on Android.
  static Future<bool> isDndPermissionGranted() async {
    if (!Platform.isAndroid) return false;
    try {
      final result = await _channel.invokeMethod<bool>('checkDndPermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Opens the system DND settings page.
  static Future<bool> openDndSettings() async {
    try {
      final result = await _channel.invokeMethod<bool>('openDndSettings');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Enables DND on Android. On iOS, opens settings and returns false.
  static Future<bool> enableDnd({DndMode mode = DndMode.totalSilence}) async {
    if (Platform.isIOS) {
      await openDndSettings();
      return false;
    }
    try {
      final result = await _channel.invokeMethod<bool>('enableDnd', {
        'mode': mode.androidValue,
      });
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Disables DND on Android. Returns false on iOS.
  static Future<bool> disableDnd() async {
    if (Platform.isIOS) return false;
    try {
      final result = await _channel.invokeMethod<bool>('disableDnd');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Returns the current DND interruption filter on Android, -1 on failure.
  static Future<int> getCurrentStatus() async {
    if (!Platform.isAndroid) return -1;
    try {
      final result = await _channel.invokeMethod<int>('getDndStatus');
      return result ?? -1;
    } catch (_) {
      return -1;
    }
  }

  /// Returns true when DND is active (Android only).
  static Future<bool> isDndActive() async {
    if (!Platform.isAndroid) return false;
    final status = await getCurrentStatus();
    return status > 1;
  }
}
