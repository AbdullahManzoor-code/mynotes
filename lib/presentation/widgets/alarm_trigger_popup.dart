import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/alarm/alarm_bloc.dart';
import 'package:mynotes/presentation/bloc/alarm/alarm_event.dart';
import 'package:mynotes/core/services/app_logger.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

/// Non-dismissible alarm popup that appears when alarm triggers
/// User MUST take an action (Snooze, Reschedule, or Stop) to dismiss
class AlarmTriggerPopup extends StatefulWidget {
  final dynamic alarm;
  final VoidCallback onDismiss;

  const AlarmTriggerPopup({
    super.key,
    required this.alarm,
    required this.onDismiss,
  });

  @override
  State<AlarmTriggerPopup> createState() => _AlarmTriggerPopupState();
}

class _AlarmTriggerPopupState extends State<AlarmTriggerPopup>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    AppLogger.i('🔔 [ALARM-POPUP] Initializing alarm trigger popup');

    // Pulse animation for the red circle
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Slide animation for the popup
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _slideController.forward();

    // Vibrate and play sound continuously
    _startAlarmEffects();
  }

  Future<void> _startAlarmEffects() async {
    try {
      // Vibrate
      await Vibration.vibrate(pattern: [500, 1000, 500, 1000], repeat: -1);
      // Play sound
      await FlutterRingtonePlayer().playAlarm();
      AppLogger.i('✅ [ALARM-POPUP] Alarm effects started');
    } catch (e) {
      AppLogger.w('⚠️ [ALARM-POPUP] Failed to start effects: $e');
    }
  }

  Future<void> _stopAlarmEffects() async {
    try {
      await Vibration.cancel();
      await FlutterRingtonePlayer().stop();
      AppLogger.i('✅ [ALARM-POPUP] Alarm effects stopped');
    } catch (e) {
      AppLogger.w('⚠️ [ALARM-POPUP] Failed to stop effects: $e');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _stopAlarmEffects();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.alarm.title ?? 'Alarm!';
    final time = _formatTime(widget.alarm.alarmTime);

    return SlideTransition(
      position: _slideAnimation,
      child: WillPopScope(
        onWillPop: () async {
          AppLogger.i(
            '⚠️ [ALARM-POPUP] User tried to dismiss with back button (blocked)',
          );
          return false; // Block back button
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pulsing alarm icon
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.alarm,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    '🔔 ALARM!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Alarm details
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Triggered at $time',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),

                  // Action buttons (CANNOT BE DISMISSED WITHOUT THESE)
                  Column(
                    children: [
                      // A006: Multiple snooze options (5, 10, 15 minutes)
                      // Users can choose their preferred snooze duration
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _SnoozeButton(
                            duration: 5,
                            alarm: widget.alarm,
                            onDismiss: widget.onDismiss,
                            onStopAlarmEffects: _stopAlarmEffects,
                          ),
                          _SnoozeButton(
                            duration: 10,
                            alarm: widget.alarm,
                            onDismiss: widget.onDismiss,
                            onStopAlarmEffects: _stopAlarmEffects,
                          ),
                          _SnoozeButton(
                            duration: 15,
                            alarm: widget.alarm,
                            onDismiss: widget.onDismiss,
                            onStopAlarmEffects: _stopAlarmEffects,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Reschedule button
                      _ActionButton(
                        icon: Icons.edit_calendar,
                        label: 'Reschedule',
                        color: Colors.blue,
                        onPressed: () {
                          AppLogger.i(
                            '🔔 [ALARM-POPUP] Reschedule action tapped',
                          );
                          _stopAlarmEffects();
                          widget.onDismiss();

                          // Navigate to reschedule screen
                          Navigator.of(context).pushNamed(
                            '/alarms/reschedule',
                            arguments: widget.alarm,
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // Dismiss/Stop button
                      _ActionButton(
                        icon: Icons.stop_circle_outlined,
                        label: 'Stop Alarm',
                        color: Colors.red,
                        onPressed: () {
                          AppLogger.i('🔔 [ALARM-POPUP] Stop action tapped');
                          _stopAlarmEffects();
                          context.read<AlarmsBloc>().add(
                            DismissAlarmEvent(alarmId: widget.alarm.alarmId),
                          );
                          widget.onDismiss();

                          // Navigate to dismiss confirmation screen
                          Navigator.of(context).pushNamed(
                            '/alarms/dismiss-confirmation',
                            arguments: widget.alarm,
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Warning text
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info,
                          color: Colors.orange.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Take an action to dismiss alarm',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.orange.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

/// [A006] Snooze button with configurable duration
class _SnoozeButton extends StatelessWidget {
  final int duration; // Duration in minutes (5, 10, 15)
  final dynamic alarm;
  final VoidCallback onDismiss;
  final VoidCallback onStopAlarmEffects;

  const _SnoozeButton({
    required this.duration,
    required this.alarm,
    required this.onDismiss,
    required this.onStopAlarmEffects,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        AppLogger.i(
          '🔔 [ALARM-POPUP] Snooze ${duration}m action tapped',
        );
        onStopAlarmEffects();

        final snoozeUntil = DateTime.now().add(Duration(minutes: duration));

        // Dispatch snooze event with specific duration
        context.read<AlarmsBloc>().add(
          SnoozeAlarmEvent(
            alarmId: alarm.alarmId,
            snoozeMinutes: duration,
          ),
        );

        onDismiss();

        // Navigate to snooze confirmation screen
        Navigator.of(context).pushNamed(
          '/alarms/snooze-confirmation',
          arguments: {
            'alarm': alarm,
            'snoozeUntil': snoozeUntil,
            'snoozeMinutes': duration,
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
      ),
      child: Text(
        '⏸️ ${duration}m',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Individual action button for alarm popup
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
    );
  }
}
