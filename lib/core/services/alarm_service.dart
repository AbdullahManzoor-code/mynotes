import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/alarm.dart';

/// Service for managing alarm persistence and scheduling (ALM-001 through ALM-005)
class AlarmService {
  static const String _alarmsKey = 'alarms';
  static const String _lastAlarmIdKey = 'last_alarm_id';

  /// Load all alarms from persistent storage
  Future<List<Alarm>> loadAlarms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? alarmsJson = prefs.getString(_alarmsKey);

      if (alarmsJson == null || alarmsJson.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(alarmsJson);
      return jsonList
          .map((json) => Alarm.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading alarms: $e');
      return [];
    }
  }

  /// Save all alarms to persistent storage
  Future<bool> saveAlarms(List<Alarm> alarms) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = alarms.map((alarm) => alarm.toJson()).toList();
      final alarmsJson = json.encode(jsonList);
      return await prefs.setString(_alarmsKey, alarmsJson);
    } catch (e) {
      print('Error saving alarms: $e');
      return false;
    }
  }

  /// Generate unique alarm ID
  Future<String> generateAlarmId() async {
    final prefs = await SharedPreferences.getInstance();
    final int lastId = prefs.getInt(_lastAlarmIdKey) ?? 0;
    final int newId = lastId + 1;
    await prefs.setInt(_lastAlarmIdKey, newId);
    return 'alarm_$newId';
  }

  /// Add a new alarm
  Future<Alarm?> addAlarm(Alarm alarm) async {
    try {
      final alarms = await loadAlarms();
      alarms.add(alarm);
      final success = await saveAlarms(alarms);
      return success ? alarm : null;
    } catch (e) {
      print('Error adding alarm: $e');
      return null;
    }
  }

  /// Update an existing alarm
  Future<bool> updateAlarm(Alarm alarm) async {
    try {
      final alarms = await loadAlarms();
      final index = alarms.indexWhere((a) => a.id == alarm.id);

      if (index == -1) return false;

      alarms[index] = alarm;
      return await saveAlarms(alarms);
    } catch (e) {
      print('Error updating alarm: $e');
      return false;
    }
  }

  /// Delete an alarm
  Future<bool> deleteAlarm(String alarmId) async {
    try {
      final alarms = await loadAlarms();
      final filteredAlarms = alarms.where((a) => a.id != alarmId).toList();
      return await saveAlarms(filteredAlarms);
    } catch (e) {
      print('Error deleting alarm: $e');
      return false;
    }
  }

  /// Get alarm by ID
  Future<Alarm?> getAlarmById(String alarmId) async {
    try {
      final alarms = await loadAlarms();
      return alarms.firstWhere(
        (alarm) => alarm.id == alarmId,
        orElse: () => throw Exception('Alarm not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get alarms by status (ALM-004)
  Future<List<Alarm>> getAlarmsByStatus(AlarmStatus status) async {
    final alarms = await loadAlarms();
    return alarms.where((alarm) => alarm.status == status).toList();
  }

  /// Get active alarms only
  Future<List<Alarm>> getActiveAlarms() async {
    final alarms = await loadAlarms();
    return alarms.where((alarm) => alarm.isActive).toList();
  }

  /// Get overdue alarms (ALM-004)
  Future<List<Alarm>> getOverdueAlarms() async {
    final alarms = await loadAlarms();
    return alarms.where((alarm) => alarm.isOverdue).toList();
  }

  /// Get alarms due soon (within 1 hour) (ALM-004)
  Future<List<Alarm>> getDueSoonAlarms() async {
    final alarms = await loadAlarms();
    return alarms.where((alarm) => alarm.isDueSoon).toList();
  }

  /// Get future alarms (ALM-004)
  Future<List<Alarm>> getFutureAlarms() async {
    final alarms = await loadAlarms();
    return alarms.where((alarm) {
      return alarm.isActive &&
          !alarm.isOverdue &&
          !alarm.isDueSoon &&
          alarm.status != AlarmStatus.completed;
    }).toList();
  }

  /// Get alarms linked to a specific note
  Future<List<Alarm>> getAlarmsForNote(String noteId) async {
    final alarms = await loadAlarms();
    return alarms.where((alarm) => alarm.linkedNoteId == noteId).toList();
  }

  /// Toggle alarm active state
  Future<bool> toggleAlarm(String alarmId) async {
    try {
      final alarm = await getAlarmById(alarmId);
      if (alarm == null) return false;

      final updatedAlarm = alarm.toggleActive();
      return await updateAlarm(updatedAlarm);
    } catch (e) {
      print('Error toggling alarm: $e');
      return false;
    }
  }

  /// Snooze an alarm (ALM-005, NOT-002)
  Future<bool> snoozeAlarm(String alarmId, Duration duration) async {
    try {
      final alarm = await getAlarmById(alarmId);
      if (alarm == null) return false;

      final snoozedAlarm = alarm.snooze(duration);
      return await updateAlarm(snoozedAlarm);
    } catch (e) {
      print('Error snoozing alarm: $e');
      return false;
    }
  }

  /// Quick snooze presets (NOT-002)
  Future<bool> quickSnooze(String alarmId, SnoozePreset preset) async {
    Duration duration;
    switch (preset) {
      case SnoozePreset.tenMinutes:
        duration = const Duration(minutes: 10);
        break;
      case SnoozePreset.oneHour:
        duration = const Duration(hours: 1);
        break;
      case SnoozePreset.oneDay:
        duration = const Duration(days: 1);
        break;
      case SnoozePreset.tomorrowMorning:
        // Tomorrow at 9 AM
        final now = DateTime.now();
        final tomorrow9AM = DateTime(now.year, now.month, now.day + 1, 9, 0);
        duration = tomorrow9AM.difference(now);
        break;
    }

    return await snoozeAlarm(alarmId, duration);
  }

  /// Reschedule an alarm (ALM-005)
  Future<bool> rescheduleAlarm(String alarmId, DateTime newTime) async {
    try {
      final alarm = await getAlarmById(alarmId);
      if (alarm == null) return false;

      final rescheduledAlarm = alarm.reschedule(newTime);
      return await updateAlarm(rescheduledAlarm);
    } catch (e) {
      print('Error rescheduling alarm: $e');
      return false;
    }
  }

  /// Mark alarm as triggered
  Future<bool> markTriggered(String alarmId) async {
    try {
      final alarm = await getAlarmById(alarmId);
      if (alarm == null) return false;

      final triggeredAlarm = alarm.markTriggered();
      return await updateAlarm(triggeredAlarm);
    } catch (e) {
      print('Error marking alarm as triggered: $e');
      return false;
    }
  }

  /// Mark alarm as completed
  Future<bool> markCompleted(String alarmId) async {
    try {
      final alarm = await getAlarmById(alarmId);
      if (alarm == null) return false;

      final completedAlarm = alarm.markCompleted();
      return await updateAlarm(completedAlarm);
    } catch (e) {
      print('Error marking alarm as completed: $e');
      return false;
    }
  }

  /// Sort alarms by scheduled time
  List<Alarm> sortByTime(List<Alarm> alarms, {bool ascending = true}) {
    final sorted = List<Alarm>.from(alarms);
    sorted.sort((a, b) {
      final aTime = a.snoozedUntil ?? a.scheduledTime;
      final bTime = b.snoozedUntil ?? b.scheduledTime;
      return ascending ? aTime.compareTo(bTime) : bTime.compareTo(aTime);
    });
    return sorted;
  }

  /// Get alarm statistics
  Future<AlarmStats> getStats() async {
    final alarms = await loadAlarms();
    final active = alarms.where((a) => a.isActive).length;
    final overdue = alarms.where((a) => a.isOverdue).length;
    final dueSoon = alarms.where((a) => a.isDueSoon).length;
    final completed = alarms
        .where((a) => a.status == AlarmStatus.completed)
        .length;

    return AlarmStats(
      total: alarms.length,
      active: active,
      overdue: overdue,
      dueSoon: dueSoon,
      completed: completed,
    );
  }

  /// Clear all completed alarms
  Future<bool> clearCompleted() async {
    try {
      final alarms = await loadAlarms();
      final activeAlarms = alarms
          .where((alarm) => alarm.status != AlarmStatus.completed)
          .toList();
      return await saveAlarms(activeAlarms);
    } catch (e) {
      print('Error clearing completed alarms: $e');
      return false;
    }
  }
}

/// Snooze preset options (NOT-002)
enum SnoozePreset { tenMinutes, oneHour, oneDay, tomorrowMorning }

extension SnoozePresetExtension on SnoozePreset {
  String get displayName {
    switch (this) {
      case SnoozePreset.tenMinutes:
        return '+10 minutes';
      case SnoozePreset.oneHour:
        return '+1 hour';
      case SnoozePreset.oneDay:
        return '+1 day';
      case SnoozePreset.tomorrowMorning:
        return 'Tomorrow 9 AM';
    }
  }
}

/// Alarm statistics
class AlarmStats {
  final int total;
  final int active;
  final int overdue;
  final int dueSoon;
  final int completed;

  AlarmStats({
    required this.total,
    required this.active,
    required this.overdue,
    required this.dueSoon,
    required this.completed,
  });
}
