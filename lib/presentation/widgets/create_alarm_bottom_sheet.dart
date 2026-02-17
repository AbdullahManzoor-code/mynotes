import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/note/note_bloc.dart';
import 'package:mynotes/presentation/bloc/note/note_event.dart';
import 'package:mynotes/presentation/bloc/note/note_state.dart';
import 'package:mynotes/presentation/bloc/params/alarm_params.dart';
import '../design_system/design_system.dart';
import '../../domain/entities/alarm.dart';
import '../../domain/entities/note.dart';
import '../bloc/alarm/alarms_bloc.dart';
import '../../injection_container.dart' show getIt;
import 'package:mynotes/core/notifications/notification_service.dart';

class CreateAlarmBottomSheet extends StatefulWidget {
  final dynamic alarm; // Can be Alarm or AlarmParams

  const CreateAlarmBottomSheet({super.key, this.alarm});

  @override
  State<CreateAlarmBottomSheet> createState() => _CreateAlarmBottomSheetState();
}

class _CreateAlarmBottomSheetState extends State<CreateAlarmBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _messageController;
  late DateTime _selectedDateTime;
  late AlarmRecurrence _selectedRecurrence;
  late bool _vibrate;
  String? _linkedNoteId;
  String? _soundPath;
  List<Note>? _availableNotes;
  List<int> _selectedWeekDays = [];
  final bool _isLoadingNotes = false;

  // Helper getters for both Alarm and AlarmParams
  String? get _alarmMessage {
    if (widget.alarm == null) return null;
    return widget.alarm is Alarm
        ? (widget.alarm as Alarm).message
        : (widget.alarm as AlarmParams).title;
  }

  DateTime? get _alarmScheduledTime {
    if (widget.alarm == null) return null;
    return widget.alarm is Alarm
        ? (widget.alarm as Alarm).scheduledTime
        : (widget.alarm as AlarmParams).alarmTime;
  }

  AlarmRecurrence get _alarmRecurrence {
    if (widget.alarm == null) return AlarmRecurrence.none;
    if (widget.alarm is Alarm) {
      return (widget.alarm as Alarm).recurrence;
    }
    return (widget.alarm as AlarmParams).isRecurring
        ? AlarmRecurrence.daily
        : AlarmRecurrence.none;
  }

  bool get _alarmVibrate {
    if (widget.alarm == null) return true;
    return widget.alarm is Alarm
        ? (widget.alarm as Alarm).vibrate
        : (widget.alarm as AlarmParams).vibrate;
  }

  String? get _alarmLinkedNoteId {
    if (widget.alarm == null) return null;
    return widget.alarm is Alarm
        ? (widget.alarm as Alarm).linkedNoteId
        : (widget.alarm as AlarmParams).noteId;
  }

  String? get _alarmSoundPath {
    if (widget.alarm == null) return null;
    return widget.alarm is Alarm
        ? (widget.alarm as Alarm).soundPath
        : (widget.alarm as AlarmParams).sound;
  }

  List<int> get _alarmWeekDays {
    if (widget.alarm == null) return [];
    return widget.alarm is Alarm
        ? (widget.alarm as Alarm).weekDays ?? []
        : (widget.alarm as AlarmParams).repeatDays;
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: _alarmMessage ?? '');
    _messageController = TextEditingController(text: _alarmMessage ?? '');
    _selectedDateTime =
        _alarmScheduledTime ?? DateTime.now().add(const Duration(hours: 1));
    _selectedRecurrence = _alarmRecurrence;
    _vibrate = _alarmVibrate;
    _linkedNoteId = _alarmLinkedNoteId;
    _soundPath = _alarmSoundPath;
    _selectedWeekDays = _alarmWeekDays;
    _loadAvailableNotes();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableNotes() async {
    try {
      final notesBloc = context.read<NotesBloc>();
      // Get current notes from bloc state if available
      if (notesBloc.state is NotesLoaded) {
        final loadedNotes = (notesBloc.state as NotesLoaded).notes;
        if (mounted) {
          setState(() => _availableNotes = loadedNotes);
        }
      } else {
        // Trigger load if not already loaded
        notesBloc.add(const LoadNotesEvent());

        // Listen for the loaded state
        if (mounted) {
          notesBloc.stream.listen((state) {
            if (state is NotesLoaded && mounted) {
              setState(() => _availableNotes = state.notes);
            }
          });
        }
      }
    } catch (e) {
      AppLogger.e('Error loading notes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 24.h),
                  _buildTitleField(),
                  SizedBox(height: 24.h),
                  _buildDateTimePicker(),
                  SizedBox(height: 24.h),
                  _buildRecurrenceSelector(),
                  if (_selectedRecurrence == AlarmRecurrence.weekly ||
                      _selectedRecurrence == AlarmRecurrence.custom) ...[
                    SizedBox(height: 16.h),
                    _buildWeekDaySelector(),
                  ],
                  SizedBox(height: 24.h),
                  _buildVibrateSwitch(),
                  SizedBox(height: 24.h),
                  _buildNoteLinkingSelector(),
                  SizedBox(height: 24.h),
                  _buildSoundSelector(),
                  SizedBox(height: 32.h),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.alarm == null ? 'New Reminder' : 'Edit Reminder',
          style: AppTypography.heading2(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title',
          style: AppTypography.heading3(
            context,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'Enter reminder message',
            prefixIcon: const Icon(Icons.alarm),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a message';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date & Time',
          style: AppTypography.heading3(
            context,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: AppColors.primaryColor,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        _formatDate(_selectedDateTime),
                        style: AppTypography.body2(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: AppColors.primaryColor,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        _formatTime(_selectedDateTime),
                        style: AppTypography.body2(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecurrenceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repeat',
          style: AppTypography.heading3(
            context,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: AlarmRecurrence.values.map((recurrence) {
            final isSelected = _selectedRecurrence == recurrence;
            return ChoiceChip(
              label: Text(recurrence.displayName),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedRecurrence = recurrence);
                }
              },
              selectedColor: AppColors.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              avatar: Text(recurrence.icon, style: TextStyle(fontSize: 16.sp)),
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : Colors.grey.shade300,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWeekDaySelector() {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedRecurrence == AlarmRecurrence.custom
              ? 'Select Custom Days'
              : 'Select Days',
          style: AppTypography.body2(
            context,
          ).copyWith(fontWeight: FontWeight.w600, color: Colors.grey.shade700),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            final dayNumber = index + 1; // 1 = Monday, 7 = Sunday
            final isSelected = _selectedWeekDays.contains(dayNumber);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedWeekDays.remove(dayNumber);
                  } else {
                    _selectedWeekDays.add(dayNumber);
                  }
                });
              },
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryColor
                        : Colors.grey.shade300,
                  ),
                ),
                child: Center(
                  child: Text(
                    weekDays[index],
                    style: AppTypography.caption(context).copyWith(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildVibrateSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.vibration, color: AppColors.primaryColor, size: 24.sp),
            SizedBox(width: 12.w),
            Text(
              'Vibrate',
              style: AppTypography.body2(
                context,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Switch(
          value: _vibrate,
          onChanged: (value) => setState(() => _vibrate = value),
          activeColor: AppColors.primaryColor,
        ),
      ],
    );
  }

  Widget _buildNoteLinkingSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Link to Note (Optional)',
          style: AppTypography.heading3(
            context,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        if (_isLoadingNotes)
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.h),
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (_availableNotes == null || _availableNotes!.isEmpty)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'No notes available to link',
              style: AppTypography.body2(
                context,
              ).copyWith(color: Colors.grey.shade600),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: DropdownButtonFormField<String?>(
              value: _linkedNoteId,
              decoration: InputDecoration(
                hintText: 'Select a note to link',
                prefixIcon: const Icon(Icons.note),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    'No note linked',
                    style: AppTypography.body2(context),
                  ),
                ),
                ..._availableNotes!.map((note) {
                  return DropdownMenuItem<String?>(
                    value: note.id,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            note.title.isNotEmpty
                                ? note.title
                                : 'Untitled Note',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.body2(
                              context,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (note.content.isNotEmpty)
                            Text(
                              note.content.length > 50
                                  ? '${note.content.substring(0, 50)}...'
                                  : note.content,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption(
                                context,
                              ).copyWith(color: Colors.grey.shade600),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => _linkedNoteId = value);
              },
              dropdownColor: Colors.white,
              isExpanded: true,
            ),
          ),
      ],
    );
  }

  Widget _buildSoundSelector() {
    final soundOptions = {
      null: 'Default Sound',
      'default': 'System Default',
      'alarm_1': 'Alert Tone 1',
      'alarm_2': 'Alert Tone 2',
      'alarm_3': 'Gentle Chime',
      'alarm_4': 'Bell',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notification Sound (Optional)',
          style: AppTypography.heading3(
            context,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: DropdownButtonFormField<String?>(
            value: _soundPath,
            decoration: InputDecoration(
              hintText: 'Select notification sound',
              prefixIcon: const Icon(Icons.music_note),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
            items: soundOptions.entries.map((entry) {
              return DropdownMenuItem<String?>(
                value: entry.key,
                child: Row(
                  children: [
                    Icon(
                      entry.key == null ? Icons.music_note : Icons.done_all,
                      size: 18.sp,
                      color: AppColors.primaryColor,
                    ),
                    SizedBox(width: 8.w),
                    Text(entry.value, style: AppTypography.body2(context)),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _soundPath = value);
            },
            dropdownColor: Colors.white,
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Cancel',
              style: AppTypography.body2(
                context,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _saveAlarm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              widget.alarm == null ? 'Create Reminder' : 'Update Reminder',
              style: AppTypography.body2(
                context,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _saveAlarm() {
    if (!_formKey.currentState!.validate()) return;

    if ((_selectedRecurrence == AlarmRecurrence.weekly ||
            _selectedRecurrence == AlarmRecurrence.custom) &&
        _selectedWeekDays.isEmpty) {
      getIt<GlobalUiService>().showWarning(
        'Please select at least one day for ${_selectedRecurrence == AlarmRecurrence.custom ? 'custom' : 'weekly'} recurrence',
      );
      return;
    }

    final alarm = Alarm(
      id: widget.alarm?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      message: _titleController.text.trim(),
      scheduledTime: _selectedDateTime,
      recurrence: _selectedRecurrence,
      status: widget.alarm?.status ?? AlarmStatus.scheduled,
      linkedNoteId: _linkedNoteId,
      soundPath: _soundPath,
      vibrate: _vibrate,
      weekDays:
          (_selectedRecurrence == AlarmRecurrence.weekly ||
              _selectedRecurrence == AlarmRecurrence.custom)
          ? _selectedWeekDays
          : null,
      createdAt: widget.alarm?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Trigger platform notification scheduling
    _scheduleNotification(alarm);

    if (widget.alarm == null) {
      context.read<AlarmsBloc>().add(AddAlarm(alarm));
    } else {
      context.read<AlarmsBloc>().add(UpdateAlarm(alarm));
    }

    Navigator.pop(context);

    getIt<GlobalUiService>().showSuccess(
      widget.alarm == null
          ? 'Reminder created successfully'
          : 'Reminder updated successfully',
    );
  }

  Future<void> _scheduleNotification(Alarm alarm) async {
    try {
      final notificationService = LocalNotificationService();

      await notificationService.schedule(
        id: int.parse(alarm.id),
        title: alarm.message,
        body: _linkedNoteId != null
            ? 'Linked note: ${_availableNotes?.firstWhere(
                (n) => n.id == _linkedNoteId,
                orElse: () => Note(id: '', title: 'Unknown'),
              ).title}'
            : 'Reminder notification',
        scheduledTime: alarm.scheduledTime,
        repeatDays: _platformRepeatDays(alarm),
      );

      AppLogger.i('Platform notification scheduled for alarm: ${alarm.id}');
    } catch (e) {
      AppLogger.e('Error scheduling platform notification: $e');
      // Continue even if notification fails - alarm is still saved locally
    }
  }

  List<int>? _platformRepeatDays(Alarm alarm) {
    final weekDays = alarm.weekDays;
    if (weekDays != null && weekDays.isNotEmpty) {
      final normalized = weekDays
          .map((day) => day % 7)
          .where((day) => day >= 0 && day <= 6)
          .toSet()
          .toList();
      if (normalized.isNotEmpty) {
        return normalized;
      }
    }

    switch (alarm.recurrence) {
      case AlarmRecurrence.daily:
        return List.generate(7, (index) => index);
      case AlarmRecurrence.weekly:
        return [alarm.scheduledTime.weekday % 7];
      case AlarmRecurrence.custom:
        // Custom days are passed in weekDays field
        return weekDays;
      case AlarmRecurrence.monthly:
      case AlarmRecurrence.yearly:
      case AlarmRecurrence.none:
        return null;
    }
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) {
      return 'Today';
    } else if (date == tomorrow) {
      return 'Tomorrow';
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
      return '${monthNames[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }
}
