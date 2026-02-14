import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/location_reminder/location_reminder_bloc.dart';
import 'package:mynotes/presentation/pages/location_picker_screen.dart';
import 'package:mynotes/presentation/pages/saved_locations_screen.dart';
import 'package:mynotes/presentation/widgets/location/location_reminder_card.dart';
import 'package:mynotes/presentation/widgets/location/location_permission_dialog.dart';
import 'package:mynotes/domain/entities/location_reminder_model.dart';
import 'package:mynotes/core/services/location_reminders_manager.dart';

class LocationReminderScreen extends StatelessWidget {
  const LocationReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _LocationLifecycleWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Location Reminders'),
          actions: [
            IconButton(
              icon: const Icon(Icons.bookmark),
              tooltip: 'Saved locations',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SavedLocationsScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.help_outline),
              tooltip: 'How it works',
              onPressed: () => _showHelpDialog(context),
            ),
          ],
        ),
        body: Column(
          children: [
            // Permission banner
            LocationPermissionBanner(
              onPermissionGranted: () {
                LocationRemindersManager().startMonitoring();
                context.read<LocationReminderBloc>().add(
                  LoadLocationReminders(),
                );
              },
            ),
            // Reminders list
            Expanded(
              child: BlocBuilder<LocationReminderBloc, LocationReminderState>(
                builder: (context, state) {
                  if (state is LocationReminderInitial) {
                    context.read<LocationReminderBloc>().add(
                      LoadLocationReminders(),
                    );
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is LocationReminderLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is LocationReminderError) {
                    return _buildErrorState(context, state.message);
                  }

                  if (state is LocationReminderLoaded) {
                    if (state.reminders.isEmpty) {
                      return _buildEmptyState(context);
                    }
                    return _buildReminderList(context, state);
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _createNewReminder(context),
          icon: const Icon(Icons.add_location_alt),
          label: const Text('New Location Reminder'),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Location Reminders',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Create reminders that trigger when you arrive at or leave a specific place.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _createNewReminder(context),
              icon: const Icon(Icons.add),
              label: const Text('Create First Reminder'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _showHelpDialog(context),
              child: const Text('Learn how it works'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderList(
    BuildContext context,
    LocationReminderLoaded state,
  ) {
    final activeReminders = state.reminders.where((r) => r.isActive).toList();
    final inactiveReminders = state.reminders
        .where((r) => !r.isActive)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Permission status banner
        if (!state.hasLocationPermission) _buildPermissionBanner(context),

        // Active reminders
        if (activeReminders.isNotEmpty) ...[
          _buildSectionHeader(context, 'Active', activeReminders.length),
          const SizedBox(height: 8),
          ...activeReminders.map(
            (reminder) => LocationReminderCard(
              reminder: reminder,
              onTap: () => _editReminder(context, reminder),
              onToggle: (active) => _toggleReminder(context, reminder, active),
              onDelete: () => _deleteReminder(context, reminder),
            ),
          ),
        ],

        // Inactive reminders
        if (inactiveReminders.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Inactive', inactiveReminders.length),
          const SizedBox(height: 8),
          ...inactiveReminders.map(
            (reminder) => LocationReminderCard(
              reminder: reminder,
              onTap: () => _editReminder(context, reminder),
              onToggle: (active) => _toggleReminder(context, reminder, active),
              onDelete: () => _deleteReminder(context, reminder),
            ),
          ),
        ],

        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildPermissionBanner(BuildContext context) {
  //   return Card(
  //     color: Colors.orange.shade100,
  //     margin: const EdgeInsets.only(bottom: 16),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Row(
  //         children: [
  //           const Icon(Icons.warning_amber, color: Colors.orange),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const Text(
  //                   'Background location needed',
  //                   style: TextStyle(fontWeight: FontWeight.bold),
  //                 ),
  //                 const SizedBox(height: 4),
  //                 Text(
  //                   'Enable "Always" location access for reminders to work when app is closed.',
  //                   style: Theme.of(context).textTheme.bodySmall,
  //                 ),
  //               ],
  //             ),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               context.read<LocationReminderBloc>().add(
  //                 RequestLocationPermission(),
  //               );
  //             },
  //             child: const Text('Enable'),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildErrorState(BuildContext context, String message) {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         const Icon(Icons.error_outline, size: 64, color: Colors.red),
  //         const SizedBox(height: 16),
  //         Text(message),
  //         const SizedBox(height: 16),
  //         ElevatedButton(
  //           onPressed: () {
  //             context.read<LocationReminderBloc>().add(LoadLocationReminders());
  //           },
  //           child: const Text('Retry'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _createNewReminder(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
  }

  void _editReminder(BuildContext context, LocationReminder reminder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(existingReminder: reminder),
      ),
    );
  }

  void _toggleReminder(
    BuildContext context,
    LocationReminder reminder,
    bool active,
  ) {
    context.read<LocationReminderBloc>().add(
      ToggleLocationReminder(reminderId: reminder.id, isActive: active),
    );
  }

  void _deleteReminder(BuildContext context, LocationReminder reminder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reminder?'),
        content: Text('Delete reminder "${reminder.message}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<LocationReminderBloc>().add(
                DeleteLocationReminder(reminderId: reminder.id),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('How Location Reminders Work'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                '📍 Choose a Location',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('Search for a place or drop a pin on the map.'),
              SizedBox(height: 16),
              Text(
                '⚡ Set a Trigger',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Choose "When I arrive" or "When I leave" to control when the reminder fires.',
              ),
              SizedBox(height: 16),
              Text(
                '📏 Adjust Radius',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Set how close you need to be for the reminder to trigger (50m - 500m).',
              ),
              SizedBox(height: 16),
              Text(
                '🔔 Get Notified',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'When you enter or exit the area, you\'ll receive a notification.',
              ),
              SizedBox(height: 16),
              Text(
                '⚠️ Background Location',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'For reminders to work when the app is closed, you must allow "Always" location access.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionBanner(BuildContext context) {
    return Card(
      color: Colors.orange.shade100,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Background location needed',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Enable "Always" location access for reminders to work when app is closed.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<LocationReminderBloc>().add(
                  RequestLocationPermission(),
                );
              },
              child: const Text('Enable'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<LocationReminderBloc>().add(LoadLocationReminders());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _LocationLifecycleWrapper extends StatefulWidget {
  final Widget child;
  const _LocationLifecycleWrapper({required this.child});

  @override
  State<_LocationLifecycleWrapper> createState() =>
      _LocationLifecycleWrapperState();
}

class _LocationLifecycleWrapperState extends State<_LocationLifecycleWrapper> {
  final _locationManager = LocationRemindersManager();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _locationManager.initialize();
      final permissionsGranted = await _locationManager.arePermissionsGranted();

      if (!permissionsGranted && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => LocationPermissionDialog(
            onPermissionsGranted: () {
              _locationManager.startMonitoring();
              if (mounted) {
                context.read<LocationReminderBloc>().add(
                  LoadLocationReminders(),
                );
              }
            },
          ),
        );
      } else if (permissionsGranted) {
        await _locationManager.startMonitoring();
      }
    } catch (e) {
      debugPrint('Error initializing location services: $e');
    }
  }

  @override
  void dispose() {
    _locationManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
