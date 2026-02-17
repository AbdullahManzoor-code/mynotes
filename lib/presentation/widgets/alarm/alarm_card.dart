import 'package:flutter/material.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/domain/entities/alarm.dart';

/// Unified alarm card widget for displaying individual alarms
/// Shows: Time, recurrence, status, next trigger, actions
class AlarmCard extends StatelessWidget {
  final Alarm alarm;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onSnooze;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;
  final VoidCallback? onToggle;
  final bool enableActions;

  const AlarmCard({
    super.key,
    required this.alarm,
    this.onTap,
    this.onLongPress,
    this.onSnooze,
    this.onComplete,
    this.onDelete,
    this.onToggle,
    this.enableActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final indicatorColor = _getIndicatorColor(context);
    final timeRemaining = alarm.timeRemaining;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: context.theme.dividerColor, width: 1),
            color: alarm.isActive
                ? context.theme.cardColor
                : context.theme.disabledColor.withOpacity(0.08),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with time, status, actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Time and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Enable toggle
                            if (enableActions)
                              Padding(
                                padding: EdgeInsets.only(right: 8.w),
                                child: SizedBox(
                                  width: 24.r,
                                  height: 24.r,
                                  child: Transform.scale(
                                    scale: 0.8,
                                    child: Switch(
                                      value: alarm.isActive,
                                      onChanged: (_) => onToggle?.call(),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ),
                              ),
                            // Alarm icon and time
                            Icon(
                              Icons.notifications_active,
                              size: 18.r,
                              color: indicatorColor,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              _formatTime(alarm.scheduledTime),
                              style: AppTypography.heading3(context).copyWith(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: alarm.isActive
                                    ? context.primaryColor
                                    : context.theme.disabledColor,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            // Recurrence badge
                            if (alarm.recurrence != AlarmRecurrence.none)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: indicatorColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  _getRecurrenceLabel(alarm.recurrence),
                                  style: AppTypography.caption(context)
                                      .copyWith(
                                        fontSize: 10.sp,
                                        color: indicatorColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        // Message
                        Text(
                          alarm.message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body2(context).copyWith(
                            fontSize: 13.sp,
                            color: alarm.isActive
                                ? context.theme.disabledColor
                                : context.theme.disabledColor.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Actions menu
                  if (enableActions)
                    PopupMenuButton<String>(
                      onSelected: (String value) {
                        if (value == 'delete') {
                          onDelete?.call();
                        } else if (value == 'snooze') {
                          onSnooze?.call();
                        } else if (value == 'complete') {
                          onComplete?.call();
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        if (!alarm.isSnoozed)
                          const PopupMenuItem<String>(
                            value: 'snooze',
                            child: Row(
                              children: [
                                Icon(Icons.schedule),
                                SizedBox(width: 8),
                                Text('Snooze'),
                              ],
                            ),
                          ),
                        if (alarm.isActive &&
                            alarm.status != AlarmStatus.completed)
                          const PopupMenuItem<String>(
                            value: 'complete',
                            child: Row(
                              children: [
                                Icon(Icons.check_circle),
                                SizedBox(width: 8),
                                Text('Complete'),
                              ],
                            ),
                          ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(height: 8.h),
              // Time remaining and next occurrence
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          _getIndicatorIcon(alarm.indicator),
                          size: 14.r,
                          color: indicatorColor,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          timeRemaining,
                          style: AppTypography.caption(context).copyWith(
                            fontSize: 11.sp,
                            color: indicatorColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Linked items indicator
                  if (alarm.hasLinkedItem)
                    Tooltip(
                      message: alarm.linkedNoteId != null
                          ? 'Linked Note'
                          : 'Linked Todo',
                      child: Icon(
                        alarm.linkedNoteId != null
                            ? Icons.note_outlined
                            : Icons.check_box_outlined,
                        size: 14.r,
                        color: context.primaryColor,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getRecurrenceLabel(AlarmRecurrence recurrence) {
    switch (recurrence) {
      case AlarmRecurrence.daily:
        return 'Daily';
      case AlarmRecurrence.weekly:
        return 'Weekly';
      case AlarmRecurrence.monthly:
        return 'Monthly';
      case AlarmRecurrence.yearly:
        return 'Yearly';
      case AlarmRecurrence.custom:
        return 'Custom';
      case AlarmRecurrence.none:
        return 'Once';
    }
  }

  Color _getIndicatorColor(BuildContext context) {
    switch (alarm.indicator) {
      case AlarmIndicator.overdue:
        return Colors.red;
      case AlarmIndicator.soon:
        return Colors.orange;
      case AlarmIndicator.future:
        return context.primaryColor;
      case AlarmIndicator.inactive:
        return context.theme.disabledColor;
    }
  }

  IconData _getIndicatorIcon(AlarmIndicator indicator) {
    switch (indicator) {
      case AlarmIndicator.overdue:
        return Icons.error_outline;
      case AlarmIndicator.soon:
        return Icons.warning_outlined;
      case AlarmIndicator.future:
        return Icons.schedule;
      case AlarmIndicator.inactive:
        return Icons.pause_circle_outline;
    }
  }
}
