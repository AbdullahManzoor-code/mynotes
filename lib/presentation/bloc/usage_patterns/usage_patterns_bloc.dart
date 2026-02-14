import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

part 'usage_patterns_event.dart';
part 'usage_patterns_state.dart';

/// Usage Patterns BLoC for tracking user activity
/// Monitors daily usage, active hours, and feature breakdown
class UsagePatternsBloc extends Bloc<UsagePatternsEvent, UsagePatternsState> {
  final Map<String, dynamic> _usageData = {};
  static const String _usageKey = 'app_usage_patterns';

  UsagePatternsBloc() : super(const UsagePatternsInitial()) {
    on<LoadUsagePatternsEvent>(_onLoadUsagePatterns);
    on<TrackFeatureUsageEvent>(_onTrackFeatureUsage);
    on<TrackSessionEvent>(_onTrackSession);
    on<GetDailyUsageEvent>(_onGetDailyUsage);
    on<GetActiveHoursEvent>(_onGetActiveHours);
    on<GetFeatureBreakdownEvent>(_onGetFeatureBreakdown);
  }

  Future<void> _onLoadUsagePatterns(
    LoadUsagePatternsEvent event,
    Emitter<UsagePatternsState> emit,
  ) async {
    try {
      emit(const UsagePatternsLoading());

      final prefs = await SharedPreferences.getInstance();
      final usageJson = prefs.getString(_usageKey);

      if (usageJson != null) {
        _usageData.clear();
        _usageData.addAll(jsonDecode(usageJson) as Map<String, dynamic>);
      }

      emit(UsagePatternsLoaded(patterns: _usageData));
    } catch (e) {
      emit(UsagePatternsError(e.toString()));
    }
  }

  Future<void> _onTrackFeatureUsage(
    TrackFeatureUsageEvent event,
    Emitter<UsagePatternsState> emit,
  ) async {
    try {
      final key = 'feature_${event.featureName}';
      final current = _usageData[key] as int? ?? 0;
      _usageData[key] = current + 1;
      _usageData['last_feature_used'] = event.featureName;
      _usageData['last_used_at'] = DateTime.now().toIso8601String();

      await _saveUsageData();
      emit(FeatureUsageTracked(feature: event.featureName, count: current + 1));
    } catch (e) {
      emit(UsagePatternsError(e.toString()));
    }
  }

  Future<void> _onTrackSession(
    TrackSessionEvent event,
    Emitter<UsagePatternsState> emit,
  ) async {
    try {
      final sessions = (_usageData['sessions'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      sessions.add({
        'startTime': event.startTime.toIso8601String(),
        'endTime': event.endTime.toIso8601String(),
        'duration': event.endTime.difference(event.startTime).inSeconds,
      });

      _usageData['sessions'] = sessions;
      await _saveUsageData();

      emit(SessionTracked(duration: event.endTime.difference(event.startTime)));
    } catch (e) {
      emit(UsagePatternsError(e.toString()));
    }
  }

  Future<void> _onGetDailyUsage(
    GetDailyUsageEvent event,
    Emitter<UsagePatternsState> emit,
  ) async {
    try {
      emit(const UsagePatternsLoading());

      // Calculate daily usage for the given date
      final sessions = (_usageData['sessions'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      final todayUsage = sessions
          .where((s) {
            final startTime = DateTime.parse(s['startTime'] as String);
            return startTime.year == event.date.year &&
                startTime.month == event.date.month &&
                startTime.day == event.date.day;
          })
          .fold<int>(0, (sum, s) => sum + (s['duration'] as int? ?? 0));

      emit(DailyUsageCalculated(date: event.date, usageSeconds: todayUsage));
    } catch (e) {
      emit(UsagePatternsError(e.toString()));
    }
  }

  Future<void> _onGetActiveHours(
    GetActiveHoursEvent event,
    Emitter<UsagePatternsState> emit,
  ) async {
    try {
      emit(const UsagePatternsLoading());

      // Analyze active hours from sessions
      final sessions = (_usageData['sessions'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      final hourlyActivity = <int, int>{}; // hour -> count

      for (final session in sessions) {
        final startTime = DateTime.parse(session['startTime'] as String);
        hourlyActivity[startTime.hour] =
            (hourlyActivity[startTime.hour] ?? 0) + 1;
      }

      emit(ActiveHoursAnalyzed(hourlyActivity: hourlyActivity));
    } catch (e) {
      emit(UsagePatternsError(e.toString()));
    }
  }

  Future<void> _onGetFeatureBreakdown(
    GetFeatureBreakdownEvent event,
    Emitter<UsagePatternsState> emit,
  ) async {
    try {
      emit(const UsagePatternsLoading());

      final breakdown = <String, int>{};
      _usageData.forEach((key, value) {
        if (key.startsWith('feature_')) {
          final featureName = key.replaceFirst('feature_', '');
          breakdown[featureName] = value as int;
        }
      });

      emit(FeatureBreakdownCalculated(breakdown: breakdown));
    } catch (e) {
      emit(UsagePatternsError(e.toString()));
    }
  }

  Future<void> _saveUsageData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usageKey, jsonEncode(_usageData));
  }
}
