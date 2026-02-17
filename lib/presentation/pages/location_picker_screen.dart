import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mynotes/core/services/location_service.dart';
import 'package:mynotes/core/services/places_service.dart';
import 'package:mynotes/core/services/location_reminders_manager.dart';
import 'package:mynotes/domain/entities/location_reminder_model.dart';
import 'package:mynotes/presentation/bloc/location_reminder/location_reminder_bloc.dart';
import 'package:mynotes/presentation/bloc/location_picker/location_picker_bloc.dart';
import '../design_system/design_system.dart';
import 'dart:ui' as ui;

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
  bool _useMap = true; // Added to allow bypassing the map

  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AppLogger.i('LocationPickerScreen: initState');
    _locationService = LocationService.instance;
    _placesService = PlacesService.instance;
    _pickerBloc = LocationPickerBloc();
    _pickerBloc.add(InitializeLocationPicker(widget.existingReminder));
    _messageController.text = widget.existingReminder?.message ?? '';
  }

  @override
  void dispose() {
    AppLogger.i('LocationPickerScreen: dispose');
    _messageController.dispose();
    _searchController.dispose();
    _pickerBloc.close();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      AppLogger.i('LocationPickerScreen: Getting current location');
      _pickerBloc.add(const SetLoadingState(true));
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        final location = LatLng(position.latitude, position.longitude);
        await _selectLocation(location);
        _mapController?.animateCamera(CameraUpdate.newLatLng(location));
      }
    } catch (e) {
      AppLogger.e('LocationPickerScreen: Error getting location', e);
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
    AppLogger.i('LocationPickerScreen: selectLocation: $location');
    _pickerBloc.add(SelectLocation(location));

    // Reverse geocode to get address
    try {
      final address = await _locationService.getAddressFromCoordinates(
        location.latitude,
        location.longitude,
      );
      _pickerBloc.add(UpdateAddress(address ?? ''));
    } catch (e) {
      AppLogger.e('LocationPickerScreen: Error reverse geocoding', e);
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
    AppLogger.i('LocationPickerScreen: Saving reminder');
    final state = _pickerBloc.state;
    if (state.selectedLocation == null) {
      AppLogger.w('LocationPickerScreen: Save failed - No location selected');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a location')));
      return;
    }

    if (state.messageText.isEmpty) {
      AppLogger.w('LocationPickerScreen: Save failed - Empty message');
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

  /// Build Google Map with error handling for missing API key
  Widget _buildGoogleMap(
    LocationPickerState state,
    Set<Marker> markers,
    Set<Circle> circles,
    BuildContext context,
  ) {
    try {
      return GoogleMap(
        onMapCreated: (controller) {
          try {
            _mapController = controller;
            if (state.selectedLocation != null) {
              _mapController!.animateCamera(
                CameraUpdate.newLatLngZoom(state.selectedLocation!, 15),
              );
            } else {
              _getCurrentLocation();
            }
          } catch (e) {
            AppLogger.e('LocationPickerScreen: Error in onMapCreated', e);
            if (mounted) {
              setState(() {
                _useMap = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Map initialization failed: $e'),
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
        },
        initialCameraPosition: CameraPosition(
          target: state.selectedLocation ?? const LatLng(37.7749, -122.4194),
          zoom: 15,
        ),
        markers: markers,
        circles: circles,
        onTap: _selectLocation,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        compassEnabled: true,
        zoomControlsEnabled: false,
      );
    } catch (e) {
      // If map fails to initialize, fall back to manual mode
      AppLogger.e('LocationPickerScreen: GoogleMap initialization failed', e);
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _useMap = false;
            });
          }
        });
      }
      // Return a placeholder while we switch to manual mode
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade900
            : Colors.grey.shade200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_rounded, size: 64.sp, color: Colors.amber),
              SizedBox(height: 16.h),
              Text(
                'Map Unavailable',
                style: AppTypography.heading4(context, Colors.amber),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Text(
                  'Please configure Google Maps API key or use manual selection mode.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall(context, Colors.grey),
                ),
              ),
            ],
          ),
        ),
      );
    }
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
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          (Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.darkSurface
                                  : AppColors.lightSurface)
                              .withOpacity(0.8),
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.primary.withOpacity(0.1),
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              title: Text(
                widget.existingReminder != null
                    ? 'Edit Location'
                    : 'New Location',
                style: AppTypography.heading4(
                  context,
                  AppColors.textPrimary(context),
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              leading: Container(
                margin: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary(context),
                    size: 20.sp,
                  ),
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 24.r,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    _useMap ? Icons.map : Icons.edit_location_alt,
                    color: AppColors.primary,
                  ),
                  tooltip: _useMap ? 'Using Map Mode' : 'Using Manual Mode',
                  onPressed: () {
                    AppLogger.i(
                      'LocationPickerScreen: Toggling map mode to ${!_useMap}',
                    );
                    setState(() {
                      _useMap = !_useMap;
                    });
                  },
                ),
                if (state.selectedLocation != null &&
                    state.messageText.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(right: 16.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.check,
                        color: AppColors.primary,
                        size: 22.sp,
                      ),
                      tooltip: 'Save reminder',
                      onPressed: _saveReminder,
                      splashRadius: 24.r,
                    ),
                  ),
              ],
            ),
            body: Stack(
              children: [
                // Map or Fallback
                if (_useMap)
                  _buildGoogleMap(state, markers, circles, context)
                else
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade900
                        : Colors.grey.shade200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off_outlined,
                            size: 64.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Manual Location Mode',
                            style: AppTypography.heading4(context, Colors.grey),
                          ),
                          SizedBox(height: 8.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40.w),
                            child: Text(
                              'Map view is disabled. You can still select locations from your "Quick Select" list below or enter a message manually.',
                              textAlign: TextAlign.center,
                              style: AppTypography.body2(context, Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // My Location Button
                if (_useMap)
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
                          const SizedBox(height: 24),

                          // Save button
                          _buildPremiumSaveButton(state),
                          const SizedBox(height: 32),
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

  Widget _buildPremiumSaveButton(LocationPickerState state) {
    final canSave =
        state.selectedLocation != null && state.messageText.isNotEmpty;

    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: canSave
              ? [AppColors.primary, AppColors.primary.withOpacity(0.8)]
              : [Colors.grey.withOpacity(0.5), Colors.grey.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: canSave
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canSave
              ? () {
                  // HapticFeedback.mediumImpact();
                  _saveReminder();
                }
              : null,
          borderRadius: BorderRadius.circular(16.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 20.sp,
                color: Colors.white,
              ),
              SizedBox(width: 12.w),
              Text(
                widget.existingReminder != null
                    ? 'Update Reminder'
                    : 'Set Reminder',
                style: AppTypography.body1(
                  context,
                  Colors.white,
                ).copyWith(fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
