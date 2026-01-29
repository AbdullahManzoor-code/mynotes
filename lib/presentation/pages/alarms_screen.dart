import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../design_system/design_system.dart';
import '../../domain/entities/alarm.dart';
import '../../core/services/alarm_service.dart';
import '../bloc/alarms_bloc.dart';
import '../widgets/alarm_card_widget.dart';
import '../widgets/create_alarm_bottom_sheet.dart';

class AlarmsScreen extends StatefulWidget {
  const AlarmsScreen({super.key});

  @override
  State<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends State<AlarmsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<AlarmsBloc>().add(LoadAlarms());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          'Reminders',
          style: AppTypography.heading2(context).copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.white),
            tooltip: 'Clear Completed',
            onPressed: () {
              context.read<AlarmsBloc>().add(ClearCompletedAlarms());
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          onTap: (index) {
            final filters = [
              AlarmFilter.overdue,
              AlarmFilter.dueSoon,
              AlarmFilter.future,
              AlarmFilter.completed,
            ];
            context.read<AlarmsBloc>().add(FilterAlarms(filters[index]));
          },
          tabs: const [
            Tab(text: 'Overdue', icon: Icon(Icons.warning_amber, size: 20)),
            Tab(text: 'Soon', icon: Icon(Icons.notifications_active, size: 20)),
            Tab(text: 'Future', icon: Icon(Icons.schedule, size: 20)),
            Tab(text: 'Done', icon: Icon(Icons.check_circle, size: 20)),
          ],
        ),
      ),
      body: BlocBuilder<AlarmsBloc, AlarmsState>(
        builder: (context, state) {
          if (state is AlarmsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AlarmsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    state.message,
                    style: AppTypography.body2(context),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.read<AlarmsBloc>().add(LoadAlarms()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AlarmsLoaded) {
            final alarms = state.filteredAlarms;

            if (alarms.isEmpty) {
              return _buildEmptyState(state.currentFilter);
            }

            return _buildAlarmsList(alarms, state.stats);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateAlarmSheet(context),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add_alarm, color: Colors.white),
        label: Text(
          'New Reminder',
          style: AppTypography.body2(context).copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AlarmFilter filter) {
    String message;
    IconData icon;

    switch (filter) {
      case AlarmFilter.overdue:
        message = 'No overdue reminders!\nYou\'re all caught up.';
        icon = Icons.celebration;
        break;
      case AlarmFilter.dueSoon:
        message = 'No reminders due soon.\nEnjoy your free time!';
        icon = Icons.free_breakfast;
        break;
      case AlarmFilter.future:
        message = 'No future reminders.\nTap + to create one.';
        icon = Icons.event_available;
        break;
      case AlarmFilter.completed:
        message = 'No completed reminders yet.';
        icon = Icons.inbox;
        break;
      case AlarmFilter.all:
        message = 'No reminders yet.\nCreate your first one!';
        icon = Icons.alarm_add;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80.sp, color: Colors.grey.shade400),
          SizedBox(height: 16.h),
          Text(
            message,
            style: AppTypography.heading3(
              context,
            ).copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmsList(List<Alarm> alarms, AlarmStats stats) {
    return Column(
      children: [
        _buildStatsBar(stats),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: alarms.length,
            itemBuilder: (context, index) {
              final alarm = alarms[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: AlarmCardWidget(
                  alarm: alarm,
                  onTap: () => _handleAlarmTap(alarm),
                  onToggle: () => _toggleAlarm(alarm),
                  onSnooze: (preset) => _snoozeAlarm(alarm, preset),
                  onReschedule: () => _rescheduleAlarm(alarm),
                  onDelete: () => _deleteAlarm(alarm),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBar(AlarmStats stats) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Overdue',
            stats.overdue.toString(),
            Colors.red.shade700,
            Icons.warning_amber,
          ),
          _buildStatItem(
            'Soon',
            stats.dueSoon.toString(),
            Colors.orange.shade700,
            Icons.notifications_active,
          ),
          _buildStatItem(
            'Future',
            (stats.total - stats.overdue - stats.dueSoon - stats.completed)
                .toString(),
            Colors.green.shade700,
            Icons.schedule,
          ),
          _buildStatItem(
            'Done',
            stats.completed.toString(),
            Colors.grey.shade600,
            Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String count,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16.sp, color: color),
            SizedBox(width: 4.w),
            Text(
              count,
              style: AppTypography.heading2(
                context,
              ).copyWith(color: color, fontSize: 20.sp),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: AppTypography.caption(
            context,
          ).copyWith(color: Colors.grey.shade600, fontSize: 11.sp),
        ),
      ],
    );
  }

  void _showCreateAlarmSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateAlarmBottomSheet(),
    );
  }

  void _handleAlarmTap(Alarm alarm) {
    // Navigate to alarm details or linked note
    if (alarm.linkedNoteId != null) {
      // TODO: Navigate to note detail
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Open note: ${alarm.linkedNoteId}')),
      );
    }
  }

  void _toggleAlarm(Alarm alarm) {
    context.read<AlarmsBloc>().add(ToggleAlarm(alarm.id));
  }

  void _snoozeAlarm(Alarm alarm, SnoozePreset preset) {
    context.read<AlarmsBloc>().add(SnoozeAlarm(alarm.id, preset));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Snoozed until ${_formatSnoozeTime(preset)}')),
    );
  }

  void _rescheduleAlarm(Alarm alarm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateAlarmBottomSheet(alarm: alarm),
    );
  }

  void _deleteAlarm(Alarm alarm) {
    context.read<AlarmsBloc>().add(DeleteAlarm(alarm.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Reminder deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            context.read<AlarmsBloc>().add(UndoDeleteAlarm(alarm));
          },
        ),
      ),
    );
  }

  String _formatSnoozeTime(SnoozePreset preset) {
    final now = DateTime.now();
    DateTime snoozeTime;

    switch (preset) {
      case SnoozePreset.tenMinutes:
        snoozeTime = now.add(const Duration(minutes: 10));
        break;
      case SnoozePreset.oneHour:
        snoozeTime = now.add(const Duration(hours: 1));
        break;
      case SnoozePreset.oneDay:
        snoozeTime = now.add(const Duration(days: 1));
        break;
      case SnoozePreset.tomorrowMorning:
        snoozeTime = DateTime(now.year, now.month, now.day + 1, 9, 0);
        break;
    }

    final hour = snoozeTime.hour;
    final minute = snoozeTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }
}
