import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/alarm/alarm_bloc.dart';
import 'package:mynotes/presentation/bloc/alarm/alarm_state.dart';
import 'dart:async';

/// Screen showing all active/upcoming alarms with countdown timers
class ActiveAlarmsScreen extends StatefulWidget {
  const ActiveAlarmsScreen({super.key});

  @override
  State<ActiveAlarmsScreen> createState() => _ActiveAlarmsScreenState();
}

class _ActiveAlarmsScreenState extends State<ActiveAlarmsScreen> {
  late Timer _countdownTimer;

  @override
  void initState() {
    super.initState();
    // Update countdown every second
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlarmsBloc, AlarmState>(
      builder: (context, state) {
        if (state is! AlarmLoaded) {
          return Scaffold(
            appBar: AppBar(title: const Text('📢 Active Alarms')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final upcomingAlarms =
            state.upcomingAlarms
                .where((a) => a.alarmTime.isAfter(DateTime.now()))
                .toList()
              ..sort((a, b) => a.alarmTime.compareTo(b.alarmTime));

        return Scaffold(
          appBar: AppBar(
            title: const Text('📢 Active Alarms'),
            elevation: 0,
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
          body: upcomingAlarms.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.alarm_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No Upcoming Alarms',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a reminder to get started',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: upcomingAlarms.length,
                  itemBuilder: (context, index) {
                    final alarm = upcomingAlarms[index];
                    final now = DateTime.now();
                    final duration = alarm.alarmTime.difference(now);
                    final isRinging = duration.inSeconds <= 0;

                    return _AlarmCountdownCard(
                      alarm: alarm,
                      duration: duration,
                      isRinging: isRinging,
                    );
                  },
                ),
        );
      },
    );
  }
}

/// Individual alarm countdown card showing time until alarm triggers
class _AlarmCountdownCard extends StatelessWidget {
  final dynamic alarm;
  final Duration duration;
  final bool isRinging;

  const _AlarmCountdownCard({
    required this.alarm,
    required this.duration,
    required this.isRinging,
  });

  String _formatCountdown(Duration duration) {
    if (duration.isNegative) return '🔔 RINGING NOW!';

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = alarm.title ?? 'Reminder';
    final countdown = _formatCountdown(duration);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isRinging ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isRinging ? Colors.red : Colors.deepPurple.shade200,
          width: isRinging ? 2 : 1,
        ),
      ),
      color: isRinging ? Colors.red.shade50 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isRinging ? Colors.red : Colors.black,
              ),
            ),
            const SizedBox(height: 8),

            // Countdown timer with animation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Triggers In:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      countdown,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: isRinging ? Colors.red : Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                // Time display
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('At:', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(alarm.alarmTime),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (isRinging) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_active,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'ALARM RINGING',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
