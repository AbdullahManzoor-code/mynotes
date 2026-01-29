import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mynotes/core/services/location_service.dart';
import 'package:mynotes/domain/entities/saved_location_model.dart';
import 'package:mynotes/presentation/bloc/location_reminder_bloc.dart';

class SavedLocationsScreen extends StatefulWidget {
  const SavedLocationsScreen({super.key});

  @override
  State<SavedLocationsScreen> createState() => _SavedLocationsScreenState();
}

class _SavedLocationsScreenState extends State<SavedLocationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LocationReminderBloc>().add(LoadLocationReminders());
  }

  void _showAddLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddLocationDialog(
        onSave: (name, location) {
          _addSavedLocation(name, location);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _addSavedLocation(String name, LatLng location) {
    final newLocation = SavedLocation.create(
      name: name,
      latitude: location.latitude,
      longitude: location.longitude,
    );

    context.read<LocationReminderBloc>().add(
      SaveLocation(location: newLocation),
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Saved "$name" location')));
  }

  void _editLocation(SavedLocation location) {
    showDialog(
      context: context,
      builder: (context) => _EditLocationDialog(
        location: location,
        onSave: (name) {
          final updated = location.copyWith(name: name);
          context.read<LocationReminderBloc>().add(
            UpdateSavedLocation(updated),
          );
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _deleteLocation(SavedLocation location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Location?'),
        content: Text('Remove "${location.name}" from saved locations?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<LocationReminderBloc>().add(
                DeleteSavedLocation(location),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Locations')),
      body: BlocBuilder<LocationReminderBloc, LocationReminderState>(
        builder: (context, state) {
          if (state is LocationReminderLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LocationReminderError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<LocationReminderBloc>().add(
                        LoadLocationReminders(),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is LocationReminderLoaded) {
            if (state.savedLocations.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.savedLocations.length,
              itemBuilder: (context, index) {
                final location = state.savedLocations[index];
                return _buildLocationCard(location);
              },
            );
          }

          return _buildEmptyState();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddLocationDialog,
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Add Location'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Saved Locations',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Save your favorite places to quickly select them when creating reminders.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddLocationDialog,
              icon: const Icon(Icons.add),
              label: const Text('Save First Location'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(SavedLocation location) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          Icons.location_on,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(location.name),
        subtitle: Text(
          '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: Colors.grey),
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Edit'),
              onTap: () => _editLocation(location),
            ),
            PopupMenuItem(
              child: const Text('Delete'),
              onTap: () => _deleteLocation(location),
            ),
          ],
        ),
        onTap: () {
          // Could open a detail view or map view here
        },
      ),
    );
  }
}

class _AddLocationDialog extends StatefulWidget {
  final Function(String, LatLng) onSave;

  const _AddLocationDialog({required this.onSave});

  @override
  State<_AddLocationDialog> createState() => _AddLocationDialogState();
}

class _AddLocationDialogState extends State<_AddLocationDialog> {
  final _nameController = TextEditingController();
  LatLng? _selectedLocation;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final position = LocationService.instance.lastKnownPosition;
      if (position != null) {
        setState(() {
          _selectedLocation = LatLng(position.latitude, position.longitude);
        });
      } else {
        // Try to get current position
        final newPosition = await LocationService.instance.getCurrentPosition();
        if (newPosition != null) {
          setState(() {
            _selectedLocation = LatLng(
              newPosition.latitude,
              newPosition.longitude,
            );
          });
        }
      }
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save New Location'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Location Name',
              hintText: 'e.g., Home, Work, Gym',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.location_on),
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoadingLocation)
            const Center(child: CircularProgressIndicator())
          else if (_selectedLocation != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Using current location: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            )
          else
            const Text('Could not get current location'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _nameController.text.isEmpty || _selectedLocation == null
              ? null
              : () {
                  widget.onSave(_nameController.text, _selectedLocation!);
                },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

class _EditLocationDialog extends StatefulWidget {
  final SavedLocation location;
  final Function(String) onSave;

  const _EditLocationDialog({required this.location, required this.onSave});

  @override
  State<_EditLocationDialog> createState() => _EditLocationDialogState();
}

class _EditLocationDialogState extends State<_EditLocationDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.location.name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Location'),
      content: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: 'Location Name',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          prefixIcon: const Icon(Icons.location_on),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _nameController.text.isEmpty
              ? null
              : () => widget.onSave(_nameController.text),
          child: const Text('Update'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

