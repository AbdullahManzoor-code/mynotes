# Screen Deduplication and UI Unification Plan

## Current Duplicate Screens Found

### Home Screens (DUPLICATES - NEED MERGING)
1. `home_page.dart` - Original home page
2. `main_home_screen.dart` - Main home implementation  
3. `modern_home_screen.dart` - Modern UI version
4. `unified_home_screen.dart` - Unified implementation
5. `dashboard_screen.dart` - Dashboard variant
6. `today_dashboard_screen.dart` - Today-focused dashboard

**RESOLUTION:** Keep `today_dashboard_screen.dart` as the main home (matches template `today_dashboard_home_1/2`)

### Analytics Screens (DUPLICATES)
1. `analytics_dashboard.dart` - Original analytics
2. `analytics_dashboard_screen.dart` - Enhanced version

**RESOLUTION:** Keep `analytics_dashboard_screen.dart` (more complete)

### Note Editor Screens (DUPLICATES)
1. `note_editor_page.dart` - Original editor
2. `enhanced_note_editor_screen.dart` - Enhanced version
3. `advanced_note_editor.dart` - Advanced features

**RESOLUTION:** Merge features into `enhanced_note_editor_screen.dart`

### Notes List Screens (DUPLICATES)  
1. `notes_list_screen.dart` - Original list
2. `enhanced_notes_list_screen.dart` - Enhanced version

**RESOLUTION:** Keep `enhanced_notes_list_screen.dart`

### Reminders Screens (DUPLICATES)
1. `reminders_screen.dart` - Original reminders
2. `enhanced_reminders_list_screen.dart` - Enhanced version  

**RESOLUTION:** Keep `enhanced_reminders_list_screen.dart`

### Search Screens (DUPLICATES)
1. `global_search_screen.dart` - Original search
2. `enhanced_global_search_screen.dart` - Enhanced version

**RESOLUTION:** Keep `enhanced_global_search_screen.dart`

### Quick Add Screens (DUPLICATES)
1. `universal_quick_add_screen.dart` - Original quick add
2. `fixed_universal_quick_add_screen.dart` - Fixed version

**RESOLUTION:** Keep `fixed_universal_quick_add_screen.dart`

### Todo Screens (DUPLICATES)
1. `todos_list_screen.dart` - Todo list
2. `advanced_todo_screen.dart` - Advanced todo features

**RESOLUTION:** Merge into `todos_list_screen.dart`

### Settings Screens (DUPLICATES)
1. `settings_screen.dart` - Original settings
2. `advanced_settings_screen.dart` - Advanced settings
3. `app_settings_screen.dart` - App-specific settings

**RESOLUTION:** Merge into `settings_screen.dart`

### Daily Highlight Screens (DUPLICATES)
1. `daily_highlight_summary_screen.dart` - Summary view
2. `edit_daily_highlight_screen.dart` - Edit view  
3. `edit_daily_highlight_screen_new.dart` - New edit version

**RESOLUTION:** Keep the newer versions, merge functionality

### Focus Screens (DUPLICATES)
1. `focus_session_screen.dart` - Focus session
2. `focus_session_active_screen.dart` - Active session view
3. `todo_focus_screen.dart` - Todo-specific focus
4. `focus_celebration_screen.dart` - Celebration view

**RESOLUTION:** Keep separate but consistent UI

### Empty State Screens (DUPLICATES)
1. `empty_state_notes_help_screen.dart` - Notes help
2. `empty_state_todos_help_screen.dart` - Todos help

**RESOLUTION:** Keep both, ensure consistent design

## Action Plan

### Phase 1: Remove Duplicate Home Screens
- Delete: `home_page.dart`, `main_home_screen.dart`, `modern_home_screen.dart`, `unified_home_screen.dart`, `dashboard_screen.dart`
- Keep: `today_dashboard_screen.dart` 
- Update routing to use single home screen

### Phase 2: Merge Enhanced Screens  
- Merge features from basic screens into enhanced versions
- Delete basic versions after merge
- Update imports and routing

### Phase 3: Template Matching
- Update remaining screens to match HTML templates
- Apply consistent design system
- Ensure proper navigation flow

### Phase 4: Clean Up
- Remove unused imports
- Update routing configuration  
- Test all navigation flows

## Files to DELETE
```
lib/presentation/pages/home_page.dart
lib/presentation/pages/main_home_screen.dart  
lib/presentation/pages/modern_home_screen.dart
lib/presentation/pages/unified_home_screen.dart
lib/presentation/pages/dashboard_screen.dart
lib/presentation/pages/analytics_dashboard.dart
lib/presentation/pages/note_editor_page.dart
lib/presentation/pages/notes_list_screen.dart
lib/presentation/pages/reminders_screen.dart
lib/presentation/pages/global_search_screen.dart
lib/presentation/pages/universal_quick_add_screen.dart
lib/presentation/pages/advanced_settings_screen.dart
lib/presentation/pages/app_settings_screen.dart
lib/presentation/pages/edit_daily_highlight_screen_new.dart
```

## Files to KEEP & ENHANCE
```
lib/presentation/pages/today_dashboard_screen.dart (MAIN HOME)
lib/presentation/pages/enhanced_note_editor_screen.dart
lib/presentation/pages/enhanced_notes_list_screen.dart  
lib/presentation/pages/enhanced_reminders_list_screen.dart
lib/presentation/pages/enhanced_global_search_screen.dart
lib/presentation/pages/fixed_universal_quick_add_screen.dart
lib/presentation/pages/analytics_dashboard_screen.dart
lib/presentation/pages/settings_screen.dart
lib/presentation/pages/todos_list_screen.dart
```