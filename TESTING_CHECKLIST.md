# 🧪 Alarm System Integration - Testing Checklist

## Pre-Testing Setup

- [ ] Ensure app compiles: `flutter pub get && flutter clean && flutter pub get`
- [ ] Run on Android device (API 24+)
- [ ] Disable battery optimization for the app (varies by device manufacturer)
- [ ] Enable developer logs in VS Code terminal
- [ ] Keep terminal open to monitor `[ALARM-*]` log tags

---

## Phase 1: Immediate System Tests (App Running)

### 1.1 Trigger Immediate Alarm Test
**Location**: Settings → Developer Tools → "Test: Trigger Immediate Alarm"

**Steps**:
1. Open app, navigate to Settings
2. Scroll to Developer section
3. Click "Test: Trigger Immediate Alarm" button
4. Keep app in foreground

**Expected Behavior**:
- [ ] System notification appears immediately
- [ ] Alarm sound plays (system alarm ringtone)
- [ ] Device vibrates with pattern: 500ms ON → 1000ms OFF → 500ms ON → 1000ms OFF
- [ ] Full-screen notification visible
- [ ] "Stop Alarm" button functional (click = sound stops + vibration stops)
- [ ] "Snooze 10min" button functional (click = reschedules in 10 minutes)

**Terminal Logs** (should see):
```
[ALARM-SCHEDULE-START] Scheduling alarm...
[ALARM-SCHEDULE] AndroidAlarmManager registration successful
[ALARM-TRIGGERED-CALLBACK] Notification received!
✅ [ALARM-TRIGGERED] Navigation completed
```

---

### 1.2 Permission Verification Test
**Location**: Settings → Developer Tools → "Test: Check Permissions"

**Steps**:
1. Open app, navigate to Settings
2. Scroll to Developer section
3. Click "Test: Check Permissions" button

**Expected Behavior**:
- [ ] Dialog shows: "✅ POST_NOTIFICATIONS: granted"
- [ ] Dialog shows: "✅ SCHEDULE_EXACT_ALARM: granted"
- [ ] If not granted, permission request dialog appears
- [ ] User grants both permissions
- [ ] Dialog confirms all permissions granted

**Terminal Logs** (should see):
```
[PERMISSIONS] Checking POST_NOTIFICATIONS... ✅
[PERMISSIONS] Checking SCHEDULE_EXACT_ALARM... ✅
```

---

### 1.3 Earliest Alarm Detection Test
**Location**: Settings → Developer Tools → "Test: Earliest Alarm Detection"

**Steps**:
1. Create 3 alarms:
   - Alarm A: 5 minutes from now
   - Alarm B: 15 minutes from now
   - Alarm C: 2 minutes from now
2. Go to Settings → Developer → "Test: Earliest Alarm Detection"

**Expected Behavior**:
- [ ] Dialog shows Alarm C as the earliest
- [ ] Shows correct time and title
- [ ] Display updates correctly after creation

**Terminal Logs**:
```
[ALARM-DETECTION] Scanning scheduled alarms...
[ALARM-DETECTION] Found 3 alarms, earliest: alarm_C in 2 minutes
```

---

## Phase 2: Feature Tests (App Running)

### 2.1 Create Alarm in Future
**Location**: Alarms screen → Create → Set time 5 minutes in future

**Steps**:
1. Open Alarms screen
2. Click "New Alarm" or "+" button
3. Set alarm time: 5 minutes from now
4. Set title: "Test Alarm 1"
5. Set description: "Testing background support"
6. Save alarm

**Expected Behavior**:
- [ ] Alarm added to list
- [ ] Alarm time shows correctly
- [ ] No errors in console

**Terminal Logs**:
```
[ALARM-SCHEDULE-START] Scheduling alarm: 'Test Alarm 1'
[ALARM-SCHEDULE] Duration calculated: 5 minutes
[ALARM-SCHEDULED-SUCCESS] Alarm scheduled with ID: notification_<hash>
```

---

### 2.2 Create Note with Reminder
**Location**: Notes screen → Create → Add Reminder

**Steps**:
1. Open Notes screen
2. Create new note
3. Add content: "Test note with reminder"
4. Click "Add Reminder"
5. Set time: 5 minutes from now
6. Save note

**Expected Behavior**:
- [ ] Note created successfully
- [ ] Reminder scheduled (check logs)
- [ ] No errors in console

**Terminal Logs**:
```
[ALARM-SCHEDULE-START] Scheduling note reminder...
[ALARM-SCHEDULED-SUCCESS] Note reminder scheduled
```

---

### 2.3 Create Todo with Reminder
**Location**: Todos screen → Create → Add Reminder

**Steps**:
1. Open Todos screen
2. Create new todo
3. Add content: "Test todo with reminder"
4. Click "Add Reminder"
5. Set time: 5 minutes from now
6. Save todo

**Expected Behavior**:
- [ ] Todo created successfully
- [ ] Reminder scheduled (check logs)
- [ ] No errors in console

---

## Phase 3: Background Execution Tests (Critical!)

### 3.1 Kill App During Foreground Alarm

**Preparation**:
1. Create alarm set to trigger in 2 minutes
2. Press HOME button (don't close app)

**Steps**:
1. Wait 30 seconds to ensure alarm is scheduled
2. Completely kill the app (force stop)
   - Option 1: Settings → Apps → mynotes → Force Stop
   - Option 2: Recent apps → Swipe up on mynotes
   - Option 3: adb shell am force-stop com.example.mynotes
3. Wait for alarm time (remaining 1.5 minutes)
4. Verify alarm triggers

**Expected Behavior**:
- [ ] Device screen wakes up at alarm time
- [ ] Full-screen notification appears on lock screen
- [ ] Alarm sound plays even though app is stopped
- [ ] Device vibrates with full pattern
- [ ] Can tap "Stop Alarm" without unlocking device
- [ ] Can tap "Snooze 10min" without unlocking device
- [ ] Notification is locked (can't swipe away)

**Terminal Logs** (in new terminal after kill):
```
[BACKGROUND-ALARM] Alarm callback triggered in isolate!
[BACKGROUND-ALARM] ✅ AwesomeNotifications initialized in isolate
[BACKGROUND-ALARM] ✅ Vibration started
[BACKGROUND-ALARM] ✅ Alarm sound started
[BACKGROUND-ALARM] ✅ Notification created
🔔 [ALARM-TRIGGERED-CALLBACK] Notification received!
```

---

### 3.2 Snooze Functionality (After Killed App)

**Preparation**:
1. Keep app killed from 3.1
2. Tap "Snooze 10min" button on lock screen

**Steps**:
1. Verify notification changes (snooze confirmed)
2. Wait 10 minutes
3. Verify alarm triggers again

**Expected Behavior**:
- [ ] Snooze notification acknowledged
- [ ] Alarm triggers again in 10 minutes
- [ ] Same sound + vibration pattern repeats
- [ ] New lock screen notification appears

**Terminal Logs**:
```
[SNOOZE-ACTION] Snooze button pressed
[SNOOZE-ACTION] Rescheduling alarm in 10 minutes
[BACKGROUND-ALARM] Alarm callback triggered after snooze
```

---

### 3.3 Stop Functionality (After Killed App)

**Preparation**:
1. Keep app killed
2. Wait for any alarm to trigger
3. Tap "Stop Alarm" button on lock screen

**Steps**:
1. Verify notification changes (alarm stopped)
2. Wait 5 minutes
3. Verify no alarm triggers

**Expected Behavior**:
- [ ] Alarm sound stops immediately
- [ ] Vibration stops immediately
- [ ] Notification dismissed or shows "Stopped"
- [ ] No re-trigger after time passes

**Terminal Logs**:
```
[STOP-ACTION] Stop button pressed
[STOP-ACTION] Cancelling vibration
[STOP-ACTION] Stopping alarm sound
[STOP-ACTION] Dismissing notification
```

---

### 3.4 Device Reboot During Scheduled Alarm

**Preparation**:
1. Create alarm for 20 minutes from now
2. Wait 5 minutes to ensure registration
3. Reboot device

**Steps**:
1. Device boots up
2. Wait for alarm time (15 minutes)
3. Verify alarm triggers

**Expected Behavior**:
- [ ] Alarm triggers despite device reboot
- [ ] Full-screen notification appears
- [ ] Sound + vibration work
- [ ] All action buttons functional

**Notes**: Requires `rescheduleOnReboot: true` in AndroidAlarmManager (should be set)

---

## Phase 4: Recurring Alarm Tests

### 4.1 Daily Recurring Alarm

**Preparation**:
1. Create alarm: "Daily Test"
2. Set time: 2 minutes from now
3. Set repeat: All 7 days
4. Save

**Steps**:
1. Wait for first trigger (2 minutes)
2. Verify alarm triggers
3. Stop alarm
4. Wait 24 hours
5. Verify alarm triggers again

**Expected Behavior**:
- [ ] First alarm triggers at set time
- [ ] After stop, alarm is rescheduled for next day
- [ ] Alarm triggers again at same time next day
- [ ] Pattern continues daily

**Terminal Logs**:
```
[ALARM-RECURRENCE] Recurrence type: daily
[ALARM-SCHEDULE] Registering daily recurring alarm
```

---

### 4.2 Weekday Recurring Alarm

**Preparation**:
1. Create alarm: "Weekday Test"
2. Set time: 2 minutes from now
3. Set repeat: Mon-Fri (weekdays)
4. Save on a Tuesday

**Steps**:
1. Wait for first trigger (2 minutes)
2. Verify alarm triggers on Tuesday
3. Stop alarm
4. Wait 24 hours (to Wednesday)
5. Verify alarm triggers on Wednesday
6. Stop alarm
7. Wait 48 hours (to Friday)
8. Verify alarm triggers on Friday
9. Stop alarm
10. Wait 48 hours (to Sunday)
11. Verify alarm does NOT trigger on Sunday

**Expected Behavior**:
- [ ] Triggers on Tue, Wed, Thu, Fri
- [ ] Does NOT trigger on Sat, Sun
- [ ] Does NOT trigger on the next Monday
- [ ] Instead waits for following Monday

---

## Phase 5: Navigation Tests (Feature-Specific)

### 5.1 Alarm - Notification Tap Navigation
**Setup**: Create and trigger alarm

**Steps**:
1. Alarm triggers
2. Tap notification (not just action buttons)
3. Check if app opens to Alarms screen

**Expected Behavior**:
- [ ] App opens to Alarms screen
- [ ] Triggered alarm is highlighted/selected
- [ ] Details visible in detail pane

---

### 5.2 Note Reminder - Navigation
**Setup**: Create note with reminder, schedule for 2 min

**Steps**:
1. Let app run (don't kill)
2. Wait for reminder time
3. Tap notification
4. Verify navigation

**Expected Behavior**:
- [ ] App opens to Note Editor screen
- [ ] Correct note loaded
- [ ] Content visible
- [ ] Can edit note

---

### 5.3 Todo Reminder - Navigation
**Setup**: Create todo with reminder, schedule for 2 min

**Steps**:
1. Let app run (don't kill)
2. Wait for reminder time
3. Tap notification
4. Verify navigation

**Expected Behavior**:
- [ ] App opens to Todos screen
- [ ] Correct todo highlighted
- [ ] Can mark complete

---

## Phase 6: Edge Cases & Stress Tests

### 6.1 Multiple Alarms at Same Time

**Setup**: Create 5 alarms all set for same time (2 minutes)

**Steps**:
1. Wait for alarm time
2. Verify all 5 alarms trigger
3. Check notification behavior

**Expected Behavior**:
- [ ] All 5 alarms trigger with individual notifications
- [ ] OR notifications stack/merge appropriately
- [ ] No crashes or errors
- [ ] Can interact with each notification

**Terminal Logs** should show 5 separate [ALARM-SCHEDULE] entries

---

### 6.2 Alarm Scheduled in Past

**Setup**: Try to create alarm with time already passed

**Steps**:
1. Create alarm
2. Set time: 1 hour ago
3. Save

**Expected Behavior**:
- [ ] App either prevents creation OR
- [ ] Automatically recalculates to next occurrence OR
- [ ] Shows error message
- [ ] No crashes

---

### 6.3 Timezone Change During Scheduled Alarm

**Prerequisite**: Enable timezone handling in AlarmService

**Setup**:
1. Create alarm for specific time
2. Change device timezone
3. Open app to see alarm time

**Expected Behavior**:
- [ ] Alarm time is recalculated correctly
- [ ] Time display updates to match new timezone
- [ ] Alarm still triggers at correct absolute time

---

### 6.4 Battery Saver / Doze Mode (Device-Specific)

**For Xiaomi**:
1. Settings → Battery & Device Care → Battery Saver → OFF for myno notes
2. Allow notifications in background
3. Create alarm

**For OnePlus**:
1. Settings → Apps & Notifications → App Power Management → Myno notes → Unrestricted
2. Create alarm

**For Samsung**:
1. Settings → Apps → Myno notes → Battery → Optimize
2. Click "Don't optimize"
3. Create alarm

**Expected**: Alarm still triggers despite battery optimization

---

## Phase 7: Log Analysis

### Command to Monitor Logs in Real-Time
```bash
# All alarm-related logs
adb logcat | grep -E "ALARM|BACKGROUND"

# Only background execution
adb logcat | grep BACKGROUND-ALARM

# Only scheduling
adb logcat | grep ALARM-SCHEDULE

# Filter by app package
adb logcat | grep myno
```

### Expected Log Pattern for Successful Alarm

**When creating**:
```
[ALARM-SCHEDULE-START] Scheduling alarm...
[ALARM-SCHEDULE] Duration: 300 seconds
[ALARM-SCHEDULED-SUCCESS] ID: notification_12345
```

**When triggering (app running)**:
```
[ALARM-TRIGGERED-CALLBACK] Alarm callback received
[ALARM-TRIGGERED] Playing notification
✅ [ALARM-TRIGGERED] Navigation completed
```

**When triggering (app killed)**:
```
[BACKGROUND-ALARM] Alarm callback triggered in isolate!
[BACKGROUND-ALARM] ✅ AwesomeNotifications initialized
[BACKGROUND-ALARM] ✅ Vibration started
[BACKGROUND-ALARM] ✅ Alarm sound started
[BACKGROUND-ALARM] ✅ Notification created
```

---

## ✅ Test Sign-Off

Once all tests pass, mark as complete:

- [ ] Phase 1: Immediate System Tests - PASS
- [ ] Phase 2: Feature Tests - PASS
- [ ] Phase 3: Background Execution - PASS
- [ ] Phase 4: Recurring Alarms - PASS
- [ ] Phase 5: Navigation - PASS
- [ ] Phase 6: Edge Cases - PASS
- [ ] Phase 7: Log Analysis - PASS

**System Ready for**: Production Release 🎉

---

## Troubleshooting Common Issues

### Issue: Alarm doesn't trigger
**Solutions**:
- [ ] Check if `AndroidAlarmManager.initialize()` called in `main()`
- [ ] Check if app has POST_NOTIFICATIONS permission
- [ ] Check if app has SCHEDULE_EXACT_ALARM permission
- [ ] Check battery optimization isn't blocking app
- [ ] Check logs for [ALARM-SCHEDULE] errors

### Issue: Sound doesn't play
**Solutions**:
- [ ] Check device volume (ringer, not media)
- [ ] Check if `FlutterRingtonePlayer` is imported
- [ ] Check if AwesomeNotifications initialized with alarm_channel
- [ ] Verify `alarmCallback()` calls `FlutterRingtonePlayer().playAlarm()`

### Issue: Vibration doesn't work
**Solutions**:
- [ ] Check `vibration: true` in AlarmService.scheduleAlarm()
- [ ] Check device has vibration motor
- [ ] Check manifest includes VIBRATE permission
- [ ] Verify vibration pattern in `alarmCallback()`

### Issue: Full-screen notification doesn't show on lock screen
**Solutions**:
- [ ] Check `fullScreenIntent: true` in NotificationContent
- [ ] Check `wakeUpScreen: true` in NotificationContent
- [ ] Check `USE_FULL_SCREEN_INTENT` permission in manifest
- [ ] Check device lock screen timeout isn't overriding

### Issue: Alarm doesn't trigger when app killed
**Solutions**:
- [ ] Check `AndroidAlarmManager.oneShot()` is called
- [ ] Check `wakeup: true` in AndroidAlarmManager.oneShot()
- [ ] Check `rescheduleOnReboot: true` for persistence
- [ ] Ensure `alarmCallback()` is top-level function with `@pragma('vm:entry-point')`
- [ ] Check Android services registered in manifest
- [ ] Check minSdk is 24+

---

**Expected Pass Rate**: 95%+ on Android 11+ devices
**Known Limitations**: 
- Some OEM devices may have aggressive battery optimization (Xiaomi, OnePlus)
- Older devices (API 24-26) may have inconsistent behavior under heavy system load
