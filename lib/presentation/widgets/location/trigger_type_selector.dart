import 'package:flutter/material.dart';
import 'package:mynotes/domain/entities/location_reminder_model.dart';

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
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildOption(
                context,
                type: LocationTriggerType.arrive,
                icon: Icons.login,
                label: 'I arrive',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOption(
                context,
                type: LocationTriggerType.leave,
                icon: Icons.logout,
                label: 'I leave',
                color: Colors.orange,
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
