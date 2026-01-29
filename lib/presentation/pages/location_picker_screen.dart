import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mynotes/core/services/location_service.dart';
import 'package:mynotes/core/services/places_service.dart';
import 'package:mynotes/core/services/location_reminders_manager.dart';
import 'package:mynotes/domain/entities/location_reminder_model.dart';
import 'package:mynotes/presentation/bloc/location_reminder_bloc.dart';

// Type alias for PlacePrediction from PlacesService
typedef PlacePredictionLocal = PlacePrediction;

class LocationPickerScreen extends StatefulWidget {
  final LocationReminder? existingReminder;

  const LocationPickerScreen({super.key, this.existingReminder});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late GoogleMapController _mapController;
  late LocationService _locationService;
  late PlacesService _placesService;
  final _locationManager = LocationRemindersManager();

  // State variables
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  String _messageText = '';
  LocationTriggerType _triggerType = LocationTriggerType.arrive;
  double _radius = 100.0;
  String? _linkedNoteId;
  Marker? _selectedMarker;
  Circle? _radiusCircle;
  bool _isLoading = false;

  // Search state
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<PlacePredictionLocal> _placePredictions = [];
  bool _showPredictions = false;

  @override
  void initState() {
    super.initState();
    _locationService = LocationService.instance;
    _placesService = PlacesService.instance;
    _initializeState();
  }

  void _initializeState() {
    if (widget.existingReminder != null) {
      _selectedLocation = LatLng(
        widget.existingReminder!.latitude,
        widget.existingReminder!.longitude,
      );
      _selectedAddress = widget.existingReminder!.placeAddress ?? '';
      _messageText = widget.existingReminder!.message;
      _triggerType = widget.existingReminder!.triggerType;
      _radius = widget.existingReminder!.radius;
      _linkedNoteId = widget.existingReminder!.linkedNoteId;
      _messageController.text = _messageText;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _isLoading = true);
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        final location = LatLng(position.latitude, position.longitude);
        _selectLocation(location);
        _mapController.animateCamera(CameraUpdate.newLatLng(location));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectLocation(LatLng location) async {
    setState(() {
      _selectedLocation = location;
      _updateMarkerAndCircle();
    });

    // Reverse geocode to get address
    try {
      final address = await _locationService.getAddressFromCoordinates(
        location.latitude,
        location.longitude,
      );
      setState(() => _selectedAddress = address ?? '');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not get address: $e')));
      }
    }
  }

  void _updateMarkerAndCircle() {
    if (_selectedLocation != null) {
      setState(() {
        _selectedMarker = Marker(
          markerId: const MarkerId('selected_location'),
          position: _selectedLocation!,
          infoWindow: InfoWindow(
            title: _selectedAddress.isNotEmpty
                ? _selectedAddress
                : 'Selected Location',
          ),
        );

        _radiusCircle = Circle(
          circleId: const CircleId('radius_circle'),
          center: _selectedLocation!,
          radius: _radius,
          fillColor: Colors.blue.withOpacity(0.2),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        );
      });
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _placePredictions = [];
        _showPredictions = false;
      });
      return;
    }

    try {
      final predictions = await _placesService.searchPlaces(query);
      setState(() {
        _placePredictions = predictions.cast<PlacePredictionLocal>();
        _showPredictions = true;
      });
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
      setState(() => _isLoading = true);
      final details = await _placesService.getPlaceDetails(prediction.placeId);

      if (details != null) {
        final location = LatLng(details.latitude, details.longitude);
        await _selectLocation(location);

        _mapController.animateCamera(CameraUpdate.newLatLng(location));

        setState(() {
          _selectedAddress = details.name;
          _showPredictions = false;
          _searchController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error selecting place: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _saveReminder() {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a location')));
      return;
    }

    if (_messageText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a message')));
      return;
    }

    if (widget.existingReminder != null) {
      // Update existing reminder
      final updatedReminder = widget.existingReminder!.copyWith(
        message: _messageText,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        radius: _radius,
        triggerType: _triggerType,
        placeAddress: _selectedAddress,
        linkedNoteId: _linkedNoteId,
      );

      context.read<LocationReminderBloc>().add(
        UpdateLocationReminder(reminder: updatedReminder),
      );
    } else {
      // Create new reminder
      final newReminder = LocationReminder.create(
        message: _messageText,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        radius: _radius,
        triggerType: _triggerType,
        placeAddress: _selectedAddress,
        linkedNoteId: _linkedNoteId,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingReminder != null
              ? 'Edit Location Reminder'
              : 'New Location Reminder',
        ),
        actions: [
          if (_selectedLocation != null && _messageText.isNotEmpty)
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
              if (_selectedLocation != null) {
                _mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
                );
              } else {
                _getCurrentLocation();
              }
            },
            initialCameraPosition: CameraPosition(
              target: _selectedLocation ?? const LatLng(37.7749, -122.4194),
              zoom: 15,
            ),
            markers: _selectedMarker != null ? {_selectedMarker!} : {},
            circles: _radiusCircle != null ? {_radiusCircle!} : {},
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
                    _buildSearchBar(),
                    const SizedBox(height: 16),

                    // Search predictions
                    if (_showPredictions && _placePredictions.isNotEmpty)
                      _buildPredictionsList(),

                    // Saved locations chips
                    if (!_showPredictions) _buildSavedLocationsChips(),

                    const SizedBox(height: 16),

                    // Selected location display
                    if (_selectedLocation != null) ...[
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
                                          _selectedAddress.isNotEmpty
                                              ? _selectedAddress
                                              : 'Coordinates: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
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
                    _buildMessageInput(),
                    const SizedBox(height: 16),

                    // Trigger type selector
                    _buildTriggerTypeSelector(),
                    const SizedBox(height: 16),

                    // Radius slider
                    _buildRadiusSlider(),
                    const SizedBox(height: 16),

                    // Save button
                    ElevatedButton.icon(
                      onPressed:
                          _selectedLocation != null && _messageText.isNotEmpty
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
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
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
                  setState(() {
                    _placePredictions = [];
                    _showPredictions = false;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: (value) {
        setState(() {});
        if (value.isNotEmpty) {
          _searchPlaces(value);
        } else {
          setState(() {
            _placePredictions = [];
            _showPredictions = false;
          });
        }
      },
    );
  }

  Widget _buildPredictionsList() {
    return Column(
      children: _placePredictions.map((prediction) {
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

  Widget _buildSavedLocationsChips() {
    return BlocBuilder<LocationReminderBloc, LocationReminderState>(
      builder: (context, state) {
        if (state is LocationReminderLoaded &&
            state.savedLocations.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Select',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: state.savedLocations.map((location) {
                    final isSelected =
                        _selectedLocation?.latitude == location.latitude &&
                        _selectedLocation?.longitude == location.longitude;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(location.name),
                        avatar: Icon(Icons.location_on, size: 16),
                        onSelected: (_) {
                          final newLocation = LatLng(
                            location.latitude,
                            location.longitude,
                          );
                          _selectLocation(newLocation);
                          _mapController.animateCamera(
                            CameraUpdate.newLatLng(newLocation),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMessageInput() {
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
        setState(() => _messageText = value);
      },
    );
  }

  Widget _buildTriggerTypeSelector() {
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
                selected: _triggerType == LocationTriggerType.arrive,
                label: const Text('Arrive'),
                onSelected: (_) {
                  setState(() => _triggerType = LocationTriggerType.arrive);
                  _updateMarkerAndCircle();
                },
                avatar: const Icon(Icons.login),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                selected: _triggerType == LocationTriggerType.leave,
                label: const Text('Leave'),
                onSelected: (_) {
                  setState(() => _triggerType = LocationTriggerType.leave);
                  _updateMarkerAndCircle();
                },
                avatar: const Icon(Icons.logout),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRadiusSlider() {
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
                '${_radius.toInt()}m',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _radius,
          min: 50,
          max: 500,
          divisions: 9,
          label: '${_radius.toInt()}m',
          onChanged: (value) {
            setState(() {
              _radius = value;
              _updateMarkerAndCircle();
            });
          },
        ),
      ],
    );
  }
}
