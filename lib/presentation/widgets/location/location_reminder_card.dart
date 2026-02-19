import 'package:flutter/material.dart';
import 'package:mynotes/domain/entities/location_reminder_model.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';

class LocationReminderCard extends StatelessWidget {
  final LocationReminder reminder;
  final VoidCallback onTap;
  final Function(bool) onToggle;
  final VoidCallback onDelete;

  const LocationReminderCard({
    super.key,
    required this.reminder,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = reminder.isActive;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Trigger type icon
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: isActive
                          ? (reminder.triggerType == LocationTriggerType.arrive
                                ? AppColors.successColor.withOpacity(0.1)
                                : AppColors.warningColor.withOpacity(0.1))
                          : AppColors.grey400.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      reminder.triggerType == LocationTriggerType.arrive
                          ? Icons.login
                          : Icons.logout,
                      color: isActive
                          ? (reminder.triggerType == LocationTriggerType.arrive
                                ? AppColors.successColor
                                : AppColors.warningColor)
                          : AppColors.grey500,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.message,
                          style: theme.textTheme.titleMedium?.copyWith(
                            decoration: isActive
                                ? null
                                : TextDecoration.lineThrough,
                            color: isActive ? null : AppColors.grey500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: AppColors.grey500,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                reminder.placeName ?? 'Unknown location',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.grey500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Toggle switch
                  Switch(value: isActive, onChanged: onToggle),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Bottom info row
              Row(
                children: [
                  // Trigger type badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      reminder.triggerTypeDisplay,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),

                  // Radius badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.radar, size: 12, color: AppColors.grey500),
                        SizedBox(width: 4.w),
                        Text(
                          reminder.radiusDisplay,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Last triggered
                  if (reminder.lastTriggered != null)
                    Text(
                      'Last: ${_formatDate(reminder.lastTriggered!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),

                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: AppColors.errorColor,
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
