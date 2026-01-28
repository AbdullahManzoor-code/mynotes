import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../presentation/design_system/app_colors.dart';
import '../../presentation/design_system/app_typography.dart';
import '../../presentation/design_system/app_spacing.dart';
import '../../domain/entities/alarm.dart';
import '../../domain/entities/note.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_state.dart';

/// Calendar Integration View
/// Shows calendar with integrated reminders and events
class CalendarIntegrationScreen extends StatefulWidget {
  const CalendarIntegrationScreen({Key? key}) : super(key: key);

  @override
  State<CalendarIntegrationScreen> createState() =>
      _CalendarIntegrationScreenState();
}

class _CalendarIntegrationScreenState extends State<CalendarIntegrationScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<Note> _notesForSelectedDay = [];
  Map<DateTime, List<Note>> _notesMap = {};

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    // Load notes and organize them by date
    // This would typically come from the BLoC
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              setState(() {
                _selectedDay = DateTime.now();
                _focusedDay = DateTime.now();
              });
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
              borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
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
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) => _getNotesForDay(day),
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _notesForSelectedDay = _getNotesForDay(selectedDay);
                });
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
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
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
                borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
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
                        _formatSelectedDay(),
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
                        icon: Icon(Icons.add, color: AppColors.primaryColor),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSpacing.lg),

                  Expanded(
                    child: _notesForSelectedDay.isEmpty
                        ? _buildEmptyDayState()
                        : ListView.builder(
                            itemCount: _notesForSelectedDay.length,
                            itemBuilder: (context, index) {
                              final note = _notesForSelectedDay[index];
                              return _buildEventCard(note);
                            },
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
          _showCalendarIntegrationSetup();
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
  }

  List<Note> _getNotesForDay(DateTime day) {
    // Get notes that have alarms set for this day
    return _notesMap[DateTime(day.year, day.month, day.day)] ?? [];
  }

  String _formatSelectedDay() {
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

    return '${months[_selectedDay.month]} ${_selectedDay.day}, ${_selectedDay.year}';
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
    final time = alarm.alarmTime;
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  void _showCalendarIntegrationSetup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CalendarIntegrationSetupSheet(),
    );
  }
}

class _CalendarIntegrationSetupSheet extends StatefulWidget {
  @override
  State<_CalendarIntegrationSetupSheet> createState() =>
      _CalendarIntegrationSetupSheetState();
}

class _CalendarIntegrationSetupSheetState
    extends State<_CalendarIntegrationSetupSheet> {
  bool _googleCalendarEnabled = false;
  bool _appleCalendarEnabled = false;
  bool _outlookEnabled = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              'Connect your calendar apps to sync reminders and events',
              style: AppTypography.bodyMedium(
                context,
                AppColors.textSecondary(context),
              ),
            ),

            SizedBox(height: AppSpacing.xxl),

            // Calendar Options
            _buildCalendarOption(
              'Google Calendar',
              'Sync with your Google account',
              Icons.calendar_today,
              _googleCalendarEnabled,
              (value) => setState(() => _googleCalendarEnabled = value),
            ),

            SizedBox(height: AppSpacing.lg),

            _buildCalendarOption(
              'Apple Calendar',
              'Sync with iCloud calendar',
              Icons.event,
              _appleCalendarEnabled,
              (value) => setState(() => _appleCalendarEnabled = value),
            ),

            SizedBox(height: AppSpacing.lg),

            _buildCalendarOption(
              'Outlook Calendar',
              'Sync with Microsoft Outlook',
              Icons.calendar_month,
              _outlookEnabled,
              (value) => setState(() => _outlookEnabled = value),
            ),

            const Spacer(),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Save calendar integration settings
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                  ),
                ),
                child: Text(
                  'Save Settings',
                  style: AppTypography.button(context, Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarOption(
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
