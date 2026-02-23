import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PlacesService {
  static const String _host = 'maps.googleapis.com';
  static const String _basePath = '/maps/api/place';
  static PlacesService? _instance;
  final String _apiKey;

  PlacesService._internal(this._apiKey);

  factory PlacesService({String? apiKey}) {
    if (_instance != null) return _instance!;

    final resolvedApiKey = (apiKey ?? const String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: 'AIzaSyC3LdxNlGw6oxkSJSjzpqXMmSk5mEI91kk')).trim();

    _instance = PlacesService._internal(resolvedApiKey);
    return _instance!;
  }

  static PlacesService get instance {
    return PlacesService();
  }

  bool get _hasApiKey => _apiKey.isNotEmpty;
  bool get hasApiKey => _hasApiKey;

  Uri _buildUri(String endpoint, Map<String, String> queryParameters) {
    return Uri.https(_host, '$_basePath/$endpoint', queryParameters);
  }

  bool _isPlacesSuccessStatus(String status) {
    return status == 'OK' || status == 'ZERO_RESULTS';
  }

  // Search for places using autocomplete
  Future<List<PlacePrediction>> searchPlaces(
    String query, {
    double? latitude,
    double? longitude,
    int radiusMeters = 50000,
  }) async {
    if (query.length < 2) return [];
    if (!_hasApiKey) {
      debugPrint('PlacesService: Missing GOOGLE_MAPS_API_KEY');
      return [];
    }

    final params = <String, String>{'input': query, 'key': _apiKey};
    if (latitude != null && longitude != null) {
      params['location'] = '$latitude,$longitude';
      params['radius'] = '$radiusMeters';
    }
    final uri = _buildUri('autocomplete/json', params);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = (data['status'] as String?) ?? '';

        if (_isPlacesSuccessStatus(status)) {
          final predictions = data['predictions'] as List;
          return predictions.map((p) => PlacePrediction.fromJson(p)).toList();
        }

        debugPrint('PlacesService.searchPlaces status: $status');
      }

      return [];
    } catch (e) {
      debugPrint('Error searching places: $e');
      return [];
    }
  }

  // Get place details including coordinates
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    if (!_hasApiKey) {
      debugPrint('PlacesService: Missing GOOGLE_MAPS_API_KEY');
      return null;
    }

    final uri = _buildUri('details/json', {
      'place_id': placeId,
      'fields': 'name,formatted_address,geometry',
      'key': _apiKey,
    });

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = (data['status'] as String?) ?? '';

        if (status == 'OK') {
          return PlaceDetails.fromJson(data['result']);
        }

        debugPrint('PlacesService.getPlaceDetails status: $status');
      }

      return null;
    } catch (e) {
      debugPrint('Error getting place details: $e');
      return null;
    }
  }

  // Get nearby places
  Future<List<NearbyPlace>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    int radiusMeters = 1000,
    String? type, // e.g., "grocery_or_supermarket", "restaurant", etc.
  }) async {
    if (!_hasApiKey) {
      debugPrint('PlacesService: Missing GOOGLE_MAPS_API_KEY');
      return [];
    }

    final params = <String, String>{
      'location': '$latitude,$longitude',
      'radius': '$radiusMeters',
      'key': _apiKey,
    };
    if (type != null && type.isNotEmpty) {
      params['type'] = type;
    }
    final uri = _buildUri('nearbysearch/json', params);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = (data['status'] as String?) ?? '';

        if (_isPlacesSuccessStatus(status)) {
          final results = data['results'] as List;
          return results.map((r) => NearbyPlace.fromJson(r)).toList();
        }

        debugPrint('PlacesService.getNearbyPlaces status: $status');
      }

      return [];
    } catch (e) {
      debugPrint('Error getting nearby places: $e');
      return [];
    }
  }
}

class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structuredFormatting = json['structured_formatting'] ?? {};
    return PlacePrediction(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText: structuredFormatting['main_text'] ?? '',
      secondaryText: structuredFormatting['secondary_text'] ?? '',
    );
  }
}

class PlaceDetails {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  PlaceDetails({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] ?? {};
    final location = geometry['location'] ?? {};

    return PlaceDetails(
      name: json['name'] ?? '',
      address: json['formatted_address'] ?? '',
      latitude: (location['lat'] ?? 0.0).toDouble(),
      longitude: (location['lng'] ?? 0.0).toDouble(),
    );
  }
}

class NearbyPlace {
  final String placeId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> types;
  final double? rating;

  NearbyPlace({
    required this.placeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.types,
    this.rating,
  });

  factory NearbyPlace.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] ?? {};
    final location = geometry['location'] ?? {};

    return NearbyPlace(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? '',
      address: json['vicinity'] ?? '',
      latitude: (location['lat'] ?? 0.0).toDouble(),
      longitude: (location['lng'] ?? 0.0).toDouble(),
      types: List<String>.from(json['types'] ?? []),
      rating: json['rating']?.toDouble(),
    );
  }
}
