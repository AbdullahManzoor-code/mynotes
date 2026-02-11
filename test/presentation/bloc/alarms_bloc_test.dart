// import 'package:bloc_test/bloc_test.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:mynotes/core/notifications/alarm_service.dart' as notifications;
// import 'package:mynotes/domain/repositories/alarm_repository.dart';
// import 'package:mynotes/domain/entities/alarm.dart';
// import 'package:mynotes/presentation/bloc/alarms_bloc.dart';
// import 'dart:convert';

// class MockAlarmRepository extends Mock implements AlarmRepository {}

// class MockNotificationService extends Mock
//     implements notifications.AlarmService {}

// void main() {
//   late MockAlarmRepository mockAlarmRepository;
//   late MockNotificationService mockNotificationService;
//   late AlarmsBloc alarmsBloc;

//   setUp(() {
//     mockAlarmRepository = MockAlarmRepository();
//     mockNotificationService = MockNotificationService();
//     alarmsBloc = AlarmsBloc(
//       alarmRepository: mockAlarmRepository,
//       notificationService: mockNotificationService,
//     );
//   });

//   tearDown(() {
//     alarmsBloc.close();
//   });

//   final tAlarm = Alarm(
//     id: '1',
//     message: 'Test Alarm',
//     scheduledTime: DateTime.now().add(const Duration(hours: 1)),
//     createdAt: DateTime.now(),
//     updatedAt: DateTime.now(),
//     isActive: true,
//     isEnabled: true,
//   );

//   test('initial state is AlarmsInitial', () {
//     expect(alarmsBloc.state, equals(AlarmsInitial()));
//   });

//   group('SnoozeAlarm', () {
//     blocTest<AlarmsBloc, AlarmsState>(
//       'emits [AlarmsLoaded] when SnoozeAlarm is added',
//       build: () {
//         when(
//           () => mockPersistenceService.quickSnooze(any(), any()),
//         ).thenAnswer((_) async => true);
//         when(() => mockPersistenceService.getAlarmById(any())).thenAnswer(
//           (_) async => tAlarm.copyWith(
//             snoozedUntil: DateTime.now().add(const Duration(minutes: 10)),
//           ),
//         );
//         when(
//           () => mockPersistenceService.loadAlarms(),
//         ).thenAnswer((_) async => [tAlarm]);
//         when(() => mockPersistenceService.getStats()).thenAnswer(
//           (_) async => persistence.AlarmStats(
//             total: 1,
//             active: 1,
//             completed: 0,
//             overdue: 0,
//             today: 0,
//             upcoming: 1,
//             snoozed: 0,
//           ),
//         );
//         when(
//           () => mockPersistenceService.sortByTime(any()),
//         ).thenReturn([tAlarm]);
//         when(
//           () => mockNotificationService.scheduleAlarm(
//             dateTime: any(named: 'dateTime'),
//             id: any(named: 'id'),
//             title: any(named: 'title'),
//             payload: any(named: 'payload'),
//           ),
//         ).thenAnswer((_) async {});

//         when(
//           () => mockNotificationService.requestPermissions(),
//         ).thenAnswer((_) async {});

//         return alarmsBloc;
//       },
//       seed: () => AlarmsLoaded(
//         alarms: [tAlarm],
//         filteredAlarms: [tAlarm],
//         stats: persistence.AlarmStats(
//           total: 1,
//           active: 1,
//           completed: 0,
//           overdue: 0,
//           today: 0,
//           upcoming: 1,
//           snoozed: 0,
//         ),
//       ),
//       act: (bloc) =>
//           bloc.add(SnoozeAlarm('1', persistence.SnoozePreset.tenMinutes)),
//       expect: () => [isA<AlarmsLoading>(), isA<AlarmsLoaded>()],
//       verify: (_) {
//         verify(
//           () => mockPersistenceService.quickSnooze(
//             '1',
//             persistence.SnoozePreset.tenMinutes,
//           ),
//         ).called(1);
//         verify(
//           () => mockNotificationService.scheduleAlarm(
//             dateTime: any(named: 'dateTime'),
//             id: '1',
//             title: any(named: 'title'),
//             payload: any(named: 'payload'),
//           ),
//         ).called(1);
//       },
//     );
//   });

//   group('MarkAlarmCompleted', () {
//     blocTest<AlarmsBloc, AlarmsState>(
//       'emits [AlarmsLoaded] when MarkAlarmCompleted is added',
//       build: () {
//         when(
//           () => mockPersistenceService.markCompleted(any()),
//         ).thenAnswer((_) async => true);
//         when(
//           () => mockPersistenceService.loadAlarms(),
//         ).thenAnswer((_) async => [tAlarm.markCompleted()]);
//         when(() => mockPersistenceService.getStats()).thenAnswer(
//           (_) async => persistence.AlarmStats(
//             total: 1,
//             active: 0,
//             completed: 1,
//             overdue: 0,
//             today: 0,
//             upcoming: 0,
//             snoozed: 0,
//           ),
//         );
//         when(
//           () => mockPersistenceService.sortByTime(any()),
//         ).thenReturn([tAlarm.markCompleted()]);
//         when(
//           () => mockNotificationService.cancelAlarm(any()),
//         ).thenAnswer((_) async {});

//         when(
//           () => mockNotificationService.requestPermissions(),
//         ).thenAnswer((_) async {});

//         return alarmsBloc;
//       },
//       seed: () => AlarmsLoaded(
//         alarms: [tAlarm],
//         filteredAlarms: [tAlarm],
//         stats: persistence.AlarmStats(
//           total: 1,
//           active: 1,
//           completed: 0,
//           overdue: 0,
//           today: 0,
//           upcoming: 1,
//           snoozed: 0,
//         ),
//       ),
//       act: (bloc) => bloc.add(MarkAlarmCompleted('1')),
//       expect: () => [isA<AlarmsLoading>(), isA<AlarmsLoaded>()],
//       verify: (_) {
//         verify(() => mockPersistenceService.markCompleted('1')).called(1);
//         verify(() => mockNotificationService.cancelAlarm('1')).called(1);
//       },
//     );
//   });
// }
