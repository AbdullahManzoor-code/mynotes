

// Primary Navigation Hierarchy
// text

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │                        APP ENTRY POINT ALGORITHM                             │
// ├─────────────────────────────────────────────────────────────────────────────┤
// │                                                                              │
// │  STEP 1: App Cold Start                                                      │
// │  ├── Show Splash Screen                                                      │
// │  ├── Initialize Database Connections (SQLite + Isar)                         │
// │  ├── Load SharedPreferences                                                  │
// │  └── Wait 2 seconds (minimum)                                                │
// │                                                                              │
// │  STEP 2: Check First Run Flag                                                │
// │  ├── IF isFirstRun == TRUE                                                   │
// │  │   └── Navigate → Onboarding Screen                                        │
// │  │       ├── Page 1: Welcome                                                 │
// │  │       ├── Page 2: Smart Capture                                           │
// │  │       ├── Page 3: Privacy Focus                                           │
// │  │       ├── On Complete → Set isFirstRun = FALSE                            │
// │  │       └── Navigate → Main Home                                            │
// │  │                                                                           │
// │  └── IF isFirstRun == FALSE                                                  │
// │      └── Check Biometric Lock Setting                                        │
// │          ├── IF biometricEnabled == TRUE                                     │
// │          │   ├── Show Biometric Lock Screen                                  │
// │          │   ├── On Success → Navigate → Main Home                           │
// │          │   └── On Fail → Show PIN Fallback                                 │
// │          └── IF biometricEnabled == FALSE                                    │
// │              └── Navigate → Main Home                                        │
// │                                                                              │
// └─────────────────────────────────────────────────────────────────────────────┘
// Main Home Shell Structure
// text

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │                          MAIN HOME SHELL ALGORITHM                           │
// ├─────────────────────────────────────────────────────────────────────────────┤
// │                                                                              │
// │  Main Home acts as PARENT CONTAINER for:                                     │
// │  ├── Today Dashboard (Tab Index 0 - Default)                                 │
// │  ├── Notes List (Tab Index 1)                                                │
// │  ├── Todos List (Tab Index 2)                                                │
// │  ├── Reminders List (Tab Index 3)                                            │
// │  └── Reflection Home (Tab Index 4 - Optional in Bottom Nav or Drawer)        │
// │                                                                              │
// │  BOTTOM NAVIGATION BAR:                                                      │
// │  ┌─────────┬─────────┬─────────┬─────────┬─────────┐                        │
// │  │  🏠     │   📝    │   ➕    │   ✅    │   ⏰    │                        │
// │  │Dashboard│  Notes  │   FAB   │  Todos  │Reminders│                        │
// │  └─────────┴─────────┴─────────┴─────────┴─────────┘                        │
// │                                                                              │
// │  FLOATING ACTION BUTTON (Center):                                            │
// │  ├── On Tap → Show Quick Add Bottom Sheet                                    │
// │  │   ├── Option 1: New Note → Note Editor                                    │
// │  │   ├── Option 2: New Todo → Todo Create Sheet                              │
// │  │   ├── Option 3: New Reminder → Reminder Create                            │
// │  │   ├── Option 4: Scan Document → Document Scan                             │
// │  │   ├── Option 5: Voice Note → Audio Recorder                               │
// │  │   └── Option 6: Quick Reflect → Reflection Editor                         │
// │  │                                                                           │
// │  └── On Long Press → Universal Quick Add (Natural Language Input)            │
// │                                                                              │
// │  TOP APP BAR (Persistent):                                                   │
// │  ├── Left: Hamburger Menu (if drawer enabled) OR Back Button                 │
// │  ├── Center: Screen Title                                                    │
// │  ├── Right-1: Search Icon → Global Search                                    │
// │  └── Right-2: Profile/Settings Icon → Settings Screen                        │
// │                                                                              │
// │  DRAWER MENU (if enabled):                                                   │
// │  ├── User Profile Section                                                    │
// │  ├── Smart Collections                                                       │
// │  ├── Archived Notes                                                          │
// │  ├── Analytics Dashboard                                                     │
// │  ├── Integrated Features Hub                                                 │
// │  ├── Template Gallery                                                        │
// │  └── Settings                                                                │
// │                                                                              │
// └─────────────────────────────────────────────────────────────────────────────┘
// 📂 Screen Categories & Groupings
// Category Mapping (75+ Screens)
// text

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │                         SCREEN CATEGORY MAPPING                              │
// ├─────────────────────────────────────────────────────────────────────────────┤
// │                                                                              │
// │  CATEGORY A: ENTRY & AUTH (4 Screens)                                        │
// │  ├── A1: Splash Screen                                                       │
// │  ├── A2: Onboarding (3 pages as single screen)                               │
// │  ├── A3: Biometric Lock                                                      │
// │  └── A4: PIN Setup                                                           │
// │                                                                              │
// │  CATEGORY B: MAIN NAVIGATION (5 Screens)                                     │
// │  ├── B1: Main Home (Shell)                                                   │
// │  ├── B2: Today Dashboard                                                     │
// │  ├── B3: Notes List (Enhanced)                                               │
// │  ├── B4: Todos List                                                          │
// │  └── B5: Reminders List                                                      │
// │                                                                              │
// │  CATEGORY C: NOTE SCREENS (6 Screens)                                        │
// │  ├── C1: Note Editor (Basic)                                                 │
// │  ├── C2: Advanced Note Editor (Rich Text)                                    │
// │  ├── C3: Archived Notes                                                      │
// │  ├── C4: Empty Notes Help                                                    │
// │  ├── C5: Unified Items Screen                                                │
// │  └── C6: Drawing Canvas (Note Attachment)                                    │
// │                                                                              │
// │  CATEGORY D: TODO SCREENS (5 Screens)                                        │
// │  ├── D1: Advanced Todo View                                                  │
// │  ├── D2: Todo Focus Mode                                                     │
// │  ├── D3: Recurring Todo Schedule                                             │
// │  ├── D4: Empty Todos Help                                                    │
// │  └── D5: Kanban Board View (from Integrated Features)                        │
// │                                                                              │
// │  CATEGORY E: REMINDER SCREENS (10 Screens)                                   │
// │  ├── E1: Alarms                                                              │
// │  ├── E2: Calendar Integration                                                │
// │  ├── E3: Smart Reminders                                                     │
// │  ├── E4: Location Reminder                                                   │
// │  ├── E5: Location Reminder Coming Soon                                       │
// │  ├── E6: Saved Locations                                                     │
// │  ├── E7: Reminder Templates                                                  │
// │  ├── E8: Suggestion Recommendations                                          │
// │  ├── E9: Reminder Patterns                                                   │
// │  └── E10: Quick Add (Reminder Context)                                       │
// │                                                                              │
// │  CATEGORY F: REFLECTION SCREENS (6 Screens)                                  │
// │  ├── F1: Reflection Home                                                     │
// │  ├── F2: Reflection Editor                                                   │
// │  ├── F3: Reflection Answer                                                   │
// │  ├── F4: Reflection History                                                  │
// │  ├── F5: Reflection Carousel                                                 │
// │  └── F6: Reflection Questions (Settings)                                     │
// │                                                                              │
// │  CATEGORY G: FOCUS & PRODUCTIVITY (5 Screens)                                │
// │  ├── G1: Focus Session                                                       │
// │  ├── G2: Focus Celebration                                                   │
// │  ├── G3: Analytics Dashboard                                                 │
// │  ├── G4: Daily Highlight Summary                                             │
// │  └── G5: Edit Daily Highlight                                                │
// │                                                                              │
// │  CATEGORY H: SEARCH & FILTERS (8 Screens)                                    │
// │  ├── H1: Global Search                                                       │
// │  ├── H2: Enhanced Global Search                                              │
// │  ├── H3: Advanced Search                                                     │
// │  ├── H4: Search Results                                                      │
// │  ├── H5: Search Filter                                                       │
// │  ├── H6: Search Operators (Help)                                             │
// │  ├── H7: Advanced Filters                                                    │
// │  └── H8: Sort Customization                                                  │
// │                                                                              │
// │  CATEGORY I: SMART COLLECTIONS (4 Screens)                                   │
// │  ├── I1: Smart Collections Overview                                          │
// │  ├── I2: Create Collection                                                   │
// │  ├── I3: Rule Builder                                                        │
// │  └── I4: Collection Details                                                  │
// │                                                                              │
// │  CATEGORY J: MEDIA & ATTACHMENTS (10 Screens)                                │
// │  ├── J1: Media Picker                                                        │
// │  ├── J2: Audio Recorder                                                      │
// │  ├── J3: Full Media Gallery                                                  │
// │  ├── J4: Video Trimming                                                      │
// │  ├── J5: Media Viewer                                                        │
// │  ├── J6: Media Filter                                                        │
// │  ├── J7: Media Organization                                                  │
// │  ├── J8: Media Search Results                                                │
// │  ├── J9: Document Scan                                                       │
// │  └── J10: OCR Text Extraction                                                │
// │                                                                              │
// │  CATEGORY K: DOCUMENT & CREATIVE (3 Screens)                                 │
// │  ├── K1: Drawing Canvas                                                      │
// │  ├── K2: PDF Preview                                                         │
// │  └── K3: PDF Annotation                                                      │
// │                                                                              │
// │  CATEGORY L: TEMPLATES (2 Screens)                                           │
// │  ├── L1: Template Gallery                                                    │
// │  └── L2: Template Editor                                                     │
// │                                                                              │
// │  CATEGORY M: QUICK ACTIONS (3 Screens)                                       │
// │  ├── M1: Quick Add                                                           │
// │  ├── M2: Quick Add Confirmation                                              │
// │  └── M3: Universal Quick Add                                                 │
// │                                                                              │
// │  CATEGORY N: SETTINGS (8 Screens)                                            │
// │  ├── N1: Settings (Main)                                                     │
// │  ├── N2: Advanced Settings                                                   │
// │  ├── N3: Voice Settings                                                      │
// │  ├── N4: Font Settings                                                       │
// │  ├── N5: Tag Management                                                      │
// │  ├── N6: Backup & Export                                                     │
// │  ├── N7: Biometric Lock Setup                                                │
// │  └── N8: PIN Setup                                                           │
// │                                                                              │
// │  CATEGORY O: ANALYTICS (3 Screens)                                           │
// │  ├── O1: Frequency Analytics                                                 │
// │  ├── O2: Engagement Metrics                                                  │
// │  └── O3: Media Analytics                                                     │
// │                                                                              │
// │  CATEGORY P: ADVANCED FEATURES (3 Screens)                                   │
// │  ├── P1: Integrated Features Hub                                             │
// │  ├── P2: Home Widgets                                                        │
// │  └── P3: Cross-Feature Demo                                                  │
// │                                                                              │
// │  TOTAL: 75+ Screens                                                          │
// │                                                                              │
// └─────────────────────────────────────────────────────────────────────────────┘
// 🔄 Core Module Flow Algorithms
// Algorithm 1: Today Dashboard Flow
// text

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │                      TODAY DASHBOARD FLOW ALGORITHM                          │
// ├─────────────────────────────────────────────────────────────────────────────┤
// │                                                                              │
// │  ENTRY: User lands on Today Dashboard (Tab 0)                                │
// │                                                                              │
// │  STEP 1: Load Dashboard Data                                                 │
// │  ├── Fetch Today's Date                                                      │
// │  ├── Query Active Reminders (due today) from Isar/SQLite                     │
// │  ├── Query Pending Todos (due today/overdue) from SQLite                     │
// │  ├── Query Recent Notes (modified in last 24h) from SQLite                   │
// │  ├── Query Reflection Streak from Reflection Table                           │
// │  ├── Query Daily Highlight (if set) from UserPrefs                           │
// │  └── Query Focus Session Stats (today) from Analytics                        │
// │                                                                              │
// │  STEP 2: Render Dashboard Widgets                                            │
// │  ┌─────────────────────────────────────────────────────────────────────┐    │
// │  │                                                                      │    │
// │  │  WIDGET A: Daily Streak Card                                         │    │
// │  │  ├── Display: Current streak count, best streak                      │    │
// │  │  └── On Tap → Navigate to Analytics Dashboard (G3)                   │    │
// │  │                                                                      │    │
// │  │  WIDGET B: Daily Highlight Card                                      │    │
// │  │  ├── IF highlight exists:                                            │    │
// │  │  │   ├── Display: Highlight task name, progress                      │    │
// │  │  │   ├── On Tap → Navigate to Daily Highlight Summary (G4)           │    │
// │  │  │   └── On Long Press → Quick Mark Complete                         │    │
// │  │  └── IF no highlight:                                                │    │
// │  │      ├── Display: "Set your focus for today"                         │    │
// │  │      └── On Tap → Navigate to Edit Daily Highlight (G5)              │    │
// │  │                                                                      │    │
// │  │  WIDGET C: Quick Actions Row                                         │    │
// │  │  ├── Button 1: "New Note" → Note Editor (C1)                         │    │
// │  │  ├── Button 2: "New Task" → Todo Create Sheet (D1)                   │    │
// │  │  ├── Button 3: "Reminder" → Reminder Create                          │    │
// │  │  ├── Button 4: "Scan" → Document Scan (J9)                           │    │
// │  │  └── Button 5: "Reflect" → Reflection Editor (F2)                    │    │
// │  │                                                                      │    │
// │  │  WIDGET D: Today's Reminders Section                                 │    │
// │  │  ├── List: Up to 5 reminders due today                               │    │
// │  │  ├── Each Item On Tap → Enhanced Reminders List (B5) with filter     │    │
// │  │  ├── Toggle Switch → Enable/Disable Reminder                         │    │
// │  │  └── "See All" → Reminders List (B5)                                 │    │
// │  │                                                                      │    │
// │  │  WIDGET E: Pending Tasks Section                                     │    │
// │  │  ├── List: Up to 5 pending/overdue todos                             │    │
// │  │  ├── Checkbox → Mark Complete (update DB)                            │    │
// │  │  ├── Task Body On Tap → Advanced Todo View (D1)                      │    │
// │  │  └── "See All" → Todos List (B4)                                     │    │
// │  │                                                                      │    │
// │  │  WIDGET F: Recent Notes Section                                      │    │
// │  │  ├── Horizontal Scroll: 5 most recent notes                          │    │
// │  │  ├── Note Card On Tap → Note Editor (C1) with Note data              │    │
// │  │  └── "See All" → Notes List (B3)                                     │    │
// │  │                                                                      │    │
// │  │  WIDGET G: Mood Check-In (if enabled)                                │    │
// │  │  ├── Display: Emoji selector (5 moods)                               │    │
// │  │  └── On Select → Log mood to Reflection + Navigate to Reflection     │    │
// │  │                                                                      │    │
// │  └─────────────────────────────────────────────────────────────────────┘    │
// │                                                                              │
// │  STEP 3: Top Bar Actions                                                     │
// │  ├── Search Icon → Global Search (H1)                                        │
// │  └── Profile Icon → Settings (N1)                                            │
// │                                                                              │
// └─────────────────────────────────────────────────────────────────────────────┘
// Algorithm 2: Notes Module Complete Flow
// text

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │                        NOTES MODULE FLOW ALGORITHM                           │
// ├─────────────────────────────────────────────────────────────────────────────┤
// │                                                                              │
// │  ENTRY: User taps "Notes" in Bottom Navigation (Tab 1)                       │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  SCREEN: Notes List (Enhanced) - B3                                          │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  STEP 1: Check Notes Count                                                   │
// │  ├── IF notesCount == 0                                                      │
// │  │   └── Show Empty Notes Help Screen (C4) EMBEDDED                          │
// │  │       ├── "Create First Note" → Note Editor (C1)                          │
// │  │       └── "Import Notes" → File Picker → Import Flow                      │
// │  │                                                                           │
// │  └── IF notesCount > 0                                                       │
// │      └── Continue to STEP 2                                                  │
// │                                                                              │
// │  STEP 2: Load & Display Notes                                                │
// │  ├── Query all notes from SQLite (NotesBloc)                                 │
// │  ├── Apply current filter (if any)                                           │
// │  ├── Apply current sort order                                                │
// │  └── Render in Grid or List view                                             │
// │                                                                              │
// │  STEP 3: Top Bar Components                                                  │
// │  ├── Search Bar                                                              │
// │  │   ├── On Focus → Expand + Show suggestions                                │
// │  │   ├── On Input → Filter notes in real-time (300ms debounce)               │
// │  │   └── On Submit → Navigate to Search Results (H4)                         │
// │  │                                                                           │
// │  ├── View Toggle Button                                                      │
// │  │   ├── On Tap → Switch between Grid/List                                   │
// │  │   └── Save preference to SharedPrefs                                      │
// │  │                                                                           │
// │  └── Sort Button                                                             │
// │      └── On Tap → Show Sort Options Bottom Sheet                             │
// │          ├── Date Created (New First)                                        │
// │          ├── Date Created (Old First)                                        │
// │          ├── Date Modified                                                   │
// │          ├── Title A-Z                                                       │
// │          ├── Title Z-A                                                       │
// │          └── By Color                                                        │
// │                                                                              │
// │  STEP 4: Filter Chips (Below Search)                                         │
// │  ├── "All Notes" - Clear all filters                                         │
// │  ├── "Pinned" - Show only pinned                                             │
// │  ├── Color Chips - Filter by color                                           │
// │  ├── Tag Chips - Filter by tag (dynamic from DB)                             │
// │  └── "With Media" - Show notes with attachments                              │
// │                                                                              │
// │  STEP 5: Notes Display Sections                                              │
// │  ├── SECTION A: Pinned Notes (if any)                                        │
// │  │   ├── Header: "Pinned" with pin icon                                      │
// │  │   └── Grid/List of pinned notes (max 10)                                  │
// │  │                                                                           │
// │  └── SECTION B: All Notes                                                    │
// │      ├── Header: "All Notes" with count                                      │
// │      └── Grid/List of remaining notes                                        │
// │                                                                              │
// │  STEP 6: Note Card Interactions                                              │
// │  ┌─────────────────────────────────────────────────────────────────────┐    │
// │  │                                                                      │    │
// │  │  ON TAP (Note Card):                                                 │    │
// │  │  └── Navigate to Note Editor (C1)                                    │    │
// │  │      └── Pass: Note object {id, title, content, color, tags, ...}    │    │
// │  │                                                                      │    │
// │  │  ON LONG PRESS (Note Card):                                          │    │
// │  │  └── Show Context Menu Bottom Sheet                                  │    │
// │  │      ├── "Pin/Unpin" → Toggle pin status                             │    │
// │  │      ├── "Change Color" → Color Picker                               │    │
// │  │      ├── "Add Tags" → Tag Selector                                   │    │
// │  │      ├── "Set Reminder" → Create reminder linked to note ⭐           │    │
// │  │      ├── "Convert to Todo" → Create todo from note ⭐                 │    │
// │  │      ├── "Archive" → Move to archived                                │    │
// │  │      ├── "Share" → Share Sheet                                       │    │
// │  │      ├── "Export" → Export Options                                   │    │
// │  │      └── "Delete" → Confirm Dialog → Delete                          │    │
// │  │                                                                      │    │
// │  │  ON SWIPE LEFT (List View):                                          │    │
// │  │  └── Quick Archive                                                   │    │
// │  │                                                                      │    │
// │  │  ON SWIPE RIGHT (List View):                                         │    │
// │  │  └── Quick Delete (with undo snackbar)                               │    │
// │  │                                                                      │    │
// │  └─────────────────────────────────────────────────────────────────────┘    │
// │                                                                              │
// │  STEP 7: FAB Actions                                                         │
// │  ├── ON TAP → Note Editor (C1) with empty note                               │
// │  └── ON LONG PRESS → Show Template Selection                                 │
// │      └── Template Gallery (L1) → Select → Create with template              │
// │                                                                              │
// │  STEP 8: Pull-to-Refresh                                                     │
// │  └── Reload notes from database                                              │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  SCREEN: Note Editor - C1                                                    │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  ENTRY MODES:                                                                │
// │  ├── MODE A: New Note (no data passed)                                       │
// │  │   └── Generate new UUID, set timestamps                                   │
// │  ├── MODE B: Edit Existing (Note object passed)                              │
// │  │   └── Populate fields from Note object                                    │
// │  └── MODE C: From Template (Template object passed)                          │
// │      └── Clone template content to new note                                  │
// │                                                                              │
// │  STEP 1: Editor Layout                                                       │
// │  ┌─────────────────────────────────────────────────────────────────────┐    │
// │  │                                                                      │    │
// │  │  TOP BAR:                                                            │    │
// │  │  ├── Back Button → Save & Return to Notes List                       │    │
// │  │  ├── Title: "New Note" or "Edit Note"                                │    │
// │  │  ├── Undo Button → Revert last change                                │    │
// │  │  ├── Redo Button → Reapply change                                    │    │
// │  │  └── More Menu (⋮)                                                   │    │
// │  │      ├── "Advanced Editor" → Navigate to C2                          │    │
// │  │      ├── "Add to Home Widget"                                        │    │
// │  │      ├── "Share"                                                     │    │
// │  │      ├── "Export As..."                                              │    │
// │  │      ├── "Print"                                                     │    │
// │  │      └── "Delete Note"                                               │    │
// │  │                                                                      │    │
// │  │  TITLE INPUT:                                                        │    │
// │  │  └── Text field, auto-focus if new note                              │    │
// │  │                                                                      │    │
// │  │  CONTENT AREA:                                                       │    │
// │  │  └── Rich text editor with basic formatting                          │    │
// │  │                                                                      │    │
// │  │  FORMATTING TOOLBAR (above keyboard):                                │    │
// │  │  ├── Bold (B)                                                        │    │
// │  │  ├── Italic (I)                                                      │    │
// │  │  ├── Underline (U)                                                   │    │
// │  │  ├── Strikethrough                                                   │    │
// │  │  ├── Bullet List                                                     │    │
// │  │  ├── Numbered List                                                   │    │
// │  │  ├── Checkbox List                                                   │    │
// │  │  ├── Indent/Outdent                                                  │    │
// │  │  └── Text Color                                                      │    │
// │  │                                                                      │    │
// │  │  ATTACHMENTS SECTION:                                                │    │
// │  │  ├── Display existing attachments (thumbnails)                       │    │
// │  │  ├── On Tap Attachment → Media Viewer (J5)                           │    │
// │  │  └── On Long Press → Remove attachment                               │    │
// │  │                                                                      │    │
// │  │  BOTTOM ACTION BAR:                                                  │    │
// │  │  ├── 📌 Pin Toggle → Pin/Unpin note                                  │    │
// │  │  ├── 🎨 Color → Color Picker Bottom Sheet                            │    │
// │  │  ├── 🏷️ Tags → Tag Selector Bottom Sheet                            │    │
// │  │  ├── 🔔 Reminder → Create reminder linked to this note ⭐             │    │
// │  │  ├── 📎 Attach → Attachment Options                                  │    │
// │  │  │   ├── "Photo/Video" → Media Picker (J1)                           │    │
// │  │  │   ├── "Take Photo" → Camera                                       │    │
// │  │  │   ├── "Record Audio" → Audio Recorder (J2)                        │    │
// │  │  │   ├── "Scan Document" → Document Scan (J9)                        │    │
// │  │  │   ├── "Draw/Sketch" → Drawing Canvas (K1)                         │    │
// │  │  │   ├── "Add Link" → URL Input Dialog                               │    │
// │  │  │   └── "Attach File" → File Picker                                 │    │
// │  │  └── ⋯ More → Extended Options                                       │    │
// │  │                                                                      │    │
// │  └─────────────────────────────────────────────────────────────────────┘    │
// │                                                                              │
// │  STEP 2: Auto-Save Logic                                                     │
// │  ├── On any content change → Start 500ms debounce timer                      │
// │  ├── On timer complete → Save to database                                    │
// │  └── Show subtle "Saved" indicator                                           │
// │                                                                              │
// │  STEP 3: Exit Handling                                                       │
// │  ├── On Back Press                                                           │
// │  │   ├── IF content is empty → Discard note (don't save)                     │
// │  │   └── IF content exists → Save and return                                 │
// │  └── On Navigate Away → Save current state                                   │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  CROSS-LINK: Note → Reminder Integration ⭐                                  │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  WHEN user taps "Set Reminder" from Note:                                    │
// │  ├── STEP 1: Show Reminder Creation Bottom Sheet                             │
// │  │   ├── Date Picker (default: tomorrow)                                     │
// │  │   ├── Time Picker (default: 9:00 AM)                                      │
// │  │   ├── Recurrence Options                                                  │
// │  │   │   └── On "Repeat" tap → Recurring Todo Schedule (D3)                  │
// │  │   └── Note Link: AUTO-FILLED with current note ID                         │
// │  │                                                                           │
// │  ├── STEP 2: On Save                                                         │
// │  │   ├── Create Reminder record in Alarms table                              │
// │  │   ├── Link Reminder to Note (foreign key: noteId)                         │
// │  │   ├── Update Note record (hasReminder = true, reminderId = X)             │
// │  │   └── Schedule notification                                               │
// │  │                                                                           │
// │  └── STEP 3: Display Indication                                              │
// │      ├── Show bell icon on Note card in Notes List                           │
// │      ├── Show note preview in Reminders List                                 │
// │      └── On Reminder tap → Navigate to Note Editor (C1)                      │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  CROSS-LINK: Note → Todo Integration ⭐                                      │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  WHEN user taps "Convert to Todo" from Note:                                 │
// │  ├── STEP 1: Show Conversion Options                                         │
// │  │   ├── Option A: "Create single task with note attached"                   │
// │  │   │   └── Creates 1 Todo with noteId reference                            │
// │  │   └── Option B: "Extract checklist items as separate tasks"               │
// │  │       └── Parse checkboxes from note → Create multiple Todos              │
// │  │                                                                           │
// │  ├── STEP 2: On Create                                                       │
// │  │   ├── Create Todo record(s) in Todos table                                │
// │  │   ├── Link Todo to Note (foreign key: noteId)                             │
// │  │   ├── Update Note record (hasTodo = true, todoIds = [X,Y])                │
// │  │   └── Show confirmation                                                   │
// │  │                                                                           │
// │  └── STEP 3: Display Indication                                              │
// │      ├── Show checkmark icon on Note card                                    │
// │      ├── Show note preview in Todo details                                   │
// │      └── Changes in either sync to both ⭐                                   │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  SCREEN: Advanced Note Editor - C2                                           │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  ENTRY: From Note Editor (C1) → More Menu → "Advanced Editor"                │
// │  DATA: Current Note object                                                   │
// │                                                                              │
// │  ADDITIONAL FEATURES:                                                        │
// │  ├── Block-based editing (like Notion)                                       │
// │  │   ├── Text blocks                                                         │
// │  │   ├── Heading blocks (H1, H2, H3)                                         │
// │  │   ├── Code blocks                                                         │
// │  │   ├── Quote blocks                                                        │
// │  │   ├── Divider blocks                                                      │
// │  │   ├── Table blocks                                                        │
// │  │   ├── Image blocks                                                        │
// │  │   └── Embed blocks                                                        │
// │  │                                                                           │
// │  ├── Insert Menu (+)                                                         │
// │  │   ├── All block types above                                               │
// │  │   └── Templates insertion                                                 │
// │  │                                                                           │
// │  ├── Read Mode Toggle                                                        │
// │  │   └── Switch to read-only formatted view                                  │
// │  │                                                                           │
// │  └── Collaboration indicators (future)                                       │
// │                                                                              │
// │  ON BACK: Save and return to Note Editor (C1)                                │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  SCREEN: Archived Notes - C3                                                 │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  ENTRY: Menu/Drawer → "Archived Notes"                                       │
// │                                                                              │
// │  LAYOUT: Same as Notes List but filtered to isArchived = TRUE                │
// │                                                                              │
// │  INTERACTIONS:                                                               │
// │  ├── On Tap Note → Note Editor (C1) in read-only mode                        │
// │  ├── On Swipe Right → Unarchive (move back to main list)                     │
// │  ├── On Swipe Left → Permanent Delete (with confirm)                         │
// │  └── Batch Actions: Select All → Unarchive All / Delete All                  │
// │                                                                              │
// └─────────────────────────────────────────────────────────────────────────────┘
// Algorithm 3: Todos Module Complete Flow
// text

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │                        TODOS MODULE FLOW ALGORITHM                           │
// ├─────────────────────────────────────────────────────────────────────────────┤
// │                                                                              │
// │  ENTRY: User taps "Todos" in Bottom Navigation (Tab 2)                       │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  SCREEN: Todos List - B4                                                     │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  STEP 1: Check Todos Count                                                   │
// │  ├── IF todosCount == 0                                                      │
// │  │   └── Show Empty Todos Help Screen (D4) EMBEDDED                          │
// │  │       ├── "Add First Task" → Todo Create Sheet                            │
// │  │       ├── "View Templates" → Template Gallery (L1)                        │
// │  │       └── "Import Tasks" → Import Flow                                    │
// │  │                                                                           │
// │  └── IF todosCount > 0                                                       │
// │      └── Continue to STEP 2                                                  │
// │                                                                              │
// │  STEP 2: Load & Display Todos                                                │
// │  ├── Query all todos from SQLite (TodosBloc)                                 │
// │  ├── Separate into: Active, Completed, Overdue                               │
// │  ├── Apply current filter (category, priority)                               │
// │  └── Apply current sort order                                                │
// │                                                                              │
// │  STEP 3: Progress Overview Widget                                            │
// │  ├── Display: Completion percentage bar                                      │
// │  ├── Display: "X of Y tasks complete"                                        │
// │  └── On Tap → Analytics Dashboard (G3)                                       │
// │                                                                              │
// │  STEP 4: Category Filter Chips                                               │
// │  ├── [All] - Show all todos                                                  │
// │  ├── [Personal] - Filter by category                                         │
// │  ├── [Work] - Filter by category                                             │
// │  ├── [Shopping] - Filter by category                                         │
// │  ├── [Health] - Filter by category                                           │
// │  ├── [Finance] - Filter by category                                          │
// │  └── [More ▼] - Show all categories                                          │
// │                                                                              │
// │  STEP 5: Todos Display Sections                                              │
// │  ┌─────────────────────────────────────────────────────────────────────┐    │
// │  │                                                                      │    │
// │  │  SECTION A: Overdue Tasks (if any)                                   │    │
// │  │  ├── Header: "Overdue" with red indicator                            │    │
// │  │  ├── List of overdue todos sorted by due date                        │    │
// │  │  └── Each shows days overdue                                         │    │
// │  │                                                                      │    │
// │  │  SECTION B: Today's Tasks                                            │    │
// │  │  ├── Header: "Today" with date                                       │    │
// │  │  └── List of todos due today                                         │    │
// │  │                                                                      │    │
// │  │  SECTION C: Upcoming Tasks                                           │    │
// │  │  ├── Header: "Upcoming"                                              │    │
// │  │  └── List of todos due in future (grouped by date)                   │    │
// │  │                                                                      │    │
// │  │  SECTION D: No Due Date                                              │    │
// │  │  ├── Header: "Anytime"                                               │    │
// │  │  └── List of todos without due date                                  │    │
// │  │                                                                      │    │
// │  │  SECTION E: Completed (Collapsible)                                  │    │
// │  │  ├── Header: "Completed" with count + expand/collapse                │    │
// │  │  ├── List of completed todos                                         │    │
// │  │  └── "Clear All Completed" button                                    │    │
// │  │                                                                      │    │
// │  └─────────────────────────────────────────────────────────────────────┘    │
// │                                                                              │
// │  STEP 6: Todo Item Interactions                                              │
// │  ┌─────────────────────────────────────────────────────────────────────┐    │
// │  │                                                                      │    │
// │  │  CHECKBOX (Left Side):                                               │    │
// │  │  ├── On Tap → Toggle completion status                               │    │
// │  │  ├── Update database (isCompleted, completedAt)                      │    │
// │  │  ├── Play subtle animation                                           │    │
// │  │  └── Move to Completed section                                       │    │
// │  │                                                                      │    │
// │  │  TASK BODY (Main Area):                                              │    │
// │  │  └── On Tap → Navigate to Advanced Todo View (D1)                    │    │
// │  │      └── Pass: Todo object                                           │    │
// │  │                                                                      │    │
// │  │  PRIORITY INDICATOR (Color bar left):                                │    │
// │  │  ├── Red = Urgent                                                    │    │
// │  │  ├── Orange = High                                                   │    │
// │  │  ├── Yellow = Medium                                                 │    │
// │  │  └── Green = Low                                                     │    │
// │  │                                                                      │    │
// │  │  STAR ICON (Right):                                                  │    │
// │  │  └── On Tap → Toggle "Important" flag                                │    │
// │  │                                                                      │    │
// │  │  FOCUS ICON (if visible):                                            │    │
// │  │  └── On Tap → Navigate to Todo Focus Mode (D2)                       │    │
// │  │                                                                      │    │
// │  │  SUBTASK INDICATOR:                                                  │    │
// │  │  ├── Shows: "2 of 5 subtasks"                                        │    │
// │  │  └── Progress mini-bar                                               │    │
// │  │                                                                      │    │
// │  │  LINKED NOTE ICON (if exists):                                       │    │
// │  │  └── On Tap → Navigate to linked Note Editor (C1) ⭐                  │    │
// │  │                                                                      │    │
// │  │  ATTACHMENT ICON (if media attached):                                │    │
// │  │  └── On Tap → Show attachments preview                               │    │
// │  │                                                                      │    │
// │  │  ON LONG PRESS:                                                      │    │
// │  │  └── Show Context Menu                                               │    │
// │  │      ├── "Edit" → Advanced Todo View (D1)                            │    │
// │  │      ├── "Set Priority" → Priority Selector                          │    │
// │  │      ├── "Change Category" → Category Selector                       │    │
// │  │      ├── "Set Due Date" → Date/Time Picker                           │    │
// │  │      ├── "Set Reminder" → Create reminder for this todo ⭐            │    │
// │  │      ├── "Convert to Note" → Create note from todo ⭐                 │    │
// │  │      ├── "Add Subtasks" → Quick subtask input                        │    │
// │  │      ├── "Attach Media" → Attachment Options                         │    │
// │  │      ├── "Repeat" → Recurring Todo Schedule (D3)                     │    │
// │  │      ├── "Start Focus" → Todo Focus Mode (D2)                        │    │
// │  │      └── "Delete" → Confirm → Delete                                 │    │
// │  │                                                                      │    │
// │  │  ON SWIPE LEFT:                                                      │    │
// │  │  └── Quick Delete (with undo snackbar)                               │    │
// │  │                                                                      │    │
// │  │  ON SWIPE RIGHT:                                                     │    │
// │  │  └── Quick Complete                                                  │    │
// │  │                                                                      │    │
// │  └─────────────────────────────────────────────────────────────────────┘    │
// │                                                                              │
// │  STEP 7: FAB Action                                                          │
// │  └── ON TAP → Show Todo Create Bottom Sheet                                  │
// │      ├── Task title input (with voice option)                                │
// │      ├── Quick date buttons: Today, Tomorrow, Next Week, Custom              │
// │      ├── Priority selector                                                   │
// │      ├── Category selector                                                   │
// │      └── "Add" button → Create todo                                          │
// │                                                                              │
// │  STEP 8: Top Bar Actions                                                     │
// │  ├── Sort Button → Sort Options (by date, priority, alphabetical)            │
// │  ├── Search → Filter todos by title                                          │
// │  └── More Menu                                                               │
// │      ├── "Kanban View" → Integrated Features → Kanban Board                  │
// │      └── "Import Tasks" → Import flow                                        │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  SCREEN: Advanced Todo View - D1                                             │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  ENTRY: Tap on Todo item from Todos List                                     │
// │  DATA: Todo object passed                                                    │
// │                                                                              │
// │  LAYOUT:                                                                     │
// │  ┌─────────────────────────────────────────────────────────────────────┐    │
// │  │                                                                      │    │
// │  │  HEADER:                                                             │    │
// │  │  ├── Back Button → Save & Return                                     │    │
// │  │  ├── Title: Task name (editable)                                     │    │
// │  │  ├── Checkbox (large)                                                │    │
// │  │  └── More Menu (Delete, Share, Duplicate)                            │    │
// │  │                                                                      │    │
// │  │  DETAIL SECTIONS:                                                    │    │
// │  │                                                                      │    │
// │  │  📅 Due Date Section:                                                │    │
// │  │  ├── Date display/picker                                             │    │
// │  │  ├── Time display/picker                                             │    │
// │  │  └── "Repeat" option → Recurring Todo Schedule (D3)                  │    │
// │  │                                                                      │    │
// │  │  🔔 Reminder Section:                                                │    │
// │  │  ├── IF reminder exists → Show reminder details                      │    │
// │  │  │   └── On Tap → Edit reminder                                      │    │
// │  │  └── IF no reminder → "Add Reminder" button                          │    │
// │  │      └── On Tap → Create reminder linked to this todo ⭐              │    │
// │  │                                                                      │    │
// │  │  📝 Description Section:                                             │    │
// │  │  └── Multi-line text input for details                               │    │
// │  │                                                                      │    │
// │  │  ☑️ Subtasks Section:                                                │    │
// │  │  ├── List of subtasks with checkboxes                                │    │
// │  │  ├── Each subtask: Check → Complete                                  │    │
// │  │  ├── Drag handle for reorder                                         │    │
// │  │  ├── Swipe to delete subtask                                         │    │
// │  │  └── "+ Add Subtask" input at bottom                                 │    │
// │  │                                                                      │    │
// │  │  🎯 Priority Section:                                                │    │
// │  │  └── Priority selector (Urgent/High/Medium/Low)                      │    │
// │  │                                                                      │    │
// │  │  📁 Category Section:                                                │    │
// │  │  └── Category selector with icons                                    │    │
// │  │                                                                      │    │
// │  │  🏷️ Tags Section:                                                   │    │
// │  │  └── Tag input with suggestions                                      │    │
// │  │                                                                      │    │
// │  │  📎 Attachments Section: ⭐                                          │    │
// │  │  ├── Display existing media attachments                              │    │
// │  │  │   └── On Tap → Media Viewer (J5)                                  │    │
// │  │  └── "+ Add Attachment" button                                       │    │
// │  │      └── On Tap → Same attachment options as Notes                   │    │
// │  │          ├── "Photo/Video" → Media Picker (J1)                       │    │
// │  │          ├── "Camera" → Take photo                                   │    │
// │  │          ├── "Audio" → Audio Recorder (J2)                           │    │
// │  │          ├── "Scan" → Document Scan (J9)                             │    │
// │  │          └── "File" → File Picker                                    │    │
// │  │                                                                      │    │
// │  │  📝 Linked Note Section: ⭐                                          │    │
// │  │  ├── IF note linked → Show note preview                              │    │
// │  │  │   └── On Tap → Navigate to Note Editor (C1)                       │    │
// │  │  └── IF no note → "Link to Note" button                              │    │
// │  │      └── On Tap → Note selector or Create new note                   │    │
// │  │                                                                      │    │
// │  │  ⏱️ Focus Section:                                                   │    │
// │  │  └── "Start Focus Session" button → Todo Focus Mode (D2)             │    │
// │  │                                                                      │    │
// │  └─────────────────────────────────────────────────────────────────────┘    │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  SCREEN: Todo Focus Mode - D2                                                │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  ENTRY: From Todos List or Advanced Todo View → "Focus" action               │
// │  DATA: Todo object (optional, can focus without specific task)               │
// │                                                                              │
// │  FLOW:                                                                       │
// │  ├── STEP 1: Session Setup                                                   │
// │  │   ├── Select task (if not passed) from todo list                         │
// │  │   ├── Set session duration (25 min default, customizable)                 │
// │  │   └── Optional: Set goal for session                                      │
// │  │                                                                           │
// │  ├── STEP 2: Active Session                                                  │
// │  │   ├── Display: Circular timer countdown                                   │
// │  │   ├── Display: Task name                                                  │
// │  │   ├── Display: Session number (1 of 4)                                    │
// │  │   ├── Controls: Pause / Resume                                            │
// │  │   ├── Controls: Stop (with confirmation)                                  │
// │  │   └── Controls: Skip to break (if paused)                                 │
// │  │                                                                           │
// │  ├── STEP 3: Session Complete                                                │
// │  │   └── Navigate to Focus Celebration (G2)                                  │
// │  │                                                                           │
// │  └── STEP 4: Return                                                          │
// │      └── Back to Todos List or Dashboard                                     │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  SCREEN: Recurring Todo Schedule - D3                                        │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  ENTRY: From Todo or Reminder → "Repeat" option                              │
// │                                                                              │
// │  OPTIONS:                                                                    │
// │  ├── None (One-time)                                                         │
// │  ├── Daily                                                                   │
// │  │   └── Every X days selector                                               │
// │  ├── Weekly                                                                  │
// │  │   ├── Days of week selector (M/T/W/T/F/S/S)                               │
// │  │   └── Every X weeks selector                                              │
// │  ├── Monthly                                                                 │
// │  │   ├── On specific date (1-31)                                             │
// │  │   └── On pattern (First Monday, Last Friday, etc.)                        │
// │  ├── Yearly                                                                  │
// │  │   └── On specific date                                                    │
// │  └── Custom                                                                  │
// │      └── Advanced interval picker                                            │
// │                                                                              │
// │  END CONDITIONS:                                                             │
// │  ├── Never                                                                   │
// │  ├── After X occurrences                                                     │
// │  └── Until specific date                                                     │
// │                                                                              │
// │  ON SAVE: Store recurrence rule in database                                  │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  CROSS-LINK: Todo → Reminder Integration ⭐                                  │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  WHEN user sets reminder from Todo:                                          │
// │  ├── STEP 1: Create reminder with todoId reference                           │
// │  ├── STEP 2: Update todo record (hasReminder = true)                         │
// │  ├── STEP 3: Reminder appears in Reminders List                              │
// │  │   └── Shows todo title and due date                                       │
// │  └── STEP 4: On reminder tap → Navigate to Advanced Todo View (D1)           │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  CROSS-LINK: Todo → Note Integration ⭐                                      │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  OPTION A: Link existing note to todo                                        │
// │  ├── STEP 1: Show note selector (list of all notes)                          │
// │  ├── STEP 2: User selects note                                               │
// │  ├── STEP 3: Update todo record (noteId = selected)                          │
// │  └── STEP 4: Update note record (todoIds += this todo)                       │
// │                                                                              │
// │  OPTION B: Create new note from todo                                         │
// │  ├── STEP 1: Create new note with todo title as note title                   │
// │  ├── STEP 2: Link bidirectionally                                            │
// │  └── STEP 3: Navigate to Note Editor (C1)                                    │
// │                                                                              │
// │  OPTION C: Convert todo to note                                              │
// │  ├── STEP 1: Create note from todo content                                   │
// │  ├── STEP 2: Optionally delete todo                                          │
// │  └── STEP 3: Navigate to Note Editor (C1)                                    │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  CROSS-LINK: Todo → Media Attachments ⭐                                     │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  WHEN user adds attachment to Todo:                                          │
// │  ├── STEP 1: Show attachment options (same as Notes)                         │
// │  ├── STEP 2: Process media (compress, generate thumbnail)                    │
// │  ├── STEP 3: Save to MediaItems table with todoId reference                  │
// │  ├── STEP 4: Update todo record (hasMedia = true)                            │
// │  └── STEP 5: Display attachment in Todo detail view                          │
// │                                                                              │
// │  Attachment appears in:                                                      │
// │  ├── Advanced Todo View (D1) - Attachments section                           │
// │  ├── Full Media Gallery (J3) - Filtered by "Todo Media"                      │
// │  └── Unified Items Screen (C5) - With todo                                   │
// │                                                                              │
// └─────────────────────────────────────────────────────────────────────────────┘
// Algorithm 4: Reminders Module Complete Flow
// text

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │                      REMINDERS MODULE FLOW ALGORITHM                         │
// ├─────────────────────────────────────────────────────────────────────────────┤
// │                                                                              │
// │  ENTRY: User taps "Reminders" in Bottom Navigation (Tab 3)                   │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  SCREEN: Reminders List - B5                                                 │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  STEP 1: Load Reminders Data                                                 │
// │  ├── Query all alarms from Isar/SQLite (AlarmsBloc)                          │
// │  ├── Separate into: Today, Scheduled, Snoozed, Completed                     │
// │  └── Calculate overdue status                                                │
// │                                                                              │
// │  STEP 2: Tab Navigation                                                      │
// │  ┌─────────────────────────────────────────────────────────────────────┐    │
// │  │  [All]  [Today]  [Upcoming]  [Overdue]  [Snoozed]  [Completed]      │    │
// │  └─────────────────────────────────────────────────────────────────────┘    │
// │                                                                              │
// │  STEP 3: Reminder Item Display                                               │
// │  ┌─────────────────────────────────────────────────────────────────────┐    │
// │  │                                                                      │    │
// │  │  EACH REMINDER ITEM SHOWS:                                           │    │
// │  │  ├── Time indicator (color-coded)                                    │    │
// │  │  │   ├── Red = Overdue                                               │    │
// │  │  │   ├── Yellow = Due within 1 hour                                  │    │
// │  │  │   └── Green = Future                                              │    │
// │  │  │                                                                   │    │
// │  │  ├── Title/Message                                                   │    │
// │  │  ├── Date and Time                                                   │    │
// │  │  ├── Recurrence indicator (if repeating)                             │    │
// │  │  │                                                                   │    │
// │  │  ├── LINKED ITEM INDICATOR ⭐:                                       │    │
// │  │  │   ├── IF linkedNoteId exists:                                     │    │
// │  │  │   │   ├── Show 📝 icon with note title preview                    │    │
// │  │  │   │   └── On Tap → Navigate to Note Editor (C1)                   │    │
// │  │  │   └── IF linkedTodoId exists:                                     │    │
// │  │  │       ├── Show ✅ icon with todo title preview                    │    │
// │  │  │       └── On Tap → Navigate to Advanced Todo View (D1)            │    │
// │  │  │                                                                   │    │
// │  │  └── Toggle Switch → Enable/Disable reminder                         │    │
// │  │                                                                      │    │
// │  └─────────────────────────────────────────────────────────────────────┘    │
// │                                                                              │
// │  STEP 4: Reminder Item Interactions                                          │
// │  ┌─────────────────────────────────────────────────────────────────────┐    │
// │  │                                                                      │    │
// │  │  ON TAP (Reminder Item):                                             │    │
// │  │  └── IF has linked note → Note Editor (C1)                           │    │
// │  │      ELSE IF has linked todo → Advanced Todo View (D1)               │    │
// │  │      ELSE → Show Edit Reminder Bottom Sheet                          │    │
// │  │                                                                      │    │
// │  │  ON LONG PRESS:                                                      │    │
// │  │  └── Show Context Menu                                               │    │
// │  │      ├── "Edit" → Edit Reminder Sheet                                │    │
// │  │      ├── "Snooze" → Smart Snooze Options                             │    │
// │  │      │   ├── +10 minutes                                             │    │
// │  │      │   ├── +1 hour                                                 │    │
// │  │      │   ├── +1 day                                                  │    │
// │  │      │   ├── Tomorrow 9 AM                                           │    │
// │  │      │   ├── Next week same time                                     │    │
// │  │      │   └── Custom...→ Date/Time Picker                             │    │
// │  │      ├── "Complete" → Mark as done                                   │    │
// │  │      ├── "Link to Note" → Note selector ⭐                           │    │
// │  │      ├── "Link to Todo" → Todo selector ⭐                           │    │
// │  │      ├── "Set Recurrence" → Recurring Schedule (D3)                  │    │
// │  │      └── "Delete" → Confirm → Delete                                 │    │
// │  │                                                                      │    │
// │  │  TOGGLE SWITCH:                                                      │    │
// │  │  ├── ON → Schedule notification                                      │    │
// │  │  └── OFF → Cancel notification                                       │    │
// │  │                                                                      │    │
// │  │  ON SWIPE LEFT:                                                      │    │
// │  │  └── Show Snooze options                                             │    │
// │  │                                                                      │    │
// │  │  ON SWIPE RIGHT:                                                     │    │
// │  │  └── Quick Complete                                                  │    │
// │  │                                                                      │    │
// │  └─────────────────────────────────────────────────────────────────────┘    │
// │                                                                              │
// │  STEP 5: FAB Action                                                          │
// │  └── ON TAP → Show Create Reminder Bottom Sheet                              │
// │      ├── Message input                                                       │
// │      ├── Date picker                                                         │
// │      ├── Time picker                                                         │
// │      ├── Recurrence selector                                                 │
// │      │   └── On "Custom" → Recurring Todo Schedule (D3)                      │
// │      └── Link options ⭐                                                     │
// │          ├── "Link to existing Note" → Note selector                         │
// │          ├── "Link to existing Todo" → Todo selector                         │
// │          └── "Create new Note" → Creates note + links                        │
// │                                                                              │
// │  STEP 6: Quick Add (Header Button)                                           │
// │  └── On Tap → Quick Add screen (M1) in Reminder context                      │
// │                                                                              │
// │  STEP 7: AI & Insights Button                                                │
// │  └── On Tap → Integrated Features Hub (P1) with AI tab focused              │
// │      ├── Smart Reminders suggestions                                         │
// │      ├── Reminder Patterns analytics                                         │
// │      └── Suggestion Recommendations                                          │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  SCREEN: Alarms - E1                                                         │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  ENTRY: Reminders List → "Alarms" tab/section                                │
// │                                                                              │
// │  PURPOSE: Traditional alarm clock style alarms (wake-up, etc.)               │
// │                                                                              │
// │  FEATURES:                                                                   │
// │  ├── Alarm time display (large)                                              │
// │  ├── Days of week selector                                                   │
// │  ├── Alarm tone selection                                                    │
// │  ├── Snooze duration setting                                                 │
// │  └── Vibration toggle                                                        │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  SCREEN: Smart Reminders - E3                                                │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  ENTRY: Reminders List → AI Insights → Smart Reminders                       │
// │                                                                              │
// │  FEATURES:                                                                   │
// │  ├── AI-generated suggestions based on user patterns                         │
// │  ├── "You usually [action] at [time]" suggestions                            │
// │  ├── Accept/Reject swipe actions                                             │
// │  └── Enable/Disable AI toggle                                                │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  SCREEN: Calendar Integration - E2                                           │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  ENTRY: Settings → Integrations → Calendar                                   │
// │                                                                              │
// │  FEATURES:                                                                   │
// │  ├── Connect Google Calendar (OAuth)                                         │
// │  ├── Connect Apple Calendar (native)                                         │
// │  ├── Connect Outlook Calendar (OAuth)                                        │
// │  ├── Sync preferences (which items to sync)                                  │
// │  ├── Two-way sync toggle                                                     │
// │  └── Sync interval setting                                                   │
// │                                                                              │
// │  SYNC LOGIC:                                                                 │
// │  ├── Reminders → Calendar Events                                             │
// │  ├── Todos with due dates → Calendar Events                                  │
// │  └── Calendar Events → Reminders (optional)                                  │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  CROSS-LINK: Reminder → Note Integration ⭐                                  │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  WHEN creating reminder linked to note:                                      │
// │  ├── STEP 1: Store noteId in reminder record                                 │
// │  ├── STEP 2: Update note record (hasReminder = true, reminderIds += X)       │
// │  ├── STEP 3: On reminder trigger notification → Show note preview            │
// │  └── STEP 4: On notification tap → Open Note Editor (C1)                     │
// │                                                                              │
// │  DISPLAY BEHAVIOR:                                                           │
// │  ├── In Notes List → Show 🔔 icon on note card                               │
// │  ├── In Reminders List → Show 📝 icon with note preview                      │
// │  └── In Unified Items → Shows as single linked item                          │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  CROSS-LINK: Reminder → Todo Integration ⭐                                  │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  WHEN creating reminder linked to todo:                                      │
// │  ├── STEP 1: Store todoId in reminder record                                 │
// │  ├── STEP 2: Update todo record (hasReminder = true, reminderId = X)         │
// │  ├── STEP 3: On reminder trigger → Include todo details                      │
// │  └── STEP 4: On notification actions:                                        │
// │      ├── "View Task" → Open Advanced Todo View (D1)                          │
// │      ├── "Complete Task" → Mark todo complete + dismiss reminder             │
// │      └── "Snooze" → Snooze reminder                                          │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  NOTIFICATION SYSTEM                                                         │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  WHEN reminder triggers:                                                     │
// │  ├── STEP 1: Show local notification                                         │
// │  │   ├── Title: Reminder message                                             │
// │  │   ├── Body: Linked item preview (if any)                                  │
// │  │   └── Actions: Open, Snooze, Complete                                     │
// │  │                                                                           │
// │  ├── STEP 2: On notification tap                                             │
// │  │   ├── IF app closed → Launch app → Navigate to linked item               │
// │  │   └── IF app open → Navigate to linked item                              │
// │  │                                                                           │
// │  └── STEP 3: On action button tap                                            │
// │      ├── "Open" → Same as notification tap                                   │
// │      ├── "Snooze 10m" → Reschedule + 10 minutes                              │
// │      └── "Complete" → Mark done, dismiss notification                        │
// │                                                                              │
// └─────────────────────────────────────────────────────────────────────────────┘
// Algorithm 5: Reflection Module Complete Flow
// text

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │                      REFLECTION MODULE FLOW ALGORITHM                        │
// ├─────────────────────────────────────────────────────────────────────────────┤
// │                                                                              │
// │  ENTRY: User taps "Reflect" in Bottom Nav or Drawer                          │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  SCREEN: Reflection Home - F1                                                │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  STEP 1: Load Reflection Data                                                │
// │  ├── Query reflection entries from database                                  │
// │  ├── Calculate current streak                                                │
// │  ├── Get today's prompt (or random from pool)                                │
// │  └── Load mood history (last 7 days)                                         │
// │                                                                              │
// │  STEP 2: Display Widgets                                                     │
// │  ┌─────────────────────────────────────────────────────────────────────┐    │
// │  │                                                                      │    │
// │  │  WIDGET A: Streak & Stats Bar                                        │    │
// │  │  ├── 🔥 Current streak: X days                                       │    │
// │  │  ├── 📝 Total reflections: Y                                         │    │
// │  │  └── ⏱️ Total time: Z hours                                          │    │
// │  │      └── On Tap → Analytics Dashboard (G3) filtered to Reflection    │    │
// │  │                                                                      │    │
// │  │  WIDGET B: Today's Prompt Card                                       │    │
// │  │  ├── Display: Daily question                                         │    │
// │  │  ├── Display: Category badge                                         │    │
// │  │  └── "Start Writing →" button                                        │    │
// │  │      └── On Tap → Reflection Editor (F2) with this prompt            │    │
// │  │                                                                      │    │
// │  │  WIDGET C: Categories Grid                                           │    │
// │  │  ├── 🎯 Life & Purpose (tap → filtered prompts)                      │    │
// │  │  ├── 🌅 Daily Reflection (tap → filtered prompts)                    │    │
// │  │  ├── 💼 Career & Study (tap → filtered prompts)                      │    │
// │  │  └── 🧘 Mental Health (tap → filtered prompts)                       │    │
// │  │      └── On Tap any → Reflection Questions (F6) filtered             │    │
// │  │                                                                      │    │
// │  │  WIDGET D: Mood Overview (Weekly)                                    │    │
// │  │  ├── Display: 7-day mood chart                                       │    │
// │  │  └── "View Insights →"                                               │    │
// │  │      └── On Tap → Analytics Dashboard (G3)                           │    │
// │  │                                                                      │    │
// │  │  WIDGET E: Recent Reflections                                        │    │
// │  │  ├── List: Last 3 entries (preview)                                  │    │
// │  │  ├── On Tap entry → Reflection Answer (F3)                           │    │
// │  │  └── "See All History →"                                             │    │
// │  │      └── On Tap → Reflection History (F4)                            │    │
// │  │                                                                      │    │
// │  └─────────────────────────────────────────────────────────────────────┘    │
// │                                                                              │
// │  STEP 3: FAB Action                                                          │
// │  └── ON TAP → Reflection Editor (F2) with random prompt                      │
// │                                                                              │
// │  STEP 4: Top Bar Actions                                                     │
// │  ├── Settings Icon → Reflection Questions (F6)                               │
// │  └── Calendar Icon → Reflection History (F4) calendar view                   │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  SCREEN: Reflection Editor - F2                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  ENTRY MODES:                                                                │
// │  ├── MODE A: New with specific prompt (Question object passed)               │
// │  ├── MODE B: New with random prompt (no data passed)                         │
// │  └── MODE C: Edit existing (ReflectionEntry object passed)                   │
// │                                                                              │
// │  LAYOUT:                                                                     │
// │  ┌─────────────────────────────────────────────────────────────────────┐    │
// │  │                                                                      │    │
// │  │  HEADER:                                                             │    │
// │  │  ├── Back Button → Save & Return                                     │    │
// │  │  ├── Date display                                                    │    │
// │  │  └── Privacy Lock icon (if private)                                  │    │
// │  │                                                                      │    │
// │  │  PROMPT SECTION:                                                     │    │
// │  │  ├── Display: Question text (read-only)                              │    │
// │  │  ├── Category badge                                                  │    │
// │  │  └── "Change Prompt" button → Question carousel                      │    │
// │  │                                                                      │    │
// │  │  WRITING AREA:                                                       │    │
// │  │  ├── Large multi-line text input                                     │    │
// │  │  ├── Character counter                                               │    │
// │  │  └── Voice input button 🎤                                           │    │
// │  │                                                                      │    │
// │  │  MOOD SELECTOR:                                                      │    │
// │  │  ├── 5 emoji options (😢 😔 😐 😊 😄)                                │    │
// │  │  └── On Select → Store mood value (1-5)                              │    │
// │  │                                                                      │    │
// │  │  ADDITIONAL TRACKING (Optional expandable):                          │    │
// │  │  ├── Energy level (1-5)                                              │    │
// │  │  ├── Sleep quality (1-5)                                             │    │
// │  │  └── Activity tags                                                   │    │
// │  │                                                                      │    │
// │  │  STATS BAR:                                                          │    │
// │  │  ├── ⏱️ Writing time: X:XX                                           │    │
// │  │  └── 📝 Characters: XXX                                              │    │
// │  │                                                                      │    │
// │  │  BOTTOM ACTIONS:                                                     │    │
// │  │  ├── 🔒 "Make Private" toggle                                        │    │
// │  │  ├── 🎤 "Voice Input" → Audio Recorder mode                          │    │
// │  │  └── 💾 "Save Reflection" button                                     │    │
// │  │                                                                      │    │
// │  └─────────────────────────────────────────────────────────────────────┘    │
// │                                                                              │
// │  AUTO-SAVE: Every 30 seconds during writing                                  │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  SCREEN: Reflection Answer - F3                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  ENTRY: Tap on existing reflection entry                                     │
// │  DATA: ReflectionEntry object                                                │
// │                                                                              │
// │  PURPOSE: Read-only view of past reflection                                  │
// │                                                                              │
// │  FEATURES:                                                                   │
// │  ├── Display: Question, Answer, Mood, Date                                   │
// │  ├── "Edit" button → Reflection Editor (F2)                                  │
// │  ├── "Share" button → Generate shareable image                               │
// │  └── "Delete" button → Confirm → Delete                                      │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  SCREEN: Reflection History - F4                                             │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  ENTRY: Reflection Home → "See All History"                                  │
// │                                                                              │
// │  VIEW OPTIONS:                                                               │
// │  ├── Timeline View (List by date)                                            │
// │  └── Calendar View (Calendar with entries marked)                            │
// │                                                                              │
// │  FILTERS:                                                                    │
// │  ├── By Month                                                                │
// │  ├── By Category                                                             │
// │  ├── By Mood                                                                 │
// │  └── Search by content                                                       │
// │                                                                              │
// │  INTERACTIONS:                                                               │
// │  ├── On Tap entry → Reflection Answer (F3)                                   │
// │  └── On Tap calendar date → Show entries for that date                       │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  SCREEN: Reflection Carousel - F5                                            │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  ENTRY: Reflection History → "Visual Mode" or viewing entry detail           │
// │                                                                              │
// │  FEATURES:                                                                   │
// │  ├── Swipeable card carousel                                                 │
// │  ├── Each card shows one reflection beautifully formatted                    │
// │  ├── Swipe left/right for prev/next                                          │
// │  └── "Share" button → Generate image for social share                        │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  SCREEN: Reflection Questions - F6                                           │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  ENTRY: Reflection Home → Settings icon or "Manage Prompts"                  │
// │                                                                              │
// │  FEATURES:                                                                   │
// │  ├── List of all questions by category                                       │
// │  ├── Toggle default questions on/off                                         │
// │  ├── Create custom questions                                                 │
// │  ├── Edit custom questions                                                   │
// │  ├── Delete custom questions                                                 │
// │  └── Reorder questions (drag handles)                                        │
// │                                                                              │
// │  QUESTION CREATION:                                                          │
// │  ├── Question text input                                                     │
// │  ├── Category selector                                                       │
// │  └── Save to database                                                        │
// │                                                                              │
// └─────────────────────────────────────────────────────────────────────────────┘
// Algorithm 6: Focus & Productivity Flow
// text

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │                    FOCUS & PRODUCTIVITY FLOW ALGORITHM                       │
// ├─────────────────────────────────────────────────────────────────────────────┤
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  SCREEN: Focus Session - G1                                                  │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  ENTRY POINTS:                                                               │
// │  ├── Dashboard → "Start Focus" button                                        │
// │  ├── Todo item → Focus icon                                                  │
// │  ├── Advanced Todo View → "Start Focus Session"                              │
// │  └── Command Palette → "Start Focus"                                         │
// │                                                                              │
// │  DATA PASSED (optional): Todo object                                         │
// │                                                                              │
// │  STEP 1: Session Setup                                                       │
// │  ┌─────────────────────────────────────────────────────────────────────┐    │
// │  │                                                                      │    │
// │  │  IF no Todo passed:                                                  │    │
// │  │  ├── Show task selection list                                        │    │
// │  │  ├── Option: "Focus without task"                                    │    │
// │  │  └── On Select → Proceed to timer                                    │    │
// │  │                                                                      │    │
// │  │  IF Todo passed:                                                     │    │
// │  │  └── Display task name, proceed to timer                             │    │
// │  │                                                                      │    │
// │  │  SETTINGS (accessible via gear icon):                                │    │
// │  │  ├── Work duration: 15/25/30/45/60 min (default 25)                  │    │
// │  │  ├── Short break: 3/5/10 min (default 5)                             │    │
// │  │  ├── Long break: 15/20/30 min (default 15)                           │    │
// │  │  ├── Sessions before long break: 2/3/4/5 (default 4)                 │    │
// │  │  └── Notification sounds                                             │    │
// │  │                                                                      │    │
// │  └─────────────────────────────────────────────────────────────────────┘    │
// │                                                                              │
// │  STEP 2: Active Timer                                                        │
// │  ┌─────────────────────────────────────────────────────────────────────┐    │
// │  │                                                                      │    │
// │  │  DISPLAY:                                                            │    │
// │  │  ├── Large circular progress timer                                   │    │
// │  │  ├── Digital countdown (MM:SS)                                       │    │
// │  │  ├── Session type (WORK / BREAK)                                     │    │
// │  │  ├── Session number (Session 2 of 4)                                 │    │
// │  │  └── Current task name (if selected)                                 │    │
// │  │                                                                      │    │
// │  │  CONTROLS:                                                           │    │
// │  │  ├── ⏸️ Pause → Pauses timer                                         │    │
// │  │  │   └── On Paused → ▶️ Resume button appears                        │    │
// │  │  ├── ⏹️ Stop → Confirmation dialog                                   │    │
// │  │  │   ├── "End Session Early" → Save partial, exit                    │    │
// │  │  │   └── "Cancel" → Continue timer                                   │    │
// │  │  └── ⏭️ Skip Break (during break) → Start next work session          │    │
// │  │                                                                      │    │
// │  │  ADDITIONAL:                                                         │    │
// │  │  ├── "Change Task" button → Task selector                            │    │
// │  │  └── Today's stats preview (sessions completed, total time)          │    │
// │  │                                                                      │    │
// │  └─────────────────────────────────────────────────────────────────────┘    │
// │                                                                              │
// │  STEP 3: Timer Lifecycle                                                     │
// │  ├── WORK SESSION COMPLETE:                                                  │
// │  │   ├── Vibrate/Sound notification                                         │
// │  │   ├── Log session to analytics                                            │
// │  │   ├── IF 4 work sessions complete → Long break                            │
// │  │   └── ELSE → Short break                                                  │
// │  │                                                                           │
// │  ├── BREAK COMPLETE:                                                         │
// │  │   ├── Vibrate/Sound notification                                         │
// │  │   └── Auto-start next work session OR wait for manual start              │
// │  │                                                                           │
// │  └── SESSION END (all 4 complete or stopped):                                │
// │      └── Navigate to Focus Celebration (G2)                                  │
// │                                                                              │
// │  BACKGROUND BEHAVIOR:                                                        │
// │  ├── Timer continues in background                                           │
// │  ├── Notification shows remaining time                                       │
// │  ├── On complete → Push notification                                         │
// │  └── On return → Resume display                                              │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  SCREEN: Focus Celebration - G2                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  ENTRY: Auto-navigate after focus session complete                           │
// │                                                                              │
// │  DISPLAY:                                                                    │
// │  ├── Celebration animation (confetti, etc.)                                  │
// │  ├── "Great Work!" message                                                   │
// │  ├── Session stats:                                                          │
// │  │   ├── Duration focused                                                    │
// │  │   ├── Task completed (if applicable)                                      │
// │  │   └── Sessions today                                                      │
// │  ├── Streak counter (if applicable)                                          │
// │  └── Star rating (optional self-rating)                                      │
// │                                                                              │
// │  ACTIONS:                                                                    │
// │  ├── "Take Break" → Return to timer with break                               │
// │  ├── "Start Next Session" → Return to timer                                  │
// │  ├── "Mark Task Complete" (if todo linked) → Complete todo + exit            │
// │  ├── "Share Achievement" → Social share                                      │
// │  └── "Done" → Return to previous screen                                      │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  SCREEN: Analytics Dashboard - G3                                            │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  ENTRY: Profile → Analytics OR Dashboard → Stats widget                      │
// │                                                                              │
// │  TABS:                                                                       │
// │  ├── [Overview] - Combined stats                                             │
// │  ├── [Focus] - Focus session analytics                                       │
// │  ├── [Tasks] - Todo completion analytics                                     │
// │  ├── [Notes] - Note creation analytics                                       │
// │  └── [Reflection] - Reflection analytics                                     │
// │                                                                              │
// │  OVERVIEW TAB:                                                               │
// │  ├── Total focus time (week/month)                                           │
// │  ├── Tasks completed (week/month)                                            │
// │  ├── Notes created (week/month)                                              │
// │  ├── Reflection streak                                                       │
// │  └── Daily activity chart                                                    │
// │                                                                              │
// │  FOCUS TAB:                                                                  │
// │  ├── Focus time chart (bar/line)                                             │
// │  ├── Sessions per day                                                        │
// │  ├── Average session length                                                  │
// │  ├── Best focus day                                                          │
// │  └── Streak information                                                      │
// │                                                                              │
// │  TASKS TAB:                                                                  │
// │  ├── Completion rate                                                         │
// │  ├── Tasks by priority breakdown                                             │
// │  ├── Tasks by category breakdown                                             │
// │  ├── Overdue rate                                                            │
// │  └── Completion trends                                                       │
// │                                                                              │
// │  PERIOD SELECTOR: Day / Week / Month / Year                                  │
// │                                                                              │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │  SCREEN: Daily Highlight Summary - G4                                        │
// │  ═══════════════════════════════════════════════════════════════════════    │
// │                                                                              │
// │  ENTRY: Dashboard → Daily Highlight widget                                   │
// │                                                                              │
// │  DISPLAY:                                                                    │
// │  ├── Today's highlight task (if set)                                         │
// │  ├── Progress indicator                                                      │
// │  ├── Time spent on highlight                                                 │
// │  └── Related subtasks

// // LEVEL 0: App Entry
// // ├── LEVEL 1: Authentication Layer
// // │   ├── Splash Screen
// // │   ├── Onboarding Flow
// // │   └── Biometric/PIN Lock
// // │
// // ├── LEVEL 2: Shell Container (Main Home)
// // │   ├── Bottom Navigation Bar (4 tabs + FAB)
// // │   ├── Top App Bar (Search, Profile)
// // │   └── Drawer/Side Menu (optional)
// // │
// // ├── LEVEL 3: Primary Modules
// // │   ├── Today Dashboard
// // │   ├── Notes List
// // │   ├── Todos List
// // │   ├── Reminders List
// // │   └── Reflection Home
// // │
// // ├── LEVEL 4: Secondary Screens (Editors/Details)
// // │   ├── Note Editor / Advanced Note Editor
// // │   ├── Todo Detail / Advanced Todo
// // │   ├── Reminder Editor
// // │   ├── Reflection Editor
// // │   └── Focus Session
// // │
// // ├── LEVEL 5: Utility Screens (Modals/Sheets)
// // │   ├── Media Picker / Audio Recorder
// // │   ├── Document Scan / OCR
// // │   ├── Quick Add Sheets
// // │   ├── Filter/Sort Dialogs
// // │   └── Search Overlays
// // │
// // └── LEVEL 6: Settings & Configuration
// //     ├── Settings Main
// //     ├── Sub-Settings Screens
// //     └── Backup/Export
// // 📱 Module-Level Flow Algorithms
// // Algorithm 6: Reminders Module Complete Flow
// // text
//    . Search & Discovery Flow
// Algorithm: SEARCH_DISCOVERY_FLOW
// text

// START SEARCH_DISCOVERY_MODULE

// ═══════════════════════════════════════════════════════════════
// SECTION A: GLOBAL SEARCH
// ═══════════════════════════════════════════════════════════════

// STEP A1: Activate Search
//     WHEN user taps search icon OR swipes down:
//         ├── Open Global Command Palette
//         ├── Focus search input field
//         └── Show keyboard

// STEP A2: Global Command Palette Structure
//     ┌────────────────────────────────────────┐
//     │ 🔍 Search or type a command...    ⌘K  │
//     ├────────────────────────────────────────┤
//     │ QUICK ACTIONS                           │
//     │ ┌──────────────────────────────────┐   │
//     │ │ 📝 New Note                  ⌘+N │   │
//     │ │ ✅ New Todo                  ⌘+T │   │
//     │ │ 🔔 New Reminder              ⌘+R │   │
//     │ │ ⏱️ Start Focus               ⌘+F │   │
//     │ │ ⚙️ Settings                  ⌘+, │   │
//     │ └──────────────────────────────────┘   │
//     ├────────────────────────────────────────┤
//     │ RECENT SEARCHES                         │
//     │ meeting notes | project alpha | todo   │
//     └────────────────────────────────────────┘

// STEP A3: Command Detection
//     AS user types:
//         ├── IF starts with "/" or ">":
//         │   └── Treat as command, show command options
//         ├── IF matches quick action keyword:
//         │   └── Highlight matching action
//         └── ELSE:
//             └── Treat as search query

// STEP A4: Command Execution
//     WHEN user selects command:
//         ├── "/new note" OR "📝 New Note" → Navigate to Note Editor
//         ├── "/new todo" OR "✅ New Todo" → Open Todo Creation Sheet
//         ├── "/new reminder" → Open Reminder Creation
//         ├── "/focus" → Navigate to Focus Session
//         ├── "/settings" → Navigate to Settings
//         ├── "/archive" → Navigate to Archived Notes
//         └── Close command palette after navigation

// ═══════════════════════════════════════════════════════════════
// SECTION B: SEARCH EXECUTION
// ═══════════════════════════════════════════════════════════════

// STEP B1: Search Processing
//     WHEN user enters search query:
//         ├── Debounce input (300ms wait)
//         ├── IF query length < 2:
//         │   └── Show recent/suggested
//         └── IF query length >= 2:
//             ├── Execute full-text search
//             ├── Search across: Notes, Todos, Reminders, Reflections
//             ├── Rank results by relevance
//             └── Display results

// STEP B2: Search Results Display
//     ┌────────────────────────────────────────┐
//     │ 🔍 meeting notes                    ✕ │
//     ├────────────────────────────────────────┤
//     │ FILTER: [All] [📝] [✅] [🔔] [🧠]    │
//     ├────────────────────────────────────────┤
//     │ RESULTS (12 found)                      │
//     │                                         │
//     │ 📝 NOTES (5)                           │
//     │ ├── Project **Meeting Notes**          │
//     │ │   "...discussed the new **meeting**" │
//     │ │   Modified: 2 days ago               │
//     │ └── Team **Meeting** Summary           │
//     │                                         │
//     │ ✅ TODOS (4)                           │
//     │ ├── Prepare **meeting** agenda         │
//     │ │   Due: Tomorrow | Priority: High     │
//     │                                         │
//     │ 🔔 REMINDERS (3)                       │
//     │ ├── Team **meeting** at 3pm            │
//     │     Friday, Jan 17 at 3:00 PM          │
//     └────────────────────────────────────────┘

// STEP B3: Search Result Interactions
    
//     INTERACTION: Tap Filter Chip
//         ├── Filter results by item type
//         └── Update results display
    
//     INTERACTION: Tap Result Item
//         ├── IF Note → Navigate to Note Editor
//         ├── IF Todo → Navigate to Advanced Todo View
//         ├── IF Reminder → Navigate to Edit Reminder
//         └── IF Reflection → Navigate to Reflection Answer

// ═══════════════════════════════════════════════════════════════
// SECTION C: ADVANCED SEARCH
// ═══════════════════════════════════════════════════════════════

// STEP C1: Access Advanced Search
//     WHEN user needs complex queries:
//         └── Navigate to Advanced Search Screen

// STEP C2: Advanced Search Features
//     ┌────────────────────────────────────────┐
//     │         ADVANCED SEARCH                 │
//     ├────────────────────────────────────────┤
//     │ KEYWORDS                                │
//     │ [Contains: _________]                   │
//     │ [Does NOT contain: _________]           │
//     ├────────────────────────────────────────┤
//     │ DATE RANGE                              │
//     │ From: [📅 Select] To: [📅 Select]      │
//     ├────────────────────────────────────────┤
//     │ ITEM TYPES                              │
//     │ ☑ Notes  ☑ Todos  ☑ Reminders         │
// //     │ ☑ Reflections                          │
// //     ├────────────────────────────────────────┤
// //     │ ADDITIONAL FILTERS                      │
// //     │ Tags: [Select tags ▼]                  │
// //     │ Colors: [Any ▼]                        │
// //     │ Priority: [Any ▼]                      │
// //     │ Has attachments: [Yes/No/Any]          │
// //     ├────────────────────────────────────────┤
// //     │            [Run Search]                 │
// //     └────────────────────────────────────────┘


//   PART 9: SEARCH & DISCOVERY FLOWS
// FLOW P: GLOBAL SEARCH
// text

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │                    ALGORITHM: GLOBAL SEARCH (H1)                             │
// ├─────────────────────────────────────────────────────────────────────────────┤
// │                                                                              │
// │  ENTRY POINTS:                                                               │
// │  ├── Search icon in any app bar                                              │
// │  ├── Swipe down gesture on Dashboard (optional)                              │
// │  └── Keyboard shortcut (Ctrl+K on desktop)                                   │
// │                                                                              │
// │  ON LOAD:                                                                    │
// │  ├── Show search input with auto-focus                                       │
// │  ├── Display recent searches (if any)                                        │
// │  └── Show quick action shortcuts                                             │
// │                                                                              │
// │  QUICK ACTIONS (Before typing):                                              │
// │  ├── "📝 New Note" → Note Editor                                            │
// │  ├── "✅ New Todo" → Quick Todo sheet                                       │
// │  ├── "🔔 New Reminder" → Quick Reminder sheet                               │
// │  ├── "⏱️ Start Focus" → Focus Session                                       │
// │  └── "⚙️ Settings" → Settings                                               │
// │                                                                              │
// │  SEARCH INPUT:                                                               │
// │  ├── Text input with 300ms debounce                                          │
// │  ├── Voice input button → Speech-to-text                                    │
// │  └── Clear button                                                            │
// │                                                                              │
// │  SEARCH ALGORITHM:                                                           │
// │  ├── On input (debounced)                                                    │
// │  │   ├── Query Notes table: title LIKE %query% OR content LIKE %query%      │
// │  │   ├── Query Todos table: title LIKE %query%                              │
// │  │   ├── Query Reminders table: title LIKE %query%                          │
// │  │   ├── Query Reflections table: answer LIKE %query%                       │
// │  │   └── Query Tags table: name LIKE %query%                                │
// │  │                                                                           │
// │  └── Display results grouped by type                                        │
// │                                                                              │
// │  FILTER CHIPS:                                                               │
// │  ├── [All] [📝 Notes] [✅ Todos] [🔔 Reminders] [🧠 Reflections]           │
// │  ├── Tap chip → Filter results to that type only                            │
// │  └── Multiple selection for combination filtering                            │
// │                                                                              │
// │  RESULTS DISPLAY:                                                            │
// │  ├── Grouped sections: "NOTES (n)", "TODOS (n)", etc.                       │
// │  ├── Highlight matching text in results                                      │
// │  ├── Show preview: title, snippet with match highlighted                     │
// │  ├── Show metadata: date, tags, color                                        │
// │  └── "See More" in each section if results > 3                              │
// │                                                                              │
// │  RESULT ITEM TAP:                                                            │
// │  ├── Note → Navigate to Note Editor (C1)                                    │
// │  ├── Todo → Navigate to Advanced Todo View (D2)                             │
// │  ├── Reminder → Navigate to Reminders List (B5) with item highlighted       │
// │  └── Reflection → Navigate to Reflection Editor (E2)                        │
// │                                                                              │
// │  ADVANCED MODE:                                                              │
// │  ├── "Advanced" toggle → Switch to Enhanced Global Search                   │
// │  └── Navigate to Enhanced Global Search (H2)                                 │
// │                                                                              │
// └─────────────────────────────────────────────────────────────────────────────┘
// PART 10: MEDIA & ATTACHMENTS FLOWS
// FLOW Q: UNIVERSAL MEDIA ATTACHMENT
// text

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │           ALGORITHM: MEDIA ATTACHMENT (Works for Notes AND Todos)            │
// ├─────────────────────────────────────────────────────────────────────────────┤
// │                                                                              │
// │  CONCEPT: Same media system used in Note Editor AND Advanced Todo View       │
// │                                                                              │
// │  ATTACHMENT SOURCE SELECTION (Shows in both editors):                        │
// │  ├── When user taps "Attach" or "+" button                                  │
// │  │   └── Show bottom sheet with options:                                     │
// │  │       ├── 📷 Photo/Video → Media Picker (J1)                             │
// │  │       ├── 📸 Camera → Device camera                                      │
// │  │       ├── 🎙️ Audio → Audio Recorder (J2)                                │
// │  │       ├── 📄 Scan Document → Document Scan (J9)                          │
// │  │       ├── ✏️ Sketch → Drawing Canvas (K1)                                │
// │  │       └── 🔗 Link → URL input dialog                                     │
// │                                                                              │
// │  MEDIA PICKER FLOW (J1):                                                     │
// │  ├── Show device gallery                                                     │
// │  ├── Allow multi-select                                                      │
// │  ├── Support photos and videos                                               │
// │  ├── On "Done":                                                              │
// │  │   ├── For each selected item:                                            │
// │  │   │   ├── Copy to app storage                                            │
// │  │   │   ├── Compress if needed (photo: 1080p 70%, video: 720p)            │
// │  │   │   ├── Generate thumbnail                                              │
// │  │   │   ├── Create Media record with UUID                                  │
// │  │   │   ├── Set Media.parentId = note.uuid OR todo.uuid                    │
// │  │   │   └── Set Media.parentType = "note" OR "todo"                        │
// │  │   └── Return list of media UUIDs to calling editor                       │
// │  │                                                                           │
// │  └── Editor adds media UUIDs to parent.mediaIds array                        │
// │                                                                              │
// │  AUDIO RECORDER FLOW (J2):                                                   │
// │  ├── Show recording interface                                                │
// │  ├── Display waveform during recording                                       │
// │  ├── Pause/Resume capability                                                 │
// │  ├── On "Stop":                                                              │
// │  │   ├── Save as M4A file                                                    │
// │  │   ├── Create Media record                                                 │
// │  │   └── Return media UUID to calling editor                                │
// │  └── On "Discard": Delete file, return nothing                              │
// │                                                                              │
// │  DOCUMENT SCAN FLOW (J9 → J10):                                             │
// │  ├── Open camera in document mode                                            │
// │  ├── Auto-detect document edges                                              │
// │  ├── Capture image                                                           │
// │  ├── Show crop/rotate/filter tools                                           │
// │  ├── Option: "Extract Text"                                                  │
// │  │   ├── Navigate to OCR Extraction (J10)                                   │
// │  │   ├── Process image with ML Kit                                          │
// │  │   ├── Display extracted text                                              │
// │  │   ├── "Copy to Note" → Insert text into editor content                   │
// │  │   └── Return to editor                                                    │
// │  ├── "Save as Image" → Create Media record, add to parent                   │
// │  └── Return media UUID to calling editor                                    │
// │                                                                              │
// │  DRAWING CANVAS FLOW (K1):                                                   │
// │  ├── Open blank canvas or existing drawing                                   │
// │  ├── Pen/brush/eraser tools                                                  │
// │  ├── Color palette                                                           │
// │  ├── Undo/redo                                                               │
// │  ├── On "Save":                                                              │
// │  │   ├── Export as PNG file                                                  │
// │  │   ├── Create Media record                                                 │
// │  │   └── Return media UUID to calling editor                                │
// │  └── On "Cancel": Discard changes                                           │
// │                                                                              │
// │  VIEWING ATTACHED MEDIA:                                                     │
// │  ├── Thumbnails displayed in editor's attachments section                   │
// │  ├── Tap thumbnail → Navigate to Media Viewer (J5)                          │
// │  │   ├── Full-screen display                                                 │
// │  │   ├── Pinch-to-zoom for images                                           │
// │  │   ├── Playback controls for video/audio                                  │
// │  │   ├── Swipe left/right for multi-media                                   │
// │  │   └── Actions: Share, Delete, Edit (for images)                          │
// │  └── Long press thumbnail → Quick actions menu                              │
// │                                                                              │
// │  DELETING ATTACHED MEDIA:                                                    │
// │  ├── Remove from parent.mediaIds array                                       │
// │  ├── Mark for deletion (actual file delete on parent save)                  │
// │  └── Show undo snackbar                                                      │
// │                                                                              │
// └─────────────────────────────────────────────────────────────────────────────┘
// PART 11: SETTINGS & CONFIGURATION FLOWS
// FLOW R: SETTINGS NAVIGATION
// text

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │                    ALGORITHM: SETTINGS (N1) & SUB-SCREENS                    │
// ├─────────────────────────────────────────────────────────────────────────────┤
// │                                                                              │
// │  ENTRY POINT:                                                                │
// │  ├── Profile icon in app bar → Settings                                     │
// │  └── Drawer menu → Settings                                                  │
// │                                                                              │
// │  SETTINGS MAIN SCREEN (N1):                                                  │
// │  ├── Organized in sections                                                   │
// │  └── Each section has expandable tiles                                       │
// │                                                                              │
// │  SECTION: APPEARANCE                                                         │
// │  ├── "Theme" tile                                                            │
// │  │   ├── Tap → Show theme picker dialog                                     │
// │  │   ├── Options: System, Light, Dark, Ocean, Forest, Sunset, Midnight      │
// │  │   └── Apply immediately, save preference                                 │
// │  ├── "Font Family" tile → Navigate to Font Settings (N4)                    │
// │  └── "Font Size" tile                                                        │
// │      ├── Slider: 0.8x to 1.5x                                               │
// │      └── Preview text shown                                                  │
// │                                                                              │
// │  SECTION: SECURITY                                                           │
// │  ├── "Biometric Lock" tile                                                   │
// │  │   ├── Switch toggle                                                       │
// │  │   ├── If enabling → Authenticate first → Navigate to Biometric Lock (N7)│
// │  │   └── If disabling → Confirm with current auth                          │
// │  ├── "Auto-lock Timer" tile                                                  │
// │  │   ├── Options: Never, 1 min, 5 min, 15 min, 30 min                       │
// │  │   └── Save preference                                                     │
// │  └── "Change PIN" tile → Navigate to PIN Setup (N8)                         │
// │                                                                              │
// │  SECTION: NOTIFICATIONS                                                      │
// │  ├── "Enable Notifications" switch                                           │
// │  ├── "Sound" selector → Pick from system sounds                             │
// │  ├── "Vibration" switch                                                      │
// │  └── "Quiet Hours" tile → Set start/end time for DND                        │
// │                                                                              │
// │  SECTION: VOICE                                                              │
// │  └── Tap → Navigate to Voice Settings (N3)                                  │
// │      ├── Language selection                                                  │
// │      ├── Voice commands toggle                                               │
// │      ├── Audio feedback toggle                                               │
// │      └── Confidence threshold slider                                         │
// │                                                                              │
// │  SECTION: DATA & STORAGE                                                     │
// │  ├── "Backup & Export" tile → Navigate to Backup & Export (N6)              │
// │  ├── "Storage Used" display (calculated)                                     │
// │  └── "Clear Cache" tile → Show size, confirm, clear                         │
// │                                                                              │
// │  SECTION: INTEGRATIONS                                                       │
// │  ├── "Calendar Integration" → Navigate to Calendar Integration (G2)         │
// │  └── "Home Screen Widgets" → Navigate to Home Widgets (P2)                  │
// │                                                                              │
// │  SECTION: ORGANIZATION                                                       │
// │  └── "Tag Management" → Navigate to Tag Management (N5)                     │
// │      ├── List all tags                                                       │
// │      ├── Edit tag names/colors                                               │
// │      ├── Delete tags (show item count affected)                              │
// │      └── Create new tags                                                     │
// │                                                                              │
// │  SECTION: ADVANCED                                                           │
// │  └── Tap → Navigate to Advanced Settings (N2)                               │
// │      ├── Developer options                                                   │
// │      ├── Debug mode                                                          │
// │      └── Experimental features                                               │
// │                                                                              │
// │  SECTION: ABOUT                                                              │
// │  ├── "Version" display                                                       │
// │  ├── "Privacy Policy" → Web view                                            │
// │  ├── "Terms of Service" → Web view                                          │
// │  └── "Rate App" → App store link                                            │
// │                                                                              │
// └─────────────────────────────────────────────────────────────────────────────┘
// FLOW S: BACKUP & EXPORT
// text

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │                    ALGORITHM: BACKUP & EXPORT (N6)                           │
// ├─────────────────────────────────────────────────────────────────────────────┤
// │                                                                              │
// │  ON LOAD:                                                                    │
// │  ├── Query last backup date                                                  │
// │  ├── Calculate backup size (DB + media files)                                │
// │  └── Count items (notes, todos, reminders, reflections)                      │
// │                                                                              │
// │  BACKUP STATUS DISPLAY:                                                      │
// │  ├── Last backup date/time                                                   │
// │  ├── Backup size                                                             │
// │  └── Item counts                                                             │
// │                                                                              │
// │  EXPORT OPTIONS:                                                             │
// │  ├── "Full Backup (ZIP)"                                                     │
// │  │   ├── Tap → Start backup process                                         │
// │  │   ├── Export database + all media files                                  │
// │  │   ├── Create ZIP archive                                                  │
// │  │   ├── Show progress indicator                                             │
// │  │   └── On complete → Share sheet OR save to location                      │
// │  │                                                                           │
// │  ├── "Notes Only"                                                            │
// │  │   ├── Format selector: Markdown, Text, PDF, HTML                         │
// │  │   ├── Tap "Export Notes"                                                 │
// │  │   ├── Generate files in selected format                                  │
// │  │   └── Share/save                                                          │
// │  │                                                                           │
// │  └── "Data Only (No Media)"                                                  │
// │      ├── Export as JSON                                                      │
// │      └── Smaller file size                                                   │
// │                                                                              │
// │  IMPORT/RESTORE:                                                             │
// │  ├── "Import from File" button                                               │
// │  ├── Open file picker                                                        │
// │  ├── Validate file format                                                    │
// │  ├── Import options:                                                         │
// │  │   ├── ○ Merge with existing data                                         │
// │  │   └── ○ Replace all data (destructive - confirm)                        │
// │  ├── Process import with progress                                            │
// │  └── Show success/failure summary                                            │
// │                                                                              │
// └─────────────────────────────────────────────────────────────────────────────┘
// PART 12: QUICK ADD & UNIVERSAL INPUT FLOWS
// FLOW T: QUICK ADD SYSTEM
// text

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │                    ALGORITHM: QUICK ADD SYSTEM (M1, M2, M3)                  │
// ├─────────────────────────────────────────────────────────────────────────────┤
// │                                                                              │
// │  ENTRY POINTS:                                                               │
// │  ├── FAB tap on any main screen                                              │
// │  ├── FAB long press → Universal Quick Add                                   │
// │  ├── Home widget tap                                                         │
// │  ├── Notification action "Quick Add"                                        │
// │  └── Keyboard shortcut (desktop)                                             │
// │                                                                              │
// │  QUICK ADD BOTTOM SHEET (M1):                                                │
// │  ├── Context-aware default based on current screen                           │
// │  │   ├── From Notes List → Default to Note input                            │
// │  │   ├── From Todos List → Default to Todo input                            │
// │  │   └── From Reminders → Default to Reminder input                         │
// │  │                                                                           │
// │  ├── Input field with placeholder                                            │
// │  ├── Type selector tabs: Note | Todo | Reminder                             │
// │  ├── Voice input button                                                      │
// │  │                                                                           │
// │  ├── IF Note selected:                                                       │
// │  │   ├── Title input                                                         │
// │  │   ├── Quick content input                                                 │
// │  │   └── "Create" → Save note, navigate to Note Editor (optional)           │
// │  │                                                                           │
// │  ├── IF Todo selected:                                                       │
// │  │   ├── Task input                                                          │
// │  │   ├── Quick due date: Today | Tomorrow | Pick Date                       │
// │  │   ├── Quick priority selector                                             │
// │  │   └── "Add" → Save todo                                                   │
// │  │                                                                           │
// │  └── IF Reminder selected:                                                   │
// │      ├── Message input                                                        │
// │      ├── Date/time quick picker                                              │
// │      └── "Set" → Create and schedule reminder                               │
// │                                                                              │
// │  UNIVERSAL QUICK ADD (M3) - Smart Input:                                     │
// │  ├── Single text input accepting natural language                            │
// │  ├── AI/Rule parsing engine                                                  │
// │  │   ├── Detect item type from text                                         │
// │  │   │   ├── "remind me to..." → Reminder                                   │
// │  │   │   ├── "buy...", "todo..." → Todo                                     │
// │  │   │   └── Default → Note                                                  │
// │  │   │                                                                        │
// │  │   ├── Extract 




// STEP C3: Search Operators Help
//     WHEN user needs syntax help:
//         ├── Navigate to Search Operators Screen
//         └── Show examples:
//             ├── AND: "meeting AND project"
//             ├── OR: "meeting OR call"
//             ├── NOT: "meeting NOT cancelled"
//             ├── Phrase: "\"project meeting\""
//             └── Tag: "tag:work"

// ═══════════════════════════════════════════════════════════════
// SECTION D: SMART COLLECTIONS
// ═══════════════════════════════════════════════════════════════

// STEP D1: Collections Overview
//     WHEN accessing Smart Collections:
//         ├── Query all user-defined collections
//         ├── Display collection cards with item counts
//         └── Show system collections (if any)

// STEP D2: Collection Display
//     ┌────────────────────────────────────────┐
//     │         SMART COLLECTIONS               │
//     ├────────────────────────────────────────┤
//     │ ┌──────────────┐  ┌──────────────┐    │
//     │ │ 🔴 Urgent    │  │ 💼 Work      │    │
//     │ │    (5)       │  │    (23)      │    │
//     │ └──────────────┘  └──────────────┘    │
//     │ ┌──────────────┐  ┌──────────────┐    │
//     │ │ 📌 Pinned    │  │ 





   
// SCREEN: Reminders List (Enhanced)
// │
// ├── HEADER SECTION
// │   │
// │   ├── Search Bar
// │   │   └── ON INPUT → Filter reminders by title/message
// │   │
// │   └── Quick Add Button
// │       └── ON TAP → Navigate to Quick Add Screen (reminder mode)
// │
// ├── TAB FILTER SECTION
// │   │
// │   ├── Tab: "All"
// │   │   └── Query: All active reminders (not completed)
// │   │
// │   ├── Tab: "Today"
// │   │   └── Query: Reminders WHERE scheduledDate == TODAY
// │   │
// │   ├── Tab: "Upcoming"
// │   │   └── Query: Reminders WHERE scheduledDate > TODAY
// │   │
// │   ├── Tab: "Overdue"
// │   │   └── Query: Reminders WHERE scheduledDate < NOW AND isComplete == FALSE
// │   │
// │   └── Tab: "Snoozed"
// │       └── Query: Reminders WHERE isSnoozed == TRUE
// │
// ├── CONTENT SECTION
// │   │
// │   ├── IF reminders list is empty
// │   │   └── Display empty state with "Create Reminder" button
// │   │
// │   └── IF reminders list has items
// │       │
// │       ├── Group by date sections
// │       │   ├── "Overdue" (red header)
// │       │   ├── "Today" (yellow header)
// │       │   ├── "Tomorrow"
// │       │   ├── "This Week"
// │       │   └── "Later"
// │       │
// │       └── EACH REMINDER ITEM
// │           │
// │           ├── Status Indicator (color dot)
// │           │   ├── 🔴 Red = Overdue
// │           │   ├── 🟡 Yellow = Due within 1 hour
// │           │   ├── 🟢 Green = Future
// │           │   └── 🔵 Blue = Snoozed
// │           │
// │           ├── Time/Date Display
// │           │   └── Show scheduled time (relative or absolute)
// │           │
// │           ├── Title/Message
// │           │   └── ON TAP → Navigate to Reminder Editor
// │           │
// │           ├── Linked Note Indicator
// │           │   ├── IF linkedNoteId exists
// │           │   │   ├── Display 📝 icon + note title preview
// │           │   │   └── ON ICON TAP → Navigate to Note Editor with linked note
// │           │   └── IF no linked note
// │           │       └── Display "Link Note" option
// │           │
// │           ├── Linked Todo Indicator
// │           │   ├── IF linkedTodoId exists
// │           │   │   ├── Display ✅ icon + todo title preview
// │           │   │   └── ON ICON TAP → Navigate to Advanced Todo View
// │           │   └── IF no linked todo
// │           │       └── Display "Link Task" option
// │           │
// │           ├── Toggle Switch (right side)
// │           │   ├── ON = Reminder is active
// │           │   ├── OFF = Reminder is disabled
// │           │   └── ON TOGGLE → Update reminder status in database
// │           │
// │           ├── ON TAP (main area) → Navigate to Reminder Editor
// │           │
// │           ├── ON LONG PRESS → Show context menu
// │           │   ├── "Edit"
// │           │   ├── "Snooze" → Show Smart Snooze options
// │           │   ├── "Link Note" / "View Linked Note"
// │           │   ├── "Link Task" / "View Linked Task"
// │           │   ├── "Duplicate"
// │           │   └── "Delete"
// │           │
// │           ├── ON SWIPE RIGHT → Complete reminder
// │           │   ├── Set isComplete = TRUE
// │           │   ├── Set completedAt = now
// │           │   └── IF has recurrence → Generate next occurrence
// │           │
// │           └── ON SWIPE LEFT → Show Snooze Options
// │               └── Same as Smart Snooze bottom sheet
// │
// ├── FAB: Create New Reminder
// │   └── ON TAP → Open Create Reminder Bottom Sheet
// │       │
// │       ├── Title Input
// │       │   └── Placeholder: "Remind me to..."
// │       │
// │       ├── Voice Input Button
// │       │   └── ON TAP → Transcribe voice to title
// │       │
// │       ├── Quick Time Buttons
// │       │   ├── "In 10 min"
// │       │   ├── "In 1 hour"
// │       │   ├── "Today evening"
// │       │   ├── "Tomorrow morning"
// │       │   └── "Next week"
// │       │
// │       ├── Custom Date/Time Button
// │       │   └── ON TAP → Show combined date/time picker
// │       │
// │       ├── Link Section
// │       │   │
// │       │   ├── "Link to Note" Button
// │       │   │   └── ON TAP → Show Note Selector
// │       │   │       ├── Display recent notes
// │       │   │       ├── Search notes
// │       │   │       └── ON SELECT → Set linkedNoteId
// │       │   │
// │       │   └── "Link to Task" Button
// │       │       └── ON TAP → Show Todo Selector
// │       │           ├── Display active todos
// │       │           └── ON SELECT → Set linkedTodoId
// │       │
// │       ├── Recurrence Button
// │       │   └── ON TAP → Navigate to Recurring Todo Schedule Screen
// │       │       └── Return with recurrence rule
// │       │
// │       └── "Save" Button
// │           ├── Validate: title not empty, time set
// │           ├── Create reminder in database
// │           ├── Schedule local notification
// │           ├── Close sheet
// │           └── Show confirmation snackbar
// │
// └── MENU OPTIONS
//     ├── "Alarms" → Navigate to Alarms Screen
//     ├── "Calendar Integration" → Navigate to Calendar Integration
//     ├── "Smart Reminders" → Navigate to Smart Reminders
//     ├── "Templates" → Navigate to Reminder Templates
//     └── "AI & Insights" → Navigate to Integrated Features
// Algorithm 6.1: Smart Snooze Flow
// text

// COMPONENT: Smart Snooze Bottom Sheet
// │
// ├── TRIGGER
// │   ├── Swipe left on reminder
// │   ├── Long press → "Snooze"
// │   └── From reminder notification action
// │
// ├── QUICK OPTIONS
// │   │
// │   ├── "+10 Minutes" Button
// │   │   └── ON TAP → snoozeUntil = now + 10 minutes
// │   │
// │   ├── "+1 Hour" Button
// │   │   └── ON TAP → snoozeUntil = now + 1 hour
// │   │
// │   ├── "+1 Day" Button
// │   │   └── ON TAP → snoozeUntil = now + 24 hours
// │   │
// │   ├── "Tomorrow 9 AM" Button
// │   │   └── ON TAP → snoozeUntil = tomorrow 9:00 AM
// │   │
// │   ├── "Next Week Same Time" Button
// │   │   └── ON TAP → snoozeUntil = now + 7 days
// │   │
// │   └── "Custom..." Button
// │       └── ON TAP → Show date/time picker
// │           └── ON SELECT → snoozeUntil = selected datetime
// │
// └── ON SNOOZE SELECTED
//     ├── Update reminder.snoozeUntil
//     ├── Set reminder.isSnoozed = TRUE
//     ├── Cancel current notification
//     ├── Schedule new notification for snoozeUntil
//     ├── Close bottom sheet
//     └── Show confirmation: "Snoozed until [time]"
// Algorithm 6.2: Reminder Editor Flow
// text

// SCREEN: Reminder Editor (Create/Edit)
// │
// ├── ENTRY POINTS
// │   ├── From Reminders List → FAB (create mode)
// │   ├── From Reminders List → Tap reminder (edit mode)
// │   ├── From Note Editor → Create linked reminder
// │   ├── From Todo View → Create linked reminder
// │   └── From Quick Add → Reminder option
// │
// ├── HEADER
// │   ├── Back Button → Save and return
// │   └── Delete Button (edit mode only) → Delete with confirmation
// │
// ├── CONTENT
// │   │
// │   ├── Title/Message Field
// │   │   ├── Large text input
// │   │   └── Voice input option
// │   │
// │   ├── Date Picker Row
// │   │   ├── Display selected date
// │   │   └── ON TAP → Show date picker
// │   │
// │   ├── Time Picker Row
// │   │   ├── Display selected time
// │   │   └── ON TAP → Show time picker
// │   │
// │   ├── Recurrence Row
// │   │   └── ON TAP → Navigate to Recurring Todo Schedule
// │   │
// │   ├── Notification Settings Row
// │   │   ├── Sound picker
// │   │   ├── Vibration toggle
// │   │   └── Priority (normal/high for heads-up)
// │   │
// │   ├── Linked Note Section
// │   │   │
// │   │   ├── IF linkedNoteId exists
// │   │   │   ├── Display note card preview
// │   │   │   ├── ON TAP → Navigate to Note Editor
// │   │   │   └── "Remove Link" button
// │   │   │
// │   │   └── IF no linked note
// │   │       └── "Link to Note" button
// │   │           ├── ON TAP → Show Note Selector
// │   │           ├── "Create New Note" option
// │   │           │   └── Navigate to Note Editor
// │   │           │       ├── Create note
// │   │           │       ├── Return with note ID
// │   │           │       └── Set linkedNoteId
// │   │           │
// │   │           └── "Select Existing Note"
// │   │               └── ON SELECT → Set linkedNoteId
// │   │
// │   └── Linked Todo Section
// │       ├── Same pattern as Linked Note
// │       └── "Link to Task" / "Create New Task"
// │
// └── SAVE BEHAVIOR
//     ├── ON SAVE (create mode)
//     │   ├── Generate UUID
//     │   ├── Set createdAt = now
//     │   ├── Insert reminder into database
//     │   ├── IF linkedNoteId → Update note's linkedReminders array
//     │   ├── IF linkedTodoId → Update todo's linkedReminder
//     │   ├── Schedule local notification
//     │   └── Navigate back
//     │
//     └── ON SAVE (edit mode)
//         ├── Set modifiedAt = now
//         ├── Update reminder in database
//         ├── Cancel existing notification
//         ├── Reschedule notification with new time
//         └── Navigate back
// Algorithm 7: Reflection Module Complete Flow
// text

// SCREEN: Reflection Home
// │
// ├── HEADER SECTION
// │   │
// │   ├── Streak Display Card
// │   │   ├── Display current streak (🔥 X days)
// │   │   ├── Display longest streak
// │   │   ├── Display total reflections count
// │   │   └── ON TAP → Navigate to Analytics Dashboard (Reflection stats)
// │   │
// │   └── Settings Icon
// │       └── ON TAP → Navigate to Reflection Questions (manage prompts)
// │
// ├── TODAY'S PROMPT SECTION
// │   │
// │   ├── Card displaying today's reflection question
// │   │   ├── Question text (large, prominent)
// │   │   ├── Category indicator (icon + color)
// │   │   └── "Shuffle" button → Load different random question
// │   │
// │   ├── IF already answered today
// │   │   ├── Display "Already reflected today ✓"
// │   │   └── "View Entry" button → Navigate to today's entry
// │   │
// │   └── IF not answered today
// │       └── "Start Writing →" Button
// │           └── ON TAP → Navigate to Reflection Editor with today's question
// │
// ├── CATEGORY GRID SECTION
// │   │
// │   ├── Section Header: "Categories"
// │   │
// │   ├── Grid of category cards (2x2 or horizontal scroll)
// │   │   ├── Card: "🎯 Life & Purpose" (count: X)
// │   │   ├── Card: "🌅 Daily Reflection" (count: X)
// │   │   ├── Card: "💼 Career & Study" (count: X)
// │   │   └── Card: "🧘 Mental Health" (count: X)
// │   │
// │   └── Each card ON TAP
// │       └── Navigate to Reflection Questions filtered by category
// │
// ├── MOOD OVERVIEW SECTION
// │   │
// │   ├── Section Header: "This Week's Mood"
// │   │
// │   ├── Weekly mood display
// │   │   ├── Display emoji for each day (Mon-Sun)
// │   │   ├── Empty days show placeholder
// │   │   └── ON DAY TAP → Navigate to that day's entry (if exists)
// │   │
// │   └── "View Insights →" Button
// │       └── ON TAP → Navigate to Reflection History with analytics tab
// │
// ├── RECENT REFLECTIONS SECTION
// │   │
// │   ├── Section Header: "Recent Entries"
// │   │
// │   ├── List of recent entries (last 5-7)
// │   │   ├── Each entry shows:
// │   │   │   ├── Date
// │   │   │   ├── Question preview (truncated)
// │   │   │   ├── Answer preview (truncated)
// │   │   │   ├── Mood emoji
// │   │   │   └── Privacy lock icon (if private)
// │   │   │
// │   │   └── ON ENTRY TAP
// │   │       ├── IF private → Require biometric/PIN
// │   │       └── Navigate to Reflection Answer View
// │   │
// │   └── "See All →" Button
// │       └── ON TAP → Navigate to Reflection History
// │
// └── FAB: New Reflection
//     └── ON TAP → Navigate to Reflection Editor (blank or with prompt options)
// Algorithm 7.1: Reflection Editor Flow
// text

// SCREEN: Reflection Editor
// │
// ├── ENTRY POINTS
// │   ├── From Reflection Home → "Start Writing"
// │   ├── From Reflection Home → FAB
// │   ├── From Reflection Questions → Select question
// │   ├── From Reflection History → "New Entry"
// │   └── From Dashboard → Mood check-in
// │
// ├── HEADER
// │   │
// │   ├── Back Button
// │   │   ├── IF content exists → Save and return
// │   │   └── IF content empty → Confirm discard
// │   │
// │   ├── Timer Display
// │   │   ├── Show writing duration (0:00)
// │   │   ├── Pause on keyboard hidden
// │   │   └── Resume on keyboard shown
// │   │
// │   └── More Menu
// │       ├── "Make Private" toggle → Set isPrivate flag
// │       ├── "Change Question" → Show question selector
// │       └── "Discard" → Confirm and return
// │
// ├── QUESTION DISPLAY
// │   │
// │   ├── Card showing current question
// │   │   ├── Question text
// │   │   └── Category indicator
// │   │
// │   ├── "Shuffle" button → Load different question
// │   │
// │   └── Prompts Carousel (optional)
// │       ├── Horizontal scroll of prompt chips
// │       └── ON CHIP TAP → Insert prompt into answer
// │
// ├── ANSWER INPUT AREA
// │   │
// │   ├── Large multi-line text field
// │   ├── Placeholder: "Write your thoughts..."
// │   ├── Auto-save every 30 seconds
// │   └── Character/word count display
// │
// ├── MOOD SELECTOR
// │   │
// │   ├── Section Header: "How are you feeling?"
// │   │
// │   ├── Emoji Row (5-10 moods)
// │   │   ├── 😢 Very Sad (1)
// │   │   ├── 😔 Sad (2)
// │   │   ├── 😐 Neutral (3)
// │   │   ├── 😊 Happy (4)
// │   │   └── 😄 Very Happy (5)
// │   │
// │   └── ON EMOJI TAP → Set mood value
// │
// ├── ADDITIONAL TRACKING (optional expandable)
// │   │
// │   ├── Energy Level Slider (1-5)
// │   ├── Sleep Quality (1-5)
// │   └── Activity Tags (multi-select chips)
// │       ├── Exercise
// │       ├── Work
// │       ├── Social
// │       ├── Creative
// │       └── Rest
// │
// ├── VOICE INPUT BUTTON
// │   └── ON TAP → Start voice transcription
// │       ├── Transcribe speech
// │       └── Append to answer text
// │
// ├── BOTTOM ACTION BAR
// │   │
// │   ├── Privacy Toggle
// │   │   ├── 🔓 Public (visible in feeds)
// │   │   └── 🔒 Private (requires auth to view)
// │   │
// │   └── "Save Reflection" Button
// │       ├── Validate: answer has content
// │       ├── Create/update reflection entry
// │       ├── Save mood to mood log
// │       ├── Update streak
// │       └── Navigate back with confirmation
// │
// └── EXIT BEHAVIOR
//     ├── Auto-save draft on background
//     └── Resume draft on return
// Algorithm 7.2: Reflection History Flow
// text

// SCREEN: Reflection History
// │
// ├── HEADER
// │   ├── Back Button → Return to Reflection Home
// │   └── Filter Button → Show filter options
// │
// ├── VIEW TOGGLE
// │   ├── Timeline View (default) → Chronological list
// │   └── Calendar View → Month calendar with entry indicators
// │
// ├── FILTER OPTIONS
// │   │
// │   ├── Date Range Picker
// │   │   ├── This Week
// │   │   ├── This Month
// │   │   ├── Last 30 Days
// │   │   └── Custom Range
// │   │
// │   ├── Mood Filter
// │   │   └── Multi-select: All / Happy / Neutral / Sad
// │   │
// │   └── Category Filter
// │       └── Multi-select categories
// │
// ├── TIMELINE VIEW CONTENT
// │   │
// │   ├── Grouped by date/month
// │   │
// │   └── EACH ENTRY CARD
// │       ├── Date header
// │       ├── Question preview
// │       ├── Answer preview (2-3 lines)
// │       ├── Mood emoji
// │       ├── Writing duration badge
// │       ├── Privacy indicator
// │       │
// │       └── ON TAP
// │           ├── IF isPrivate → Authenticate first
// │           └── Navigate to Reflection Answer View
// │
// ├── CALENDAR VIEW CONTENT
// │   │
// │   ├── Month display with day cells
// │   ├── Days with entries marked (dot/color)
// │   ├── Streak visualization (connected days)
// │   │
// │   └── ON DAY TAP
// │       ├── IF has entry → Navigate to entry
// │       └── IF no entry → Navigate to Reflection Editor for that date
// │
// └── ANALYTICS TAB (optional)
//     ├── Mood Distribution Chart (pie/bar)
//     ├── Mood Trend Line (over time)
//     ├── Average Mood Score
//     ├── Writing Time Stats
//     └── Most Active Days
// Algorithm 7.3: Reflection Carousel Flow
// text

// SCREEN: Reflection Carousel
// │
// ├── ENTRY POINT
// │   └── From Reflection History → Tap entry (visual mode)
// │
// ├── DISPLAY
// │   ├── Full-screen card view of entry
// │   ├── Beautiful typography
// │   ├── Background color based on mood
// │   └── Date and mood display
// │
// ├── NAVIGATION
// │   ├── SWIPE LEFT → Next entry
// │   └── SWIPE RIGHT → Previous entry
// │
// ├── ACTIONS
// │   ├── Close Button → Return to History
// │   ├── Share Button → Generate shareable image
// │   └── Edit Button → Navigate to Reflection Editor
// │
// └── GESTURES
//     ├── Pinch to zoom text (if long)
//     └── Double tap to toggle full-screen mode
// Algorithm 8: Focus Session Flow
// text

// SCREEN: Focus Session
// │
// ├── ENTRY POINTS
// │   ├── From Dashboard → "Start Focus"
// │   ├── From Quick Actions → "Focus"
// │   ├── From Todo List → "Start Focus" on task
// │   ├── From Advanced Todo View → "Start Focus Session"
// │   └── From Command Palette → "Start Focus"
// │
// ├── INITIAL STATE (Before Starting)
// │   │
// │   ├── Settings Card
// │   │   ├── Work Duration Selector: 25/30/45/60 min
// │   │   ├── Short Break: 5/10 min
// │   │   ├── Long Break: 15/20/30 min
// │   │   └── Sessions until long break: 4
// │   │
// │   ├── Task Selection
// │   │   ├── "Select Task to Focus On" button
// │   │   └── ON TAP → Show Todo Selector
// │   │       ├── List of active todos
// │   │       ├── ON SELECT → Associate task
// │   │       └── "None - Just Focus" option
// │   │
// │   └── "Start Session" Button
// │       └── ON TAP → Begin timer
// │
// ├── ACTIVE SESSION STATE
// │   │
// │   ├── Timer Display
// │   │   ├── Large circular progress indicator
// │   │   ├── Countdown timer (MM:SS)
// │   │   ├── Color: Blue for work, Green for break
// │   │   └── Current phase indicator: "WORK" / "BREAK"
// │   │
// │   ├── Session Progress
// │   │   ├── Session indicator dots (● ● ○ ○)
// │   │   └── "Session X of Y"
// │   │
// │   ├── Current Task Display (if selected)
// │   │   ├── Task title
// │   │   └── "Change Task" button
// │   │
// │   ├── Controls
// │   │   │
// │   │   ├── Pause/Resume Button
// │   │   │   ├── ON TAP → Pause timer, dim screen
// │   │   │   └── ON TAP again → Resume timer
// │   │   │
// │   │   ├── Stop Button
// │   │   │   └── ON TAP → Confirm abandon dialog
// │   │   │       ├── IF CONFIRM → Log partial time, return to origin
// │   │   │       └── IF CANCEL → Continue session
// │   │   │
// │   │   └── Skip Break Button (during breaks only)
// │   │       └── ON TAP → Skip to next work session
// │   │
// │   └── Stats Display
// │       ├── Today's focus time: X min
// │       └── Today's sessions: X
// │
// ├── WORK SESSION COMPLETE
// │   │
// │   ├── Play completion sound
// │   ├── Show notification (if backgrounded)
// │   ├── Log session to database
// │   │
// │   └── TRANSITION LOGIC
// │       ├── IF sessionCount < 4
// │       │   └── Start short break
// │       └── IF sessionCount == 4
// │           └── Start long break, reset counter
// │
// ├── BREAK COMPLETE
// │   │
// │   ├── Play break-end sound
// │   ├── Show notification
// │   └── Prompt: "Ready for next session?"
// │       ├── "Start Work" → Begin work timer
// │       └── "I'm Done" → Navigate to celebration
// │
// └── ALL SESSIONS COMPLETE (or user done)
//     └── Navigate to Focus Celebration Screen
// Algorithm 8.1: Focus Celebration Flow
// text

// SCREEN: Focus Celebration
// │
// ├── ENTRY POINT
// │   └── From Focus Session → Timer complete / User done
// │
// ├── ANIMATION
// │   ├── Play celebration animation
// │   ├── Confetti effect
// │   └── Achievement sound
// │
// ├── STATS DISPLAY
// │   │
// │   ├── Total Focus Time: X minutes
// │   ├── Sessions Completed: X
// │   ├── Task Completed: [Task Name] (if any)
// │   │
// │   ├── Streak Info
// │   │   ├── 🔥 Current streak: X days
// │   │   └── IF new achievement → Show badge
// │   │
// │   └── Comparison
// │       └── "That's X% more than yesterday!"
// │
// ├── ACTIONS
// │   │
// │   ├── "Take a Break" Button
// │   │   └── ON TAP → Navigate to Dashboard
// │   │
// │   ├── "Start Another Session" Button
// │   │   └── ON TAP → Navigate back to Focus Session
// │   │
// │   ├── "Mark Task Complete" Button (if task linked)
// │   │   └── ON TAP → Complete todo, return to Todos List
// │   │
// │   └── "Share Achievement" Button
// │       └── ON TAP → Generate shareable image, open share sheet
// │
// └── AUTO-RETURN
//     └── After 30 seconds, auto-navigate to Dashboard
// Algorithm 9: Search & Command Palette Flow
// text

// SCREEN: Global Search
// │
// ├── ENTRY POINTS
// │   ├── From any screen → Tap search icon in app bar
// │   ├── From any screen → Swipe down gesture (optional)
// │   ├── Keyboard shortcut: Ctrl/Cmd + K
// │   └── From Dashboard → Search widget
// │
// ├── INITIAL STATE
// │   │
// │   ├── Search Input Field (auto-focused)
// │   │   ├── Placeholder: "Search notes, tasks, reminders..."
// │   │   └── Clear button (when has input)
// │   │
// │   ├── Recent Searches (below input)
// │   │   ├── List of recent queries
// │   │   └── ON TAP → Execute that search
// │   │
// │   └── Quick Actions (before typing)
// │       ├── "📝 New Note" → Navigate to Note Editor
// │       ├── "✅ New Task" → Open Todo Sheet
// │       ├── "🔔 New Reminder" → Open Reminder Sheet
// │       └── "⏱️ Start Focus" → Navigate to Focus Session
// │
// ├── WHILE TYPING (debounce 300ms)
// │   │
// │   ├── Show loading indicator
// │   │
// │   └── Execute search across:
// │       ├── Notes (title + content)
// │       ├── Todos (title + description)
// │       ├── Reminders (title/message)
// │       └── Reflections (question + answer)
// │
// ├── RESULTS STATE
// │   │
// │   ├── Filter Chips Row
// │   │   ├── "All" (default)
// │   │   ├── "📝 Notes"
// │   │   ├── "✅ Todos"
// │   │   ├── "🔔 Reminders"
// │   │   └── "🧠 Reflections"
// │   │
// │   ├── Results Count Display
// │   │   └── "Found X results"
// │   │
// │   └── Results List (grouped by type)
// │       │
// │       ├── NOTES SECTION (if any matches)
// │       │   ├── Section header: "📝 Notes (X)"
// │       │   ├── Each result:
// │       │   │   ├── Title with **highlighted** match
// │       │   │   ├── Content preview with **highlighted** match
// │       │   │   ├── Last modified date
// │       │   │   └── ON TAP → Navigate to Note Editor
// │       │   └── "See all notes →" (if truncated)
// │       │
// │       ├── TODOS SECTION (if any matches)
// │       │   ├── Section header: "✅ Todos (X)"
// │       │   ├── Each result with highlighted match
// │       │   └── ON TAP → Navigate to Advanced Todo View
// │       │
// │       ├── REMINDERS SECTION (if any matches)
// │       │   ├── Section header: "🔔 Reminders (X)"
// │       │   └── ON TAP → Navigate to Reminder Editor
// │       │
// │       └── REFLECTIONS SECTION (if any matches)
// │           ├── Section header: "🧠 Reflections (X)"
// │           └── ON TAP → Navigate to Reflection Answer View
// │
// ├── EMPTY RESULTS STATE
// │   ├── Display "No results for [query]"
// │   └── Suggestions:
// │       ├── "Try different keywords"
// │       └── "Create new: Note | Todo | Reminder"
// │
// └── EXIT
//     ├── Back button → Return to previous screen
//     ├── Clear search → Return to initial state
//     └── Select result → Navigate to item
// Algorithm 9.1: Command Palette Flow
// text

// COMPONENT: Global Command Palette
// │
// ├── ENTRY POINTS
// │   ├── Keyboard: Ctrl/Cmd + K
// │   ├── Shake gesture (optional)
// │   └── From Settings → "Quick Commands"
// │
// ├── DISPLAY
// │   ├── Overlay modal (slide down)
// │   ├── Search input field
// │   └── Command list
// │
// ├── COMMAND LIST
// │   │
// │   ├── NAVIGATION COMMANDS
// │   │   ├── "Go to Notes" → Switch to Notes tab
// │   │   ├── "Go to Todos" → Switch to Todos tab
// │   │   ├── "Go to Reminders" → Switch to Reminders tab
// │   │   ├── "Go to Settings" → Navigate to Settings
// │   │   └── "Go to Analytics" → Navigate to Analytics
// │   │
// │   ├── CREATE COMMANDS
// │   │   ├── "New Note" → Note Editor
// │   │   ├── "New Todo" → Todo Sheet
// │   │   ├── "New Reminder" → Reminder Sheet
// │   │   ├── "New Reflection" → Reflection Editor
// │   │   └── "Scan Document" → Document Scan
// │   │
// │   ├── ACTION COMMANDS
// │   │   ├── "Start Focus" → Focus Session
// │   │   ├── "Search..." → Global Search
// │   │   └── "Export All" → Backup Export
// │   │
// │   └── RECENT ITEMS
// │       └── Last 5 accessed notes/todos/reminders
// │
// ├── SEARCH BEHAVIOR
// │   ├── Filter commands by input
// │   ├── Fuzzy matching
// │   └── Show matching shortcuts
// │
// └── EXECUTION
//     ├── Arrow keys to navigate
//     ├── Enter to execute
//     └── Esc to close
// Algorithm 10: Quick Add / Universal Input Flow
// text

// SCREEN: Universal Quick Add
// │
// ├── ENTRY POINTS
// │   ├── From Main Home → Center FAB
// │   ├── From Command Palette → Create commands
// │   ├── Notification action → "Quick Add"
// │   └── Home screen widget → Quick add
// │
// ├── SMART INPUT MODE
// │   │
// │   ├── Large Text Input Field
// │   │   ├── Placeholder: "What's on your mind?"
// │   │   └── Voice input button
// │   │
// │   ├── AI DETECTION (real-time)
// │   │   │
// │   │   ├── ON INPUT → Parse text for patterns
// │   │   │
// │   │   ├── REMINDER DETECTION
// │   │   │   ├── Keywords: "remind", "reminder", "at", "on", "tomorrow"
// │   │   │   ├── Time patterns: "5pm", "5:00", "afternoon"
// │   │   │   ├── Date patterns: "tomorrow", "next week", "Jan 15"
// │   │   │   └── Display: "🔔 Reminder detected: [parsed time]"
// │   │   │
// │   │   ├── TODO DETECTION
// │   │   │   ├── Keywords: "todo", "task", "need to", "must", "should"
// │   │   │   ├── Priority words: "urgent", "important", "asap"
// │   │   │   └── Display: "✅ Task detected: [priority]"
// │   │   │
// │   │   └── NOTE DETECTION (default)
// │   │       └── Display: "📝 Will save as note"
// │   │
// │   └── CREATE BUTTON
// │       └── ON TAP → Create detected item type
// │           ├── Parse all detected metadata
// │           ├── Create in appropriate database
// │           └── Navigate to Quick Add Confirmation
// │
// ├── MANUAL CREATE MODE
// │   │
// │   ├── Type Selection Grid
// │   │   │
// │   │   ├── "📝 Note" Card
// │   │   │   └── ON TAP → Navigate to Note Editor
// │   │   │
// │   │   ├── "🔔 Reminder" Card
// │   │   │   └── ON TAP → Open Reminder Creation Sheet
// │   │   │
// │   │   ├── "✅ Todo" Card
// │   │   │   └── ON TAP → Open Todo Creation Sheet
// │   │   │
// │   │   ├── "📷 Scan Document" Card
// │   │   │   └── ON TAP → Navigate to Document Scan
// │   │   │
// │   │   ├── "🎙️ Voice Note" Card
// │   │   │   └── ON TAP → Start audio recording, then Note Editor
// │   │   │
// │   │   └── "🧠 Reflect" Card
// │   │       └── ON TAP → Navigate to Reflection Editor
// │   │
// │   └── CLOSE BUTTON
// │       └── ON TAP → Dismiss sheet
// │
// ├── KEYBOARD SHORTCUTS (desktop)
// │   ├── "N" → Note
// │   ├── "R" → Reminder
// │   ├── "T" → Todo
// │   └── "Esc" → Close
// Algorithm 10.1: Quick Add Confirmation Flow
// text

// SCREEN: Quick Add Confirmation
// │
// ├── ENTRY POINT
// │   └── From Universal Quick Add → After successful creation
// │
// ├── DISPLAY
// │   │
// │   ├── Success Animation (checkmark)
// │   │
// │   ├── Created Item Summary
// │   │   ├── Type icon + label ("🔔 Reminder Created!")
// │   │   ├── Title/content preview
// │   │   ├── Metadata (date, time, category)
// │   │   └── Linked items (if any)
// │   │
// │   └── Action Buttons
// │       │
// │       ├── "View Details" Button
// │       │   └── ON TAP → Navigate to appropriate editor
// │       │
// │       ├── "Add Another" Button
// │       │   └── ON TAP → Return to Universal Quick Add (fresh)
// │       │
// │       └── "Done ✓" Button
// │           └── ON TAP → Dismiss, return to previous screen
// │
// └── AUTO-DISMISS
//     └── After 3 seconds, auto-dismiss if no interaction
// Algorithm 11: Document Scan & OCR Flow
// text

// SCREEN: Document Scan
// │
// ├── ENTRY POINTS
// │   ├── From Note Editor → Attachment → "Scan Document"
// │   ├── From Universal Quick Add → "Scan Document"
// │   └── From Integrated Features → Document Scan
// │
// ├── CAMERA VIEW
// │   │
// │   ├── Full-screen camera preview
// │   │
// │   ├── Auto-Detection Overlay
// │   │   ├── Edge detection running continuously
// │   │   ├── When document detected:
// │   │   │   ├── Highlight edges with overlay
// │   │   │   ├── Show "Document Detected ✓"
// │   │   │   └── Auto-capture option (if enabled)
// │   │   │
// │   │   └── When no document:
// │   │       └── Show guide frame
// │   │
// │   ├── Controls
// │   │   ├── Flash Toggle (Auto/On/Off)
// │   │   ├── Gallery Button → Pick from photos
// │   │   └── Auto-detect Toggle
// │   │
// │   └── Capture Button
// │       └── ON TAP → Capture image
// │
// ├── POST-CAPTURE PROCESSING
// │   │
// │   ├── Show captured image
// │   │
// │   ├── Editing Tools
// │   │   ├── Crop Handles → Adjust corners
// │   │   ├── Rotate Button → Rotate 90°
// │   │   ├── Filter Options:
// │   │   │   ├── Original
// │   │   │   ├── Black & White
// │   │   │   ├── Enhanced
// │   │   │   └── Document (high contrast)
// │   │   │
// │   │   └── Retake Button → Return to camera
// │   │
// │   └── Action Buttons
// │       │
// │       ├── "Save as Image" → Add to current context (note/gallery)
// │       │
// │       └── "Extract Text →" → Navigate to OCR Text Extraction
// │
// └── MULTI-PAGE SCANNING (optional)
//     ├── "Add Page" button → Capture another
//     ├── Page thumbnails strip
//     └── Reorder/delete pages
// Algorithm 11.1: OCR Text Extraction Flow
// text

// SCREEN: OCR Text Extraction
// │
// ├── ENTRY POINT
// │   └── From Document Scan → "Extract Text"
// │
// ├── PROCESSING STATE
// │   ├── Show "Extracting text..." with progress
// │   └── Run ML Kit OCR on image
// │
// ├── RESULTS STATE
// │   │
// │   ├── Split View
// │   │   ├── TOP: Scanned Image (with highlight regions)
// │   │   └── BOTTOM: Extracted Text (editable)
// │   │
// │   ├── Extracted Text Area
// │   │   ├── Display recognized text
// │   │   ├── User can edit/correct
// │   │   └── Show confidence indicator
// │   │
// │   ├── AI DETECTION (optional)
// │   │   ├── Detect action items → "☑ Found 2 action items"
// │   │   ├── Detect dates → "📅 Found 1 date mention"
// │   │   └── "Apply AI Suggestions" button
// │   │       ├── ON TAP → Create todos from action items
// │   │       └── Create reminders from dates
// │   │
// │   └── Actions
// │       │
// │       ├── "📋 Copy Text" → Copy to clipboard
// │       │
// │       ├── "✏️ Edit" → Make text editable
// │       │
// │       ├── "💾 Save as Note"
// │       │   ├── Create new note with extracted text
// │       │   ├── Attach scanned image
// │       │   └── Navigate to Note Editor
// │       │
// │       └── "Insert into Current Note" (if came from note)
// │           ├── Append text to note content
// │           ├── Optionally attach image
// │           └── Return to Note Editor
// │
// └── FAILURE STATE
//     ├── Show "Could not extract text"
//     ├── Suggestions: "Try a clearer image"
//     └── "Retry" button → Process again
// Algorithm 12: Settings & Configuration Flow
// text

// SCREEN: Settings
// │
// ├── ENTRY POINTS
// │   ├── From Main Home → Profile icon
// │   ├── From any screen → Drawer → Settings
// │   └── From Command Palette → "Settings"
// │
// ├── SECTIONS
// │   │
// │   ├── ACCOUNT SECTION
// │   │   ├── Profile Settings Row
// │   │   │   └── ON TAP → Navigate to Profile Editor
// │   │   └── (Future: Cloud Sync settings)
// │   │
// │   ├── APPEARANCE SECTION
// │   │   │
// │   │   ├── Theme Row
// │   │   │   ├── Display current theme
// │   │   │   └── ON TAP → Show Theme Picker Sheet
// │   │   │       ├── System (auto)
// │   │   │       ├── Light
// │   │   │       ├── Dark
// │   │   │       ├── Ocean
// │   │   │       ├── Forest
// │   │   │       ├── Sunset
// │   │   │       └── Midnight
// │   │   │
// │   │   ├── Font Family Row
// │   │   │   └── ON TAP → Navigate to Font Settings
// │   │   │
// │   │   └── Font Size Slider
// │   │       ├── Range: 0.8x to 1.5x
// │   │       └── Real-time preview
// │   │
// │   ├── SECURITY SECTION
// │   │   │
// │   │   ├── Biometric Lock Toggle
// │   │   │   └── ON ENABLE → Navigate to Biometric Lock Setup
// │   │   │
// │   │   ├── Auto-lock Timer Row
// │   │   │   └── ON TAP → Show options (1/5/15/30 min / Never)
// │   │   │
// │   │   └── Change PIN Row
// │   │       └── ON TAP → Navigate to PIN Setup
// │   │
// │   ├── NOTIFICATIONS SECTION
// │   │   │
// │   │   ├── Enable Notifications Toggle
// │   │   │
// │   │   ├── Sound Picker Row
// │   │   │   └── ON TAP → Show sound options
// │   │   │
// │   │   ├── Vibration Toggle
// │   │   │
// │   │   └── Quiet Hours Row
// │   │       └── ON TAP → Configure quiet hours (start/end time)
// │   │
// │   ├── VOICE SECTION
// │   │   │
// │   │   ├── Voice Language Row
// │   │   │   └── ON TAP → Navigate to Voice Settings
// │   │   │
// │   │   ├── Voice Commands Toggle
// │   │   │
// │   │   └── Audio Feedback Toggle
// │   │
// │   ├── DATA & STORAGE SECTION
// │   │   │
// │   │   ├── Backup & Export Row
// │   │   │   └── ON TAP → Navigate to Backup Export Screen
// │   │   │
// │   │   ├── Storage Used Display
// │   │   │   └── Show "256 MB used"
// │   │   │
// │   │   └── Clear Cache Row
// │   │       ├── Show cache size
// │   │       └── ON TAP → Clear cache with confirmation
// │   │
// │   ├── INTEGRATIONS SECTION
// │   │   │
// │   │   ├── Calendar Integration Row
// │   │   │   └── ON TAP → Navigate to Calendar Integration
// │   │   │
// │   │   └── Home Screen Widgets Row
// │   │       └── ON TAP → Navigate to Home Widgets
// │   │
// │   └── ABOUT SECTION
// │       │
// │       ├── Version Display
// │       │
// │       ├── Privacy Policy Row
// │       │   └── ON TAP → Open privacy policy (in-app or browser)
// │       │
// │       ├── Terms of Service Row
// │       │   └── ON TAP → Open terms
// │       │
// │       ├── Rate App Row
// │       │   └── ON TAP → Open app store rating
// │       │
// │       └── Contact Support Row
// │           └── ON TAP → Open email composer
// │
// └── DEVELOPER OPTIONS (if enabled)
//     ├── Test All Screens → Navigate to Test Links Screen
//     ├── Reset Onboarding
//     └── Clear All Data (with confirmation)
// Algorithm 12.1: Backup & Export Flow
// text

// SCREEN: Backup & Export
// │
// ├── ENTRY POINT
// │   └── From Settings → "Backup & Export"
// │
// ├── BACKUP STATUS SECTION
// │   ├── Last Backup Date/Time
// │   ├── Backup Size
// │   └── Items count (notes, todos, reminders)
// │
// ├── EXPORT OPTIONS SECTION
// │   │
// │   ├── "📦 Full Backup (ZIP)" Card
// │   │   ├── Description: "All data + media files"
// │   │   └── "Export Full Backup" Button
// │   │       ├── ON TAP → Generate ZIP file
// │   │       ├── Include: Database + media files
// │   │       ├── Show progress indicator
// │   │       └── ON COMPLETE → Share sheet / Save to files
// │   │
// │   ├── "📝 Notes Only" Card
// │   │   ├── Format Selector: Markdown / Text / PDF / HTML
// │   │   └── "Export Notes" Button
// │   │       └── ON TAP → Generate selected format, share
// │   │
// │   └── "📊 Data Only (No Media)" Card
// │       ├── Description: "Database export (JSON)"
// │       └── "Export Data" Button
// │
// ├── IMPORT / RESTORE SECTION
// │   │
// │   ├── "📂 Import from File" Button
// │   │   └── ON TAP → Open file picker
// │   │       ├── Select backup file (ZIP/JSON)
// │   │       ├── Validate file format
// │   │       └── Show import options
// │   │
// │   └── Import Options
// │       ├── Radio: "Merge with existing data"
// │       │   └── Keep current + add imported (dedupe by ID)
// │       │
// │       └── Radio: "Replace all data (destructive)"
// │           ├── Show warning dialog
// │           └── IF CONFIRM → Clear all, import fresh
// │
// └── CLOUD BACKUP (Future)
//     ├── Google Drive integration
//     ├── Auto-backup scheduling
//     └── Sync across devices
// 🔗 Cross-Module Data Sharing
// Algorithm: Note-Reminder Bidirectional Linking
// text

// CONCEPT: Notes and Reminders are Linked Bidirectionally
// │
// ├── DATA MODEL
// │   │
// │   ├── Note Entity
// │   │   ├── id: UUID
// │   │   ├── title: String
// │   │   ├── content: String
// │   │   ├── linkedReminderIds: List<UUID>  ← References to reminders
// │   │   └── ...other fields
// │   │
// │   └── Reminder Entity
// │       ├── id: UUID
// │       ├── message: String
// │       ├── scheduledAt: DateTime
// │       ├── linkedNoteId: UUID?  ← Reference to note
// │       └── ...other fields
// │
// ├── CREATING LINK FROM NOTE
// │   │
// │   ├── User is in Note Editor
// │   ├── User taps "Add Reminder" button
// │   │
// │   ├── OPTION A: Create New Reminder
// │   │   ├── Open Reminder Creation Sheet
// │   │   ├── Pre-fill title with note title
// │   │   ├── User sets time/date
// │   │   ├── Save reminder with linkedNoteId = note.id
// │   │   ├── Add reminder.id to note.linkedReminderIds
// │   │   └── Save both to database
// │   │
// │   └── OPTION B: Link Existing Reminder
// │       ├── Show list of unlinked reminders
// │       ├── User selects reminder
// │       ├── Set reminder.linkedNoteId = note.id
// │       ├── Add reminder.id to note.linkedReminderIds
// │       └── Save both to database
// │
// ├── CREATING LINK FROM REMINDER
// │   │
// │   ├── User is in Reminder Editor
// │   ├── User taps "Link to Note" button
// │   │
// │   ├── OPTION A: Create New Note
// │   │   ├── Navigate to Note Editor (create mode)
// │   │   ├── User creates note
// │   │   ├── On save: Set reminder.linkedNoteId = newNote.id
// │   │   ├── Add reminder.id to note.linkedReminderIds
// │   │   └── Return to Reminder Editor
// │   │
// │   └── OPTION B: Link Existing Note
// │       ├── Show Note Selector (search/list)
// │       ├── User selects note
// │       ├── Set reminder.linkedNoteId = note.id
// │       ├── Add reminder.id to note.linkedReminderIds
// │       └── Save both
// │
// ├── DISPLAYING LINKED ITEMS
// │   │
// │   ├── IN NOTE EDITOR
// │   │   ├── Query: Get reminders WHERE id IN note.linkedReminderIds
// │   │   ├── Display linked reminders section
// │   │   ├── Each reminder shows: time, status
// │   │   └── ON TAP reminder → Navigate to Reminder Editor
// │   │
// │   ├── IN NOTES LIST
// │   │   ├── IF note.linkedReminderIds.isNotEmpty
// │   │   │   └── Display 🔔 badge/icon on note card
// │   │   └── Show next reminder time in preview
// │   │
// │   ├── IN REMINDER EDITOR
// │   │   ├── IF reminder.linkedNoteId != null
// │   │   │   ├── Query: Get note WHERE id == reminder.linkedNoteId
// │   │   │   ├── Display note preview
