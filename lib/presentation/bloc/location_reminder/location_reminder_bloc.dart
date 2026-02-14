import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mynotes/domain/entities/location_reminder_model.dart';
import 'package:mynotes/domain/entities/saved_location_model.dart';
import 'package:mynotes/data/repositories/location_reminder_repository.dart';
import 'package:mynotes/core/services/location_service.dart';
import 'package:mynotes/core/services/geofence_service.dart';

// Events
abstract class LocationReminderEvent extends Equatable {
  const LocationReminderEvent();
  @override
  List<Object?> get props => [];
}

class LoadLocationReminders extends LocationReminderEvent {}

class CreateLocationReminder extends LocationReminderEvent {
  final LocationReminder reminder;
  const CreateLocationReminder({required this.reminder});
  @override
  List<Object?> get props => [reminder];
}

class UpdateLocationReminder extends LocationReminderEvent {
  final LocationReminder reminder;
  const UpdateLocationReminder({required this.reminder});
  @override
  List<Object?> get props => [reminder];
}

class DeleteLocationReminder extends LocationReminderEvent {
  final String reminderId;
  const DeleteLocationReminder({required this.reminderId});
  @override
  List<Object?> get props => [reminderId];
}

class ToggleLocationReminder extends LocationReminderEvent {
  final String reminderId;
  final bool isActive;
  const ToggleLocationReminder({
    required this.reminderId,
    required this.isActive,
  });
  @override
  List<Object?> get props => [reminderId, isActive];
}

class RequestLocationPermission extends LocationReminderEvent {}

class SaveLocation extends LocationReminderEvent {
  final SavedLocation location;
  const SaveLocation({required this.location});
  @override
  List<Object?> get props => [location];
}

class DeleteSavedLocation extends LocationReminderEvent {
  final SavedLocation location;
  const DeleteSavedLocation(this.location);
  @override
  List<Object?> get props => [location];
}

class UpdateSavedLocation extends LocationReminderEvent {
  final SavedLocation location;
  const UpdateSavedLocation(this.location);
  @override
  List<Object?> get props => [location];
}

class GetCurrentLocation extends LocationReminderEvent {}

class ClearFetchedLocation extends LocationReminderEvent {}

// States
abstract class LocationReminderState extends Equatable {
  const LocationReminderState();
  @override
  List<Object?> get props => [];
}

class LocationReminderInitial extends LocationReminderState {}

class LocationReminderLoading extends LocationReminderState {}

class LocationReminderLoaded extends LocationReminderState {
  final List<LocationReminder> reminders;
  final List<SavedLocation> savedLocations;
  final bool hasLocationPermission;
  final bool isMonitoring;
  final LatLng? currentPosition;
  final bool isFetchingLocation;

  const LocationReminderLoaded({
    required this.reminders,
    this.savedLocations = const [],
    this.hasLocationPermission = false,
    this.isMonitoring = false,
    this.currentPosition,
    this.isFetchingLocation = false,
  });

  @override
  List<Object?> get props => [
    reminders,
    savedLocations,
    hasLocationPermission,
    isMonitoring,
    currentPosition,
    isFetchingLocation,
  ];

  LocationReminderLoaded copyWith({
    List<LocationReminder>? reminders,
    List<SavedLocation>? savedLocations,
    bool? hasLocationPermission,
    bool? isMonitoring,
    LatLng? currentPosition,
    bool? isFetchingLocation,
    bool clearPosition = false,
  }) {
    return LocationReminderLoaded(
      reminders: reminders ?? this.reminders,
      savedLocations: savedLocations ?? this.savedLocations,
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
      isMonitoring: isMonitoring ?? this.isMonitoring,
      currentPosition: clearPosition
          ? null
          : (currentPosition ?? this.currentPosition),
      isFetchingLocation: isFetchingLocation ?? this.isFetchingLocation,
    );
  }
}

class LocationReminderError extends LocationReminderState {
  final String message;
  const LocationReminderError({required this.message});
  @override
  List<Object?> get props => [message];
}

// BLoC
class LocationReminderBloc
    extends Bloc<LocationReminderEvent, LocationReminderState> {
  final LocationReminderRepository repository;
  final LocationService _locationService = LocationService();
  final GeofenceManager _geofenceManager = GeofenceManager();

  LocationReminderBloc({required this.repository})
    : super(LocationReminderInitial()) {
    on<LoadLocationReminders>(_onLoadReminders);
    on<CreateLocationReminder>(_onCreateReminder);
    on<UpdateLocationReminder>(_onUpdateReminder);
    on<DeleteLocationReminder>(_onDeleteReminder);
    on<ToggleLocationReminder>(_onToggleReminder);
    on<RequestLocationPermission>(_onRequestPermission);
    on<SaveLocation>(_onSaveLocation);
    on<DeleteSavedLocation>(_onDeleteSavedLocation);
    on<UpdateSavedLocation>(_onUpdateSavedLocation);
    on<GetCurrentLocation>(_onGetCurrentLocation);
    on<ClearFetchedLocation>(_onClearFetchedLocation);
  }

  Future<void> _onLoadReminders(
    LoadLocationReminders event,
    Emitter<LocationReminderState> emit,
  ) async {
    emit(LocationReminderLoading());

    try {
      final reminders = await repository.getAllLocationReminders();
      final savedLocations = await repository.getSavedLocations();
      final permissionStatus = await _locationService.requestPermission();
      final hasPermission =
          permissionStatus == LocationPermissionStatus.granted;

      // Initialize geofencing if we have permission and active reminders
      if (hasPermission && reminders.any((r) => r.isActive)) {
        await _geofenceManager.initialize();
        await _geofenceManager.startMonitoring();
      }

      emit(
        LocationReminderLoaded(
          reminders: reminders,
          savedLocations: savedLocations,
          hasLocationPermission: hasPermission,
          isMonitoring: hasPermission && reminders.any((r) => r.isActive),
        ),
      );
    } catch (e) {
      emit(LocationReminderError(message: 'Failed to load reminders: $e'));
    }
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocation event,
    Emitter<LocationReminderState> emit,
  ) async {
    if (state is! LocationReminderLoaded) return;
    final currentState = state as LocationReminderLoaded;

    emit(currentState.copyWith(isFetchingLocation: true));

    try {
      final position = _locationService.lastKnownPosition;
      if (position != null) {
        emit(
          currentState.copyWith(
            currentPosition: LatLng(position.latitude, position.longitude),
            isFetchingLocation: false,
          ),
        );
      } else {
        final newPosition = await _locationService.getCurrentPosition();
        if (newPosition != null) {
          emit(
            currentState.copyWith(
              currentPosition: LatLng(
                newPosition.latitude,
                newPosition.longitude,
              ),
              isFetchingLocation: false,
            ),
          );
        } else {
          emit(currentState.copyWith(isFetchingLocation: false));
        }
      }
    } catch (e) {
      emit(currentState.copyWith(isFetchingLocation: false));
    }
  }

  void _onClearFetchedLocation(
    ClearFetchedLocation event,
    Emitter<LocationReminderState> emit,
  ) {
    if (state is LocationReminderLoaded) {
      emit((state as LocationReminderLoaded).copyWith(clearPosition: true));
    }
  }

  Future<void> _onCreateReminder(
    CreateLocationReminder event,
    Emitter<LocationReminderState> emit,
  ) async {
    try {
      await repository.insertLocationReminder(event.reminder);
      await _geofenceManager.registerGeofence(event.reminder);
      await _geofenceManager.refreshGeofences();
      add(LoadLocationReminders());
    } catch (e) {
      emit(LocationReminderError(message: 'Failed to create reminder: $e'));
    }
  }

  Future<void> _onUpdateReminder(
    UpdateLocationReminder event,
    Emitter<LocationReminderState> emit,
  ) async {
    try {
      await repository.updateLocationReminder(event.reminder);
      await _geofenceManager.refreshGeofences();
      add(LoadLocationReminders());
    } catch (e) {
      emit(LocationReminderError(message: 'Failed to update reminder: $e'));
    }
  }

  Future<void> _onDeleteReminder(
    DeleteLocationReminder event,
    Emitter<LocationReminderState> emit,
  ) async {
    try {
      await repository.deleteLocationReminder(event.reminderId);
      await _geofenceManager.unregisterGeofence(event.reminderId);
      add(LoadLocationReminders());
    } catch (e) {
      emit(LocationReminderError(message: 'Failed to delete reminder: $e'));
    }
  }

  Future<void> _onToggleReminder(
    ToggleLocationReminder event,
    Emitter<LocationReminderState> emit,
  ) async {
    try {
      final reminder = await repository.getLocationReminderById(
        event.reminderId,
      );
      if (reminder != null) {
        final updated = reminder.copyWith(isActive: event.isActive);
        await repository.updateLocationReminder(updated);
        await _geofenceManager.refreshGeofences();
        add(LoadLocationReminders());
      }
    } catch (e) {
      emit(LocationReminderError(message: 'Failed to toggle reminder: $e'));
    }
  }

  Future<void> _onRequestPermission(
    RequestLocationPermission event,
    Emitter<LocationReminderState> emit,
  ) async {
    final status = await _locationService.requestPermission();

    if (status == LocationPermissionStatus.deniedForever) {
      await _locationService.openAppSettings();
    }

    add(LoadLocationReminders());
  }

  Future<void> _onSaveLocation(
    SaveLocation event,
    Emitter<LocationReminderState> emit,
  ) async {
    try {
      await repository.insertSavedLocation(event.location);
      add(LoadLocationReminders());
    } catch (e) {
      emit(LocationReminderError(message: 'Failed to save location: $e'));
    }
  }

  Future<void> _onDeleteSavedLocation(
    DeleteSavedLocation event,
    Emitter<LocationReminderState> emit,
  ) async {
    try {
      await repository.deleteSavedLocation(event.location.id);
      add(LoadLocationReminders());
    } catch (e) {
      emit(
        LocationReminderError(message: 'Failed to delete saved location: $e'),
      );
    }
  }

  Future<void> _onUpdateSavedLocation(
    UpdateSavedLocation event,
    Emitter<LocationReminderState> emit,
  ) async {
    try {
      await repository.updateSavedLocation(event.location);
      add(LoadLocationReminders());
    } catch (e) {
      emit(
        LocationReminderError(message: 'Failed to update saved location: $e'),
      );
    }
  }

  @override
  Future<void> close() {
    _geofenceManager.dispose();
    _locationService.dispose();
    return super.close();
  }
}
