import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() => _instance;

  static LocationService get instance => _instance;

  LocationService._internal();

  StreamSubscription<Position>? _positionSubscription;
  final _locationController = StreamController<Position>.broadcast();

  Stream<Position> get locationStream => _locationController.stream;
  Position? _lastKnownPosition;
  Position? get lastKnownPosition => _lastKnownPosition;

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Request location permissions
  Future<LocationPermissionStatus> requestPermission() async {
    // Check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    // Check current permission status
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationPermissionStatus.denied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    }

    // For geofencing, we need "always" permission
    if (permission == LocationPermission.whileInUse) {
      // Request background permission
      final backgroundStatus = await Permission.locationAlways.request();
      if (backgroundStatus.isGranted) {
        return LocationPermissionStatus.granted;
      } else {
        return LocationPermissionStatus.whileInUseOnly;
      }
    }

    return LocationPermissionStatus.granted;
  }

  // Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      final permission = await requestPermission();
      if (permission != LocationPermissionStatus.granted &&
          permission != LocationPermissionStatus.whileInUseOnly) {
        return null;
      }

      _lastKnownPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      return _lastKnownPosition;
    } catch (e) {
      debugPrint('Error getting current position: $e');
      return null;
    }
  }

  // Start listening to location updates
  Future<void> startLocationUpdates() async {
    final permission = await requestPermission();
    if (permission != LocationPermissionStatus.granted) {
      return;
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50, // Update every 50 meters
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            _lastKnownPosition = position;
            _locationController.add(position);
          },
          onError: (error) {
            debugPrint('Location stream error: $error');
          },
        );
  }

  // Stop listening to location updates
  void stopLocationUpdates() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  // Get address from coordinates
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return _formatAddress(place);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting address: $e');
      return null;
    }
  }

  // Get coordinates from address
  Future<LocationCoordinates?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        return LocationCoordinates(
          latitude: location.latitude,
          longitude: location.longitude,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error getting coordinates: $e');
      return null;
    }
  }

  // Calculate distance between two points
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  // Check if user is within radius of a location
  bool isWithinRadius(
    Position userPosition,
    double targetLat,
    double targetLng,
    double radiusMeters,
  ) {
    final distance = calculateDistance(
      userPosition.latitude,
      userPosition.longitude,
      targetLat,
      targetLng,
    );
    return distance <= radiusMeters;
  }

  String _formatAddress(Placemark place) {
    List<String> parts = [];
    if (place.street?.isNotEmpty == true) {
      parts.add(place.street!);
    }
    if (place.locality?.isNotEmpty == true) {
      parts.add(place.locality!);
    }
    if (place.administrativeArea?.isNotEmpty == true) {
      parts.add(place.administrativeArea!);
    }
    if (place.country?.isNotEmpty == true) {
      parts.add(place.country!);
    }
    return parts.join(', ');
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // Open app settings for permissions
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  void dispose() {
    stopLocationUpdates();
    _locationController.close();
  }
}

enum LocationPermissionStatus {
  granted,
  whileInUseOnly,
  denied,
  deniedForever,
  serviceDisabled,
}

class LocationCoordinates {
  final double latitude;
  final double longitude;

  LocationCoordinates({required this.latitude, required this.longitude});
}
