# MyNotes Feature & Flow Reference

## 1. What This App Is
- **Multi-platform note + productivity hub** built with Flutter/BLoC that runs on mobile, web, and desktop (see `pubspec.yaml`).
- Covers **core modules**: Notes, Reminders, Todos, Reflections, Focus sessions, Analytics, Backup/export, Voice/AI helpers.
- Follows the **"Complete Params"** pattern: rich events carry `NoteParams`, `TodoParams`, and `AlarmParams` through the BLoCs so downstream services get a single canonical payload.

## 2. Feature At-A-Glance
| Area | Primary Files | Behavior Highlights |
| --- | --- | --- |
| Notes | [lib/presentation/screens/enhanced_notes_list_screen.dart](lib/presentation/screens/enhanced_notes_list_screen.dart), [lib/presentation/bloc/note_bloc.dart](lib/presentation/bloc/note_bloc.dart), [lib/presentation/bloc/params/note_params.dart](lib/presentation/bloc/params/note_params.dart) | Search, tag/color filtering, pin/archive toggles, rich editor (supports media, links, alarms). NotesBloc mediates CRUD via `NoteRepository`. |
| Reminders (Alarms) | [lib/presentation/widgets/create_alarm_bottom_sheet.dart](lib/presentation/widgets/create_alarm_bottom_sheet.dart), [lib/presentation/bloc/alarms_bloc.dart](lib/presentation/bloc/alarms_bloc.dart), [lib/domain/entities/alarm.dart](lib/domain/entities/alarm.dart) | Creates schedulable reminders with recurrence, linked notes/todos, repeat-days, and platform scheduling via `LocalNotificationService`.
| Todos | [lib/presentation/bloc/todos_bloc.dart](lib/presentation/bloc/todos_bloc.dart), [lib/domain/entities/todo_item.dart](lib/domain/entities/todo_item.dart) | Advanced TODO list with categories, priorities, subtasks, and Completion toggles. TodoBloc exposes load/search/toggle events and persists through `TodoParams`. |
| Quick Add | [lib/presentation/widgets/quick_add_bottom_sheet.dart](lib/presentation/widgets/quick_add_bottom_sheet.dart), [lib/core/utils/smart_voice_parser.dart](lib/core/utils/smart_voice_parser.dart), [lib/presentation/widgets/universal_item_card.dart](lib/presentation/widgets/universal_item_card.dart) | Voice-aware parser emits `UniversalItem`; Quick Add dispatches to NotesBloc, TodosBloc, or AlarmsBloc depending on the current tab so the same input can become a note, todo, or reminder. |
| Reflection & Smart Reminders | [lib/presentation/bloc/reflection_bloc.dart](lib/presentation/bloc/reflection_bloc.dart), [lib/presentation/bloc/smart_reminders_bloc.dart](lib/presentation/bloc/smart_reminders_bloc.dart), [lib/domain/services/ai_suggestion_engine.dart](lib/domain/services/ai_suggestion_engine.dart) | Collects journal entries, runs AI pattern detection across notes/alarms, and surfaces smart suggestion cards. |
| Focus Engine | [lib/presentation/pages/focus_session_screen.dart](lib/presentation/pages/focus_session_screen.dart), [lib/presentation/bloc/focus_bloc.dart](lib/presentation/bloc/focus_bloc.dart) | Pomodoro timer, session tracking, celebration overlays, and analytics via the stats repository. |
| Shared UI/Services | [lib/presentation/widgets/global_command_palette.dart](lib/presentation/widgets/global_command_palette.dart), [lib/core/notifications/notification_service.dart](lib/core/notifications/notification_service.dart) | Global palette routes, persistent theme, notification scheduling/cancellation helper used by alarm flows.

## 3. High-Level User Flows
- **Notes workflow:** Enhanced Notes List → (create/edit) → Enhanced Note Editor. Editor can pin, colorize, tag, attach media, link to reminders, and push alarms via `NoteBloc`. Supporting screens include reflection, analytics, templates, etc.
- **Reminder workflow:** Enhanced Reminders Screen → Create/Edit Bottom Sheet → `AlarmsBloc` stores data via `AlarmService` and schedules platform notifications through `LocalNotificationService`. Recurrence and weekly day selection live inside the bottom sheet logic (see `_selectedWeekDays`, `_selectedRecurrence`).
- **Todo workflow:** Todos screen features filters, completion toggles, subtasks; `TodosBloc` exposes add/update/clear actions and relies on `TodoParams`/`TodoItem` conversions.
- **Quick Add:** Opens `QuickAddBottomSheet` (voice input allowed). Depending on the current tab, it fires `CreateNoteEvent`, `AddTodo`, or `AddAlarm` after parsing text. The parser determines title/content, potential due/reminder time, and priority/category before passing a `UniversalItem` to the relevant BLoC.
- **Global/Smart helpers:** `SmartRemindersBloc` listens to repository data to feed AI suggestions (`AISuggestionEngine`). Command palette listens for shortcuts and routes to notes/reminders/todos.

## 4. Technical Architecture Highlights
1. **Dependency injection:** `injection_container.dart` wires GetIt singletons (Database, Repositories, BLoCs, Services). `main.dart` registers BlocProviders (Notes, Alarms, Todos, etc.) for the widget tree.
2. **Repository pattern:** Each feature uses a repository interface (`NoteRepository`, `AlarmService`, etc.) with `Impl` classes working against `NotesDatabase` (sqflite). Unified quick-add repository was deprecated in favor of direct BLoC events.
3. **BLoC orchestration:** All user interactions flow through BLoC events (`CreateNoteEvent`, `AddTodo`, `AddAlarm`, etc.). States (e.g., `NotesLoaded`, `AlarmsLoaded`, `TodosLoaded`) drive the UI. Observers react to emitted states (loading, error, success). 
4. **Notification pipeline:** `AlarmsBloc` ties to `_notificationService` to schedule/cancel alarms, and `LocalNotificationService` wraps `flutter_local_notifications`. `AlarmBloc` (different from `AlarmsBloc`) handles deeper alarm validation/integration when linking notes.
5. **Shared utility layer:** `SmartVoiceParser`, `AISuggestionEngine`, `GlobalErrorHandlerListener`, and custom design system widgets ensure consistent style and logic. Shared helpers live under `lib/core/*` and `lib/presentation/design_system/*`.

## 5. How Modules Connect
1. **Bloc-to-Service:** Events like `AddAlarm`, `CreateNoteEvent` convert rich params/entities and call `_alarmService` or `_noteRepository`. Example: `NotesBloc._onCreateNote` builds a `Note` from `NoteParams` and calls `NoteRepository.createNote` before emitting `NoteCreated`.
2. **Inter-module linking:** Notes can link to alarms (`AddAlarmToNoteEvent`) and alarms can link back to notes or todos (`linkAlarmToNote`, `linkAlarmToTodo` events in `AlarmsBloc`). The UI bottom sheets surface note selectors and send IDs down via `AlarmParams`/`Alarm`.
3. **Quick-add bridging:** The quick add sheet uses `SmartVoiceParser` → `UniversalItem` → BLoC event, making use of existing data models rather than the old unified repository. This keeps the new input path aligned with existing persistence flows.
4. **Notification coordination:** Creating/updating alarms triggers both local persistence (`AlarmService`) and platform scheduling via `_notificationService.scheduleAlarm`. Cancelling/removing also cancels platform reminders.
5. **Global services:** Theme, analytics, and focus BLoCs live above the main navigator so all screens inherit the same state. Routes defined in `lib/core/routes/*` ensure navigation occurs consistently.

## 6. Operational Notes
- **High-level behaviors** to document in future releases: focus timer phases, smart suggestion acceptance, cross-feature linking (notes ↔ reminders ↔ todos), backup/export jobs, and accessibility support via `design_system` components.
- **When modifying a feature:** Follow the pattern of emitting a BLoC event, letting the BLoC call the repository/service, then reloading the affected state.
- **Testing tips:** Because most functionality is centralized in BLoCs, unit tests should mock repositories/services and assert emitted states after sending events.

Feel free to integrate this doc into your release notes or add subsections per module as the product evolves.