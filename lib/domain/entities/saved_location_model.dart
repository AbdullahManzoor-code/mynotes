import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class SavedLocation extends Equatable {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? address;
  final String icon;
  final DateTime createdAt;

  const SavedLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    this.icon = 'location_on',
    required this.createdAt,
  });

  factory SavedLocation.create({
    required String name,
    required double latitude,
    required double longitude,
    String? address,
    String icon = 'location_on',
  }) {
    return SavedLocation(
      id: const Uuid().v4(),
      name: name,
      latitude: latitude,
      longitude: longitude,
      address: address,
      icon: icon,
      createdAt: DateTime.now(),
    );
  }

  // Preset locations
  static SavedLocation home({
    required double latitude,
    required double longitude,
    String? address,
  }) {
    return SavedLocation.create(
      name: 'Home',
      latitude: latitude,
      longitude: longitude,
      address: address,
      icon: 'home',
    );
  }

  static SavedLocation work({
    required double latitude,
    required double longitude,
    String? address,
  }) {
    return SavedLocation.create(
      name: 'Work',
      latitude: latitude,
      longitude: longitude,
      address: address,
      icon: 'work',
    );
  }

  SavedLocation copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? address,
    String? icon,
    DateTime? createdAt,
  }) {
    return SavedLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'icon': icon,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SavedLocation.fromMap(Map<String, dynamic> map) {
    return SavedLocation(
      id: map['id'] as String,
      name: map['name'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      address: map['address'] as String?,
      icon: map['icon'] as String? ?? 'location_on',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    latitude,
    longitude,
    address,
    icon,
    createdAt,
  ];
}
