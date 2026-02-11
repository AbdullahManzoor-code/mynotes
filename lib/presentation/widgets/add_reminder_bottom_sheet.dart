import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/injection_container.dart';
import 'package:uuid/uuid.dart';
import '../design_system/design_system.dart';
import '../../domain/entities/alarm.dart';
import '../bloc/alarms_bloc.dart';
import '../../core/services/global_ui_service.dart';

/// Add Reminder Bottom Sheet
/// Specialized sheet for creating system alarms/reminders
class AddReminderBottomSheet extends StatefulWidget {
  final Function(Alarm)? onReminderCreated;
  final Alarm? editAlarm;

  const AddReminderBottomSheet({
    super.key,
    this.onReminderCreated,
    this.editAlarm,
  });

  @override
  State<AddReminderBottomSheet> createState() => _AddReminderBottomSheetState();
}

class _AddReminderBottomSheetState extends State<AddReminderBottomSheet>
    with SingleTickerProviderStateMixin {
  late TextEditingController _textController;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();

    // Initialize with existing alarm data if editing
    if (widget.editAlarm != null) {
      final alarm = widget.editAlarm!;
      _textController.text = alarm.message;
      _selectedDate = alarm.scheduledTime;
      _selectedTime = TimeOfDay.fromDateTime(alarm.scheduledTime);
    } else {
      // Default to next hour
      final now = DateTime.now();
      final nextHour = now.add(const Duration(hours: 1));
      _selectedDate = nextHour;
      _selectedTime = TimeOfDay.fromDateTime(nextHour);
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)), // 2 years
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface(context),
              onSurface: AppColors.textPrimary(context),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        // Keep time if selected, or default to current time
        final time = _selectedTime ?? TimeOfDay.now();
        _selectedDate = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  void _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface(context),
              onSurface: AppColors.textPrimary(context),
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
        if (_selectedDate != null) {
          _selectedDate = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            time.hour,
            time.minute,
          );
        } else {
          final now = DateTime.now();
          _selectedDate = DateTime(
            now.year,
            now.month,
            now.day,
            time.hour,
            time.minute,
          );
        }
      });
    }
  }

  void _createReminder() {
    if (_textController.text.trim().isEmpty) {
      getIt<GlobalUiService>().showWarning('Please enter a reminder message');
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      getIt<GlobalUiService>().showWarning('Please start date and time');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Construct final DateTime
      final scheduledTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final now = DateTime.now();
      if (scheduledTime.isBefore(now)) {
        getIt<GlobalUiService>().showWarning(
          'Cannot schedule reminder in the past',
        );
        setState(() => _isLoading = false);
        return;
      }

      final alarm = Alarm(
        id: widget.editAlarm?.id ?? const Uuid().v4(),
        message: _textController.text.trim(),
        scheduledTime: scheduledTime,
        isActive: true,
        createdAt: widget.editAlarm?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.editAlarm != null) {
        context.read<AlarmsBloc>().add(UpdateAlarm(alarm));
      } else {
        context.read<AlarmsBloc>().add(AddAlarm(alarm));
      }

      if (widget.onReminderCreated != null) {
        widget.onReminderCreated!(alarm);
      }

      Navigator.pop(context);
      HapticFeedback.mediumImpact();
    } catch (e) {
      getIt<GlobalUiService>().showError('Error creating reminder: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            (1 - _slideAnimation.value) *
                MediaQuery.of(context).size.height *
                0.3,
          ),
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: AppColors.textSecondary(context).withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.editAlarm != null
                          ? Icons.edit
                          : Icons.notification_add,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.editAlarm != null ? 'Edit Reminder' : 'New Reminder',
                    style: AppTypography.heading3(
                      context,
                      AppColors.textPrimary(context),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text Input
                    TextField(
                      controller: _textController,
                      autofocus: widget.editAlarm == null,
                      decoration: InputDecoration(
                        hintText: 'Remind me to...',
                        hintStyle: AppTypography.bodyLarge(context).copyWith(
                          color: AppColors.textSecondary(
                            context,
                          ).withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                      ),
                      style: AppTypography.heading3(
                        context,
                        AppColors.textPrimary(context),
                      ),
                      maxLines: null,
                    ),

                    const SizedBox(height: 24),

                    // Date & Time Selectors
                    Row(
                      children: [
                        Expanded(
                          child: _buildSelector(
                            context: context,
                            icon: Icons.calendar_today,
                            label: _selectedDate == null
                                ? 'Select Date'
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            onTap: _selectDate,
                            isActive: _selectedDate != null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSelector(
                            context: context,
                            icon: Icons.access_time,
                            label: _selectedTime == null
                                ? 'Select Time'
                                : _selectedTime!.format(context),
                            onTap: _selectTime,
                            isActive: _selectedTime != null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Action Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createReminder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.editAlarm != null
                              ? 'Update Reminder'
                              : 'Set Reminder',
                          style: AppTypography.labelLarge(
                            context,
                            Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelector({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border(context),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive
                  ? AppColors.primary
                  : AppColors.textSecondary(context),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.bodyMedium(context).copyWith(
                color: isActive
                    ? AppColors.primary
                    : AppColors.textPrimary(context),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
