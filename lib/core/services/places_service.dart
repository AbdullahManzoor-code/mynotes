import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static final PlacesService _instance = PlacesService._internal();
  final String _apiKey;

  PlacesService._internal() : _apiKey = 'YOUR_GOOGLE_API_KEY';

  factory PlacesService({String? apiKey}) {
    return _instance;
  }

  static PlacesService get instance {
    return _instance;
  }

  // Search for places using autocomplete
  Future<List<PlacePrediction>> searchPlaces(
    String query, {
    double? latitude,
    double? longitude,
    int radiusMeters = 50000,
  }) async {
    if (query.length < 2 || _apiKey == 'YOUR_GOOGLE_API_KEY') return [];

    String url = '$_baseUrl/autocomplete/json?input=$query&key=$_apiKey';

    if (latitude != null && longitude != null) {
      url += '&location=$latitude,$longitude&radius=$radiusMeters';
    }

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          return predictions.map((p) => PlacePrediction.fromJson(p)).toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error searching places: $e');
      return [];
    }
  }

  // Get place details including coordinates
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    if (_apiKey == 'YOUR_GOOGLE_API_KEY') return null;

    final url =
        '$_baseUrl/details/json?place_id=$placeId&fields=name,formatted_address,geometry&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          return PlaceDetails.fromJson(data['result']);
        }
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
    String url =
        '$_baseUrl/nearbysearch/json?location=$latitude,$longitude&radius=$radiusMeters&key=$_apiKey';

    if (type != null) {
      url += '&type=$type';
    }

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          return results.map((r) => NearbyPlace.fromJson(r)).toList();
        }
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
