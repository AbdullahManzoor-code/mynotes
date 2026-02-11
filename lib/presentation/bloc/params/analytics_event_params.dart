import 'package:equatable/equatable.dart';

/// Complete Param Model for Analytics Events
/// 📦 Container for all analytics-related data
class AnalyticsEventParams extends Equatable {
  final String eventName;
  final Map<String, dynamic> eventProperties;
  final DateTime timestamp;
  final String? userId;
  final String? sessionId;
  final String? screenName;

  AnalyticsEventParams({
    required this.eventName,
    this.eventProperties = const {},
    DateTime? timestamp,
    this.userId,
    this.sessionId,
    this.screenName,
  }) : timestamp = timestamp ?? DateTime.now();

  AnalyticsEventParams copyWith({
    String? eventName,
    Map<String, dynamic>? eventProperties,
    DateTime? timestamp,
    String? userId,
    String? sessionId,
    String? screenName,
  }) {
    return AnalyticsEventParams(
      eventName: eventName ?? this.eventName,
      eventProperties: eventProperties ?? this.eventProperties,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      screenName: screenName ?? this.screenName,
    );
  }

  AnalyticsEventParams withProperty(String key, dynamic value) {
    final props = Map<String, dynamic>.from(eventProperties);
    props[key] = value;
    return copyWith(eventProperties: props);
  }

  AnalyticsEventParams withUserId(String id) => copyWith(userId: id);
  AnalyticsEventParams withSessionId(String id) => copyWith(sessionId: id);
  AnalyticsEventParams withScreenName(String screen) =>
      copyWith(screenName: screen);

  @override
  List<Object?> get props => [
    eventName,
    eventProperties,
    timestamp,
    userId,
    sessionId,
    screenName,
  ];
}
