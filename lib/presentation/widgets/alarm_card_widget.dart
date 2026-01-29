import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../design_system/design_system.dart';
import '../../domain/entities/alarm.dart';
import '../../core/services/alarm_service.dart';

class AlarmCardWidget extends StatelessWidget {
  final Alarm alarm;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final Function(SnoozePreset) onSnooze;
  final VoidCallback onReschedule;
  final VoidCallback onDelete;

  const AlarmCardWidget({
    super.key,
    required this.alarm,
    required this.onTap,
    required this.onToggle,
    required this.onSnooze,
    required this.onReschedule,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final indicator = alarm.indicator;
    final statusColor = _getIndicatorColor(indicator);
    final statusIcon = _getIndicatorIcon(indicator);

    return Slidable(
      key: ValueKey(alarm.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          if (alarm.status == AlarmStatus.triggered ||
              alarm.status == AlarmStatus.snoozed)
            ..._buildSnoozeActions(),
          SlidableAction(
            onPressed: (_) => onReschedule(),
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            icon: Icons.edit_calendar,
            label: 'Reschedule',
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Status Indicator Bar
              Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    // Status Icon
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(statusIcon, color: statusColor, size: 28.sp),
                    ),
                    SizedBox(width: 16.w),
                    // Alarm Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alarm.message,
                            style: AppTypography.heading3(context).copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: alarm.status == AlarmStatus.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14.sp,
                                color: Colors.grey.shade600,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                _formatDateTime(alarm.scheduledTime),
                                style: AppTypography.body2(context).copyWith(
                                  color: Colors.grey.shade700,
                                  fontSize: 13.sp,
                                ),
                              ),
                              if (alarm.recurrence != AlarmRecurrence.none) ...[
                                SizedBox(width: 8.w),
                                Icon(
                                  Icons.repeat,
                                  size: 14.sp,
                                  color: Colors.grey.shade600,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  alarm.recurrence.displayName,
                                  style: AppTypography.caption(context)
                                      .copyWith(
                                        color: Colors.grey.shade600,
                                        fontSize: 11.sp,
                                      ),
                                ),
                              ],
                            ],
                          ),
                          if (alarm.message.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              alarm.message,
                              style: AppTypography.caption(
                                context,
                              ).copyWith(color: Colors.grey.shade600),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (alarm.status == AlarmStatus.snoozed) ...[
                            SizedBox(height: 6.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.snooze,
                                    size: 12.sp,
                                    color: Colors.orange.shade700,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Snoozed until ${_formatDateTime(alarm.snoozedUntil!)}',
                                    style: AppTypography.caption(context)
                                        .copyWith(
                                          color: Colors.orange.shade700,
                                          fontSize: 10.sp,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (indicator == AlarmIndicator.overdue ||
                              indicator == AlarmIndicator.soon) ...[
                            SizedBox(height: 6.h),
                            Text(
                              alarm.timeRemaining,
                              style: AppTypography.caption(context).copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Toggle Switch
                    Transform.scale(
                      scale: 0.9,
                      child: Switch(
                        value: alarm.status != AlarmStatus.completed,
                        onChanged: (_) => onToggle(),
                        activeColor: AppColors.primaryColor,
                        inactiveThumbColor: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<SlidableAction> _buildSnoozeActions() {
    return [
      SlidableAction(
        onPressed: (_) => onSnooze(SnoozePreset.tenMinutes),
        backgroundColor: Colors.orange.shade400,
        foregroundColor: Colors.white,
        icon: Icons.snooze,
        label: '+10min',
      ),
      SlidableAction(
        onPressed: (_) => onSnooze(SnoozePreset.oneHour),
        backgroundColor: Colors.orange.shade500,
        foregroundColor: Colors.white,
        icon: Icons.access_time,
        label: '+1hr',
      ),
    ];
  }

  Color _getIndicatorColor(AlarmIndicator indicator) {
    switch (indicator) {
      case AlarmIndicator.overdue:
        return Colors.red.shade700;
      case AlarmIndicator.soon:
        return Colors.orange.shade700;
      case AlarmIndicator.future:
        return Colors.green.shade700;
      case AlarmIndicator.inactive:
        return Colors.grey.shade600;
    }
  }

  IconData _getIndicatorIcon(AlarmIndicator indicator) {
    switch (indicator) {
      case AlarmIndicator.overdue:
        return Icons.warning_amber;
      case AlarmIndicator.soon:
        return Icons.notifications_active;
      case AlarmIndicator.future:
        return Icons.schedule;
      case AlarmIndicator.inactive:
        return Icons.check_circle;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final alarmDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final timeStr = '$displayHour:${minute.toString().padLeft(2, '0')} $period';

    if (alarmDate == today) {
      return 'Today, $timeStr';
    } else if (alarmDate == tomorrow) {
      return 'Tomorrow, $timeStr';
    } else {
      final monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${monthNames[dateTime.month - 1]} ${dateTime.day}, $timeStr';
    }
  }
}
