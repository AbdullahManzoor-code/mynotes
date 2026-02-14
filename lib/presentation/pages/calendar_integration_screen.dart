import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:device_calendar/device_calendar.dart';
import '../../presentation/design_system/app_colors.dart';
import '../../presentation/design_system/app_typography.dart';
import '../../presentation/design_system/app_spacing.dart';
import '../../domain/entities/alarm.dart';
import '../../domain/entities/note.dart';
import '../bloc/note/note_bloc.dart';
import '../bloc/note/note_state.dart';
import '../bloc/calendar_integration/calendar_integration_bloc.dart';
import '../bloc/calendar_integration/calendar_integration_state.dart';
import '../../injection_container.dart';

/// Calendar Integration View
/// Shows calendar with integrated reminders and events
class CalendarIntegrationScreen extends StatefulWidget {
  const CalendarIntegrationScreen({super.key});

  @override
  State<CalendarIntegrationScreen> createState() =>
      _CalendarIntegrationScreenState();
}

class _CalendarIntegrationScreenState extends State<CalendarIntegrationScreen> {
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<Note>> _notesMap = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => getIt<CalendarIntegrationBloc>(),
      child: BlocBuilder<NotesBloc, NoteState>(
        builder: (context, noteState) {
          if (noteState is NotesLoaded) {
            _updateNotesMap(noteState.notes);
          }

          return BlocBuilder<CalendarIntegrationBloc, CalendarIntegrationState>(
            builder: (context, calendarState) {
              CalendarFormat calendarFormat = CalendarFormat.month;
              DateTime selectedDay = _selectedDay;
              DateTime focusedDay = DateTime.now();

              if (calendarState is CalendarIntegrationInitial) {
                calendarFormat = calendarState.format;
                selectedDay = calendarState.selectedDay;
                focusedDay = calendarState.focusedDay;
              } else if (calendarState is CalendarDaySelected) {
                calendarFormat = calendarState.format;
                selectedDay = calendarState.selectedDay;
                focusedDay = calendarState.focusedDay;
              } else if (calendarState is CalendarFormatChanged) {
                calendarFormat = calendarState.format;
                selectedDay = calendarState.selectedDay;
                focusedDay = calendarState.focusedDay;
              }

              _selectedDay = selectedDay;
              final notesForSelectedDay = _getNotesForDay(selectedDay);

              return Scaffold(
                backgroundColor: isDark
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                appBar: AppBar(
                  backgroundColor: isDark
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.textPrimary(context),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Text(
                    'Calendar',
                    style: AppTypography.heading2(
                      context,
                      AppColors.textPrimary(context),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.today, color: AppColors.primaryColor),
                      onPressed: () {
                        context.read<CalendarIntegrationBloc>().add(
                          const ResetToTodayEvent(),
                        );
                      },
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    // Calendar Widget
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      padding: EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkCardBackground
                            : AppColors.lightCardBackground,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXL,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TableCalendar<Note>(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(selectedDay, day),
                        eventLoader: (day) => _getNotesForDay(day),
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        calendarFormat: calendarFormat,
                        onFormatChanged: (format) {
                          context.read<CalendarIntegrationBloc>().add(
                            ChangeCalendarFormatEvent(format),
                          );
                        },
                        onDaySelected: (newSelectedDay, newFocusedDay) {
                          context.read<CalendarIntegrationBloc>().add(
                            SelectDayEvent(newSelectedDay, newFocusedDay),
                          );
                        },
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          weekendTextStyle: AppTypography.bodyMedium(
                            context,
                            AppColors.textPrimary(context),
                          ),
                          holidayTextStyle: AppTypography.bodyMedium(
                            context,
                            AppColors.accentOrange,
                          ),
                          defaultTextStyle: AppTypography.bodyMedium(
                            context,
                            AppColors.textPrimary(context),
                          ),
                          selectedTextStyle: AppTypography.bodyMedium(
                            context,
                            Colors.white,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: BoxDecoration(
                            color: AppColors.accentOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: true,
                          titleCentered: true,
                          formatButtonShowsNext: false,
                          formatButtonDecoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLG,
                            ),
                          ),
                          formatButtonTextStyle: AppTypography.caption(
                            context,
                            AppColors.primaryColor,
                            FontWeight.w600,
                          ),
                          titleTextStyle: AppTypography.heading3(
                            context,
                            AppColors.textPrimary(context),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: AppSpacing.xl),

                    // Selected Day Events
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        padding: EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCardBackground
                              : AppColors.lightCardBackground,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusXL,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusMD,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.event,
                                    color: AppColors.primaryColor,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: AppSpacing.sm),
                                Text(
                                  _formatSelectedDay(selectedDay),
                                  style: AppTypography.heading3(
                                    context,
                                    AppColors.textPrimary(context),
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () {
                                    // Add new reminder for selected day
                                  },
                                  icon: Icon(
                                    Icons.add,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: AppSpacing.lg),

                            Expanded(
                              child: notesForSelectedDay.isEmpty
                                  ? _buildEmptyDayState()
                                  : AnimationLimiter(
                                      child: ListView.builder(
                                        itemCount: notesForSelectedDay.length,
                                        itemBuilder: (context, index) {
                                          final note =
                                              notesForSelectedDay[index];
                                          return AnimationConfiguration.staggeredList(
                                            position: index,
                                            duration: const Duration(
                                              milliseconds: 375,
                                            ),
                                            child: SlideAnimation(
                                              verticalOffset: 50.0,
                                              child: FadeInAnimation(
                                                child: _buildEventCard(note),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: AppSpacing.lg),
                  ],
                ),
                floatingActionButton: FloatingActionButton.extended(
                  onPressed: () {
                    _showCalendarIntegrationSetup(context);
                  },
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.sync),
                  label: Text(
                    'Sync Calendar',
                    style: AppTypography.button(context, Colors.white),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _updateNotesMap(List<Note> notes) {
    _notesMap = {};
    for (final note in notes) {
      if (note.alarms != null) {
        for (final alarm in note.alarms!) {
          final date = DateTime(
            alarm.scheduledTime.year,
            alarm.scheduledTime.month,
            alarm.scheduledTime.day,
          );
          if (_notesMap[date] == null) {
            _notesMap[date] = [];
          }
          if (!_notesMap[date]!.contains(note)) {
            _notesMap[date]!.add(note);
          }
        }
      }
    }
  }

  List<Note> _getNotesForDay(DateTime day) {
    return _notesMap[DateTime(day.year, day.month, day.day)] ?? [];
  }

  String _formatSelectedDay(DateTime selectedDay) {
    final months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[selectedDay.month]} ${selectedDay.day}, ${selectedDay.year}';
  }

  Widget _buildEmptyDayState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 64,
            color: AppColors.textSecondary(context).withOpacity(0.5),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'No events for this day',
            style: AppTypography.bodyLarge(
              context,
              AppColors.textSecondary(context),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Tap + to add a reminder',
            style: AppTypography.caption(
              context,
              AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Note note) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title.isNotEmpty ? note.title : 'Untitled Note',
                  style: AppTypography.bodyLarge(
                    context,
                    AppColors.textPrimary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  note.content,
                  style: AppTypography.caption(
                    context,
                    AppColors.textSecondary(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (note.alarms?.isNotEmpty ?? false) ...[
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    '🔔 ${_formatAlarmTime(note.alarms!.first)}',
                    style: AppTypography.caption(
                      context,
                      AppColors.primaryColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  // Edit note
                  break;
                case 'delete':
                  // Delete reminder
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
              PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
            ],
            child: Icon(
              Icons.more_vert,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAlarmTime(Alarm alarm) {
    final time = alarm.scheduledTime;
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  void _showCalendarIntegrationSetup(BuildContext context) {
    final calendarBloc = context.read<CalendarIntegrationBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: calendarBloc,
        child: _CalendarIntegrationSetupSheet(),
      ),
    );
  }
}

class _CalendarIntegrationSetupSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<CalendarIntegrationBloc, CalendarIntegrationState>(
      builder: (context, state) {
        bool isLoading = false;
        List<Calendar> availableCalendars = [];

        if (state is CalendarIntegrationInitial) {
          isLoading = state.isLoading;
          availableCalendars = state.availableCalendars;
        } else if (state is CalendarDaySelected) {
          availableCalendars = state.availableCalendars;
        } else if (state is CalendarFormatChanged) {
          availableCalendars = state.availableCalendars;
        }

        if (availableCalendars.isEmpty && !isLoading) {
          context.read<CalendarIntegrationBloc>().add(
            const LoadAvailableCalendarsEvent(),
          );
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkCardBackground
                : AppColors.lightCardBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSpacing.radiusLG),
              topRight: Radius.circular(AppSpacing.radiusLG),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary(context).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.xl),

                Text(
                  'Calendar Integration',
                  style: AppTypography.heading2(
                    context,
                    AppColors.textPrimary(context),
                  ),
                ),

                SizedBox(height: AppSpacing.sm),

                Text(
                  'Connect your local device calendars to sync reminders',
                  style: AppTypography.bodyMedium(
                    context,
                    AppColors.textSecondary(context),
                  ),
                ),

                SizedBox(height: AppSpacing.xxl),

                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (availableCalendars.isEmpty)
                  Center(
                    child: Text(
                      'No local calendars found or permission denied',
                      style: AppTypography.bodyMedium(
                        context,
                        AppColors.textSecondary(context),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: availableCalendars.length,
                      itemBuilder: (context, index) {
                        final calendar = availableCalendars[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.lg),
                          child: _buildCalendarOption(
                            context,
                            calendar.name ?? 'Unknown Calendar',
                            calendar.accountName ?? 'Local Account',
                            Icons.calendar_today,
                            calendar.isReadOnly ?? false,
                            (value) {
                              // Toggle sync logic
                            },
                          ),
                        );
                      },
                    ),
                  ),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLG,
                        ),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: AppTypography.button(context, Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool isEnabled,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        border: Border.all(
          color: isEnabled
              ? AppColors.primaryColor
              : AppColors.textSecondary(context).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 24),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge(
                    context,
                    AppColors.textPrimary(context),
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.caption(
                    context,
                    AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onChanged,
            activeColor: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }
}

