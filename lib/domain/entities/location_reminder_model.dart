import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

enum LocationTriggerType {
  arrive, // Trigger when entering the area
  leave, // Trigger when exiting the area
}

class LocationReminder extends Equatable {
  final String id;
  final String message;
  final double latitude;
  final double longitude;
  final double radius; // in meters (default 100m)
  final LocationTriggerType triggerType;
  final String? placeName;
  final String? placeAddress;
  final String? linkedNoteId;
  final bool isActive;
  final DateTime? lastTriggered;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LocationReminder({
    required this.id,
    required this.message,
    required this.latitude,
    required this.longitude,
    this.radius = 100.0,
    this.triggerType = LocationTriggerType.arrive,
    this.placeName,
    this.placeAddress,
    this.linkedNoteId,
    this.isActive = true,
    this.lastTriggered,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LocationReminder.create({
    required String message,
    required double latitude,
    required double longitude,
    double radius = 100.0,
    LocationTriggerType triggerType = LocationTriggerType.arrive,
    String? placeName,
    String? placeAddress,
    String? linkedNoteId,
  }) {
    final now = DateTime.now();
    return LocationReminder(
      id: const Uuid().v4(),
      message: message,
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      triggerType: triggerType,
      placeName: placeName,
      placeAddress: placeAddress,
      linkedNoteId: linkedNoteId,
      isActive: true,
      lastTriggered: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  LocationReminder copyWith({
    String? id,
    String? message,
    double? latitude,
    double? longitude,
    double? radius,
    LocationTriggerType? triggerType,
    String? placeName,
    String? placeAddress,
    String? linkedNoteId,
    bool? isActive,
    DateTime? lastTriggered,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LocationReminder(
      id: id ?? this.id,
      message: message ?? this.message,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      triggerType: triggerType ?? this.triggerType,
      placeName: placeName ?? this.placeName,
      placeAddress: placeAddress ?? this.placeAddress,
      linkedNoteId: linkedNoteId ?? this.linkedNoteId,
      isActive: isActive ?? this.isActive,
      lastTriggered: lastTriggered ?? this.lastTriggered,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'trigger_type': triggerType == LocationTriggerType.arrive
          ? 'arrive'
          : 'leave',
      'place_name': placeName,
      'place_address': placeAddress,
      'linked_note_id': linkedNoteId,
      'is_active': isActive ? 1 : 0,
      'last_triggered': lastTriggered?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory LocationReminder.fromMap(Map<String, dynamic> map) {
    return LocationReminder(
      id: map['id'] as String,
      message: map['message'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      radius: map['radius'] as double? ?? 100.0,
      triggerType: map['trigger_type'] == 'leave'
          ? LocationTriggerType.leave
          : LocationTriggerType.arrive,
      placeName: map['place_name'] as String?,
      placeAddress: map['place_address'] as String?,
      linkedNoteId: map['linked_note_id'] as String?,
      isActive: (map['is_active'] as int?) == 1,
      lastTriggered: map['last_triggered'] != null
          ? DateTime.parse(map['last_triggered'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  String get triggerTypeDisplay {
    switch (triggerType) {
      case LocationTriggerType.arrive:
        return 'When I arrive';
      case LocationTriggerType.leave:
        return 'When I leave';
    }
  }

  String get radiusDisplay {
    if (radius < 1000) {
      return '${radius.toInt()}m';
    } else {
      return '${(radius / 1000).toStringAsFixed(1)}km';
    }
  }

  @override
  List<Object?> get props => [
    id,
    message,
    latitude,
    longitude,
    radius,
    triggerType,
    placeName,
    placeAddress,
    linkedNoteId,
    isActive,
    lastTriggered,
    createdAt,
    updatedAt,
  ];
}
