import '../../domain/entities/alarm.dart';
import '../../domain/repositories/alarm_repository.dart';
import 'package:mynotes/core/database/core_database.dart';

class AlarmRepositoryImpl implements AlarmRepository {
  final CoreDatabase _database;

  AlarmRepositoryImpl({required CoreDatabase database}) : _database = database;

  @override
  Future<List<Alarm>> getAlarms() async {
    return await _database.getAllAlarms();
  }

  @override
  Future<Alarm?> getAlarmById(String id) async {
    return await _database.getAlarmById(id);
  }

  @override
  Future<void> createAlarm(Alarm alarm) async {
    await _database.createAlarm(alarm);
  }

  @override
  Future<void> updateAlarm(Alarm alarm) async {
    await _database.updateAlarm(alarm);
  }

  @override
  Future<void> deleteAlarm(String id) async {
    await _database.deleteAlarm(id);
  }

  @override
  Future<void> toggleAlarm(String id) async {
    final alarm = await getAlarmById(id);
    if (alarm != null) {
      await updateAlarm(alarm.copyWith(isEnabled: !alarm.isEnabled));
    }
  }

  @override
  Future<void> quickSnooze(String id, SnoozePreset preset) async {
    final alarm = await getAlarmById(id);
    if (alarm == null) return;

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
        final now = DateTime.now();
        final tomorrow9AM = DateTime(now.year, now.month, now.day + 1, 9, 0);
        duration = tomorrow9AM.difference(now);
        break;
    }

    final snoozedAlarm = alarm.snooze(duration);
    await updateAlarm(snoozedAlarm);
  }

  @override
  Future<void> rescheduleAlarm(String id, DateTime newTime) async {
    final alarm = await getAlarmById(id);
    if (alarm != null) {
      await updateAlarm(alarm.reschedule(newTime));
    }
  }

  @override
  Future<void> markTriggered(String id) async {
    final alarm = await getAlarmById(id);
    if (alarm != null) {
      await updateAlarm(alarm.markTriggered());
    }
  }

  @override
  Future<void> markCompleted(String id) async {
    final alarm = await getAlarmById(id);
    if (alarm != null) {
      await updateAlarm(alarm.markCompleted());
    }
  }

  @override
  Future<void> clearCompleted() async {
    final alarms = await getAlarms();
    for (final alarm in alarms) {
      if (alarm.isCompleted) {
        await deleteAlarm(alarm.id);
      }
    }
  }

  @override
  Future<List<Alarm>> searchAlarms(String query) async {
    return await _database.searchAlarms(query);
  }
}
