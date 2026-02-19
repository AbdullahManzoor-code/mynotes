import 'package:flutter/material.dart';
import 'package:mynotes/domain/entities/saved_location_model.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';

class SavedLocationChip extends StatelessWidget {
  final SavedLocation location;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const SavedLocationChip({
    super.key,
    required this.location,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: FilterChip(
        selected: isSelected,
        label: Text(location.name),
        avatar: Icon(
          Icons.location_on,
          size: 16,
          color: isSelected ? Theme.of(context).colorScheme.onPrimary : null,
        ),
        onSelected: (_) => onTap(),
        deleteIcon: onDelete != null ? const Icon(Icons.close, size: 16) : null,
        onDeleted: onDelete,
        backgroundColor: AppColors.grey400.withOpacity(0.1),
        selectedColor: Theme.of(context).colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Colors.black,
        ),
      ),
    );
  }
}

class SavedLocationChips extends StatelessWidget {
  final List<SavedLocation> savedLocations;
  final SavedLocation? selectedLocation;
  final Function(SavedLocation) onLocationSelected;
  final Function(SavedLocation)? onLocationDeleted;

  const SavedLocationChips({
    super.key,
    required this.savedLocations,
    this.selectedLocation,
    required this.onLocationSelected,
    this.onLocationDeleted,
  });

  @override
  Widget build(BuildContext context) {
    if (savedLocations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Select', style: Theme.of(context).textTheme.labelMedium),
        SizedBox(height: 8.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: savedLocations.map((location) {
              final isSelected = selectedLocation?.id == location.id;
              return SavedLocationChip(
                location: location,
                isSelected: isSelected,
                onTap: () => onLocationSelected(location),
                onDelete: onLocationDeleted != null
                    ? () => onLocationDeleted!(location)
                    : null,
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }
}
