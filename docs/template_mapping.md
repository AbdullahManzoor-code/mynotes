# Template to Flutter Screen Mapping

This document maps HTML templates from `/templete/` to Flutter screens in the MyNotes app.

## Template Analysis

### Core Screens (Main Navigation)

| HTML Template | Flutter Screen | Route | BLoC | Status |
|--------------|----------------|-------|------|--------|
| `today_dashboard_home_1/2` | `TodayDashboardScreen` | `/today` | NotesBloc, AlarmBloc, ReflectionBloc | To Create |
| `notes_list_and_templates_1/2` | `NotesListScreen` | `/notes` | NotesBloc | ✅ Exists - Update UI |
| `reminders_list_and_smart_snooze_1/2` | `RemindersScreen` | `/reminders` | AlarmBloc | ✅ Exists - Update UI |
| `home_screen_widgets_ui` | `MainHomeScreen` | `/` | Multiple | ✅ Exists - Update UI |

### Notes Feature

| HTML Template | Flutter Screen | Route | BLoC | Status |
|--------------|----------------|-------|------|--------|
| `note_editor_with_links_and_pins` | `NoteEditorPage` | `/note-editor` | NotesBloc | ✅ Exists - Update UI |
| `empty_state_notes_help` | `EmptyStateNotes` (widget) | N/A | N/A | To Create Widget |
| `document_scan_capture` | `DocumentScanScreen` | `/document-scan` | NotesBloc | To Create |
| `ocr_text_extraction` | `OCRTextScreen` | `/ocr-extract` | NotesBloc | To Create |

### Todos Feature

| HTML Template | Flutter Screen | Route | BLoC | Status |
|--------------|----------------|-------|------|--------|
| `empty_state_todos_help` | `EmptyStateTodos` (widget) | N/A | N/A | To Create Widget |
| `recurring_todo_schedule_picker` | `RecurringSchedulePicker` (widget/sheet) | N/A | TodoBloc | To Create |
| `focus_session_active_1/2` | `TodoFocusScreen` | `/focus-session` | TodoBloc | ✅ Exists - Update UI |
| `focus_session_celebration_1/2` | `FocusCelebrationSheet` (bottom sheet) | N/A | TodoBloc | To Create |

### Reflection Feature

| HTML Template | Flutter Screen | Route | BLoC | Status |
|--------------|----------------|-------|------|--------|
| `reflection_privacy_and_insights_1/2` | `ReflectionHomeScreen` | `/reflection` | ReflectionBloc | ✅ Exists - Update UI |
| `daily_highlight_summary` | `DailyHighlightScreen` | `/daily-highlight` | ReflectionBloc | To Create |
| `edit_daily_highlight` | `EditHighlightScreen` | `/edit-highlight` | ReflectionBloc | To Create |

### Search & Navigation

| HTML Template | Flutter Screen | Route | BLoC | Status |
|--------------|----------------|-------|------|--------|
| `global_search_results_1/2` | `GlobalSearchScreen` | `/search` | NotesBloc | ✅ Exists - Update UI |
| `global_command_palette_1/2` | `CommandPaletteSheet` (overlay) | N/A | Multiple | To Create |
| `universal_quick_add_smart_input_1/2` | `QuickAddSheet` (bottom sheet) | N/A | Multiple | To Create |
| `quick_add_confirmation_flow` | `QuickAddConfirmation` (dialog) | N/A | Multiple | To Create |

### Settings & System

| HTML Template | Flutter Screen | Route | BLoC | Status |
|--------------|----------------|-------|------|--------|
| `app_settings_and_privacy` | `SettingsScreen` | `/settings` | ThemeBloc, SettingsBloc | ✅ Exists - Update UI |
| `backup_and_export_start` | `BackupExportWizard` (screen 1) | `/backup` | N/A | To Create |
| `backup_and_export_complete` | `BackupExportWizard` (screen 2) | `/backup/complete` | N/A | To Create |
| `calendar_integration_view` | `CalendarIntegrationScreen` | `/calendar` | AlarmBloc | To Create |

### Onboarding

| HTML Template | Flutter Screen | Route | BLoC | Status |
|--------------|----------------|-------|------|--------|
| `onboarding_welcome` | `OnboardingScreen` (page 1) | `/onboarding` | N/A | ✅ Exists - Update UI |
| `onboarding_smart_capture` | `OnboardingScreen` (page 2) | `/onboarding` | N/A | ✅ Exists - Update UI |
| `onboarding_privacy_focus` | `OnboardingScreen` (page 3) | `/onboarding` | N/A | ✅ Exists - Update UI |

### Future Features

| HTML Template | Flutter Screen | Route | BLoC | Status |
|--------------|----------------|-------|------|--------|
| `location_reminder_coming_soon` | `LocationReminderPlaceholder` | N/A | N/A | To Create |
| `untitled_screen_1/2` | TBD | N/A | N/A | Analysis Needed |

---

## Design System Elements from Templates

### Colors (Extracted from Tailwind Config)
- **Primary**: `#13b6ec` (Cyan Blue)
- **Background Light**: `#f6f8f8`
- **Background Dark**: `#101d22`
- **Text Dark**: `#111618`
- **Text Light**: `#ffffff`
- **Text Muted**: `#617f89`
- **Success**: `#078836`
- **Card Border Light**: `#e5e7eb` (gray-100)
- **Card Border Dark**: `#374151` (gray-700)

### Typography (Inter Font Family)
- **Display/Heading**: Inter Bold (24px, 20px, 18px)
- **Body**: Inter Regular/Medium (14px, 16px)
- **Label**: Inter Semibold (12px, 10px uppercase)
- **Caption**: Inter Regular (12px)

### Spacing & Radius
- **Border Radius**: 0.25rem (default), 0.5rem (lg), 0.75rem (xl), 9999px (full)
- **Padding**: 1rem (16px), 1.5rem (24px), 2rem (32px)
- **Gap**: 0.5rem (8px), 1rem (16px), 1.5rem (24px)

### Components Identified
1. **Stat Card**: Two-column grid with label + value + percentage
2. **Prompt Card**: Colored background with icon + title + description + button
3. **List Item**: Icon + title + subtitle with action button
4. **Section Header**: Title + "See all" link
5. **Bottom Nav**: 4 tabs with icons (filled when active)
6. **Avatar**: Circular with border
7. **Empty State**: Icon + title + description + CTA button
8. **Search Bar**: Rounded with icon + placeholder
9. **Filter Chips**: Horizontal scroll, selectable states
10. **Action Buttons**: Primary (filled), Secondary (outlined)

---

## Implementation Priority

### Phase 1: Design System Foundation ✅
- [x] `app_colors.dart`
- [x] `app_typography.dart`
- [x] `app_spacing.dart`
- [ ] Reusable components (buttons, cards, inputs)

### Phase 2: Core Screen Updates (Week 1)
- [ ] Update `MainHomeScreen` with bottom nav from templates
- [ ] Update `NotesListScreen` with template chips & grid layout
- [ ] Update `RemindersScreen` with smart grouping UI
- [ ] Create `TodayDashboardScreen` (new)

### Phase 3: Feature Screens (Week 2)
- [ ] Update `NoteEditorPage` with link/pin UI
- [ ] Update `TodoFocusScreen` with Pomodoro UI
- [ ] Update `ReflectionHomeScreen` with insights cards
- [ ] Create Quick Add flows

### Phase 4: Advanced Features (Week 3)
- [ ] Command Palette overlay
- [ ] Document Scan & OCR screens
- [ ] Backup/Export wizard
- [ ] Calendar integration

### Phase 5: Polish & Responsive (Week 4)
- [ ] Tablet/Desktop layouts
- [ ] Dark mode refinements
- [ ] Animations & transitions
- [ ] Empty states & loading states

---

## Notes
- All templates use Material Symbols Outlined icons
- Responsive breakpoint: 448px (max-w-md)
- Dark mode uses `dark:` prefix in Tailwind (translate to ThemeBloc in Flutter)
- Templates show glassmorphism effects (backdrop blur) on some cards
