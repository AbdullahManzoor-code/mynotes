import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class DoNotDisturbSettings extends Equatable {
  final bool enabled;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool allowUrgent;
  final List<String> allowedContacts;

  const DoNotDisturbSettings({
    this.enabled = false,
    required this.startTime,
    required this.endTime,
    this.allowUrgent = false,
    this.allowedContacts = const [],
  });

  DoNotDisturbSettings copyWith({
    bool? enabled,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? allowUrgent,
    List<String>? allowedContacts,
  }) {
    return DoNotDisturbSettings(
      enabled: enabled ?? this.enabled,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      allowUrgent: allowUrgent ?? this.allowUrgent,
      allowedContacts: allowedContacts ?? this.allowedContacts,
    );
  }

  bool isActive() {
    if (!enabled) return false;

    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    if (startMinutes <= endMinutes) {
      return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
    }
    return nowMinutes >= startMinutes || nowMinutes <= endMinutes;
  }

  @override
  List<Object?> get props => [
    enabled,
    startTime,
    endTime,
    allowUrgent,
    allowedContacts,
  ];
}
