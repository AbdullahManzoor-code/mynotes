import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

/// Service to monitor clipboard and detect copy events
/// Notifies listeners when text is copied to clipboard
///
/// Features:
/// - Continuously monitors system clipboard for text changes
/// - Works when app is in foreground or background (on supported platforms)
/// - Emits clipboard text changes through reactive stream
/// - Debounces rapid clipboard changes
/// - Prevents duplicate detections
///
/// Platform Support:
/// - iOS: Monitoring works when app is active or in foreground
/// - Android: Monitoring works in foreground; background monitoring requires separate service
/// - Windows/macOS: Full monitoring support
///
/// To enable background monitoring on Android, consider:
/// 1. Adding a foreground service with notification
/// 2. Using WorkManager for periodic checks
/// 3. Implementing native Android receiver for clipboard changes
class ClipboardService {
  static const platform = MethodChannel(
    'com.abdullahmanzoor.mynotes/clipboard',
  );

  final _clipboardSubject = BehaviorSubject<String?>();

  /// Stream of clipboard text changes
  Stream<String?> get clipboardStream => _clipboardSubject.stream;

  /// Current clipboard content
  String? get currentClipboard => _clipboardSubject.value;

  Timer? _pollingTimer;
  String? _lastClipboard;
  bool _isMonitoring = false;

  /// Check if currently monitoring clipboard
  bool get isMonitoring => _isMonitoring;

  /// Start monitoring clipboard for changes
  ///
  /// On foreground:
  /// - Polls clipboard every 1 second
  /// - Minimum latency for clipboard change detection (~1 second)
  ///
  /// To extend monitoring to background on Android:
  /// 1. Add android:permission.READ_FRAME_BUFFER
  /// 2. Implement native receiver or foreground service
  /// 3. Use keep_screen_on or foreground service
  Future<void> startMonitoring() async {
    if (_isMonitoring) {
      print('Clipboard monitoring already active');
      return;
    }

    _isMonitoring = true;
    print('Starting clipboard monitoring...');

    // Initialize with current clipboard content
    try {
      final data = await Clipboard.getData('text/plain');
      if (data?.text != null) {
        _lastClipboard = data!.text;
      }
    } catch (e) {
      print('Error initializing clipboard: $e');
    }

    // Poll clipboard every 1 second for changes
    _pollingTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!_isMonitoring) return;

      try {
        final data = await Clipboard.getData('text/plain');
        final currentText = data?.text;

        // Only emit if text changed and is not empty
        if (currentText != null &&
            currentText.isNotEmpty &&
            currentText != _lastClipboard) {
          _lastClipboard = currentText;
          print('Clipboard text detected: ${currentText.length} chars');
          _clipboardSubject.add(currentText);
        }
      } catch (e) {
        print('Error reading clipboard: $e');
      }
    });
  }

  /// Stop monitoring clipboard
  void stopMonitoring() {
    _pollingTimer?.cancel();
    _isMonitoring = false;
    print('Clipboard monitoring stopped');
  }

  /// Clear the clipboard
  Future<void> clearClipboard() async {
    try {
      await Clipboard.setData(const ClipboardData(text: ''));
      _lastClipboard = '';
    } catch (e) {
      print('Error clearing clipboard: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
    _clipboardSubject.close();
  }
}
