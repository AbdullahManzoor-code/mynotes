import '../../domain/entities/alarm.dart';

abstract class AlarmRepository {
  Future<List<Alarm>> getAlarms();
  Future<Alarm?> getAlarmById(String id);
  Future<void> createAlarm(Alarm alarm);
  Future<void> updateAlarm(Alarm alarm);
  Future<void> deleteAlarm(String id);
  Future<void> toggleAlarm(String id);
  Future<void> quickSnooze(String id, SnoozePreset preset);
  Future<void> rescheduleAlarm(String id, DateTime newTime);
  Future<void> markTriggered(String id);
  Future<void> markCompleted(String id);
  Future<void> clearCompleted();
  Future<List<Alarm>> searchAlarms(String query);
}
