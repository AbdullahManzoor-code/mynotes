import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/alarm/alarm_bloc.dart';
import 'package:mynotes/presentation/bloc/alarm/alarm_state.dart';
import 'package:mynotes/core/services/alarm_popup_service.dart';
import 'package:mynotes/core/services/app_logger.dart';

/// Widget that listens to AlarmsBloc and shows popup when alarm triggers
/// Should be placed at app root (MaterialApp or Navigator level)
class AlarmPopupListener extends StatefulWidget {
  final Widget child;

  const AlarmPopupListener({super.key, required this.child});

  @override
  State<AlarmPopupListener> createState() => _AlarmPopupListenerState();
}

class _AlarmPopupListenerState extends State<AlarmPopupListener> {
  final AlarmPopupService _popupService = AlarmPopupService();
  String? _lastAlarmId; // Track which alarm is currently showing

  @override
  void initState() {
    super.initState();
    // Initialize popup service with current context after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _popupService.initialize(context);
      AppLogger.i('✅ [ALARM-POPUP-LISTENER] Initialized');
    });
  }

  @override
  void dispose() {
    _popupService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AlarmsBloc, AlarmState>(
      listener: (context, state) {
        // Show popup when alarm triggers
        if (state is AlarmTriggered) {
          AppLogger.i(
            '🔔 [ALARM-POPUP-LISTENER] AlarmTriggered state detected',
          );
          AppLogger.i('Alarm: ${state.alarm.title}');

          // Only show if it's a different alarm or popup isn't already shown
          if (_lastAlarmId != state.alarm.alarmId &&
              !_popupService.isPopupShown) {
            _lastAlarmId = state.alarm.alarmId;
            _popupService.showAlarmPopup(alarm: state.alarm, context: context);
          }
        }

        // Clear popup when alarm is dismissed/snoozed
        if (state is AlarmSnoozed || state is AlarmDeleted) {
          AppLogger.i(
            '🔔 [ALARM-POPUP-LISTENER] Alarm action taken, clearing popup',
          );
          _lastAlarmId = null;
          _popupService.dismissAlarmPopup();
        }

        // Clear on error
        if (state is AlarmError) {
          AppLogger.w(
            '⚠️ [ALARM-POPUP-LISTENER] Error state: ${state.message}',
          );
          _popupService.dismissAlarmPopup();
        }
      },
      child: widget.child,
    );
  }
}
