import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mynotes/core/services/location_service.dart';
import 'package:mynotes/core/services/places_service.dart';
import 'package:mynotes/core/services/location_reminders_manager.dart';
import 'package:mynotes/domain/entities/location_reminder_model.dart';
import 'package:mynotes/presentation/bloc/location_reminder/location_reminder_bloc.dart';
import 'package:mynotes/presentation/bloc/location_picker/location_picker_bloc.dart';

// Type alias for PlacePrediction from PlacesService
typedef PlacePredictionLocal = PlacePrediction;

class LocationPickerScreen extends StatelessWidget {
  final LocationReminder? existingReminder;

  const LocationPickerScreen({super.key, this.existingReminder});

  @override
  Widget build(BuildContext context) {
    return _LocationPickerLifecycleWrapper(existingReminder: existingReminder);
  }
}

class _LocationPickerLifecycleWrapper extends StatefulWidget {
  final LocationReminder? existingReminder;

  const _LocationPickerLifecycleWrapper({this.existingReminder});

  @override
  State<_LocationPickerLifecycleWrapper> createState() =>
      _LocationPickerLifecycleWrapperState();
}

class _LocationPickerLifecycleWrapperState
    extends State<_LocationPickerLifecycleWrapper> {
  late final LocationPickerBloc _pickerBloc;
  GoogleMapController? _mapController;
  late LocationService _locationService;
  late PlacesService _placesService;
  final _locationManager = LocationRemindersManager();

  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _locationService = LocationService.instance;
    _placesService = PlacesService.instance;
    _pickerBloc = LocationPickerBloc();
    _pickerBloc.add(InitializeLocationPicker(widget.existingReminder));
    _messageController.text = widget.existingReminder?.message ?? '';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    _pickerBloc.close();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      _pickerBloc.add(const SetLoadingState(true));
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        final location = LatLng(position.latitude, position.longitude);
        await _selectLocation(location);
        _mapController?.animateCamera(CameraUpdate.newLatLng(location));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
      }
    } finally {
      _pickerBloc.add(const SetLoadingState(false));
    }
  }

  Future<void> _selectLocation(LatLng location) async {
    _pickerBloc.add(SelectLocation(location));

    // Reverse geocode to get address
    try {
      final address = await _locationService.getAddressFromCoordinates(
        location.latitude,
        location.longitude,
      );
      _pickerBloc.add(UpdateAddress(address ?? ''));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not get address: $e')));
      }
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      _pickerBloc.add(const UpdatePlacePredictions([]));
      return;
    }

    try {
      final predictions = await _placesService.searchPlaces(query);
      _pickerBloc.add(
        UpdatePlacePredictions(predictions.cast<PlacePredictionLocal>()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Search error: $e')));
      }
    }
  }

  Future<void> _selectPrediction(PlacePredictionLocal prediction) async {
    try {
      _pickerBloc.add(const SetLoadingState(true));
      final details = await _placesService.getPlaceDetails(prediction.placeId);

      if (details != null) {
        final location = LatLng(details.latitude, details.longitude);
        await _selectLocation(location);

        _mapController?.animateCamera(CameraUpdate.newLatLng(location));

        _pickerBloc.add(UpdateAddress(details.name));
        _pickerBloc.add(const TogglePredictions(false));
        _searchController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error selecting place: $e')));
      }
    } finally {
      _pickerBloc.add(const SetLoadingState(false));
    }
  }

  void _saveReminder() {
    final state = _pickerBloc.state;
    if (state.selectedLocation == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a location')));
      return;
    }

    if (state.messageText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a message')));
      return;
    }

    if (widget.existingReminder != null) {
      // Update existing reminder
      final updatedReminder = widget.existingReminder!.copyWith(
        message: state.messageText,
        latitude: state.selectedLocation!.latitude,
        longitude: state.selectedLocation!.longitude,
        radius: state.radius,
        triggerType: state.triggerType,
        placeAddress: state.selectedAddress,
        linkedNoteId: state.linkedNoteId,
      );

      context.read<LocationReminderBloc>().add(
        UpdateLocationReminder(reminder: updatedReminder),
      );
    } else {
      // Create new reminder
      final newReminder = LocationReminder.create(
        message: state.messageText,
        latitude: state.selectedLocation!.latitude,
        longitude: state.selectedLocation!.longitude,
        radius: state.radius,
        triggerType: state.triggerType,
        placeAddress: state.selectedAddress,
        linkedNoteId: state.linkedNoteId,
      );

      context.read<LocationReminderBloc>().add(
        CreateLocationReminder(reminder: newReminder),
      );
    }

    // Refresh geofences after saving
    _locationManager.refreshGeofences();

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _pickerBloc,
      child: BlocBuilder<LocationPickerBloc, LocationPickerState>(
        builder: (context, state) {
          final markers = state.selectedLocation != null
              ? {
                  Marker(
                    markerId: const MarkerId('selected_location'),
                    position: state.selectedLocation!,
                    infoWindow: InfoWindow(
                      title: state.selectedAddress.isNotEmpty
                          ? state.selectedAddress
                          : 'Selected Location',
                    ),
                  ),
                }
              : <Marker>{};

          final circles = state.selectedLocation != null
              ? {
                  Circle(
                    circleId: const CircleId('radius_circle'),
                    center: state.selectedLocation!,
                    radius: state.radius,
                    fillColor: state.triggerType == LocationTriggerType.arrive
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    strokeColor: state.triggerType == LocationTriggerType.arrive
                        ? Colors.green
                        : Colors.orange,
                    strokeWidth: 2,
                  ),
                }
              : <Circle>{};

          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.existingReminder != null
                    ? 'Edit Location Reminder'
                    : 'New Location Reminder',
              ),
              actions: [
                if (state.selectedLocation != null &&
                    state.messageText.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.check),
                    tooltip: 'Save reminder',
                    onPressed: _saveReminder,
                  ),
              ],
            ),
            body: Stack(
              children: [
                // Map
                GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                    if (state.selectedLocation != null) {
                      _mapController!.animateCamera(
                        CameraUpdate.newLatLngZoom(state.selectedLocation!, 15),
                      );
                    } else {
                      _getCurrentLocation();
                    }
                  },
                  initialCameraPosition: CameraPosition(
                    target:
                        state.selectedLocation ??
                        const LatLng(37.7749, -122.4194),
                    zoom: 15,
                  ),
                  markers: markers,
                  circles: circles,
                  onTap: _selectLocation,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  compassEnabled: true,
                  zoomControlsEnabled: false,
                ),

                // My Location Button
                Positioned(
                  right: 16,
                  bottom: 100,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: _getCurrentLocation,
                    tooltip: 'My location',
                    child: const Icon(Icons.my_location),
                  ),
                ),

                // Bottom sheet with controls
                DraggableScrollableSheet(
                  initialChildSize: 0.35,
                  minChildSize: 0.2,
                  maxChildSize: 0.85,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Handle
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Search bar
                          _buildSearchBar(state),
                          const SizedBox(height: 16),

                          // Search predictions
                          if (state.showPredictions &&
                              state.placePredictions.isNotEmpty)
                            _buildPredictionsList(state),

                          // Saved locations chips
                          if (!state.showPredictions)
                            _buildSavedLocationsChips(state),

                          const SizedBox(height: 16),

                          // Selected location display
                          if (state.selectedLocation != null) ...[
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                state.selectedAddress.isNotEmpty
                                                    ? state.selectedAddress
                                                    : 'Coordinates: ${state.selectedLocation!.latitude.toStringAsFixed(4)}, ${state.selectedLocation!.longitude.toStringAsFixed(4)}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Message input
                          _buildMessageInput(state),
                          const SizedBox(height: 16),

                          // Trigger type selector
                          _buildTriggerTypeSelector(state),
                          const SizedBox(height: 16),

                          // Radius slider
                          _buildRadiusSlider(state),
                          const SizedBox(height: 16),

                          // Save button
                          ElevatedButton.icon(
                            onPressed:
                                state.selectedLocation != null &&
                                    state.messageText.isNotEmpty
                                ? _saveReminder
                                : null,
                            icon: const Icon(Icons.check),
                            label: const Text('Save Reminder'),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Loading overlay
                if (state.isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(LocationPickerState state) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search for a place...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _searchController.clear();
                  _pickerBloc.add(const UpdatePlacePredictions([]));
                },
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: (value) {
        if (value.isNotEmpty) {
          _searchPlaces(value);
        } else {
          _pickerBloc.add(const UpdatePlacePredictions([]));
        }
      },
    );
  }

  Widget _buildPredictionsList(LocationPickerState state) {
    return Column(
      children: state.placePredictions.map((prediction) {
        return ListTile(
          leading: const Icon(Icons.location_on_outlined),
          title: Text(prediction.mainText),
          subtitle: Text(
            prediction.secondaryText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => _selectPrediction(prediction),
        );
      }).toList(),
    );
  }

  Widget _buildSavedLocationsChips(LocationPickerState pickerState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Select', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        BlocBuilder<LocationReminderBloc, LocationReminderState>(
          builder: (context, state) {
            if (state is LocationReminderLoaded &&
                state.savedLocations.isNotEmpty) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: state.savedLocations.map((location) {
                    final isSelected =
                        pickerState.selectedLocation?.latitude ==
                            location.latitude &&
                        pickerState.selectedLocation?.longitude ==
                            location.longitude;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(location.name),
                        avatar: const Icon(Icons.location_on, size: 16),
                        onSelected: (_) {
                          final newLocation = LatLng(
                            location.latitude,
                            location.longitude,
                          );
                          _selectLocation(newLocation);
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLng(newLocation),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildMessageInput(LocationPickerState state) {
    return TextField(
      controller: _messageController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Reminder Message',
        hintText: 'What do you want to be reminded?',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.message),
      ),
      onChanged: (value) {
        _pickerBloc.add(UpdateMessageText(value));
      },
    );
  }

  Widget _buildTriggerTypeSelector(LocationPickerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Remind me when I...',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                selected: state.triggerType == LocationTriggerType.arrive,
                label: const Text('Arrive'),
                onSelected: (_) {
                  _pickerBloc.add(
                    const UpdateTriggerType(LocationTriggerType.arrive),
                  );
                },
                avatar: const Icon(Icons.login),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                selected: state.triggerType == LocationTriggerType.leave,
                label: const Text('Leave'),
                onSelected: (_) {
                  _pickerBloc.add(
                    const UpdateTriggerType(LocationTriggerType.leave),
                  );
                },
                avatar: const Icon(Icons.logout),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRadiusSlider(LocationPickerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Radius', style: Theme.of(context).textTheme.labelMedium),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${state.radius.toInt()}m',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: state.radius,
          min: 50,
          max: 500,
          divisions: 9,
          label: '${state.radius.toInt()}m',
          onChanged: (value) {
            _pickerBloc.add(UpdateRadius(value));
          },
        ),
      ],
    );
  }
}
