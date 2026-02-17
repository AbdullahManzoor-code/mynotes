import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/domain/entities/alarm.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'alarm_card.dart';

/// Reusable alarms list component displaying alarms in active/completed sections
/// Supports list and grid layouts with filtering and callbacks
class AlarmsList extends StatelessWidget {
  final List<Alarm> activeAlarms;
  final List<Alarm> completedAlarms;
  final ValueChanged<Alarm>? onAlarmTap;
  final ValueChanged<String>? onAlarmDelete;
  final ValueChanged<String>? onAlarmComplete;
  final ValueChanged<String>? onAlarmToggle;
  final ValueChanged<String>? onAlarmSnooze;
  final bool isGridView;

  const AlarmsList({
    super.key,
    required this.activeAlarms,
    required this.completedAlarms,
    this.onAlarmTap,
    this.onAlarmDelete,
    this.onAlarmComplete,
    this.onAlarmToggle,
    this.onAlarmSnooze,
    this.isGridView = false,
  });

  @override
  Widget build(BuildContext context) {
    if (activeAlarms.isEmpty && completedAlarms.isEmpty) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Alarms Section
          if (activeAlarms.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: Text(
                    'Active (${activeAlarms.length})',
                    style: AppTypography.heading3(
                      context,
                    ).copyWith(fontSize: 16.sp, fontWeight: FontWeight.w700),
                  ),
                ),
                _buildAlarmsList(context, activeAlarms),
              ],
            ),
          // Completed Alarms Section
          if (completedAlarms.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: Text(
                    'Completed (${completedAlarms.length})',
                    style: AppTypography.heading3(context).copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: context.theme.disabledColor,
                    ),
                  ),
                ),
                _buildAlarmsList(context, completedAlarms, isCompleted: true),
              ],
            ),
        ],
      ),
    );
  }

  /// Build alarms list based on view mode (list or grid)
  Widget _buildAlarmsList(
    BuildContext context,
    List<Alarm> alarms, {
    bool isCompleted = false,
  }) {
    if (isGridView) {
      return MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8.h,
        crossAxisSpacing: 8.w,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        itemCount: alarms.length,
        itemBuilder: (context, index) =>
            _buildAlarmCard(context, alarms[index], isCompleted),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: alarms.length,
      itemBuilder: (context, index) =>
          _buildAlarmCard(context, alarms[index], isCompleted),
    );
  }

  /// Build single alarm card with callbacks
  Widget _buildAlarmCard(BuildContext context, Alarm alarm, bool isCompleted) {
    return AlarmCard(
      alarm: alarm,
      onTap: () => onAlarmTap?.call(alarm),
      onDelete: onAlarmDelete != null
          ? () => onAlarmDelete?.call(alarm.id)
          : null,
      onComplete: onAlarmComplete != null
          ? () => onAlarmComplete?.call(alarm.id)
          : null,
      onToggle: onAlarmToggle != null
          ? () => onAlarmToggle?.call(alarm.id)
          : null,
      onSnooze: onAlarmSnooze != null
          ? () => onAlarmSnooze?.call(alarm.id)
          : null,
      enableActions: !isCompleted,
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 64.h),
          Icon(
            Icons.alarm_add_outlined,
            size: 80.r,
            color: context.theme.disabledColor.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Alarms',
            style: AppTypography.heading2(
              context,
            ).copyWith(fontSize: 18.sp, color: context.theme.disabledColor),
          ),
          SizedBox(height: 8.h),
          Text(
            'Create an alarm to get started',
            style: AppTypography.body2(context).copyWith(
              fontSize: 13.sp,
              color: context.theme.disabledColor.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 64.h),
        ],
      ),
    );
  }
}
