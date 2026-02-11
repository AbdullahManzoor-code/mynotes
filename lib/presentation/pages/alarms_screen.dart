import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../design_system/design_system.dart';
import '../../injection_container.dart' show getIt;
import '../../domain/entities/alarm.dart';
import '../bloc/alarms_bloc.dart';
import '../widgets/alarm_card_widget.dart';
import '../widgets/create_alarm_bottom_sheet.dart';

class AlarmsScreen extends StatelessWidget {
  const AlarmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initial load
    context.read<AlarmsBloc>().add(LoadAlarms());

    return DefaultTabController(
      length: 6, // All, Today, Upcoming, Overdue, Snoozed, Completed
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          title: Text(
            'Reminders',
            style: AppTypography.heading2(
              context,
            ).copyWith(color: Colors.white),
          ),
          bottom: TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            onTap: (index) {
              final filters = [
                AlarmFilter.all,
                AlarmFilter.today,
                AlarmFilter.upcoming,
                AlarmFilter.overdue,
                AlarmFilter.snoozed,
                AlarmFilter.completed,
              ];
              context.read<AlarmsBloc>().add(FilterAlarms(filters[index]));
            },
            tabs: const [
              Tab(text: 'All', icon: Icon(Icons.list, size: 20)),
              Tab(text: 'Today', icon: Icon(Icons.today, size: 20)),
              Tab(text: 'Upcoming', icon: Icon(Icons.event, size: 20)),
              Tab(text: 'Overdue', icon: Icon(Icons.warning_amber, size: 20)),
              Tab(text: 'Snoozed', icon: Icon(Icons.snooze, size: 20)),
              Tab(text: 'Done', icon: Icon(Icons.check_circle, size: 20)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              tooltip: 'Search Reminders',
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: _AlarmSearchDelegate(context.read<AlarmsBloc>()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              tooltip: 'Clear Completed',
              onPressed: () {
                _showClearCompletedConfirmation(context);
              },
            ),
          ],
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
                return _buildEmptyState(context, state.currentFilter);
              }

              return Column(
                children: [
                  _buildStatsBar(context, state.stats),
                  Expanded(child: _buildAlarmsList(context, alarms)),
                ],
              );
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
      ),
    );
  }

  void _showClearCompletedConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Completed'),
        content: const Text(
          'Are you sure you want to delete all completed reminders? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AlarmsBloc>().add(ClearCompletedAlarms());
              Navigator.pop(context);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AlarmFilter filter) {
    String message;
    IconData icon;

    switch (filter) {
      case AlarmFilter.overdue:
        message = 'No overdue reminders!\nYou\'re all caught up.';
        icon = Icons.celebration;
        break;
      case AlarmFilter.today:
        message = 'No reminders for today.\nEnjoy your day!';
        icon = Icons.wb_sunny;
        break;
      case AlarmFilter.upcoming:
        message = 'No upcoming reminders.\nTime to relax!';
        icon = Icons.event_available;
        break;
      case AlarmFilter.snoozed:
        message = 'No snoozed reminders.\nStay focused!';
        icon = Icons.timer_off;
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

  Widget _buildStatsBar(BuildContext context, AlarmStats stats) {
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatItem(
              context,
              'Overdue',
              stats.overdue.toString(),
              Colors.red.shade700,
              Icons.warning_amber,
            ),
            SizedBox(width: 16.w),
            _buildStatItem(
              context,
              'Today',
              stats.today.toString(),
              Colors.blue.shade700,
              Icons.today,
            ),
            SizedBox(width: 16.w),
            _buildStatItem(
              context,
              'Upcoming',
              stats.upcoming.toString(),
              Colors.green.shade700,
              Icons.event,
            ),
            SizedBox(width: 16.w),
            _buildStatItem(
              context,
              'Snoozed',
              stats.snoozed.toString(),
              Colors.orange.shade700,
              Icons.snooze,
            ),
            SizedBox(width: 16.w),
            _buildStatItem(
              context,
              'Done',
              stats.completed.toString(),
              Colors.grey.shade600,
              Icons.check_circle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: color),
              SizedBox(width: 6.w),
              Text(
                count,
                style: AppTypography.heading3(context).copyWith(
                  color: color,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: AppTypography.caption(context).copyWith(
              color: color,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmsList(BuildContext context, List<Alarm> alarms) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: alarms.length,
      itemBuilder: (context, index) {
        final alarm = alarms[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: AlarmCardWidget(
            alarm: alarm,
            onTap: () => _handleAlarmTap(context, alarm),
            onToggle: () =>
                context.read<AlarmsBloc>().add(ToggleAlarmEnabled(alarm.id)),
            onSnooze: (preset) {
              context.read<AlarmsBloc>().add(SnoozeAlarm(alarm.id, preset));
              getIt<GlobalUiService>().showInfo('Snoozed: ${preset.name}');
            },
            onReschedule: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => CreateAlarmBottomSheet(alarm: alarm),
              );
            },
            onDelete: () {
              context.read<AlarmsBloc>().add(DeleteAlarm(alarm.id));
              getIt<GlobalUiService>().showInfo(
                'Reminder deleted',
                // action: SnackBarAction(
                //   label: 'UNDO',
                //   onPressed: () {
                //     context.read<AlarmsBloc>().add(UndoDeleteAlarm(alarm));
                  // },
                // ),
              );
            },
          ),
        );
      },
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

  void _handleAlarmTap(BuildContext context, Alarm alarm) {
    if (alarm.linkedNoteId != null) {
      // Navigate to note
      getIt<GlobalUiService>().showInfo(
        'Opening linked note: ${alarm.linkedNoteId}',
      );
      // Implementation: Navigation.pushNamed(context, AppRoutes.noteDetail, arguments: alarm.linkedNoteId);
    } else if (alarm.linkedTodoId != null) {
      getIt<GlobalUiService>().showInfo(
        'Opening linked todo: ${alarm.linkedTodoId}',
      );
    } else {
      // Edit alarm
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CreateAlarmBottomSheet(alarm: alarm),
      );
    }
  }
}

class _AlarmSearchDelegate extends SearchDelegate<String> {
  final AlarmsBloc alarmsBloc;

  _AlarmSearchDelegate(this.alarmsBloc);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          alarmsBloc.add(SearchAlarms(''));
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
        alarmsBloc.add(SearchAlarms('')); // Reset search on exit
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    alarmsBloc.add(SearchAlarms(query));

    return BlocBuilder<AlarmsBloc, AlarmsState>(
      bloc: alarmsBloc,
      builder: (context, state) {
        if (state is AlarmsLoaded) {
          final results = state.filteredAlarms;
          if (results.isEmpty) {
            return Center(child: Text('No reminders found for "$query"'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final alarm = results[index];
              return ListTile(
                title: Text(alarm.message),
                subtitle: Text(alarm.scheduledTime.toString()),
                onTap: () {
                  // Handle selection
                  close(context, alarm.id);
                },
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(); // Optional: show recent searches or suggestions
  }
}
