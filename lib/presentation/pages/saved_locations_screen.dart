import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mynotes/core/services/app_logger.dart' show AppLogger;
import 'package:mynotes/domain/entities/saved_location_model.dart';
import 'package:mynotes/presentation/bloc/location_reminder/location_reminder_bloc.dart';

class SavedLocationsScreen extends StatelessWidget {
  const SavedLocationsScreen({super.key});

  void _showAddLocationDialog(BuildContext context) {
    AppLogger.i('SavedLocationsScreen: Show add location dialog');
    context.read<LocationReminderBloc>().add(GetCurrentLocation());
    showDialog(
      context: context,
      builder: (_) => _AddLocationDialog(
        onSave: (name, location) {
          _addSavedLocation(context, name, location);
          Navigator.of(context).pop();
        },
      ),
    ).then((_) {
      context.read<LocationReminderBloc>().add(ClearFetchedLocation());
    });
  }

  void _addSavedLocation(BuildContext context, String name, LatLng location) {
    AppLogger.i(
      'SavedLocationsScreen: Saving location - name: $name, coords: $location',
    );
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

  void _editLocation(BuildContext context, SavedLocation location) {
    AppLogger.i('SavedLocationsScreen: Editing location - ${location.name}');
    showDialog(
      context: context,
      builder: (_) => _EditLocationDialog(
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

  void _deleteLocation(BuildContext context, SavedLocation location) {
    AppLogger.i('SavedLocationsScreen: Deleting location - ${location.name}');
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Location?'),
        content: Text('Remove "${location.name}" from saved locations?'),
        actions: [
          TextButton(
            onPressed: () {
              AppLogger.i('SavedLocationsScreen: Delete location cancelled');
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              AppLogger.i('SavedLocationsScreen: Delete location confirmed');
              context.read<LocationReminderBloc>().add(
                DeleteSavedLocation(location),
              );
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.i('SavedLocationsScreen: build');
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Locations')),
      body: BlocBuilder<LocationReminderBloc, LocationReminderState>(
        builder: (context, state) {
          if (state is LocationReminderLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LocationReminderError) {
            AppLogger.e(
              'SavedLocationsScreen: LocationReminderError',
              state.message,
            );
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
                      AppLogger.i(
                        'SavedLocationsScreen: Retry loading reminders',
                      );
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
              return _buildEmptyState(context);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.savedLocations.length,
              itemBuilder: (context, index) {
                final location = state.savedLocations[index];
                return _buildLocationCard(context, location);
              },
            );
          }

          return _buildEmptyState(context);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AppLogger.i('SavedLocationsScreen: FAB Add Location pressed');
          _showAddLocationDialog(context);
        },
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Add Location'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
              'Save your favorite places to quickly select them '
              'when creating reminders.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                AppLogger.i(
                  'SavedLocationsScreen: Empty state Add Location pressed',
                );
                _showAddLocationDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Save First Location'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, SavedLocation location) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          Icons.location_on,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(location.name),
        subtitle: Text(
          '${location.latitude.toStringAsFixed(4)}, '
          '${location.longitude.toStringAsFixed(4)}',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: Colors.grey),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') _editLocation(context, location);
            if (value == 'delete') _deleteLocation(context, location);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Add Location Dialog (uses Bloc for current location)
// =============================================================================

class _AddLocationDialog extends StatefulWidget {
  final Function(String, LatLng) onSave;

  const _AddLocationDialog({required this.onSave});

  @override
  State<_AddLocationDialog> createState() => _AddLocationDialogState();
}

class _AddLocationDialogState extends State<_AddLocationDialog> {
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationReminderBloc, LocationReminderState>(
      builder: (context, state) {
        LatLng? selectedLocation;
        bool isLoadingLocation = false;

        if (state is LocationReminderLoaded) {
          selectedLocation = state.currentPosition;
          isLoadingLocation = state.isFetchingLocation;
        }

        // Capture in a local final so Dart can promote inside the closure
        final currentLocation = selectedLocation;

        return AlertDialog(
          title: const Text('Save New Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                onChanged: (_) => setState(() {}),
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
              if (isLoadingLocation)
                const Center(child: CircularProgressIndicator())
              else if (currentLocation != null)
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
                          'Using current location: '
                          '${currentLocation.latitude.toStringAsFixed(4)}, '
                          '${currentLocation.longitude.toStringAsFixed(4)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    const Text('Could not get current location'),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        AppLogger.i(
                          'AddLocationDialog: Requesting location retry',
                        );
                        context.read<LocationReminderBloc>().add(
                          GetCurrentLocation(),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _nameController.text.isEmpty || currentLocation == null
                  ? null
                  : () {
                      AppLogger.i('AddLocationDialog: Save button pressed');
                      widget.onSave(_nameController.text, currentLocation);
                    },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

// =============================================================================
// Edit Location Dialog
// =============================================================================

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
        onChanged: (_) => setState(() {}),
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
              : () {
                  AppLogger.i('EditLocationDialog: Update button pressed');
                  widget.onSave(_nameController.text);
                },
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


