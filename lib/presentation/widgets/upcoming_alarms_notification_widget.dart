import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/alarm/alarm_bloc.dart';
import 'package:mynotes/presentation/bloc/alarm/alarm_state.dart';
import 'package:mynotes/core/services/app_logger.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';

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
        color: AppColors.infoColor.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: AppColors.infoColor.withOpacity(0.2),
            width: 2,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
              child: Icon(
                Icons.notifications_active,
                color: AppColors.infoDark,
              ),
            ),
            ...List.generate(alarms.length, (index) {
              final alarm = alarms[index];
              return _AlarmNotificationChip(alarm: alarm);
            }),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Icon(
                Icons.info_outline,
                color: AppColors.infoDark,
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
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
      child: GestureDetector(
        onTap: () {
          AppLogger.i(
            '📢 [UPCOMING-ALARM] Tapped on alarm: ${widget.alarm.title}',
          );
          Navigator.of(context).pushNamed('/alarms/active');
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isRinging ? AppColors.errorLight : AppColors.lightSurface,
            border: Border.all(
              color: isRinging ? AppColors.errorColor : AppColors.infoColor,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (isRinging)
                BoxShadow(
                  color: AppColors.errorColor.withOpacity(0.3),
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
                  color: isRinging ? AppColors.errorDark : AppColors.infoDark,
                ),
              ),
              SizedBox(height: 2.h),

              // Time
              Text(
                timeFormat.format(widget.alarm.alarmTime),
                style: TextStyle(
                  fontSize: 10,
                  color: isRinging ? AppColors.errorColor : AppColors.infoColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),

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
                    color: AppColors.grey500,
                  ),
                ),
              ),

              // Ringing indicator
              if (isRinging) ...[
                SizedBox(height: 3.h),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.errorColor,
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
