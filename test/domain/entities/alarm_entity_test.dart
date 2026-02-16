import 'package:flutter_test/flutter_test.dart';
import 'package:mynotes/domain/entities/alarm.dart';

void main() {
  group('Alarm Entity Tests', () {
    test('Alarm can be created with single occurrence', () {
      final scheduledTime = DateTime(2026, 2, 20, 10, 0);
      final alarm = Alarm(
        id: 'a1',
        noteId: 'n1',
        scheduledTime: scheduledTime,
        recurrence: AlarmRecurrence.none,
        status: AlarmStatus.scheduled,
        createdAt: DateTime.now(),
      );

      expect(alarm.id, 'a1');
      expect(alarm.noteId, 'n1');
      expect(alarm.scheduledTime, scheduledTime);
      expect(alarm.recurrence, AlarmRecurrence.none);
      expect(alarm.status, AlarmStatus.scheduled);
    });

    test('Alarm with daily recurrence should be valid', () {
      final alarm = Alarm(
        id: 'a1',
        noteId: 'n1',
        scheduledTime: DateTime(2026, 2, 20, 9, 0),
        recurrence: AlarmRecurrence.daily,
        status: AlarmStatus.scheduled,
        createdAt: DateTime.now(),
      );

      expect(alarm.recurrence, AlarmRecurrence.daily);
    });

    test('Alarm with weekly recurrence should be valid', () {
      final alarm = Alarm(
        id: 'a1',
        noteId: 'n1',
        scheduledTime: DateTime(2026, 2, 20, 9, 0),
        recurrence: AlarmRecurrence.weekly,
        status: AlarmStatus.scheduled,
        createdAt: DateTime.now(),
      );

      expect(alarm.recurrence, AlarmRecurrence.weekly);
    });

    test('Alarm with monthly recurrence should be valid', () {
      final alarm = Alarm(
        id: 'a1',
        noteId: 'n1',
        scheduledTime: DateTime(2026, 2, 20, 9, 0),
        recurrence: AlarmRecurrence.monthly,
        status: AlarmStatus.scheduled,
        createdAt: DateTime.now(),
      );

      expect(alarm.recurrence, AlarmRecurrence.monthly);
    });

    test('Alarm with yearly recurrence should be valid', () {
      final alarm = Alarm(
        id: 'a1',
        noteId: 'n1',
        scheduledTime: DateTime(2026, 2, 20, 9, 0),
        recurrence: AlarmRecurrence.yearly,
        status: AlarmStatus.scheduled,
        createdAt: DateTime.now(),
      );

      expect(alarm.recurrence, AlarmRecurrence.yearly);
    });

    test('Alarm status transitions: scheduled -> triggered', () {
      final alarm = Alarm(
        id: 'a1',
        noteId: 'n1',
        scheduledTime: DateTime.now(),
        recurrence: AlarmRecurrence.none,
        status: AlarmStatus.scheduled,
        createdAt: DateTime.now(),
      );

      final triggered = alarm.copyWith(status: AlarmStatus.triggered);

      expect(alarm.status, AlarmStatus.scheduled);
      expect(triggered.status, AlarmStatus.triggered);
    });

    test('Alarm can be snoozed', () {
      final alarm = Alarm(
        id: 'a1',
        noteId: 'n1',
        scheduledTime: DateTime(2026, 2, 20, 9, 0),
        recurrence: AlarmRecurrence.none,
        status: AlarmStatus.triggered,
        createdAt: DateTime.now(),
      );

      final snoozed = alarm.copyWith(
        status: AlarmStatus.snoozed,
        scheduledTime: alarm.scheduledTime.add(const Duration(minutes: 10)),
      );

      expect(snoozed.status, AlarmStatus.snoozed);
      expect(snoozed.scheduledTime.difference(alarm.scheduledTime).inMinutes, 10);
    });

    test('Alarm can be marked as completed', () {
      final alarm = Alarm(
        id: 'a1',
        noteId: 'n1',
        scheduledTime: DateTime.now(),
        recurrence: AlarmRecurrence.none,
        status: AlarmStatus.triggered,
        createdAt: DateTime.now(),
      );

      final completed = alarm.copyWith(status: AlarmStatus.completed);

      expect(completed.status, AlarmStatus.completed);
    });

    test('Alarm with title and description should work', () {
      final alarm = Alarm(
        id: 'a1',
        noteId: 'n1',
        scheduledTime: DateTime(2026, 2, 20, 14, 30),
        recurrence: AlarmRecurrence.daily,
        status: AlarmStatus.scheduled,
        createdAt: DateTime.now(),
        title: 'Team Meeting',
        description: 'Weekly sync with product team',
      );

      expect(alarm.title, 'Team Meeting');
      expect(alarm.description, 'Weekly sync with product team');
    });

    test('Multiple alarms for same note should be independent', () {
      final now = DateTime.now();
      final alarms = [
        Alarm(
          id: 'a1',
          noteId: 'n1',
          scheduledTime: now.add(const Duration(hours: 1)),
          recurrence: AlarmRecurrence.none,
          status: AlarmStatus.scheduled,
          createdAt: now,
        ),
        Alarm(
          id: 'a2',
          noteId: 'n1',
          scheduledTime: now.add(const Duration(hours: 2)),
          recurrence: AlarmRecurrence.daily,
          status: AlarmStatus.scheduled,
          createdAt: now,
        ),
        Alarm(
          id: 'a3',
          noteId: 'n1',
          scheduledTime: now.add(const Duration(hours: 3)),
          recurrence: AlarmRecurrence.weekly,
          status: AlarmStatus.scheduled,
          createdAt: now,
        ),
      ];

      expect(alarms, hasLength(3));
      expect(alarms.where((a) => a.noteId == 'n1'), hasLength(3));
      expect(alarms.map((a) => a.recurrence).toSet(), hasLength(3));
    });

    test('Alarm equality should work correctly', () {
      final time = DateTime(2026, 2, 20, 10, 0);
      final alarm1 = Alarm(
        id: 'a1',
        noteId: 'n1',
        scheduledTime: time,
        recurrence: AlarmRecurrence.daily,
        status: AlarmStatus.scheduled,
        createdAt: DateTime(2026, 2, 15),
      );

      final alarm2 = Alarm(
        id: 'a1',
        noteId: 'n1',
        scheduledTime: time,
        recurrence: AlarmRecurrence.daily,
        status: AlarmStatus.scheduled,
        createdAt: DateTime(2026, 2, 15),
      );

      expect(alarm1, alarm2);
    });
  });
}
