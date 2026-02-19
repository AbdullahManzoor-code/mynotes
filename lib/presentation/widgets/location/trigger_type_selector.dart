import 'package:flutter/material.dart';
import 'package:mynotes/domain/entities/location_reminder_model.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';

class TriggerTypeSelector extends StatelessWidget {
  final LocationTriggerType selectedType;
  final ValueChanged<LocationTriggerType> onChanged;

  const TriggerTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Trigger When', style: Theme.of(context).textTheme.titleSmall),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _buildOption(
                context,
                type: LocationTriggerType.arrive,
                icon: Icons.login,
                label: 'I arrive',
                color: AppColors.successColor,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildOption(
                context,
                type: LocationTriggerType.leave,
                icon: Icons.logout,
                label: 'I leave',
                color: AppColors.warningColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required LocationTriggerType type,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = selectedType == type;

    return InkWell(
      onTap: () => onChanged(type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : AppColors.grey400.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : AppColors.grey500),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.grey500,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
