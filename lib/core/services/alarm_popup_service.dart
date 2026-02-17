import 'package:flutter/material.dart';
import 'package:mynotes/presentation/widgets/alarm_trigger_popup.dart';
import 'package:mynotes/core/services/app_logger.dart';

/// Service to manage in-app alarm popup overlay
/// Ensures non-dismissible alarm popup is shown when alarm triggers
class AlarmPopupService {
  static final AlarmPopupService _instance = AlarmPopupService._internal();

  factory AlarmPopupService() {
    return _instance;
  }

  AlarmPopupService._internal();

  OverlayEntry? _overlayEntry;
  bool _isPopupShown = false;

  /// Initialize with app context
  void initialize(BuildContext context) {
    AppLogger.i('✅ [ALARM-POPUP-SERVICE] Initialized');
  }

  /// Show non-dismissible alarm popup
  void showAlarmPopup({required dynamic alarm, required BuildContext context}) {
    if (_isPopupShown) {
      AppLogger.w(
        '⚠️ [ALARM-POPUP-SERVICE] Popup already shown, ignoring new request',
      );
      return;
    }

    AppLogger.i(
      '🔔 [ALARM-POPUP-SERVICE] Showing alarm popup for: ${alarm.title}',
    );

    _isPopupShown = true;

    // Create overlay entry
    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black54, // Dark overlay behind popup
        child: Center(
          child: AlarmTriggerPopup(
            alarm: alarm,
            onDismiss: () {
              AppLogger.i('✅ [ALARM-POPUP-SERVICE] Alarm popup dismissed');
              dismissAlarmPopup();
            },
          ),
        ),
      ),
    );

    // Insert into overlay
    try {
      Overlay.of(context).insert(_overlayEntry!);
      AppLogger.i('✅ [ALARM-POPUP-SERVICE] Popup inserted into overlay');
    } catch (e) {
      AppLogger.e('❌ [ALARM-POPUP-SERVICE] Failed to show popup: $e');
      _isPopupShown = false;
    }
  }

  /// Dismiss the alarm popup
  void dismissAlarmPopup() {
    if (!_isPopupShown || _overlayEntry == null) {
      AppLogger.w('⚠️ [ALARM-POPUP-SERVICE] No popup to dismiss');
      return;
    }

    try {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isPopupShown = false;
      AppLogger.i('✅ [ALARM-POPUP-SERVICE] Popup dismissed');
    } catch (e) {
      AppLogger.e('❌ [ALARM-POPUP-SERVICE] Failed to dismiss popup: $e');
    }
  }

  /// Check if popup is currently shown
  bool get isPopupShown => _isPopupShown;

  /// Dispose service
  void dispose() {
    dismissAlarmPopup();
    AppLogger.i('✅ [ALARM-POPUP-SERVICE] Disposed');
  }
}
