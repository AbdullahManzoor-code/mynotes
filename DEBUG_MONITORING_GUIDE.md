/// MyNotes App - Debug Monitoring Guide

# Debug Console Monitoring

## Quick Status Check

When testing manually in VS Code, watch for these key indicators:

### ✅ Good Signs
```
✓ "Service locator setup complete"
✓ "Initializing CoreDatabase..."
✓ "Loading initial alarms..."
✓ "Running MyNotesApp..."
✓ No red error messages
```

### ⚠️ Warning Signs
```
⚠ "Database: FTS5 not available"  → EXPECTED (we disabled FTS5)
⚠ "Warning:" messages             → Non-critical usually
```

### ❌ Error Signs (Stop & Debug)
```
✗ "Exception:" or "Error:"        → Critical issue
✗ "Undefined class"               → Import or dependency issue
✗ "Cannot open database"          → Database initialization failed
✗ Red stack trace                 → Crash - check full stack trace
```

---

## Log Files Location

After running the app, debug logs are saved to:

**Android/iOS:** `/data/user/0/com.example.mynotes/cache/`
**Desktop:** `~/.mynotes_logs/debug_TIMESTAMP.log`
**Windows:** `C:\Users\<USER>\AppData\Roaming\mynotes_logs\`

---

## What to Look For During Manual Testing

### 1. App Launch Phase
```
[Expected Output]
App starting: main() entry point
Flutter binding initialized
Initializing database factory for desktop platform
Setting up service locator...
Registering GlobalUiService...
Registering NotificationService...
... (many service registrations)
Registering Database...
Running MyNotesApp...
```

### 2. Note Creation
```
[Watch for these logs]
Creating new note...
Note created: <note_id>
Calling addTodos with todos count: N
Calling updateAlarms with alarms count: N
Note sync complete
```

### 3. Todo Completion
```
[Should see]
Marking todo as completed: <todo_id>
Updating note in database
Note updated successfully
UI refreshed
```

### 4. Alarm Triggers
```
[Expected when alarm time reaches]
Alarm triggered: <alarm_id>
Showing notification
Updating alarm status: triggered → <new_status>
```

### 5. Search Operations
```
[When searching notes]
Search query: "<query>"
Found N matching notes
Sorting by: <sort_option>
```

---

## Common Issues & Debug Steps

### Issue: App Crashes on Startup

**Debug Steps:**
1. Look for stack trace in debug console
2. Find the line causing failure
3. Check if it's a database issue:
   ```
   grep -i "database\|error\|exception" debug_log.txt
   ```

### Issue: Todos Not Saving

**Debug Steps:**
1. Check console for "addTodos" calls
2. Verify database write succeeded
3. Confirm TodoItem mapping is correct

### Issue: Alarms Not Triggering

**Debug Steps:**
1. Check alarm scheduled time vs current time
2. Verify recurrence enum (none, daily, weekly, monthly, yearly)
3. Look for notification service errors

### Issue: Slow Performance

**Debug Steps:**
1. Check database query time logs
2. Look for repeated operations
3. Monitor memory usage in Android Profiler

---

## Console Output Examples

### Successful Note Creation
```
I/flutter (12345): Creating note: N001
I/flutter (12345): inserting 3 todos
I/flutter (12345): inserting 2 alarms
I/flutter (12345): syncing 1 media item
I/flutter (12345): Note created successfully
```

### Database Error (Needs Fix)
```
E/flutter (12345): Exception: Unable to open database
E/flutter (12345): Stack trace: ...
D/flutter (12345): Check database path and permissions
```

### Clean Search
```
I/flutter (12345): Searching for: "meeting"
I/flutter (12345): Found 5 results
I/flutter (12345): Notes filtered and sorted
```

---

## Real-Time Monitoring Commands

### View console while running:
```powershell
# Watch Flutter logs (live)
flutter logs

# Filter only errors
flutter logs | Select-String "error|Error|E/"

# See print statements
flutter logs | Select-String "I/"
```

### Save to file:
```powershell
# Redirect to file
flutter logs > debug_output.txt

# Live monitoring file
Get-Content -Path debug_output.txt -Wait -Tail 50
```

---

## Key Metrics to Track

| Metric | Value | Notes |
|--------|-------|-------|
| Startup Time | < 3 sec | From launch to UI visible |
| DB Query Time | < 100ms | Per operation |
| Memory Usage | < 200MB | Peak during heavy operations |
| Note Count | Variable | Test with 10, 100, 1000 notes |
| Todo Count | Variable | Test with 5, 50, 500 todos |

---

## Logging Framework

The app uses **AppLogger** for all log output:

```dart
AppLogger.i('Info message');      // Info
AppLogger.e('Error', error, st);  // Error with stacktrace
AppLogger.w('Warning');           // Warning
AppLogger.d('Debug info');        // Debug
```

All messages appear in:
1. **VS Code Debug Console** → Live during development
2. **Android Logcat** → Android device logs
3. **Debug Log File** → Persistent logs for later analysis

---

## Automated Debug Checklist

Run this after each manual test session:

```bash
# 1. Check for errors
flutter logs 2>&1 | grep -i "error\|exception" | wc -l

# 2. Check startup time
flutter logs 2>&1 | grep "App starting\|Running MyNotesApp"

# 3. Check database operations
flutter logs 2>&1 | grep "database\|query"

# 4. Check memory
adb shell dumpsys meminfo com.example.mynotes | grep "TOTAL"

# 5. Generate report
dart pub global activate coverage && flutter test --coverage
```

---

## Next Steps

1. **Start app** → Watch console for startup logs
2. **Create note** → Verify creation logs appear
3. **Add todos** → Check todo addition logs
4. **Set alarm** → Confirm alarm scheduling logs
5. **Search notes** → Verify search logs
6. **Check file** → Review debug log file

**Check debug console now and share any error messages you see!**
