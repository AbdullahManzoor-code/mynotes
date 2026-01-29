import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service to manage app auto-lock timer
class AutoLockService extends ChangeNotifier {
  static const List<int> autoLockDurations = [
    0, // Never
    1, // 1 minute
    5, // 5 minutes
    15, // 15 minutes
  ];

  Timer? _autoLockTimer;
  int _selectedDuration = 5; // Default 5 minutes
  bool _isLocked = false;

  int get selectedDuration => _selectedDuration;
  bool get isLocked => _isLocked;

  /// Set auto-lock duration in minutes (0 = never)
  void setAutoLockDuration(int minutes) {
    _selectedDuration = minutes;
    _resetTimer();
    notifyListeners();
  }

  /// Reset the auto-lock timer (call on app interaction)
  void _resetTimer() {
    _autoLockTimer?.cancel();

    if (_selectedDuration == 0) {
      // Auto-lock disabled
      return;
    }

    _autoLockTimer = Timer(Duration(minutes: _selectedDuration), () {
      _lockApp();
    });
  }

  /// Lock the app (trigger biometric/PIN screen)
  void _lockApp() {
    _isLocked = true;
    notifyListeners();
  }

  /// Unlock the app (after successful authentication)
  void unlockApp() {
    _isLocked = false;
    _resetTimer();
    notifyListeners();
  }

  /// Call when app goes to background
  void onAppPaused() {
    _resetTimer();
  }

  /// Call when app comes to foreground
  void onAppResumed() {
    if (_isLocked) {
      // App was locked, trigger auth screen
      notifyListeners();
    } else {
      _resetTimer();
    }
  }

  /// Disable auto-lock (user interaction)
  void disableAutoLock() {
    _selectedDuration = 0;
    _autoLockTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _autoLockTimer?.cancel();
    super.dispose();
  }
}
