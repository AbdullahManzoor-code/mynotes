import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/alarm.dart';
import '../../domain/entities/note.dart';
import '../bloc/alarm_bloc.dart';
import '../bloc/alarm_event.dart';

class AlarmBottomSheet extends StatefulWidget {
  final Note note;
  final Alarm? existingAlarm;

  const AlarmBottomSheet({Key? key, required this.note, this.existingAlarm})
    : super(key: key);

  @override
  State<AlarmBottomSheet> createState() => _AlarmBottomSheetState();
}

class _AlarmBottomSheetState extends State<AlarmBottomSheet> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late AlarmRepeatType _selectedRepeat;
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    final initialDate =
        widget.existingAlarm?.alarmTime ??
        DateTime.now().add(const Duration(minutes: 5));
    _selectedDate = initialDate;
    _selectedTime = TimeOfDay.fromDateTime(initialDate);
    _selectedRepeat = widget.existingAlarm?.repeatType ?? AlarmRepeatType.none;
    _messageController = TextEditingController(
      text: widget.existingAlarm?.message ?? widget.note.title,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _saveAlarm() {
    final scheduledDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (scheduledDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a future time')),
      );
      return;
    }

    final alarm = Alarm(
      id: widget.existingAlarm?.id ?? const Uuid().v4(),
      noteId: widget.note.id,
      alarmTime: scheduledDateTime,
      repeatType: _selectedRepeat,
      message: _messageController.text,
      createdAt: widget.existingAlarm?.createdAt ?? DateTime.now(),
      isActive: true,
      updatedAt: DateTime.now(),
    );

    if (widget.existingAlarm != null) {
      context.read<AlarmBloc>().add(UpdateAlarmEvent(alarm));
    } else {
      context.read<AlarmBloc>().add(AddAlarmEvent(alarm));
    }

    Navigator.pop(context, alarm); // Return the alarm object

    // Trigger confetti or success feedback in parent if needed (handled by listener usually)
  }

  @override
  Widget build(BuildContext context) {
    // Determine background color based on note color or default
    final bgColor = Color(widget.note.color.lightColor).withOpacity(0.95);

    return Container(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 24.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.existingAlarm != null ? 'Edit Reminder' : 'Add Reminder',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.black54),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Message Field
          TextField(
            controller: _messageController,
            decoration: InputDecoration(
              hintText: 'Reminder message...',
              filled: true,
              fillColor: Colors.white.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.edit_note, color: Colors.black54),
            ),
          ),

          SizedBox(height: 16.h),

          // Date & Time Selectors
          Row(
            children: [
              Expanded(
                child: _buildTimePickerButton(
                  icon: Icons.calendar_today,
                  label:
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(
                        const Duration(days: 3650),
                      ), // 10 years
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                    }
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTimePickerButton(
                  icon: Icons.access_time,
                  label: _selectedTime.format(context),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (time != null) {
                      setState(() => _selectedTime = time);
                    }
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Recurrence Chips
          Text(
            'Repeat',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            children: AlarmRepeatType.values.map((type) {
              final isSelected = _selectedRepeat == type;
              return ChoiceChip(
                label: Text(type.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedRepeat = type);
                },
                selectedColor: AppColors.primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                avatar: Text(type.icon),
                backgroundColor: Colors.white.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                  side: BorderSide(
                    color: isSelected ? Colors.transparent : Colors.black12,
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 32.h),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: _saveAlarm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 2,
              ),
              child: Text(
                'Set Reminder',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: Colors.black54),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

