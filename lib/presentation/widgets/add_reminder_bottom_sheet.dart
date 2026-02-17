import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/injection_container.dart';
import 'package:mynotes/presentation/bloc/params/alarm_params.dart';
import '../design_system/design_system.dart';
import '../../domain/entities/alarm.dart';
import '../bloc/alarm/alarms_bloc.dart';

/// Add Reminder Bottom Sheet
/// Specialized sheet for creating system alarms/reminders
/// Refactored to use AlarmsBloc for centralized state management
class AddReminderBottomSheet extends StatelessWidget {
  final Function(Alarm)? onReminderCreated;
  final Alarm? editAlarm;

  const AddReminderBottomSheet({
    super.key,
    this.onReminderCreated,
    this.editAlarm,
  });

  static void show(
    BuildContext context, {
    Alarm? editAlarm,
    Function(Alarm)? onReminderCreated,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddReminderBottomSheet(
        editAlarm: editAlarm,
        onReminderCreated: onReminderCreated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initialize draft in bloc if not already there or if editing a different one
    final alarmsBloc = context.read<AlarmsBloc>();
    final currentState = alarmsBloc.state;

    if (currentState is AlarmLoaded) {
      if (currentState.draftParams == null ||
          (editAlarm != null &&
              currentState.draftParams!.alarmId != editAlarm!.id)) {
        final initialParams = editAlarm != null
            ? AlarmParams.fromAlarm(editAlarm!)
            : AlarmParams(
                alarmTime: DateTime.now().add(const Duration(hours: 1)),
                title: '',
                createdAt: DateTime.now(),
              );
        alarmsBloc.add(UpdateAlarmDraftEvent(params: initialParams));
      }
    }

    return BlocBuilder<AlarmsBloc, AlarmState>(
      builder: (context, state) {
        if (state is! AlarmLoaded || state.draftParams == null) {
          return Container(
            height: 200.h,
            color: AppColors.surface(context),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final draft = state.draftParams!;
        final textController = TextEditingController(text: draft.title);
        textController.selection = TextSelection.fromPosition(
          TextPosition(offset: textController.text.length),
        );

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
            left: 24.w,
            right: 24.w,
            top: 24.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    editAlarm != null ? 'Edit Reminder' : 'New Reminder',
                    style: AppTypography.heading3(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              TextField(
                controller: textController,
                autofocus: editAlarm == null,
                style: AppTypography.bodyLarge(context),
                decoration: InputDecoration(
                  hintText: 'What do you want to be reminded about?',
                  hintStyle: AppTypography.bodyLarge(
                    context,
                    AppColors.textMuted,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.border(context)),
                  ),
                ),
                onChanged: (value) =>
                    _updateDraft(context, draft.copyWith(title: value)),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: _buildPickerTile(
                      context,
                      label: 'Date',
                      value: _formatDate(draft.alarmTime),
                      icon: Icons.calendar_today,
                      onTap: () => _selectDate(context, draft),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildPickerTile(
                      context,
                      label: 'Time',
                      value: _formatTime(draft.alarmTime),
                      icon: Icons.access_time,
                      onTap: () => _selectTime(context, draft),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state is AlarmLoading
                      ? null
                      : () => _saveReminder(context, draft),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: state is AlarmLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          editAlarm != null
                              ? 'Update Reminder'
                              : 'Set Reminder',
                          style: AppTypography.bodyLarge(
                            context,
                            Colors.white,
                            FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPickerTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.background(context),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.captionSmall(context, AppColors.textMuted),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(icon, size: 16.sp, color: AppColors.primary),
                SizedBox(width: 8.w),
                Text(
                  value,
                  style: AppTypography.bodyMedium(
                    context,
                    null,
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _updateDraft(BuildContext context, AlarmParams params) {
    context.read<AlarmsBloc>().add(UpdateAlarmDraftEvent(params: params));
  }

  void _selectDate(BuildContext context, AlarmParams draft) async {
    final date = await showDatePicker(
      context: context,
      initialDate: draft.alarmTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null) {
      final newTime = DateTime(
        date.year,
        date.month,
        date.day,
        draft.alarmTime.hour,
        draft.alarmTime.minute,
      );
      _updateDraft(context, draft.copyWith(alarmTime: newTime));
    }
  }

  void _selectTime(BuildContext context, AlarmParams draft) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(draft.alarmTime),
    );

    if (time != null) {
      final newTime = DateTime(
        draft.alarmTime.year,
        draft.alarmTime.month,
        draft.alarmTime.day,
        time.hour,
        time.minute,
      );
      _updateDraft(context, draft.copyWith(alarmTime: newTime));
    }
  }

  void _saveReminder(BuildContext context, AlarmParams draft) {
    if (draft.title.trim().isEmpty) {
      getIt<GlobalUiService>().showWarning('Please enter a reminder message');
      return;
    }

    if (editAlarm != null) {
      context.read<AlarmsBloc>().add(UpdateAlarmEvent(draft));
    } else {
      context.read<AlarmsBloc>().add(AddAlarmEvent(draft));
    }

    context.read<AlarmsBloc>().add(const UpdateAlarmDraftEvent(clear: true));
    Navigator.pop(context);

    if (onReminderCreated != null) {
      onReminderCreated!(draft.toAlarm());
    }
  }
}
