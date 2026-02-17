

// # Complete User-Perspective Prompt: What Should MyNotes Actually DO for Real People?

// ## Copy this ENTIRE prompt into your AI coding assistant

// ---

// ```markdown
// =============================================================
// ROLE: You are TWO people combined:

// PERSON 1: A regular phone user who downloaded MyNotes app.
// You are NOT a developer. You don't know what BLoC means.
// You just want the app to WORK. You will describe every
// single thing you try to do and what should happen.

// PERSON 2: A senior QA engineer who takes Person 1's
// expectations and checks the ACTUAL CODE to verify if
// the app delivers what the user expects.
// =============================================================

// IMPORTANT RULES:
// - Think from the USER'S perspective first
// - Then check if the CODE delivers that experience
// - NO technical jargon in user scenarios
// - REAL situations real people face daily
// - Every scenario must map to ACTUAL code verification

// =============================================================
// ████████████████████████████████████████████████████████████████
// PART 1: WHO IS THIS APP FOR AND WHAT IS IT SUPPOSED TO DO?
// ████████████████████████████████████████████████████████████████
// =============================================================

// Based on analyzing the MyNotes project (57+ BLoCs, all features),
// answer these questions FIRST:

// ## 1.1 — APP IDENTITY

// ```
// App Name: MyNotes
// What it claims to be: [describe based on actual features built]
// Who would download this: [describe target user]
// What problem does it solve: [describe the core problem]
// One-line description: [like an app store subtitle]
// ```

// ## 1.2 — CORE PROMISES TO THE USER

// Based on what is BUILT (not planned), what does this app
// promise to the user?

// ```
// Promise 1: "You can write and organize notes"
// Promise 2: "You can create and manage to-do lists"
// Promise 3: "You can set reminders that actually notify you"
// Promise 4: "You can focus on work using a timer"
// Promise 5: "You can reflect on your day and track mood"
// Promise 6: "You can attach photos, audio, and video to notes"
// Promise 7: "You can search across everything"
// Promise 8: "You can organize with folders and tags"
// Promise 9: "You can secure the app with fingerprint/face"
// Promise 10: "You can backup and restore your data"
// Promise 11: "You can scan documents and extract text"
// Promise 12: "You can use voice to write notes"
// Promise 13: "You can set location-based reminders"
// Promise 14: "You can export notes as PDF"
// Promise 15: "You can customize how the app looks"
// [add any others based on actual built features]
// ```

// For each promise, state:
// - Is it FULLY delivered by the code?
// - Is it PARTIALLY delivered?
// - Is it BROKEN?
// - Is it just PLACEHOLDER code that does nothing?


// =============================================================
// ████████████████████████████████████████████████████████████████
// PART 2: REAL USER STORIES — EVERY WAY A PERSON USES THIS APP
// ████████████████████████████████████████████████████████████████
// =============================================================

// Below are ALL the ways real people would use MyNotes.
// For EACH story:
// 1. Describe what the USER does (plain language)
// 2. Describe what the USER expects to happen
// 3. Check the ACTUAL CODE — does it deliver?
// 4. Mark: ✅ Works | ❌ Broken | ⚠️ Partially | ⬛ Placeholder

// ---

// ## USER STORY GROUP 1: "I JUST DOWNLOADED THE APP"

// ```
// STORY 1.1 — First time opening
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I download MyNotes from the Play Store / App Store.
//   I tap the app icon for the first time.

// What I expect:
//   - App opens without crashing
//   - I see a welcome screen or tutorial showing me
//     what the app can do
//   - It should take less than 3 seconds to load
//   - I should NOT see any error messages
//   - After the welcome, I should land on the main screen
//     ready to create my first note

// Check in code:
//   - main.dart → initialization sequence
//   - splash_screen.dart → first launch check
//   - onboarding_screen.dart → welcome flow
//   - Does init error show user-friendly message or crash?
//   - What if one service fails to init (alarm, notification)?
//     Does whole app crash or graceful degradation?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 1.2 — Opening app for the 100th time
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I open the app like I do every day.

// What I expect:
//   - App opens fast (under 2 seconds)
//   - I should NOT see the welcome tutorial again
//   - I should see my notes/todos right away
//   - Everything should be where I left it
//   - If I set up fingerprint lock, it should ask me
//     to verify before showing my data

// Check in code:
//   - splash_screen.dart → first_launch SharedPreferences
//   - splash_screen.dart → biometric check flow
//   - MultiBlocProvider → are 57+ BLoCs all created at startup?
//     Is this making the app slow?
//   - How long does setupServiceLocator() take?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 1.3 — Opening app with no internet
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I open the app while on airplane mode or
//   in a place with no signal.

// What I expect:
//   - App should still open normally
//   - All my notes, todos, reminders should still be there
//   - I should be able to create new notes and todos
//   - I should NOT see a "no internet" error that blocks me
//   - This is a NOTE app — it should work offline

// Check in code:
//   - Does any init step require network?
//   - Does DioClient initialization fail without network?
//   - Does PlacesService crash on init without network?
//   - Are all features local-first (SQLite/Hive)?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 1.4 — Opening app after phone restart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   My phone ran out of battery. I charge it and
//   turn it back on. I open MyNotes.

// What I expect:
//   - All my data is still there
//   - All my reminders should still fire on time
//   - My settings should be preserved
//   - My fingerprint lock should still be active

// Check in code:
//   - main.dart → alarm rescheduling on startup
//   - Are alarms rescheduled after device boot?
//   - Is there a BOOT_COMPLETED receiver in AndroidManifest?
//   - Are SharedPreferences values preserved?
//   - Is SQLite data preserved?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ```

// ---

// ## USER STORY GROUP 2: "I WANT TO WRITE A NOTE"

// ```
// STORY 2.1 — Creating a simple note
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I tap the "+" button or "New Note" button.
//   I type a title: "Shopping List"
//   I type content: "Milk, Eggs, Bread, Butter"
//   I tap Save or go back.

// What I expect:
//   - A new note appears in my notes list
//   - The title and content I typed are saved exactly
//   - The note shows today's date
//   - The note is at the top of my list (newest first)
//   - If I close the app and reopen, the note is still there

// Check in code:
//   - How does user navigate to editor? (FAB → QuickAddBottomSheet → route)
//   - NoteEditorBloc → SaveNoteRequested
//   - Is note auto-saved or only on explicit save?
//   - What if user presses back without tapping save?
//   - Is unsaved data lost?
//   - Does NoteRepository.insert() work correctly?
//   - Does NotesBloc refresh the list after save?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 2.2 — Writing a very long note
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I write meeting notes — 5 pages of text.
//   About 5000-10000 characters.

// What I expect:
//   - The editor should not lag while typing
//   - Scrolling through my note should be smooth
//   - All text should be saved completely
//   - The note should open quickly when I tap on it later

// Check in code:
//   - Does ContentChanged event fire on every keystroke?
//   - Is there debounce on auto-save?
//   - Does SQLite TEXT column handle large text?
//   - Does the note list screen show preview without loading full content?
//   - Is LinkParserService running on every keystroke? (performance issue)

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 2.3 — Editing an existing note
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I tap on "Shopping List" note from my list.
//   I add "Cheese" to the list.
//   I go back.

// What I expect:
//   - The note opens with all my previous content
//   - I can edit anywhere in the text
//   - When I go back, the changes are saved
//   - The "last modified" date should update
//   - The "created" date should NOT change

// Check in code:
//   - NoteEditorBloc → NoteEditorInitialized with existing note ID
//   - Is note loaded correctly by ID from repository?
//   - Are ALL fields loaded (title, content, tags, color, media, pinned)?
//   - Is updatedAt updated but createdAt preserved?
//   - Does auto-save trigger or only manual save?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 2.4 — Accidentally closing note without saving
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I write a long note. My phone rings.
//   I switch to the phone app.
//   I come back to MyNotes.

// What I expect:
//   - My note should still be there with all my text
//   - Even if the app was killed in background, my work
//     should be auto-saved
//   - I should NOT lose any text I typed

// Check in code:
//   - Is there auto-save mechanism? (periodic or on each change?)
//   - What happens to NoteEditorBloc when app goes to background?
//   - Is there AppLifecycleObserver saving draft on pause?
//   - Does SaveDraftEvent exist in NoteEditorBloc?
//   - If app is killed, is any unsaved content lost?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 2.5 — Deleting a note
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I swipe on a note or long-press and tap Delete.

// What I expect:
//   - The note disappears from my list
//   - I should see an "Undo" option for a few seconds
//     in case I made a mistake
//   - If I tap Undo, the note comes back
//   - If I don't tap Undo, the note is permanently gone
//   - Any reminder attached to that note should also be cancelled
//   - Any photos/audio attached should be cleaned up

// Check in code:
//   - NotesBloc → DeleteNoteEvent
//   - Is there undo functionality for notes? (TodosBloc has UndoDeleteTodo
//     but does NotesBloc have undo?)
//   - Does delete cascade to:
//     - AlarmRepository (delete alarms for this note)?
//     - Media files (delete from storage)?
//     - CrossFeatureBloc (remove links)?
//     - NoteVersioningBloc (delete versions)?
//     - NoteLinkingBloc (remove note links)?
//     - SmartCollectionsBloc (update collections)?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 2.6 — Deleting multiple notes at once
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I long-press to enter selection mode.
//   I select 10 notes. I tap Delete All.

// What I expect:
//   - All 10 notes are deleted
//   - It should not take forever
//   - I should see confirmation before bulk delete
//   - All associated reminders for all 10 notes are cancelled

// Check in code:
//   - NotesBloc → DeleteMultipleNotesEvent
//   - Is there a confirmation dialog before bulk delete?
//   - Does it delete one by one or in a batch?
//   - What if deletion of note #5 fails? Do notes 1-4 stay deleted
//     while 5-10 remain? (atomicity)
//   - Is loading shown during bulk operation?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 2.7 — Pinning important notes
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I have a note with my WiFi password.
//   I want it always at the top. I tap the pin icon.

// What I expect:
//   - The note moves to the top of my list
//   - It stays at top even after creating new notes
//   - I can see a pin indicator on the note
//   - If I unpin it, it goes back to its normal position
//   - Pinned notes section should be visually separated

// Check in code:
//   - NotesBloc → TogglePinNoteEvent
//   - Does pinned status persist in database?
//   - Does NotesLoaded state sort pinned notes to top?
//   - Is pin status preserved in NoteEditorBloc when editing?
//   - Can user pin from both list view AND editor?
//   - Do both paths use the same logic?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 2.8 — Archiving old notes
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I have old meeting notes from last year.
//   I don't need them daily but don't want to delete them.
//   I archive them.

// What I expect:
//   - Note disappears from main list (less clutter)
//   - Note appears in the Archive section
//   - I can find it by going to Archive
//   - I can restore it back to main list anytime
//   - Archived notes should still show up in search results

// Check in code:
//   - NotesBloc → ToggleArchiveNoteEvent
//   - NotesBloc → LoadArchivedNotesEvent
//   - NotesBloc → RestoreArchivedNoteEvent
//   - Does search include archived notes?
//   - Are alarms preserved when archiving?
//   - What happens to a pinned note when archived?
//     Is pin status removed?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 2.9 — Color coding notes
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I color my work notes blue, personal notes green,
//   and urgent notes red.

// What I expect:
//   - I can pick a color when creating or editing a note
//   - The note card in the list shows that color
//   - Color is visible in both list and grid view
//   - I can change color of multiple notes at once
//   - Color should persist after restart

// Check in code:
//   - NoteEditorBloc → ColorChanged
//   - NotesBloc → BatchUpdateNotesColorEvent
//   - Is color stored as integer/hex in database?
//   - Is color displayed in both list and grid layouts?
//   - Does dark mode affect note colors? (should colors still be visible?)

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 2.10 — Adding tags to notes
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I tag my shopping note with "shopping" and "weekly".
//   I tag my recipe note with "cooking" and "favorites".

// What I expect:
//   - I can add multiple tags to a note
//   - Tags are visible on the note card
//   - I can tap a tag to see all notes with that tag
//   - I can remove a tag from a note
//   - I cannot add the same tag twice to one note
//   - I can see all my tags somewhere (tag cloud / tag list)

// Check in code:
//   - NotesBloc → AddTagEvent, RemoveTagEvent
//   - NoteEditorBloc → TagAdded, TagRemoved
//   - NotesBloc → LoadNotesByTagEvent
//   - ActivityTagBloc → LoadTagsEvent (is this the same tag system?)
//   - Are tags stored in the note record or a separate table?
//   - Is duplicate tag check implemented?
//   - Does tag removal from NotesBloc match NoteEditorBloc behavior?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 2.11 — Switching between list and grid view
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I tap the view toggle button to switch from list to grid.

// What I expect:
//   - Notes rearrange from list to grid smoothly
//   - Same notes, same order, just different layout
//   - My preference should be remembered next time I open app
//   - Both views should show title, preview, color, pin icon

// Check in code:
//   - NotesBloc → UpdateNoteViewConfigEvent
//   - Is view config stored in SharedPreferences?
//   - Does the UI properly switch between ListView and GridView?
//   - Are note cards responsive in both layouts?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 2.12 — Using clipboard to create note
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I copy a paragraph from a website.
//   I open MyNotes. The app detects clipboard text
//   and asks if I want to save it as a note.

// What I expect:
//   - App detects I have text in clipboard
//   - Shows me a small prompt asking "Save as note?"
//   - If I tap Yes, a new note is created with that text
//   - If I tap No, it goes away and doesn't ask again
//     until I copy something new

// Check in code:
//   - NotesBloc → ClipboardTextDetectedEvent
//   - NotesBloc → SaveClipboardAsNoteEvent
//   - ClipboardService → MethodChannel
//   - Is clipboard monitored only when app is in foreground?
//   - Is there privacy concern reading clipboard automatically?
//   - On Android 12+, does clipboard toast appear?
//   - Is clipboard reading permission handled?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ```

// ---

// ## USER STORY GROUP 3: "I WANT TO MAKE A TO-DO LIST"

// ```
// STORY 3.1 — Creating a simple todo
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I go to the Todos section.
//   I type "Buy birthday present for Mom"
//   I set it as important.
//   I set due date for Saturday.

// What I expect:
//   - Todo appears in my list
//   - It shows the title, due date, and importance marker
//   - It's in the "upcoming" or correct category
//   - I can tap the circle to mark it complete later

// Check in code:
//   - TodosBloc → AddTodo with TodoParams
//   - Is TodoParams validated (empty title check)?
//   - Is due date stored correctly with timezone?
//   - Does importance flag (ToggleImportantTodo) persist?
//   - Is the todo list sorted showing upcoming items first?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 3.2 — Completing a todo
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I bought Mom's present. I tap the checkbox on the todo.

// What I expect:
//   - Todo gets a checkmark / strikethrough
//   - It moves to a "Completed" section
//   - It feels satisfying (maybe a small animation?)
//   - Any reminder for this todo should be cancelled automatically
//   - I can un-complete it if I tapped by mistake

// Check in code:
//   - TodosBloc → ToggleTodo
//   - Is completedAt timestamp set?
//   - Does alarm get cancelled when todo is completed?
//     (AlarmService cancellation)
//   - Can user toggle back to incomplete?
//   - Does the todo physically move in the list or just show differently?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 3.3 — Todo with subtasks
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I create todo "Plan Birthday Party" with subtasks:
//   - Book venue
//   - Order cake
//   - Send invitations
//   - Buy decorations

// What I expect:
//   - I can see subtasks under the main todo
//   - I can check off individual subtasks
//   - Main todo shows progress like "2/4 done"
//   - Completing all subtasks should complete the main todo
//     (or at least prompt me)

// Check in code:
//   - TodosBloc → UpdateSubtasks
//   - How are subtasks stored? (JSON array in todo record?)
//   - Is completion percentage calculated correctly?
//   - Does checking all subtasks affect parent todo status?
//   - Can subtasks be reordered?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 3.4 — Filtering todos by category
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I have work todos and personal todos.
//   I tap "Work" category to see only work todos.

// What I expect:
//   - Only work category todos appear
//   - I can switch between categories
//   - "All" shows everything
//   - My filter choice is remembered when I come back

// Check in code:
//   - TodosBloc → FilterTodos, ChangeCategory
//   - What categories exist? Are they hardcoded or user-created?
//   - Does filter persist when navigating away and back?
//   - Does ToggleFilters show/hide the filter panel UI?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 3.5 — Deleting todo with undo
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I swipe to delete a todo. I realize it was wrong one.
//   I quickly tap "Undo."

// What I expect:
//   - Todo disappears immediately on swipe
//   - Undo snackbar appears at bottom for 5 seconds
//   - If I tap Undo, todo comes back exactly as it was
//   - If I don't tap Undo, todo is permanently deleted
//   - Associated reminder is cancelled on delete,
//     and rescheduled on undo

// Check in code:
//   - TodosBloc → DeleteTodo, UndoDeleteTodo
//   - Does UndoDeleteTodo restore from a cached copy?
//   - Is the deleted todo kept in memory for undo period?
//   - Are alarms handled correctly on delete AND undo?
//   - What if user navigates away before undo expires?
//     Is the todo permanently deleted?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 3.6 — Overdue todo
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I set a todo due yesterday but didn't complete it.
//   I open the app today.

// What I expect:
//   - The todo should show as "Overdue" in red or warning color
//   - It should not disappear just because the date passed
//   - It should appear in an "Overdue" section or at the top
//   - Analytics should count it in overdue items

// Check in code:
//   - How are overdue todos identified? (date comparison logic)
//   - Does the UI show overdue indicator?
//   - Does AnalyticsBloc → overdueItems count these?
//   - Is timezone handled correctly for date comparison?
//   - What about end of day — when exactly does a todo become overdue?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 3.7 — Converting note to todo
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I wrote a note about things to do.
//   I realize it should be a todo instead.
//   I tap "Convert to Todo" or "Promote to Todo."

// What I expect:
//   - A new todo is created with the note's content
//   - The original note is either kept or I'm asked
//   - The todo and note should be linked
//     (so I can see the connection)

// Check in code:
//   - NoteEditorBloc → PromoteToTodoRequested
//   - Does this create a todo via TodoRepository?
//   - Does it use CrossFeatureBloc to link note and todo?
//   - Is the original note preserved?
//   - Does user see confirmation of conversion?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ```

// ---

// ## USER STORY GROUP 4: "I WANT TO SET A REMINDER"

// ```
// STORY 4.1 — Setting a simple reminder
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I create a reminder: "Take medicine" at 8:00 PM today.

// What I expect:
//   - At exactly 8:00 PM, my phone buzzes and shows
//     a notification saying "Take medicine"
//   - This should happen even if the app is closed
//   - This should happen even if my phone was restarted
//   - I can tap the notification to open the app
//   - The reminder should show as "completed" or ask me
//     to dismiss/snooze

// Check in code:
//   - AlarmsBloc → AddAlarmEvent
//   - Is time validated (must be future)?
//   - Is notification scheduled via AwesomeNotifications
//     or AndroidAlarmManager?
//   - Which notification system is primary?
//   - Do they conflict?
//   - Does BOOT_COMPLETED receiver reschedule after restart?
//   - Does notification tap handler navigate correctly?
//   - What if notification permission is denied?
//   - What if battery optimization kills the alarm?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 4.2 — Snoozing a reminder
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   My 8 PM medicine reminder fires.
//   I'm busy. I tap "Snooze" to be reminded in 15 minutes.

// What I expect:
//   - Notification goes away
//   - At 8:15 PM, it fires again
//   - I can snooze again if needed
//   - The original reminder still shows in my list

// Check in code:
//   - AlarmsBloc → SnoozeAlarmEvent
//   - Is snooze time = now + 15 minutes?
//   - Is new notification scheduled?
//   - Is original notification cancelled?
//   - Can user snooze unlimited times?
//   - Is snooze count or history tracked?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 4.3 — Reminder attached to a note
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I write a note about a meeting.
//   I add a reminder for 30 minutes before the meeting.

// What I expect:
//   - The note shows a reminder icon/indicator
//   - The reminder fires at the correct time
//   - When I tap the notification, it opens THAT note
//   - If I delete the note, the reminder is cancelled
//   - If I delete the reminder, the note stays

// Check in code:
//   - NotesBloc → AddAlarmToNoteEvent
//   - Does alarm store the note ID reference?
//   - Does notification tap handler navigate to specific note?
//     (What route arguments are passed?)
//   - Does NotesBloc → DeleteNoteEvent cascade to alarm deletion?
//   - Does AlarmsBloc → DeleteAlarmEvent leave note untouched?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 4.4 — Reminder attached to a todo
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I have a todo "Submit report" due Friday.
//   I add a reminder for Thursday evening.

// What I expect:
//   - Same as note reminder but linked to the todo
//   - When I complete the todo, the reminder is auto-cancelled
//   - When notification fires, tapping it opens the todo

// Check in code:
//   - TodosBloc → AddAlarmToTodo
//   - Does completing todo (ToggleTodo) cancel the alarm?
//   - Does notification handler distinguish between note and todo alarms?
//   - Does tapping notification navigate to todo detail?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 4.5 — Recurring reminder
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I want "Take medicine" every day at 8 PM.

// What I expect:
//   - I set it once as recurring daily
//   - It fires every day at 8 PM
//   - When I dismiss today's, tomorrow's is still scheduled
//   - I can stop the recurrence anytime

// Check in code:
//   - RecurrenceBloc → SetRecurrenceEvent
//   - How is recurrence implemented? (multiple alarms? or single
//     with repeat flag?)
//   - After dismissing one occurrence, is next auto-scheduled?
//   - Is RecurrenceBloc connected to AlarmsBloc?
//   - What recurrence patterns are supported?
//     (daily, weekly, monthly?)
//   - Is this actually functional or placeholder?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 4.6 — Disabling and re-enabling a reminder
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I toggle off the "Take medicine" reminder for a week
//   (I'm traveling and have different schedule).
//   Next week I toggle it back on.

// What I expect:
//   - Toggling off cancels the notification but keeps the
//     reminder in my list (grayed out)
//   - Toggling on reschedules the notification
//   - If the original time has passed while disabled,
//     it should schedule for the NEXT occurrence

// Check in code:
//   - AlarmsBloc → ToggleAlarmEvent
//   - Does disabling cancel notification via service?
//   - Does enabling reschedule?
//   - What if alarm time is now in the past?
//     Does it schedule for next day/occurrence or show error?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 4.7 — Location-based reminder
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I want to be reminded "Buy groceries" when I arrive
//   at the supermarket.

// What I expect:
//   - I can pick a location on a map
//   - When I'm near that location, I get a notification
//   - This works even when the app is in background
//   - Battery drain should be reasonable
//   - I can cancel the location reminder anytime

// Check in code:
//   - LocationReminderBloc → CreateLocationReminderEvent
//   - LocationPickerBloc → SelectLocationEvent
//   - Is Google Maps API key actually configured (not placeholder)?
//   - Is PlacesService API key valid?
//   - Is geofencing actually implemented?
//   - Is background location permission requested?
//   - What about battery drain from constant location monitoring?
//   - Is this feature actually working or just a map screen
//     that doesn't trigger anything?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ```

// ---

// ## USER STORY GROUP 5: "I WANT TO FOCUS ON WORK"

// ```
// STORY 5.1 — Starting a focus session
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I go to the Focus section. I tap "Start Focus"
//   for 25 minutes of work.

// What I expect:
//   - A timer starts counting down from 25:00
//   - The timer updates every second (25:00 → 24:59 → ...)
//   - My phone goes into Do Not Disturb mode
//   - I can see the time remaining clearly
//   - A progress indicator shows how far I am

// Check in code:
//   - FocusBloc → StartFocusSessionEvent
//   - Is Timer created correctly?
//   - Does TickFocusEvent fire every second?
//   - Does DndService activate DND?
//   - What if DND permission not granted?
//   - Is Timer disposed in close()?
//   - FocusSessionScreen → is _initFocusScreen in build()?
//     Does this cause timer restart on rebuild?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 5.2 — Pausing focus session
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I need to take an urgent call. I pause the focus timer.
//   After the call, I resume.

// What I expect:
//   - Timer freezes at current time (e.g., 18:32)
//   - DND should turn off during pause (I'm taking a call)
//   - When I resume, timer continues from 18:32
//   - Total focus time should only count active time

// Check in code:
//   - FocusBloc → PauseFocusSessionEvent, ResumeFocusSessionEvent
//   - Is timer actually paused or just UI hidden?
//   - Is DND toggled off during pause?
//   - Is pause time excluded from total session stats?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 5.3 — Focus session completes
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   The 25-minute timer reaches 0:00.

// What I expect:
//   - I hear a sound or feel vibration
//   - DND turns off
//   - I'm asked: "Great job! Rate your focus (1-5 stars)"
//   - I see option to "Start Break" (5 min) or "Skip Break"
//   - My session is saved in my focus history/statistics
//   - I can see my streak (3 days in a row, etc.)

// Check in code:
//   - FocusBloc → timer reaches 0 → FocusCompleted state
//   - Is notification sent on completion?
//   - Is DndService deactivated?
//   - Does RateFocusSessionEvent save rating?
//   - Does StatsRepository record the session?
//   - Does AnalyticsBloc → currentStreak calculate correctly?
//   - Does StartBreakSessionEvent start break timer?
//   - Does SkipBreakEvent work?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 5.4 — Pomodoro vs Focus — user confusion
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I see both "Focus" and "Pomodoro" options in the app.
//   I'm confused. Which one should I use?

// What I expect:
//   - Either they should be clearly different features, OR
//   - They should be one feature (not confusing duplication)
//   - If they're the same thing, merge them
//   - My statistics should be in one place regardless

// Check in code:
//   - FocusBloc vs PomodoroBloc vs PomodoroTimerBloc
//     THREE BLoCs doing timer things!
//   - Are they used on different screens?
//   - Do they save stats to the same StatsRepository?
//   - Are stats double-counted?
//   - PomodoroStatsBloc is a FOURTH related BLoC
//   - Is there a clear user journey that makes sense?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 5.5 — Focus timer when app goes to background
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I start a 25-minute focus. I lock my phone and
//   put it down. After 25 minutes I check.

// What I expect:
//   - Timer should have completed even with app in background
//   - I should have received a notification that it's done
//   - If I open the app, it shows "Session Complete"
//   - NOT showing 24:59 still counting from when I left

// Check in code:
//   - Is timer based on DateTime calculation or simple countdown?
//   - If countdown, it pauses when app is in background
//   - Should use DateTime difference for background support
//   - Is there background timer mechanism?
//   - Does the app schedule a notification for 25 min later
//     so user gets notified even if timer stops in background?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ```

// ---

// ## USER STORY GROUP 6: "I WANT TO REFLECT ON MY DAY"

// ```
// STORY 6.1 — Daily reflection
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   At night, I open the Reflection section.
//   I see a question: "What are you grateful for today?"
//   I write my answer.

// What I expect:
//   - A meaningful question is shown
//   - I can write my answer freely
//   - My answer is saved with today's date
//   - Tomorrow I get a different question
//   - I can look back at my past reflections

// Check in code:
//   - ReflectionBloc → LoadQuestionsEvent
//   - Are default questions seeded for first time use?
//   - Does LoadRandomQuestionEvent give different question daily?
//   - Does SubmitAnswerEvent save with correct date?
//   - Does LoadAnswersEvent / LoadAllAnswersEvent show history?
//   - ReflectionHomeScreen has biometric logic in UI — does it
//     block access until authenticated?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 6.2 — Logging mood
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I select my mood: Happy / Sad / Neutral / Anxious / etc.

// What I expect:
//   - I can pick from mood options (emoji or icons)
//   - My mood is saved for today
//   - I can see mood history over time
//   - Maybe a chart showing mood trends

// Check in code:
//   - ReflectionBloc → LogMoodEvent
//   - What mood values are accepted? Enum? String? Number?
//   - Can multiple moods be logged per day?
//   - Does AnalyticsBloc → LoadMoodAnalyticsEvent read this?
//   - Is there a mood chart in analytics screen?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 6.3 — Daily reflection reminder
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I set a daily reminder at 9 PM to do my reflection.

// What I expect:
//   - Every day at 9 PM I get a notification
//   - Tapping it opens the reflection screen
//   - I can turn it off anytime in settings

// Check in code:
//   - ReflectionBloc → ScheduleReflectionNotificationEvent
//   - Is this a recurring notification?
//   - Does CancelReflectionNotificationEvent work?
//   - Does notification tap open reflection screen specifically?
//   - Does this survive device restart?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ```

// ---

// ## USER STORY GROUP 7: "I WANT TO ADD PHOTOS AND AUDIO TO MY NOTES"

// ```
// STORY 7.1 — Taking a photo and adding to note
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I'm in a note. I tap the camera icon.
//   I take a photo of a whiteboard in a meeting.

// What I expect:
//   - Camera opens
//   - After taking photo, it appears in my note
//   - Photo is compressed (not taking 10MB per photo)
//   - I can see the photo thumbnail in the note
//   - Photo is saved even after closing and reopening note
//   - I can tap the photo to view it full screen
//   - I can remove the photo if I don't want it

// Check in code:
//   - MediaBloc → CapturePhotoEvent or NoteEditorBloc → MediaAdded
//   - Which BLoC actually handles camera in note editor?
//   - Is camera permission requested before opening camera?
//   - Is MediaProcessingService compressing the image?
//   - Where is the photo file stored? App directory?
//   - Is the photo path stored in the note record in database?
//   - What if storage is full?
//   - What if camera is not available (emulator, tablet)?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 7.2 — Recording voice memo
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   In a note, I tap the microphone icon.
//   I speak my thoughts for 2 minutes.
//   I stop recording.

// What I expect:
//   - Recording starts with visible indicator
//   - I can see recording duration counting up
//   - Maybe a waveform visualization
//   - After stopping, I can play it back
//   - The audio is attached to my note
//   - I can pause and resume recording
//   - I can delete the recording if it's bad

// Check in code:
//   - AudioRecorderBloc → StartRecording
//   - Is microphone permission requested?
//   - Does UpdateRecordingDuration update every second?
//   - Does UpdateWaveform show real visualization?
//   - Does PauseRecording actually pause or start new file?
//   - Does StopRecording save file correctly?
//   - Does PlayRecording play back correctly?
//   - Is audio file path stored in note record?
//   - Where is audio file stored?
//   - What audio format? (WAV, AAC, MP3?)
//   - Is there max recording length?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 7.3 — Using voice-to-text
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   Instead of typing, I tap the voice input button
//   and speak. My words appear as text in the note.

// What I expect:
//   - Speech recognition starts
//   - My words appear in real-time as I speak
//   - It handles my language correctly
//   - Punctuation is somewhat accurate
//   - I can speak, pause, and speak more
//   - The text is added to wherever my cursor is
//   - I can stop voice input and continue typing

// Check in code:
//   - NoteEditorBloc → VoiceInputToggled
//   - Is SpeechService using speech_to_text package?
//   - Does SpeechResultReceived append to existing text or replace?
//   - Is the cursor position considered when inserting text?
//   - What if microphone permission denied?
//   - What if device doesn't support speech recognition?
//   - Does StopVoiceInputRequested clean up properly?
//   - Is SpeechService disposed when editor closes?
//   - VoiceCommandBloc also uses speech — can they conflict?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 7.4 — Scanning a document
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I have a printed receipt. I scan it with the app.
//   The app extracts the text from the image.

// What I expect:
//   - Camera opens in scan mode (maybe with edge detection)
//   - Photo is taken and processed
//   - Text is extracted and shown to me
//   - I can save the extracted text as a note
//   - The original scanned image is also saved
//   - OCR should be reasonably accurate

// Check in code:
//   - MediaBloc → ScanDocumentEvent
//   - DocumentScanBloc → CaptureImage
//   - OcrExtractionBloc → ExtractTextEvent
//   - DocumentScannerService → uses cunning_document_scanner?
//   - OCRService → uses google_mlkit_text_recognition?
//   - Is the flow: scan → extract text → create note?
//   - What if document has no text?
//   - What if OCR produces garbage text?
//   - Is loading shown during OCR processing?
//   - Is this a three-step process needing three BLoCs?
//     Or could it be simpler?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 7.5 — Viewing media gallery
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I want to see all photos and audio I've added
//   across all my notes.

// What I expect:
//   - A gallery view showing all media
//   - I can filter by type (photos, audio, video)
//   - I can tap to view/play
//   - I can see which note each media belongs to
//   - I can delete media from the gallery

// Check in code:
//   - MediaGalleryBloc → LoadGalleryEvent
//   - Does gallery pull from all notes or separate storage?
//   - Does FilterGalleryEvent filter correctly by type?
//   - Does SelectMediaEvent show detail view?
//   - Does DeleteMediaEvent also update the parent note?
//   - 6+ media BLoCs — are all needed for this simple flow?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 7.6 — Video in notes
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I record a short video or pick one from gallery
//   and attach to a note.

// What I expect:
//   - I can record video directly or pick from gallery
//   - Video is compressed to save space
//   - Video thumbnail shows in the note
//   - I can tap to play the video
//   - I can trim the video if needed
//   - I can remove the video from the note

// Check in code:
//   - MediaBloc → CaptureVideoEvent, PickVideoFromGalleryEvent
//   - MediaBloc → AddVideoToNoteEvent, RemoveVideoFromNoteEvent
//   - MediaBloc → CompressVideoEvent
//   - VideoPlaybackBloc → PlayVideoEvent
//   - VideoTrimmingBloc → TrimVideoEvent
//   - VideoEditorBloc → all events
//   - Are ALL these BLoCs functional or are some placeholder?
//   - Does video compression actually run?
//   - Does trimming create a new file?
//   - Does video editor (filters, text overlay) actually work?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ```

// ---

// ## USER STORY GROUP 8: "I WANT TO SEARCH AND FIND THINGS"

// ```
// STORY 8.1 — Quick search for a note
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I have 200 notes. I type "birthday" in search.

// What I expect:
//   - Results appear as I type (instant)
//   - Notes with "birthday" in title OR content show up
//   - Todos with "birthday" should also show
//   - Search results highlight the matching text
//   - Tapping a result opens that item

// Check in code:
//   - GlobalSearchBloc → SearchQueryChangedEvent
//   - Is debounce implemented? (don't search every keystroke)
//   - Does it search across notes AND todos AND alarms?
//   - Does UnifiedRepository handle cross-type search?
//   - Are results ranked by relevance?
//   - GlobalSearchScreen is 949 lines — is the search
//     actually fast with that much UI code?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 8.2 — Search with no results
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I search for "xyzabc123" — nothing matches.

// What I expect:
//   - I see a friendly "No results found" message
//   - Maybe a suggestion: "Try different keywords"
//   - NOT a blank screen or error
//   - NOT an infinite loading spinner

// Check in code:
//   - GlobalSearchBloc → GlobalSearchLoaded with empty results
//   - Is there an empty state in the UI?
//   - Does it show loading while searching?
//   - Does loading stop when results come back empty?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 8.3 — Confusion about multiple search options
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I notice there are different search options in the app.
//   I'm confused about which to use.

// What I expect:
//   - ONE search that searches everything
//   - NOT multiple confusing search screens

// Check in code:
//   - GlobalSearchBloc (search everything)
//   - SearchBloc (search notes only)
//   - AdvancedSearchBloc (another search)
//   - MediaSearchBloc (search media)
//   - NotesBloc → SearchNotesEvent (inline search)
//   - TodosBloc → SearchTodos (todo search)
//   - AlarmsBloc → SearchAlarmsEvent (alarm search)
//   - SmartCollectionsBloc → SearchSmartCollectionsEvent
  
//   HOW MANY SEARCH IMPLEMENTATIONS EXIST?
//   Do they all work? Are they consistent?
//   Should there just be ONE unified search?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ```

// ---

// ## USER STORY GROUP 9: "I WANT TO ORGANIZE MY NOTES"

// ```
// STORY 9.1 — Creating folders
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I create folders: "Work", "Personal", "Recipes"
//   I move notes into these folders.

// What I expect:
//   - I can create named folders
//   - I can move notes into folders
//   - Folders show note count
//   - I can rename folders
//   - I can delete folders (notes move back to root)
//   - Folder structure is clear and navigable

// Check in code:
//   - NoteFoldersBloc → CreateFolderEvent, MovesNotesEvent
//   - FoldersBloc → CreateFolderEvent
//   - TWO folder BLoCs exist — which is used?
//   - Do they share the same database table?
//   - Can they create conflicting data?
//   - Does DeleteFolderEvent handle notes inside?
//     (orphaned notes problem)

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 9.2 — Using smart collections
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I create a smart collection that auto-groups all notes
//   tagged "work" from the last 7 days.

// What I expect:
//   - I can define rules (tag = work AND date = last 7 days)
//   - Notes matching rules automatically appear in collection
//   - When I add a new "work" note, it appears automatically
//   - The rules can use AND or OR logic

// Check in code:
//   - SmartCollectionsBloc → CreateSmartCollectionEvent
//   - SmartCollectionWizardBloc → wizard flow
//   - RuleBuilderBloc → AddRuleEvent, ChangeLogicEvent
//   - Is SmartCollectionsParams correctly structured?
//   - Does the auto-population actually work?
//   - Or are items manually added despite rules?
//   - Is this feature fully functional?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ```

// ---

// ## USER STORY GROUP 10: "I WANT TO KEEP MY DATA SAFE"

// ```
// STORY 10.1 — Setting up fingerprint lock
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I go to Settings and enable fingerprint lock.

// What I expect:
//   - App checks if my phone has fingerprint/face
//   - If yes, I authenticate to confirm
//   - From now on, app asks for fingerprint on every open
//   - If fingerprint fails, I have a fallback (PIN)
//   - I can disable fingerprint lock in settings

// Check in code:
//   - SettingsBloc → ToggleBiometricEvent
//   - BiometricAuthBloc → CheckBiometricsEvent, AuthenticateEvent
//   - PinSetupBloc → as fallback
//   - Is BiometricAuthService using local_auth correctly?
//   - What if phone has no biometrics?
//   - What if user removes all fingerprints from device?
//   - Is PIN fallback implemented and working?
//   - Is biometric preference stored in SharedPreferences?
//   - Is it stored securely? (not easily bypassed)

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 10.2 — Creating a backup
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I want to backup all my data before switching phones.
//   I go to Settings → Backup → Create Backup.

// What I expect:
//   - Backup starts with progress indicator
//   - All my notes, todos, reminders, media, settings are included
//   - Backup file is saved somewhere I can access (Downloads?)
//   - I'm told the file size and location
//   - I can share the backup file via email/cloud

// Check in code:
//   - BackupBloc → CreateBackupEvent
//   - Does BackupService include ALL data types?
//   - Does UpdateBackupProgressEvent show percentage?
//   - Is backup format documented/consistent?
//   - Is file saved to external storage?
//   - Is storage permission requested?
//   - What format is backup? (ZIP? JSON? SQLite dump?)
//   - Does it include media files or just metadata?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 10.3 — Restoring from backup
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I set up a new phone. I install MyNotes.
//   I go to Settings → Backup → Restore.
//   I select my backup file.

// What I expect:
//   - I'm warned that restore will replace current data
//   - Restore starts with progress indicator
//   - After restore, all my notes/todos/reminders are back
//   - Reminders are rescheduled for future ones
//   - App restarts or refreshes to show restored data
//   - Settings are restored (theme, preferences)

// Check in code:
//   - BackupBloc → RestoreBackupEvent
//   - Does restore replace or merge?
//   - Is user warned about data loss?
//   - Does it handle backup version differences?
//   - Are alarms rescheduled after restore?
//   - What if backup file is corrupted?
//   - What if backup is from older app version?
//   - Does the app refresh all BLoC states after restore?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ```

// ---

// ## USER STORY GROUP 11: "I WANT TO EXPORT AND SHARE"

// ```
// STORY 11.1 — Exporting note as PDF
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I want to send my meeting notes to a colleague as PDF.
//   I tap Share/Export on the note and select PDF.

// What I expect:
//   - PDF is generated with my note title, content, date
//   - Media (images) are included in the PDF
//   - PDF opens in a preview or share sheet appears
//   - I can send via email, WhatsApp, etc.
//   - PDF looks professional (not raw text dump)

// Check in code:
//   - NotesBloc → ExportNoteToPdfEvent
//   - ExportBloc → PerformExportEvent with PDF format
//   - Is PDF generation actually implemented?
//   - Does it include images/media?
//   - Is the PDF formatted nicely (headers, margins)?
//   - Does share/save dialog appear?
//   - What PDF package is used?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 11.2 — Exporting multiple notes
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I select 5 meeting notes and export all as one PDF.

// What I expect:
//   - All 5 notes combined into one PDF
//   - Each note starts on a new page (or clear separator)
//   - Table of contents would be nice

// Check in code:
//   - NotesBloc → ExportMultipleNotesToPdfEvent
//   - Does this create one PDF or multiple?
//   - Is loading shown during generation?
//   - What if one note has very large content?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ```

// ---

// ## USER STORY GROUP 12: "I WANT TO CUSTOMIZE THE APP"

// ```
// STORY 12.1 — Dark mode
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I prefer dark mode. I go to Settings and switch to dark.

// What I expect:
//   - Entire app switches to dark theme immediately
//   - ALL screens are dark (no white flashes)
//   - Text is readable on dark background
//   - Note colors still visible and distinguishable
//   - Preference saved — app opens in dark mode next time

// Check in code:
//   - ThemeBloc → ChangeThemeVariantEvent
//   - Is ThemeData defined for both light and dark?
//   - Are ALL screens using Theme.of(context) or are there
//     hardcoded colors that don't change?
//   - Is preference saved to SharedPreferences?
//   - Does MaterialApp rebuild with new theme?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 12.2 — Changing accent color
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I change the app's accent color from blue to purple.

// What I expect:
//   - Buttons, icons, highlights change to purple
//   - It looks cohesive throughout the app
//   - Accent and theme (dark/light) work together

// Check in code:
//   - AccentColorBloc → ChangeAccentColorEvent
//   - Does accent color affect ThemeData.colorScheme?
//   - Is ThemeBloc and AccentColorBloc coordinated?
//   - Can they produce conflicting themes?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 12.3 — Accessibility settings
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I have visual impairment. I turn on:
//   - High contrast mode
//   - Larger text
//   - Reduce motion (fewer animations)

// What I expect:
//   - High contrast makes text more readable
//   - Text actually gets larger throughout app
//   - Animations stop or become simpler
//   - These settings persist

// Check in code:
//   - AccessibilityFeaturesBloc → all toggle events
//   - Do these toggles just save preferences or do they
//     ACTUALLY CHANGE THE UI?
//   - Is SettingsBloc → font_size_preference connected
//     to actual text scaling?
//   - Is SettingsBloc → font_family connected to actual fonts?
//   - Does ToggleReduceMotionEvent disable ALL animations?
//   - Does ToggleHighContrastEvent change actual colors?
//   - OR are these just checkboxes that save a boolean
//     but nothing actually changes? (PLACEHOLDER CHECK)

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 12.4 — Changing language
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I change the app language from English to Arabic.

// What I expect:
//   - All text in the app switches to Arabic
//   - Layout flips to Right-to-Left (RTL)
//   - Dates format changes to local format
//   - Numbers format might change
//   - My content (notes) stays in whatever language I wrote them

// Check in code:
//   - LocalizationBloc → ChangeLocaleEvent
//   - SettingsBloc → UpdateLanguageEvent
//   - Are there actual translation files (.arb)?
//   - How many languages are supported?
//   - Are ALL strings localized or are many hardcoded English?
//   - Is RTL layout handled?
//   - Does intl package format dates correctly per locale?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ```

// ---

// ## USER STORY GROUP 13: "I USE THE APP EVERY DAY — DASHBOARD"

// ```
// STORY 13.1 — Seeing my daily overview
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I open the app and want to see at a glance:
//   - How many todos I have today
//   - Any upcoming reminders
//   - My focus streak
//   - Recent notes

// What I expect:
//   - Dashboard shows summary widgets
//   - Numbers are accurate and up to date
//   - I can tap any widget to go to that section
//   - Dashboard loads fast

// Check in code:
//   - AnalyticsBloc → LoadAnalyticsEvent
//   - DashboardWidgetsBloc → LoadWidgetsEvent
//   - Are analytics data accurate?
//     - itemCounts correct?
//     - weeklyActivity calculation correct?
//     - currentStreak calculation correct?
//     - overdueItems count correct?
//   - Is dashboard the default home tab?
//   - Does data refresh when coming back to dashboard?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 13.2 — Viewing focus statistics
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What I do:
//   I want to see how many hours I focused this week.

// What I expect:
//   - Chart showing daily focus time
//   - Total hours this week
//   - Number of completed sessions
//   - Average session length
//   - Streak count

// Check in code:
//   - PomodoroStatsBloc → LoadStatsEvent
//   - AnalyticsBloc → focus data
//   - GraphBloc → LoadGraphDataEvent
//   - Are focus stats from FocusBloc and PomodoroBloc
//     combined or separate?
//   - Is data double-counted if user uses both?
//   - Does graph actually render?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ```

// ---

// ## USER STORY GROUP 14: "THINGS GOING WRONG — EDGE CASES"

// ```
// STORY 14.1 — App crashes and data loss
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What happens:
//   App crashes while I'm writing a long note.
//   I reopen the app.

// What I expect:
//   - My note should be auto-saved (at least partial)
//   - App should not crash on the same screen again
//   - I should be able to recover my work
//   - The app should handle the crash gracefully

// Check in code:
//   - Is there auto-save for note editor?
//   - Is there AppLifecycleObserver?
//   - Is there a crash recovery mechanism?
//   - If NoteEditorBloc emits error, what does UI show?
//   - Is the error recoverable?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 14.2 — Phone storage full
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What happens:
//   My phone has almost no storage left.
//   I try to create a note, take a photo, record audio.

// What I expect:
//   - Text note should still save (tiny data)
//   - Photo/audio should show "Not enough storage" message
//   - App should NOT crash
//   - Existing data should not be corrupted

// Check in code:
//   - Is storage space checked before saving media?
//   - Does SQLite handle low storage gracefully?
//   - Are error states shown for storage failures?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 14.3 — Permission denied for everything
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What happens:
//   I deny all permissions: camera, microphone, storage,
//   location, notifications.

// What I expect:
//   - Core app features (notes, todos) should still work
//   - Camera features show "Permission required" message
//   - Audio features show "Permission required" message
//   - Location features show "Permission required" message
//   - Notifications show warning that reminders won't work
//   - App should NOT crash when permission is denied
//   - Each denial should have a "Go to Settings" button

// Check in code:
//   - Is every permission request wrapped with error handling?
//   - What happens when camera permission denied in MediaBloc?
//   - What happens when mic denied in AudioRecorderBloc?
//   - What happens when location denied in LocationPickerBloc?
//   - What happens when notification denied in main.dart init?
//   - What happens when storage denied for backup/export?
//   - Is there a global permission handling strategy?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 14.4 — Rapid tapping and user impatience
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What happens:
//   I tap "Save" button 5 times rapidly.
//   I tap "Delete" and immediately "Undo" and "Delete" again.
//   I switch between tabs rapidly.

// What I expect:
//   - Save creates only ONE note, not 5 duplicates
//   - Delete/undo handles rapid state changes gracefully
//   - Tab switching doesn't cause errors or data corruption
//   - No duplicate operations

// Check in code:
//   - Is save button disabled after first tap?
//   - Is there a loading state that prevents double-submit?
//   - Does TodosBloc → DeleteTodo + UndoDeleteTodo handle
//     rapid toggling?
//   - Does NavigationBloc handle rapid TabChanged events?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// STORY 14.5 — Using app for a year (data accumulation)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// What happens:
//   After a year I have:
//   - 500 notes
//   - 1000 completed todos
//   - 300 reminders (past and future)
//   - 200 photos
//   - 50 audio recordings

// What I expect:
//   - App should still be fast to open
//   - Scrolling through notes should be smooth
//   - Search should still be fast
//   - The app should not take 500MB of storage
//   - Old completed items could be archived

// Check in code:
//   - Are lists using ListView.builder (not ListView)?
//   - Is pagination implemented for large lists?
//   - Are media files compressed?
//   - Is ClearOldNotesEvent used for cleanup?
//   - Is database indexed for search performance?
//   - Is CalculateCacheSizeEvent showing actual size?

// Status: ⬜
// Issues found: [list any]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ```


// =============================================================
// ████████████████████████████████████████████████████████████████
// PART 3: COMPILE ALL USER-FACING ISSUES
// ████████████████████████████████████████████████████████████████
// =============================================================

// After going through ALL user stories above, list EVERY
// issue from the USER's perspective:

// ```
// ╔═══════════════════════════════════════════════════════════════════╗
// ║  USER-FACING ISSUES                                              ║
// ╠══════╦══════════╦════════════════════════════════════════════════╣
// ║  #   ║ Impact   ║ What user experiences                         ║
// ╠══════╬══════════╬════════════════════════════════════════════════╣
// ║      ║ 😡 BAD   ║ Feature completely broken, user cannot use it ║
// ║      ║ 😕 POOR  ║ Feature works but gives wrong/confusing result║
// ║      ║ 😐 MEH   ║ Feature works but feels broken/unpolished     ║
// ║      ║ 🤔 CONF  ║ Feature exists but confuses user (duplicate)  ║
// ║      ║ 👻 FAKE  ║ Feature appears to exist but does nothing     ║
// ╚══════╩══════════╩════════════════════════════════════════════════╝
// ```

// For each issue:
// ```
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// USER ISSUE #[number] — [impact emoji]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Story: [which user story found this]
// What user tries to do: [plain language]
// What actually happens: [plain language]
// What should happen: [plain language]
// Technical cause: [code reference]
// Fix type: [Fix Code | Remove Feature | Merge Features |
//            Complete Implementation | Add Error Message]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ```


// =============================================================
// ████████████████████████████████████████████████████████████████
// PART 4: FIX LIST — MAKE EVERY EXISTING FEATURE WORK CORRECTLY
// ████████████████████████████████████████████████████████████████
// =============================================================

// RULE: NO NEW FEATURES. Only make existing things work right.

// Group fixes by priority:

// ## Priority 1: THINGS THAT ARE BROKEN (user cannot use)
// ## Priority 2: THINGS THAT GIVE WRONG RESULTS
// ## Priority 3: THINGS THAT CONFUSE (duplicates to merge)
// ## Priority 4: THINGS THAT ARE FAKE (remove or complete)
// ## Priority 5: THINGS THAT NEED POLISH

// For each fix:
// ```
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FIX #[number] — [priority level]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Fixes User Issue: #[number]
// What to do: [plain language]
// Files to change: [list]

// CURRENT CODE:
// ```dart
// // broken code
// ```

// FIXED CODE:
// ```dart
// // working code
// ```

// Verify by:
//   User action: [what to do in app]
//   Expected result: [what should happen]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ```


// =============================================================
// ████████████████████████████████████████████████████████████████
// PART 5: MERGE & CLEANUP LIST
// ████████████████████████████████████████████████████████████████
// =============================================================

// Based on the duplicate BLoC analysis, recommend merges:

// ```
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MERGE #[number]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Merge: [BLoC A] + [BLoC B] + [BLoC C]
// Into: [Single BLoC name]
// Why: [they do the same thing / confuse user]
// What to keep: [combined events/states]
// What to remove: [duplicate code]
// Screens to update: [which screens change their BLoC]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// REMOVE #[number]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Remove: [BLoC/feature name]
// Why: [placeholder / dead code / never used]
// Files to delete: [list]
// References to clean: [where it's imported but not used]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ```


// =============================================================
// ████████████████████████████████████████████████████████████████
// PART 6: FINAL CHECKLIST — IS EVERY PROMISE DELIVERED?
// ████████████████████████████████████████████████████████████████
// =============================================================

// Go back to Part 1.2 (App Promises) and verify EACH:

// ```
// ╔══════════════════════════════════════════════════════════════════╗
// ║  PROMISE DELIVERY CHECKLIST                                      ║
// ╠══════════════════════════════════════════════╦═══════╦═══════════╣
// ║ Promise                                      ║Before ║ After Fix ║
// ╠══════════════════════════════════════════════╬═══════╬═══════════╣
// ║ You can write and organize notes             ║       ║           ║
// ║ You can create and manage to-do lists        ║       ║           ║
// ║ You can set reminders that notify you        ║       ║           ║
// ║ You can focus using a timer                  ║       ║           ║
// ║ You can reflect and track mood               ║       ║           ║
// ║ You can attach photos/audio/video            ║       ║           ║
// ║ You can search across everything             ║       ║           ║
// ║ You can organize with folders and tags       ║       ║           ║
// ║ You can secure app with fingerprint          ║       ║           ║
// ║ You can backup and restore data              ║       ║           ║
// ║ You can scan documents and extract text      ║       ║           ║
// ║ You can use voice to write                   ║       ║           ║
// ║ You can set location reminders               ║       ║           ║
// ║ You can export as PDF                        ║       ║           ║
// ║ You can customize appearance                 ║       ║           ║
// ╠══════════════════════════════════════════════╬═══════╬═══════════╣
// ║ Status options:                              ║       ║           ║
// ║ ✅ = Fully delivered                          ║       ║           ║
// ║ ⚠️ = Partially delivered                     ║       ║           ║
// ║ ❌ = Broken/not delivered                     ║       ║           ║
// ║ 👻 = Placeholder (looks like it works but    ║       ║           ║
// ║      doesn't actually do anything)           ║       ║           ║
// ╚══════════════════════════════════════════════╩═══════╩═══════════╝
// ```

// ```
// ╔══════════════════════════════════════════════════════════════════╗
// ║  FINAL APP STATUS                                                ║
// ╠══════════════════════════════════════════════════════════════════╣
// ║                                                                  ║
// ║  Would a real user be HAPPY using this app?                      ║
// ║  Answer: [YES / MOSTLY / NO]                                     ║
// ║                                                                  ║
// ║  Would a real user RECOMMEND this app?                           ║
// ║  Answer: [YES / MAYBE / NO]                                      ║
// ║                                                                  ║
// ║  Would this app get good reviews on Play Store?                  ║
// ║  Estimated rating: [X.X / 5.0 stars]                             ║
// ║                                                                  ║
// ║  What is the #1 thing to fix to make users happy?                ║
// ║  Answer: [specific thing]                                        ║
// ║                                                                  ║
// ║  How many of the 57+ BLoCs are ACTUALLY needed?                  ║
// ║  Answer: [number] (rest should be merged or removed)             ║
// ║                                                                  ║
// ║  App health score:                                               ║
// ║  Before fixes: [X/10]                                            ║
// ║  After fixes:  [X/10]                                            ║
// ║                                                                  ║
// ╚══════════════════════════════════════════════════════════════════╝
// ```


// =============================================================
// NOW START. GO THROUGH EVERY USER STORY.
// READ THE ACTUAL CODE FOR EACH.
// MARK EVERY STATUS.
// BE HONEST — IF SOMETHING IS FAKE/PLACEHOLDER, SAY SO.
// START NOW.
// =============================================================
// ```

// ---

// ## HOW TO USE THIS — SIMPLE STEPS

// ```
// STEP 1: Paste this ENTIRE prompt after your project analysis
// STEP 2: Let AI go through every user story and check code
// STEP 3: Save output as USER_VERIFICATION_REPORT.md
// STEP 4: Say "Now implement FIX #1. Show complete code."
// STEP 5: After each fix say "DONE. Next fix."
// STEP 6: After all fixes say "Run Part 6 final checklist again"
// ```

// ---

// > **This prompt thinks like a REAL USER, not a developer. It checks if the app actually DELIVERS what it promises to the person who downloads it.**