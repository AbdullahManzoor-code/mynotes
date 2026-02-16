# 🔔 Alarm System Integration Guide

## Overview
All scheduling of reminders across MyNotes now routes through a unified `AlarmService` that integrates `android_alarm_manager_plus` for background/killed-app execution.

---

## System Architecture

```
┌─────────────────────────────────────────────────┐
│         Feature: Alarms, Notes, Todos, etc      │
└──────────────────┬──────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────┐
│   NotificationService (Unified Interface)       │
│   - schedule()                                   │
│   - cancel()                                     │
│   - getPendingNotifications()                    │
└──────────────────┬──────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────┐
│  LocalNotificationService (Implementation)      │
│  - Routes to AlarmService for scheduling         │
│  - Converts repeatDays to AlarmRecurrence       │
│  - Handles payload JSON serialization            │
└──────────────────┬──────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────┐
│  AlarmService (Core Implementation)              │
│  ✅ Uses flutter_local_notifications (foreground) │
│  ✅ Uses android_alarm_manager_plus (background) │
│  ✅ Vibration + Sound on trigger                │
│  ✅ Full-screen notification on lockscreen      │
│  ✅ Action buttons (Stop, Snooze)              │
└──────────────────┬──────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────┐
│  Android System                                  │
│  - FlutterLocalNotifications (foreground)       │
│  - AndroidAlarmManager (background/killed app)  │
│  - alarmCallback() in background isolate        │
└─────────────────────────────────────────────────┘
```

---

## Features Using Updated System

### ✅ **1. Alarms** (`lib/presentation/bloc/alarm/`)
**Status**: READY
- Uses: `alarm_bloc.dart` → `_notificationService.schedule()`
- Scheduling: Via `NotificationService` which delegates to `AlarmService`
- Background: ✅ Supported (via `android_alarm_manager_plus`)

**Implementation**:
```dart
// In alarm_bloc.dart _onAddAlarm():
await _notificationService.schedule(
  id: alarmId.hashCode,
  title: alarmToSave.title,
  body: alarmToSave.description,
  scheduledTime: alarmToSave.alarmTime,
  repeatDays: alarmToSave.repeatDays.isEmpty ? null : alarmToSave.repeatDays,
);
```

**How it works**:
- Converts to `AlarmService.scheduleAlarm()` internally
- Recurrence automatically determined from `repeatDays`
- Background execution handled by `AlarmService`

---

### ✅ **2. Notes Reminders** (Linked Alarms)
**Status**: READY (via Alarms feature)
- Uses: Same as Alarms (through AlarmService)
- Linking: Via `payload` JSON with `linkedNoteId`
- Navigation: `_onNotificationTap()` in alarm_service.dart

**Default Behavior**:
```dart
// When alarm triggers, if linkedNoteId in payload:
AppRouter.navigatorKey.currentState?.pushNamed(
  AppRoutes.noteEditor,
  arguments: {'noteId': linkedNoteId},
);
```

---

### ✅ **3. Todo Reminders** (Linked Alarms)
**Status**: READY (via Alarms feature)
- Uses: Same as Alarms (through AlarmService)
- Linking: Via `payload` JSON with `linkedTodoId`
- Navigation: Navigates to Todos list on trigger

---

### ✅ **4. Reflection Reminders** (Linked Alarms)
**Status**: READY (via Alarms feature)
- Uses: Same as Alarms (through AlarmService)
- Implementation: Can create alarms linked to reflection entries
- Persistence: Via AlarmRepository

---

### ⚠️ **5. Location Reminders** (`lib/core/services/location_notification_service.dart`)
**Status**: HYBRID (Immediate notifications + Optional scheduling)

**Current Implementation**:
- **Geofence Trigger**: Uses `flutter_local_notifications` directly
- **Immediate Display**: When user enters/exits location
- **Scheduling**: Can optionally use AlarmService for:
  - Recurring location reminders
  - Scheduled location checks
  - Delayed location notifications

**To Enable Background Support for Location Reminders**:
1. In `location_notification_service.dart`, instead of direct `.show()`:
```dart
// INSTEAD OF:
await _notificationsPlugin.show(notificationId, title, ...);

// USE:
await _alarmService.scheduleAlarm(
  id: 'location_reminder_${reminder.id}',
  dateTime: scheduledTime,
  title: title,
  payload: 'location_reminder:${reminder.id}',
  vibrate: true,
  recurrence: AlarmRecurrence.none,
);
```

---

## Key Classes & Files

### Core Alarm System
| File | Purpose | Status |
|------|---------|--------|
| `lib/main.dart` | Initializes `AlarmService` + `alarmCallback()` | ✅ |
| `lib/core/notifications/alarm_service.dart` | Core scheduling logic + AndroidAlarmManager | ✅ |
| `lib/core/notifications/notification_service.dart` | Unified interface | ✅ |
| `lib/injection_container.dart` | Registers AlarmService + NotificationService | ✅ |

### Feature Implementations
| File | Feature | Status |
|------|---------|--------|
| `lib/presentation/bloc/alarm/alarm_bloc.dart` | Alarms | ✅ |
| `lib/presentation/bloc/alarm/alarms_bloc.dart` | Alarms List | ✅ |
| `lib/core/services/location_notification_service.dart` | Location Reminders | ⚠️ Hybrid |
| `lib/presentation/bloc/location_reminder/location_reminder_bloc.dart` | Location Reminder UI | ✅ |

---

## Configuration Summary

### ✅ Dependencies (pubspec.yaml)
```yaml
android_alarm_manager_plus: ^5.0.0
awesome_notifications: ^0.10.1
vibration: ^3.1.6
flutter_ringtone_player: ^4.0.0+4
timezone: ^0.9.4
flutter_local_notifications: ^18.0.1
```

### ✅ Android Configuration (build.gradle.kts)
```kotlin
minSdk = 24                           // Required
multiDexEnabled = true                // Required
isCoreLibraryDesugaringEnabled = true // Required
```

### ✅ Android Manifest Permissions
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### ✅ Android Services (AndroidManifest.xml)
```xml
<service android:name="dev.fluttercommunity.plus.androidalarmmanager.AlarmService" />
<receiver android:name="dev.fluttercommunity.plus.androidalarmmanager.AlarmBroadcastReceiver" />
<receiver android:name="dev.fluttercommunity.plus.androidalarmmanager.RebootBroadcastReceiver" />
```

---

## Testing

### ✅ Alarm Test Buttons (Settings → Developer)
1. **Test: Trigger Immediate Alarm**
   - Tests immediate 10-second alarm
   - Verifies sound + vibration
   - Checks notification display

2. **Test: Check Permissions**
   - Verifies POS T_NOTIFICATIONS + SCHEDULE_EXACT_ALARM
   - Requests permissions if needed

3. **Test: Earliest Alarm Detection**
   - Finds earliest scheduled alarm
   - Shows details in dialog

4. **Test: Alarm Rescheduling**
   - Reschedules 5 minutes in future
   - Tests RefreshAlarmsEvent

5. **Test: View Alarm Logs**
   - Shows all scheduled alarms
   - Displays alarm details
   - Copy to clipboard

### Expected Output (Terminal Logs)
```
[BACKGROUND-ALARM] Alarm callback triggered in isolate!
[BACKGROUND-ALARM] ✅ AwesomeNotifications initialized in isolate
[BACKGROUND-ALARM] ✅ Vibration started
[BACKGROUND-ALARM] ✅ Alarm sound started
[BACKGROUND-ALARM] ✅ Notification created
🔔 [ALARM-TRIGGERED-CALLBACK] Notification received!
[ALARM-TRIGGERED] ✅ Navigation completed
```

---

## Debugging

### Terminal Log Tags
- `[BACKGROUND-ALARM]` - Background callback execution
- `[ALARM-SCHEDULE]` - Alarm scheduling process
- `[ALARM-TRIGGERED]` - Alarm trigger + navigation
- `[NOTIFICATION-SERVICE]` - NotificationService delegations
- `[ALARM-SERVICE-INIT]` - AlarmService initialization

### How to Filter Logs
```bash
# View only alarm scheduling logs
adb logcat | grep ALARM-SCHEDULE

# View only background execution
adb logcat | grep BACKGROUND-ALARM

# View all alarm-related logs
adb logcat | grep -E "ALARM|BACKGROUND"
```

### Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| Alarm doesn't trigger when app is killed | Missing `android_alarm_manager_plus` init | Ensure `AndroidAlarmManager.initialize()` is called in `main()` |
| Notification shows but no sound/vibration | Missing channel re-init in isolate | Verify `alarmCallback()` initializes AwesomeNotifications |
| Alarm triggers in foreground only | AlarmRecurrence parsing error | Check `repeatDays` conversion in `notification_service.dart` |
| Permissions dialog not showing | Missing manifest declaration | Verify all 6 permissions in `AndroidManifest.xml` |
| Device won't wake on alarm | Missing `wakeup: true` | Verify `wakeup: true` in `AndroidAlarmManager.oneShot()` |

---

## Integration Checklist

- [x] AlarmService initialized in `main.dart`
- [x] alarmCallback() defined as top-level function with `@pragma('vm:entry-point')`
- [x] AwesomeNotifications initialized in main isolate
- [x] AndroidAlarmManager initialized before runApp()
- [x] NotificationService delegates to AlarmService
- [x] LocalNotificationService registered with AlarmService
- [x] All 6 Android permissions declared
- [x] All 3 Android services/receivers registered
- [x] minSdk = 24, multiDexEnabled = true
- [x] Core library desugaring enabled
- [x] Alarm test buttons functional
- [x] Logging implemented at 8+ checkpoints

---

## Future Enhancements

1. **Custom Sound Support**
   - Allow users to select custom alarm sounds
   - Store sound path in AlarmParams
   - Pass to `scheduleAlarm(soundPath:)`

2. **Snooze Implementation**
   - Implement snooze duration options (5, 10, 15, 30 min)
   - Schedule new alarm via `AndroidAlarmManager.oneShot()` in action handler

3. **Recurring Alarms**
   - Test weekday/weekend/custom recurrence patterns
   - Verify `DateTimeComponents` matching works correctly

4. **Battery Optimization**
   - Add guide for disabling battery optimization per-app
   - Test on multiple device manufacturers (Xiaomi, OnePlus, Samsung)

5. **Notification Categories**
   - Different channels for alarms, reminders, location alerts
   - Custom sounds per category

---

## References

- [android_alarm_manager_plus Documentation](https://pub.dev/packages/android_alarm_manager_plus)
- [flutter_local_notifications Documentation](https://pub.dev/packages/flutter_local_notifications)
- [awesome_notifications Documentation](https://pub.dev/packages/awesome_notifications)
- [Android AlarmManager Best Practices](https://developer.android.com/guide/components/alarms-and-clocks)

---

**Last Updated**: 2026-02-16
**System Version**: AlarmService v2.0 with android_alarm_manager_plus
