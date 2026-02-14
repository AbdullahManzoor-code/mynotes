import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/domain/entities/alarm.dart';
import 'package:mynotes/presentation/bloc/params/alarm_params.dart';

class AlarmCardWidget extends StatelessWidget {
  final dynamic alarm; // Can be Alarm or AlarmParams
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

  // Getters to handle both Alarm and AlarmParams
  String get _id => alarm is Alarm
      ? (alarm as Alarm).id
      : (alarm as AlarmParams).alarmId ?? '';
  String get _message =>
      alarm is Alarm ? (alarm as Alarm).message : (alarm as AlarmParams).title;
  DateTime get _scheduledTime => alarm is Alarm
      ? (alarm as Alarm).scheduledTime
      : (alarm as AlarmParams).alarmTime;
  bool get _isEnabled => alarm is Alarm
      ? (alarm as Alarm).isEnabled
      : (alarm as AlarmParams).isEnabled;
  AlarmStatus get _status =>
      alarm is Alarm ? (alarm as Alarm).status : (alarm as AlarmParams).status;
  DateTime? get _snoozedUntil => alarm is Alarm
      ? (alarm as Alarm).snoozedUntil
      : (alarm as AlarmParams).snoozedUntil;
  bool get _isOverdue => alarm is Alarm
      ? (alarm as Alarm).isOverdue
      : (alarm as AlarmParams).isOverdue;
  String get _timeRemaining => alarm is Alarm
      ? (alarm as Alarm).timeRemaining
      : _calculateTimeRemaining();
  AlarmIndicator get _indicator =>
      alarm is Alarm ? (alarm as Alarm).indicator : _calculateIndicator();
  AlarmRecurrence get _recurrence => alarm is Alarm
      ? (alarm as Alarm).recurrence
      : (alarm as AlarmParams).isRecurring
      ? AlarmRecurrence.daily
      : AlarmRecurrence.none;
  List<int> get _weekDays => alarm is Alarm
      ? (alarm as Alarm).weekDays ?? []
      : (alarm as AlarmParams).repeatDays;

  String _calculateTimeRemaining() {
    final params = alarm as AlarmParams;
    final now = DateTime.now();
    final effectiveTime = params.snoozedUntil ?? params.alarmTime;
    final difference = effectiveTime.difference(now);

    if (difference.isNegative) {
      final absDiff = difference.abs();
      if (absDiff.inHours > 24) return '${absDiff.inDays}d ago';
      if (absDiff.inMinutes > 60) return '${absDiff.inHours}h ago';
      return '${absDiff.inMinutes}m ago';
    }

    if (difference.inDays > 0) return 'in ${difference.inDays}d';
    if (difference.inHours > 0) return 'in ${difference.inHours}h';
    return 'in ${difference.inMinutes}m';
  }

  AlarmIndicator _calculateIndicator() {
    final params = alarm as AlarmParams;
    if (!params.isEnabled || params.status == AlarmStatus.completed) {
      return AlarmIndicator.inactive;
    }
    if (params.isOverdue) return AlarmIndicator.overdue;
    final now = DateTime.now();
    final effectiveTime = params.snoozedUntil ?? params.alarmTime;
    final oneHourFromNow = now.add(const Duration(hours: 1));
    if (effectiveTime.isAfter(now) && effectiveTime.isBefore(oneHourFromNow)) {
      return AlarmIndicator.soon;
    }
    return AlarmIndicator.future;
  }

  @override
  Widget build(BuildContext context) {
    final indicator = _indicator;
    final statusColor = _getIndicatorColor(indicator);
    final statusIcon = _getIndicatorIcon(indicator);

    return Slidable(
      key: ValueKey(_id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          if (_status == AlarmStatus.triggered ||
              _status == AlarmStatus.snoozed)
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
                            _message,
                            style: AppTypography.heading3(context).copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: _status == AlarmStatus.completed
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
                                _formatDateTime(_scheduledTime),
                                style: AppTypography.body2(context).copyWith(
                                  color: Colors.grey.shade700,
                                  fontSize: 13.sp,
                                ),
                              ),
                              if (_recurrence != AlarmRecurrence.none) ...[
                                SizedBox(width: 8.w),
                                Icon(
                                  Icons.repeat,
                                  size: 14.sp,
                                  color: Colors.grey.shade600,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  _recurrence.displayName,
                                  style: AppTypography.caption(context)
                                      .copyWith(
                                        color: Colors.grey.shade600,
                                        fontSize: 11.sp,
                                      ),
                                ),
                              ],
                            ],
                          ),
                          if (_message.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              _message,
                              style: AppTypography.caption(
                                context,
                              ).copyWith(color: Colors.grey.shade600),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (_status == AlarmStatus.snoozed) ...[
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
                                    'Snoozed until ${_formatDateTime(_snoozedUntil!)}',
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
                              _timeRemaining,
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
                        value: _status != AlarmStatus.completed,
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
