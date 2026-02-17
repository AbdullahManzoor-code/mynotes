import 'package:flutter/material.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/domain/entities/alarm.dart';

/// Unified alarm header widget for editing alarm details
/// Handles: Title, time picker, recurrence selector
class AlarmHeader extends StatefulWidget {
  final Alarm alarm;
  final TextEditingController titleController;
  final ValueChanged<DateTime> onTimeChanged;
  final ValueChanged<AlarmRecurrence> onRecurrenceChanged;
  final bool isEditing;

  const AlarmHeader({
    super.key,
    required this.alarm,
    required this.titleController,
    required this.onTimeChanged,
    required this.onRecurrenceChanged,
    this.isEditing = false,
  });

  @override
  State<AlarmHeader> createState() => _AlarmHeaderState();
}

class _AlarmHeaderState extends State<AlarmHeader> {
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = widget.titleController;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: TextFormField(
            controller: _titleController,
            enabled: widget.isEditing,
            style: AppTypography.heading2(
              context,
            ).copyWith(fontSize: 24.sp, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: 'Alarm Title',
              hintStyle: AppTypography.heading2(context).copyWith(
                fontSize: 24.sp,
                color: context.theme.disabledColor.withOpacity(0.5),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            maxLines: 1,
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        Divider(height: 1.h, thickness: 1),
        // Time picker
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Icon(Icons.schedule, size: 20.r, color: context.primaryColor),
              SizedBox(width: 12.w),
              Expanded(
                child: InkWell(
                  onTap: widget.isEditing ? () => _selectTime(context) : null,
                  child: Text(
                    _formatDateTime(widget.alarm.scheduledTime),
                    style: AppTypography.heading3(context).copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: widget.isEditing
                          ? context.primaryColor
                          : context.theme.disabledColor,
                    ),
                  ),
                ),
              ),
              if (widget.isEditing)
                Icon(Icons.edit, size: 18.r, color: context.primaryColor),
            ],
          ),
        ),
        Divider(height: 1.h, thickness: 1),
        // Recurrence selector
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Icon(Icons.repeat, size: 20.r, color: context.primaryColor),
              SizedBox(width: 12.w),
              Expanded(
                child: PopupMenuButton<AlarmRecurrence>(
                  initialValue: widget.alarm.recurrence,
                  onSelected: (AlarmRecurrence value) {
                    widget.onRecurrenceChanged(value);
                  },
                  itemBuilder: (BuildContext context) => AlarmRecurrence.values
                      .map(
                        (recurrence) => PopupMenuItem<AlarmRecurrence>(
                          value: recurrence,
                          child: Row(
                            children: [
                              Icon(_getRecurrenceIcon(recurrence), size: 18.r),
                              SizedBox(width: 8.w),
                              Text(_getRecurrenceLabel(recurrence)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 6.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getRecurrenceLabel(widget.alarm.recurrence),
                          style: AppTypography.body1(context).copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(Icons.expand_more, size: 18.r),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(widget.alarm.scheduledTime),
    );

    if (picked != null) {
      final now = widget.alarm.scheduledTime;
      final newTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      widget.onTimeChanged(newTime);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final day = dateTime.difference(DateTime.now()).inDays;

    String dateStr = '';
    if (day == 0) {
      dateStr = 'Today';
    } else if (day == 1) {
      dateStr = 'Tomorrow';
    } else if (day > 0) {
      dateStr = '${dateTime.day}/${dateTime.month}';
    }

    return '$dateStr at $hour:$minute';
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
        return 'Custom Days';
      case AlarmRecurrence.none:
        return 'Once';
    }
  }

  IconData _getRecurrenceIcon(AlarmRecurrence recurrence) {
    switch (recurrence) {
      case AlarmRecurrence.daily:
        return Icons.repeat;
      case AlarmRecurrence.weekly:
        return Icons.calendar_view_week;
      case AlarmRecurrence.monthly:
        return Icons.calendar_month;
      case AlarmRecurrence.yearly:
        return Icons.event;
      case AlarmRecurrence.custom:
        return Icons.dashboard_customize;
      case AlarmRecurrence.none:
        return Icons.today;
    }
  }
}
