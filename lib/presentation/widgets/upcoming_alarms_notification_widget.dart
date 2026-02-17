import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/alarm/alarm_bloc.dart';
import 'package:mynotes/presentation/bloc/alarm/alarm_state.dart';
import 'package:mynotes/core/services/app_logger.dart';
import 'dart:async';
import 'package:intl/intl.dart';

/// Widget that displays all upcoming alarms with countdown timers
/// Wraps the entire app to show persistent notification banner
class UpcomingAlarmsNotificationWidget extends StatelessWidget {
  final Widget child;

  const UpcomingAlarmsNotificationWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Upcoming alarms notification banner (sticky at top)
        BlocBuilder<AlarmsBloc, AlarmState>(
          builder: (context, state) {
            if (state is! AlarmLoaded) {
              return const SizedBox.shrink();
            }

            final upcomingAlarms =
                state.upcomingAlarms
                    .where((a) => a.alarmTime.isAfter(DateTime.now()))
                    .toList()
                  ..sort((a, b) => a.alarmTime.compareTo(b.alarmTime));

            if (upcomingAlarms.isEmpty) {
              return const SizedBox.shrink();
            }

            return _UpcomingAlarmsBanner(alarms: upcomingAlarms);
          },
        ),
        // Main app content
        Expanded(child: child),
      ],
    );
  }
}

/// Banner that displays upcoming alarms
class _UpcomingAlarmsBanner extends StatelessWidget {
  final List<dynamic> alarms;

  const _UpcomingAlarmsBanner({required this.alarms});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.blue.shade200, width: 2),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Icon(Icons.notifications_active, color: Colors.blue[700]),
            ),
            ...List.generate(alarms.length, (index) {
              final alarm = alarms[index];
              return _AlarmNotificationChip(alarm: alarm);
            }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.info_outline,
                color: Colors.blue[700],
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual alarm notification chip with countdown timer
class _AlarmNotificationChip extends StatefulWidget {
  final dynamic alarm;

  const _AlarmNotificationChip({required this.alarm});

  @override
  State<_AlarmNotificationChip> createState() => _AlarmNotificationChipState();
}

class _AlarmNotificationChipState extends State<_AlarmNotificationChip> {
  late Timer _countdownTimer;

  @override
  void initState() {
    super.initState();
    // Update countdown every second
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });

    AppLogger.i(
      '📢 [UPCOMING-ALARM-CHIP] Created for alarm: ${widget.alarm.title}',
    );
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  String _getCountdownText(DateTime alarmTime) {
    final now = DateTime.now();
    if (alarmTime.isBefore(now)) {
      return 'RINGING NOW!';
    }

    final difference = alarmTime.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRinging = widget.alarm.alarmTime.isBefore(DateTime.now());
    final countdownText = _getCountdownText(widget.alarm.alarmTime);
    final timeFormat = DateFormat('hh:mm a');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: InkWell(
        onTap: () {
          AppLogger.i(
            '📢 [UPCOMING-ALARM] Tapped on alarm: ${widget.alarm.title}',
          );
          Navigator.of(context).pushNamed('/alarms/active');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isRinging ? Colors.red.shade100 : Colors.white,
            border: Border.all(
              color: isRinging ? Colors.red[500]! : Colors.blue[300]!,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (isRinging)
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Countdown text
              Text(
                countdownText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isRinging ? Colors.red[700] : Colors.blue[700],
                ),
              ),
              const SizedBox(height: 2),

              // Time
              Text(
                timeFormat.format(widget.alarm.alarmTime),
                style: TextStyle(
                  fontSize: 10,
                  color: isRinging ? Colors.red[600] : Colors.blue[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),

              // Title
              LimitedBox(
                maxWidth: 80,
                child: Text(
                  widget.alarm.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ),

              // Ringing indicator
              if (isRinging) ...[
                const SizedBox(height: 3),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red[500],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
