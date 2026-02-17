import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'dart:ui' as ui;
import 'package:mynotes/domain/entities/alarm.dart';
import 'package:mynotes/presentation/bloc/alarm/alarm_bloc.dart';
import 'package:mynotes/presentation/bloc/alarm/alarm_event.dart';
import 'package:mynotes/presentation/bloc/alarm/alarm_state.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/presentation/widgets/alarm/alarms_list.dart';
import 'package:mynotes/presentation/widgets/alarm/alarms_list_header.dart';
import 'package:mynotes/presentation/widgets/alarm/alarms_template_section.dart';
import 'package:mynotes/core/constants/app_strings.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// PHASE 3: ALARMS & REMINDERS REFACTORING
/// Enhanced Alarms List Screen - StatelessWidget with BLoC
/// ════════════════════════════════════════════════════════════════════════════
///
/// IMPLEMENTATION PLAN:
/// ════════════════════════════════════════════════════════════════════════════
/// 1. STATE MANAGEMENT: All state handled by AlarmsBloc
///    - Alarms list (active/completed)
///    - Search query and filtering
///    - Sort options (by time, priority, recurrence)
///    - View mode (list/grid)
///    - Loading/error states
///
/// 2. BLoC EVENTS DISPATCHED:
///    - LoadAlarmsEvent() - Load all active alarms
///    - SearchAlarmsEvent(query) - Search alarms by message
///    - AddAlarmEvent(params) - Create new alarm
///    - DeleteAlarmEvent(id) - Delete alarm
///    - SnoozeAlarmEvent(id) - Snooze alarm
///    - CompleteAlarmEvent(id) - Mark as complete
///    - ToggleAlarmEvent(id) - Toggle active/inactive
///    - ClearCompletedAlarmsEvent() - Clear all completed
///
/// 3. MAIN BUILD STRUCTURE:
///    - BLocBuilder<AlarmsBloc> wraps entire content
///    - Handles: Loading, Error, Empty, Loaded states
///    - Passes appropriate data to child widgets
///
/// 4. WIDGET COMPOSITION:
///    - AlarmsListHeader - Search & filters (BLocBuilder)
///    - AlarmsTemplateSection - Template picker (StatelessWidget)
///    - AlarmsList - Alarms display (BLocBuilder state-dependent)
///
/// 5. RESPONSIVE DESIGN:
///    All widgets use flutter_screenutil (.w, .h, .r, .sp)
///    - Mobile: Single column, auto-layout with templates
///    - Tablet: Grid view option, centered content
///    - Desktop: Full width with constraints
///
/// 6. KEY DIFFERENCES FROM NOTES & TODOS:
///    - Time-based priority (overdue, soon, future)
///    - Snooze functionality integrated
///    - Sound/vibration configuration
///    - Linked note/todo support
///    - Recurrence pattern support
/// ════════════════════════════════════════════════════════════════════════════

/// Enhanced Alarms List Screen - StatelessWidget
class EnhancedAlarmsListScreenRefactored extends StatelessWidget {
  const EnhancedAlarmsListScreenRefactored({super.key});

  static final List<AlarmTemplate> _templates = [
    AlarmTemplate(
      title: 'Morning',
      icon: Icons.light_mode,
      color: Colors.orange,
      description: 'Start your day',
      contentGenerator: _generateMorningTemplate,
    ),
    AlarmTemplate(
      title: 'Afternoon',
      icon: Icons.wb_sunny,
      color: Colors.amber,
      description: 'Midday reminder',
      contentGenerator: _generateAfternoonTemplate,
    ),
    AlarmTemplate(
      title: 'Evening',
      icon: Icons.dark_mode,
      color: AppColors.accentPurple,
      description: 'End of day',
      contentGenerator: _generateEveningTemplate,
    ),
    AlarmTemplate(
      title: 'Custom',
      icon: Icons.schedule,
      color: AppColors.primary,
      description: 'Set custom time',
      contentGenerator: _generateCustomTemplate,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    AppLogger.i('Building EnhancedAlarmsListScreenRefactored');

    // Load alarms on widget creation
    context.read<AlarmsBloc>().add(const LoadAlarms());

    return Scaffold(
      backgroundColor: AppColors.background(context),
      extendBodyBehindAppBar: true,
      floatingActionButton: _buildFAB(context),
      body: Stack(
        children: [
          // Background glow effect
          _buildBackgroundGlow(context),
          // Main content with BLoC builder
          _buildMainContent(context),
        ],
      ),
    );
  }

  /// ════════════════════════════════════════════════════════════════════════
  /// MAIN CONTENT BUILDER - Handles all BLoC state
  /// ════════════════════════════════════════════════════════════════════════
  Widget _buildMainContent(BuildContext context) {
    return BlocBuilder<AlarmsBloc, AlarmState>(
      builder: (context, state) {
        AppLogger.i('AlarmsBloc state: ${state.runtimeType}');

        // Handle different states
        if (state is AlarmLoading) {
          return _buildLoadingState(context);
        } else if (state is AlarmError) {
          return _buildErrorState(context, state);
        } else if (state is AlarmInitial) {
          return _buildEmptyState(context);
        } else if (state is AlarmsLoaded) {
          return _buildAlarmsLoadedState(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// ════════════════════════════════════════════════════════════════════════
  /// STATE: LOADING
  /// ════════════════════════════════════════════════════════════════════════
  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50.r,
            height: 50.r,
            child: const CircularProgressIndicator(),
          ),
          SizedBox(height: 16.h),
          Text(
            AppStrings.loading,
            style: AppTypography.body1(context).copyWith(fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  /// ════════════════════════════════════════════════════════════════════════
  /// STATE: ERROR
  /// ════════════════════════════════════════════════════════════════════════
  Widget _buildErrorState(BuildContext context, AlarmError error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60.r, color: context.errorColor),
          SizedBox(height: 16.h),
          Text(
            AppStrings.error,
            style: AppTypography.heading2(
              context,
            ).copyWith(fontSize: 18.sp, color: context.errorColor),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              error.message,
              textAlign: TextAlign.center,
              style: AppTypography.body2(context).copyWith(fontSize: 14.sp),
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => context.read<AlarmsBloc>().add(const LoadAlarms()),
            child: Text(AppStrings.retry),
          ),
        ],
      ),
    );
  }

  /// ════════════════════════════════════════════════════════════════════════
  /// STATE: EMPTY
  /// ════════════════════════════════════════════════════════════════════════
  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: kToolbarHeight),
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none_outlined,
                  size: 100.r,
                  color: context.theme.disabledColor,
                ),
                SizedBox(height: 24.h),
                Text(
                  'No Alarms Yet',
                  style: AppTypography.heading2(context).copyWith(
                    fontSize: 20.sp,
                    color: context.theme.disabledColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Create your first alarm to get started',
                  textAlign: TextAlign.center,
                  style: AppTypography.body2(context).copyWith(
                    fontSize: 14.sp,
                    color: context.theme.disabledColor.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 32.h),
                AlarmsTemplateSection(
                  templates: _templates,
                  onTemplateSelected: _createFromTemplate,
                  isExpanded: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ════════════════════════════════════════════════════════════════════════
  /// STATE: LOADED - Main content layout
  /// ════════════════════════════════════════════════════════════════════════
  Widget _buildAlarmsLoadedState(BuildContext context, AlarmsLoaded state) {
    final activeAlarms = state.alarms
        .where((a) => a.isEnabled && a.status != AlarmStatus.completed)
        .map((ap) => ap.toAlarm())
        .toList();
    final completedAlarms = state.alarms
        .where((a) => a.status == AlarmStatus.completed)
        .map((ap) => ap.toAlarm())
        .toList();

    final overdueCount = activeAlarms.where((a) => a.isOverdue).length;
    final soonCount = activeAlarms.where((a) => a.isDueSoon).length;

    return Column(
      children: [
        SizedBox(height: kToolbarHeight),
        // Status indicator
        _buildStatusSection(
          context,
          overdueCount,
          soonCount,
          activeAlarms.length,
        ),
        // Search & Filter Header
        _buildHeaderSection(context, state),
        // Template Section
        AlarmsTemplateSection(
          templates: _templates,
          onTemplateSelected: _createFromTemplate,
          isExpanded: activeAlarms.isEmpty,
        ),
        // Alarms List
        Expanded(
          child: AlarmsList(
            activeAlarms: activeAlarms,
            completedAlarms: completedAlarms,
            onAlarmTap: (alarm) {
              AppLogger.i('Alarm tapped: ${alarm.id}');
              Navigator.pushNamed(
                context,
                '/alarm-editor',
                arguments: {'alarm': alarm},
              );
            },
            onAlarmDelete: (alarmId) {
              AppLogger.i('Alarm delete requested: $alarmId');
              context.read<AlarmsBloc>().add(
                DeleteAlarm(alarmId: alarmId, alarmId),
              );
            },
            onAlarmComplete: (alarmId) {
              AppLogger.i('Alarm completion requested: $alarmId');
              context.read<AlarmsBloc>().add(CompleteAlarm(alarmId: alarmId));
            },
            onAlarmToggle: (alarmId) {
              AppLogger.i('Alarm toggle requested: $alarmId');
              context.read<AlarmsBloc>().add(ToggleAlarm(alarmId: alarmId));
            },
            onAlarmSnooze: (alarmId) {
              AppLogger.i('Alarm snooze requested: $alarmId');
              context.read<AlarmsBloc>().add(SnoozeAlarm(alarmId: alarmId));
            },
          ),
        ),
      ],
    );
  }

  /// ════════════════════════════════════════════════════════════════════════
  /// STATUS SECTION - Shows status indicators
  /// ════════════════════════════════════════════════════════════════════════
  Widget _buildStatusSection(
    BuildContext context,
    int overdueCount,
    int soonCount,
    int activeCount,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.theme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.theme.dividerColor, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (overdueCount > 0)
            Row(
              children: [
                Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  '$overdueCount overdue',
                  style: AppTypography.caption(context).copyWith(
                    fontSize: 11.sp,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          if (soonCount > 0 && overdueCount == 0)
            Row(
              children: [
                Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  '$soonCount due soon',
                  style: AppTypography.caption(context).copyWith(
                    fontSize: 11.sp,
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          Row(
            children: [
              Icon(
                Icons.notifications_active,
                size: 14.r,
                color: context.primaryColor,
              ),
              SizedBox(width: 4.w),
              Text(
                '$activeCount active',
                style: AppTypography.caption(
                  context,
                ).copyWith(fontSize: 11.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ════════════════════════════════════════════════════════════════════════
  /// HEADER SECTION - Search, Filter, View Options
  /// ════════════════════════════════════════════════════════════════════════
  Widget _buildHeaderSection(BuildContext context, AlarmsLoaded state) {
    return AlarmsListHeader(
      searchQuery: state.searchQuery,
      activeCount: state.alarms
          .where((a) => a.isEnabled && a.status != AlarmStatus.completed)
          .length,
      onSearchChanged: (query) {
        AppLogger.i('Searching alarms: $query');
        context.read<AlarmsBloc>().add(SearchAlarms(query: query));
      },
      onFilterTap: () {
        AppLogger.i('Filter tapped');
        _showFilterBottomSheet(context);
      },
      onViewOptionsTap: () {
        AppLogger.i('View options tapped');
        _showViewOptionsBottomSheet(context);
      },
    );
  }

  /// ════════════════════════════════════════════════════════════════════════
  /// BACKGROUND GLOW
  /// ════════════════════════════════════════════════════════════════════════
  Widget _buildBackgroundGlow(BuildContext context) {
    return Positioned(
      top: -100.h,
      right: -100.w,
      child: Container(
        width: 300.w,
        height: 300.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(0.08),
        ),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  /// ════════════════════════════════════════════════════════════════════════
  /// FLOATING ACTION BUTTON
  /// ════════════════════════════════════════════════════════════════════════
  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'alarms_fab',
      onPressed: () {
        AppLogger.i('New Alarm FAB pressed');
        Navigator.pushNamed(context, '/alarm-editor');
      },
      backgroundColor: AppColors.primary,
      elevation: 8,
      label: Text(
        'New Alarm',
        style: AppTypography.buttonMedium(context, Colors.white),
      ),
      icon: const Icon(Icons.add_alarm, color: Colors.white),
    );
  }

  /// ════════════════════════════════════════════════════════════════════════
  /// HELPER METHODS
  /// ════════════════════════════════════════════════════════════════════════

  void _createFromTemplate(AlarmTemplate template) {
    AppLogger.i('Creating alarm from template: ${template.title}');
  }

  void _showFilterBottomSheet(BuildContext context) {
    AppLogger.i('Showing filter bottom sheet');
    // TODO: Implement filter sheet
  }

  void _showViewOptionsBottomSheet(BuildContext context) {
    AppLogger.i('Showing view options bottom sheet');
    // TODO: Implement view options sheet
  }

  /// ════════════════════════════════════════════════════════════════════════
  /// TEMPLATE CONTENT GENERATORS
  /// ════════════════════════════════════════════════════════════════════════

  static String _generateMorningTemplate() => '''Morning Alarm - 07:00

Start your day right
□ Check calendar
□ Review daily goals
''';

  static String _generateAfternoonTemplate() => '''Afternoon Break - 13:00

Midday reminder
□ Lunch break
□ Hydrate
□ Stretch
''';

  static String _generateEveningTemplate() => '''Evening Reminder - 20:00

End of day wrap-up
□ Review accomplishments
□ Plan tomorrow
□ Wind down
''';

  static String _generateCustomTemplate() => '''Custom Alarm

Set your time and frequency
□ Time: 
□ Recurrence: 
□ Notification: 
''';
}
