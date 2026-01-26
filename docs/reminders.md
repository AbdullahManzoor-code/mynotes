# 🔔 Reminders & Alarms documentation
## Purpose
To ensure users never miss important tasks or deadlines by providing timely, reliable notifications.

## User Flow
1.  User opens a note.
2.  Taps "Add Reminder" (bell icon).
3.  Selects date, time, and recurrence (One-time, Daily, Weekly, Monthly).
4.  Optionally adds a custom message.
5.  Saves the reminder.
6.  At the scheduled time, a notification appears with "Open Note", "Snooze", and "Dismiss" options.

## Technical Flow
-   **Storage**: SQLite `alarm` table linked to `note_id`.
-   **Scheduling**: `flutter_local_notifications` using `timezone` for precise scheduling.
-   **State Management**: `AlarmBloc` handles CRUD operations.
-   **Persistence**: Alarms are rescheduled on device reboot using a `BroadcastReceiver`.

## Benefits
-   Integrated context: Reminders are directly linked to detailed notes.
-   Flexible scheduling: Supports complex recurrence patterns.
-   Reliable: Uses exact alarms for precision.
