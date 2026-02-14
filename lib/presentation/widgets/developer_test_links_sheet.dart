import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../design_system/design_system.dart';

/// Developer Test Links Sheet
/// Quick navigation to all 25+ screens for testing
/// Only visible in developer mode (Settings page)
class DeveloperTestLinksSheet extends StatelessWidget {
  const DeveloperTestLinksSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final testRoutes = [
      // ===== MAIN NAVIGATION (6) =====
      _TestRoute('🏠 Home / Today Dashboard', AppRoutes.todayDashboard),

      // Purpose: The starting landing page showing daily overview, active tasks, reminders, and streaks.
      // Flow: Launch -> Splash -> Onboarding -> TodayDashboard.
      // Navigate via: App Launch or BottomNav 'Home' tab.
      // Data Passed: None (Uses Providers/Blocs).
      // Database: Reads from SQLite (Notes/Todos) and Isar (Reminders).
      // Interactions:
      // • Daily Streak Card (Tap -> Analytics)
      // • 'Quick Actions' Row (Tap -> Create Note/Todo/Reminder)
      // • Recent Activity List (Tap Item -> Editor)
      // • Profile Icon (Tap -> Settings)
      // • Search Icon (Tap -> Global Search)
      _TestRoute('🏡 Main Home', AppRoutes.mainHome),

      // Purpose: The primary shell containing the bottom navigation bar and managing top-level views.
      // Flow: Parent widget for Dashboard, Notes, Todos, Reminders.
      // Navigate via: Automatically wraps main screens.
      // Data Passed: initialIndex (int) - Optional, default 0.
      // Database: None (UI Shell).
      // Interactions:
      // • Bottom Navigation Bar (Tap Tabs -> Switch Views)
      // • Floating Action Button (Tap -> Quick Add Sheet)
      // • Drawer Menu (if enabled) (Tap Hamburger -> Advanced Nav)
      _TestRoute('📝 Notes List (Enhanced)', AppRoutes.notesList),

      // Purpose: Displays all user notes with advanced filtering, search, and categorization options.
      // Flow: BottomNav 'Notes' tab.
      // Navigate via: Tap 'Notes' icon in Bottom Navigation Bar.
      // Data Passed: None.
      // Database: NotesBloc -> Repository -> SQLite (Notes Table).
      // Interactions:
      // • Note Cards (Tap -> Note Editor)
      // • Filter Chips (Tap -> Filter List)
      // • View Toggle (List/Grid)
      // • Search Bar (Tap -> Search Mode)
      // • FAB (Tap -> Create New Note)
      _TestRoute('✅ Todos List', AppRoutes.todosList),

      // Purpose: A comprehensive list of tasks and to-dos, supporting priorities, deadlines, and completion states.
      // Flow: BottomNav 'Todos' tab.
      // Navigate via: Tap 'Todos' icon in Bottom Navigation Bar.
      // Data Passed: None.
      // Database: TodosBloc -> Repository -> SQLite (Todos Table).
      // Interactions:
      // • Checkbox (Tap -> Complete Task)
      // • Task Body (Tap -> Task Details)
      // • Star Icon (Tap -> Mark Important)
      // • Sort Button (Tap -> Sort Options)
      // • FAB (Tap -> Create New Todo)
      _TestRoute('⏰ Reminders List', AppRoutes.remindersList),

      // Purpose: Manages all scheduled reminders, alarms, and notifications for the user.
      // Flow: BottomNav 'Reminders' tab.
      // Navigate via: Tap 'Reminders' icon in Bottom Navigation Bar.
      // Data Passed: None.
      // Database: AlarmsBloc -> Repository -> SQLite/Isar.
      // Interactions:
      // • 'All', 'Scheduled', 'Today' Tabs (Tap -> Filter View)
      // • Reminder Item (Tap -> Edit Reminder)
      // • Toggle Switch (Tap -> Enable/Disable)
      // • 'AI Insights' Button (Tap -> Integrated Features)
      _TestRoute('⚙️ Settings', AppRoutes.settings),
      // Purpose: Global application settings including theme, language, and account preferences.
      // Flow: Profile Icon -> Settings.
      // Navigate via: Tap User/Profile icon in Top Bar of Home/Dashboard.
      // Data Passed: None.
      // Database: SettingsBloc -> SharedPreferences/Hive.
      // Interactions:
      // • List Tiles (Tap -> Sub-settings screens)
      // • Theme Toggle (Switch -> Dark/Light Mode)
      // • 'Log Out' Button (Tap -> Authentication)
      // • 'Developer Mode' (Tap -> Test Links)

      // ===== NOTE SCREENS (5) =====
      _TestRoute('✏️ Note Editor', AppRoutes.noteEditor),

      // Purpose: The main interface for creating and editing individual notes.
      // Flow: Notes List -> Tap FAB (+) or Tap existing Note.
      // Navigate via: Floating Action Button in Notes List.
      // Data Passed: Note (optional) or Map with 'content'.
      // Database: CRUD operations via NotesBloc.
      // Interactions:
      // • Title/Body Fields (Input -> Text)
      // • Back Button (Tap -> Save & Exit)
      // • Attachment Icon (Tap -> Media Picker/Camera/Audio)
      // • 'More' Menu (Tap -> Delete, Share, Archive)
      _TestRoute('📄 Advanced Note Editor', AppRoutes.advancedNoteEditor),

      // Purpose: An enhanced editor with rich text capabilities, media embedding, and formatting tools.
      // Flow: Note Editor -> 'Expand' / 'Full Screen'.
      // Navigate via: Toggle in standard editor or Settings configuration.
      // Data Passed: Note object (for editing).
      // Database: Updates rich text content in SQLite.
      // Interactions:
      // • Formatting Toolbar (Bold, Italic, Lists)
      // • Insert Block (Tap -> Add Image/Table/Divider)
      // • 'Read Mode' Toggle (Tap -> Disable Editing)
      _TestRoute('📦 Archived Notes', AppRoutes.archivedNotes),

      // Purpose: Access to notes that have been archived and hidden from the main list.
      // Flow: Notes List -> Menu/Drawer -> Archived.
      // Navigate via: Sidebar or Top Menu 'Archived' option.
      // Data Passed: None.
      // Database: Queries notes where isArchived = 1.
      // Interactions:
      // • Archive List (Tap -> View Note)
      // • 'Unarchive' Action (Swipe/Menu -> Restore to Main List)
      _TestRoute('📁 Unified Items Screen', '/unified-items'),

      // Purpose: A consolidated view showing notes, tasks, and reminders in a single timeline or list.
      // Flow: Search Results or Dashboard -> 'See All'.
      // Navigate via: 'All Items' view from Dashboard aggregation.
      // Data Passed: Filter options (optional).
      // Database: Aggregates data from Notes, Todos, and Alarms tables.
      // Interactions:
      // • Item Cards (Tap -> Respective Editor)
      // • Filter Tabs (All, Notes, Todos)
      _TestRoute('❓ Empty Notes Help', AppRoutes.emptyStateNotesHelp),
      // Purpose: A help screen displayed when there are no notes, guiding the user on how to create one.
      // Flow: Notes List (Empty State).
      // Navigate via: Automatically shown when Notes List has 0 items.
      // Data Passed: None.
      // Database: None (Static UI).
      // Interactions:
      // • 'Create First Note' Button (Tap -> Note Editor)
      // • 'Import' Button (Tap -> File Picker)

      // ===== TODO SCREENS (5) =====
      _TestRoute('✅ Todos List', AppRoutes.todosList),

      // Purpose: Repeated entry for the Todos List (same as in Main Navigation).
      // Flow: See 'Todos List' above.
      // Interactions: See above.
      _TestRoute('🎯 Todo Focus Mode', AppRoutes.todoFocus),

      // Purpose: A dedicated mode for focusing on a single task, minimizing distractions.
      // Flow: Todo List -> Tap Focus Icon on a specific task.
      // Navigate via: Action button on Todo Item.
      // Data Passed: Note/Todo object.
      // Database: Updates task status/time spent in DB.
      // Interactions:
      // • Timer Display (Tap -> Pause/Resume)
      // • 'Complete' Button (Tap -> Finish Task & Return)
      // • 'Delay' Button (Tap -> Add 15m)
      _TestRoute('📊 Advanced Todo View', AppRoutes.advancedTodo),

      // Purpose: A detailed view for managing complex tasks with sub-tasks, attachments, and dependencies.
      // Flow: Todo List -> Tap Todo Item (Detailed view).
      // Navigate via: Tapping body of a Todo Item.
      // Data Passed: Note/Todo object.
      // Database: CRUD for task details and sub-tasks.
      // Interactions:
      // • Sub-task List (Tap + -> Add Sub-task)
      // • Due Date Picker (Tap -> Calendar)
      // • Priority Selector (Tap -> Change Low/Med/High)
      _TestRoute('🔄 Recurring Todo Schedule', AppRoutes.recurringTodoSchedule),

      // Purpose: Setup and management screen for recurring tasks (daily, weekly, custom intervals).
      // Flow: Todo Editor -> Due Date -> Repeat.
      // Navigate via: 'Repeat' option during task creation/editing.
      // Data Passed: None (or existing schedule).
      // Database: Saves recurrence rules to DB.
      // Interactions:
      // • Frequency Dropdown (Select Daily/Weekly/Monthly)
      // • Days of Week (Tap M/T/W... to toggle)
      // • 'Save Schedule' Button (Tap -> Apply)
      _TestRoute('❓ Empty Todos Help', AppRoutes.emptyStateTodosHelp),
      // Purpose: A help screen displayed when the todo list is empty.
      // Flow: Todo List (Empty State).
      // Navigate via: Automatically shown when Todo List has 0 items.
      // Data Passed: None.
      // Database: None (Static UI).
      // Interactions:
      // • 'Add Task' Button (Tap -> New Todo Sheet)
      // • 'View Templates' (Tap -> Template Gallery)

      // ===== REFLECTION SCREENS (6) =====
      _TestRoute('🧠 Reflection Home', AppRoutes.reflectionHome),

      // Purpose: The hub for daily reflections, journaling, and tracking mood or progress over time.
      // Flow: Dashboard -> 'Daily Reflection' card or BottomNav (if customized).
      // Navigate via: 'Reflect' button on Today Dashboard.
      // Data Passed: None.
      // Database: Reads Reflection entries and Mood logs from DB.
      // Interactions:
      // • Calendar View (Tap Date -> View Entry)
      // • 'Mood Check-in' (Tap Smiley -> Log Mood)
      // • 'Start Journaling' (Tap -> Editor)
      _TestRoute('📝 Reflection Editor', AppRoutes.reflectionEditor),

      // Purpose: Interface for writing new reflection entries or journal logs.
      // Flow: Reflection Home -> 'New Entry'.
      // Navigate via: '+' button in Reflection Home.
      // Data Passed: Date (optional), existing Entry (optional).
      // Database: Saves text and mood to Reflection table.
      // Interactions:
      // • Text Area (Input -> Journal)
      // • Prompts Carousel (Swipe/Tap -> Select Question)
      // • Save Button (Tap -> Commit Entry)
      _TestRoute('💭 Reflection Answer', AppRoutes.reflectionAnswer),

      // Purpose: Screen for reviewing or answering specific daily reflection prompts.
      // Flow: Reflection Editor -> Select Prompt.
      // Navigate via: Tapping a specific daily question.
      // Data Passed: Question object.
      // Database: Saves answer linked to Question ID.
      // Interactions:
      // • Pre-filled Question (Read Only)
      // • Answer Field (Input -> Text)
      _TestRoute('📜 Reflection History', AppRoutes.reflectionHistory),

      // Purpose: A historical view of all past reflections and journal entries.
      // Flow: Reflection Home -> 'History' / 'Past Entries'.
      // Navigate via: Tab or Link in Reflection Home.
      // Data Passed: None.
      // Database: Queries all Reflection entries, sorted by date.
      // Interactions:
      // • Timeline List (Tap -> View Detail)
      // • Filter by Month (Tap -> Date Picker)
      _TestRoute('🎠 Reflection Carousel', AppRoutes.reflectionCarousel),

      // Purpose: A swipable carousel view to browse through past reflections visually.
      // Flow: Reflection History -> Tap entry (visual mode).
      // Navigate via: Viewing a past entry in detail.
      // Data Passed: Initial Index implies list position.
      // Database: Reads entry content/images.
      // Interactions:
      // • Swipe Left/Right (Nav -> Next/Prev Entry)
      // • 'Share' Button (Tap -> Generate Image)
      _TestRoute('❓ Reflection Questions', AppRoutes.reflectionQuestions),
      // Purpose: Configuration screen to manage custom reflection questions and prompts.
      // Flow: Reflection Home -> Settings (Gear Icon).
      // Navigate via: 'Manage Prompts' in Reflection Settings.
      // Data Passed: None.
      // Database: CRUD on CustomQuestions table.
      // Interactions:
      // • 'Add Custom Question' (Tap -> Input Dialog)
      // • Toggle Default Questions (Switch -> On/Off)

      // ===== FOCUS & PRODUCTIVITY (5) =====
      _TestRoute('⏱️ Focus Session', AppRoutes.focusSession),

      // Purpose: A timer-based focus tool (Pomodoro style) to help users stay productive.
      // Flow: Dashboard or Todo List -> 'Start Focus'.
      // Navigate via: Focus button on a task or main dashboard widget.
      // Data Passed: Task ID (optional).
      // Database: Logs session duration to Analytics DB.
      // Interactions:
      // • Start/Pause/Stop Buttons (Tap -> Control Timer)
      // • Session Settings (Tap -> Adjust Duration/Sound)
      // • Task Selection (Tap -> Associate Task)
      _TestRoute('🎉 Focus Celebration', AppRoutes.focusCelebration),

      // Purpose: A rewarding screen displayed upon successfully completing a focus session.
      // Flow: Focus Session -> Timer Ends.
      // Navigate via: Automatically shown after successful session completion.
      // Data Passed: Session stats (duration, task completed).
      // Database: None (Display only).
      // Interactions:
      // • 'Continue' Button (Tap -> Back to Dashboard)
      // • 'Share Achievement' (Tap -> Social Share)
      _TestRoute('📈 Analytics Dashboard', AppRoutes.analytics),

      // Purpose: Detailed charts and graphs showing productivity stats, task completion rates, and focus time.
      // Flow: Profile -> Analytics or Focus Session -> 'See Stats'.
      // Navigate via: User Profile menu or completion summary.
      // Data Passed: None.
      // Database: Aggregates completion, focus time, and streaks data.
      // Interactions:
      // • Period Selector (Tap -> Week/Month/Year)
      // • Chart Segments (Tap -> View Details)
      _TestRoute('⭐ Daily Highlight Summary', AppRoutes.dailyHighlightSummary),

      // Purpose: View summary of the "Daily Highlight" - the most important task of the day.
      // Flow: Dashboard -> Daily Highlight Card.
      // Navigate via: Tapping the prominent Daily Highlight widget.
      // Data Passed: None.
      // Database: Reads 'highlight' field from UserPrefs or Task DB.
      // Interactions:
      // • 'Mark Complete' (Tap -> Finish Highlight)
      // • 'Change Highlight' (Tap -> Edit)
      _TestRoute('✏️ Edit Daily Highlight', AppRoutes.editDailyHighlight),
      // Purpose: Interface to set or modify the Daily Highlight task.
      // Flow: Dashboard -> Empty Highlight -> 'Set Highlight'.
      // Navigate via: Tapping 'Set Focus for Today' placeholder.
      // Data Passed: Current highlight (if any).
      // Database: Updates highlight setting.
      // Interactions:
      // • Text Input (Type -> Task Name)
      // • Suggestions List (Tap -> Pick from Todo List)

      // ===== SEARCH & FILTERS (8) =====
      _TestRoute('🔍 Global Search', AppRoutes.globalSearch),

      // Purpose: The main search interface to find content across notes, tasks, and reminders.
      // Flow: Home/Dashboard -> Search Icon (Top Bar).
      // Navigate via: Magnifying glass icon in top app bar.
      // Data Passed: None.
      // Database: Full-text search across all tables.
      // Interactions:
      // • Search Bar (Input -> Query)
      // • Result List (Tap -> Navigate to Item)
      // • Filter Chips (Tap -> Refine)
      _TestRoute('🔎 Enhanced Global Search', '/enhanced-global-search'),

      // Purpose: An upgraded search experience with better relevance and faster results.
      // Flow: Global Search -> 'Advanced' tab or explicit toggle.
      // Navigate via: Search screen mode switcher.
      // Data Passed: Initial Query (optional).
      // Database: Optimized FTS query.
      // Interactions:
      // • Multi-select Filters (Tap -> Apply)
      // • Search Suggestions (Tap -> Auto-fill)
      _TestRoute('🔬 Advanced Search', AppRoutes.advancedSearch),

      // Purpose: A power-user search screen allowing complex queries and boolean operators.
      // Flow: Integrated Features -> AI & Insights -> Advanced Search.
      // Navigate via: 'Advanced Search' card in Integrated Features.
      // Data Passed: None.
      // Database: Parses complex query string -> SQL.
      // Interactions:
      // • Query Builder (Tap + -> Add Condition)
      // • Date Range Picker (Tap -> Select Dates)
      // • 'Run Search' Button (Tap -> Execute)
      _TestRoute('📊 Search Results', AppRoutes.searchResults),

      // Purpose: Displays the output of a search query, with options to refine or sort.
      // Flow: Global Search -> Enter Query -> Submit.
      // Navigate via: Pressing enter/search on query input.
      // Data Passed: Search Query String.
      // Database: Fetches results based on passed query.
      // Interactions:
      // • Sort Dropdown (Select -> Reorder)
      // • Item Cards (Tap -> Open)
      _TestRoute('🎛️ Search Filter', AppRoutes.searchFilter),

      // Purpose: UI for applying specific filters (date, tag, type) to list views.
      // Flow: Search Results -> Filter Icon.
      // Navigate via: Filter button on results page.
      // Data Passed: Current Filters.
      // Database: None (Returns filter object).
      // Interactions:
      // • Checkboxes (Select -> Deselect)
      // • 'Apply' Button (Tap -> Update Results)
      _TestRoute('⚡ Search Operators', AppRoutes.searchOperators),

      // Purpose: Documentation or helper screen explaining available search operators (AND, OR, NOT).
      // Flow: Advanced Search -> Help / Info Icon.
      // Navigate via: 'How to search' tooltip or link.
      // Interactions:
      // • Example Chips (Tap -> Copy to Clipboard)
      _TestRoute('🎨 Advanced Filters', AppRoutes.advancedFilters),

      // Purpose: Configuration for saving and applying complex reusable filter sets.
      // Flow: Search Filter -> 'Save Filter Preset'.
      // Navigate via: Manage filters section.
      // Interactions:
      // • 'Save Current' Button (Tap -> Name & Save)
      // • Preset List (Tap -> Apply Preset)
      _TestRoute('🔀 Sort Customization', AppRoutes.sortCustomization),
      // Purpose: Settings to customize how items are sorted (alphabetical, date modified, priority).
      // Flow: Lists (Notes/Todos) -> Sort Icon.
      // Navigate via: Sort button in header of any list view.
      // Data Passed: Current Sort Preference.
      // Database: Updates Sort Preferences.
      // Interactions:
      // • Drag Handle (Drag -> Reorder Criteria)
      // • Asc/Desc Toggle (Tap -> Switch Direction)

      // ===== SMART COLLECTIONS (4) =====
      _TestRoute('📚 Smart Collections', AppRoutes.smartCollections),

      // Purpose: Overview of dynamic collections based on rules (e.g., "High Priority Work").
      // Flow: Menu/Sidebar -> Collections.
      // Navigate via: Main application drawer or settings.
      // Data Passed: None.
      // Database: Fetches all Collections from DB.
      // Interactions:
      // • Collection Grid (Tap -> Open Collection)
      // • Back Button (Tap -> Dashboard)
      _TestRoute('➕ Create Collection', AppRoutes.createCollection),

      // Purpose: Wizard to create a new smart collection.
      // Flow: Smart Collections -> FAB (+).
      // Navigate via: 'Add Collection' button.
      // Data Passed: None.
      // Database: Creates new Collection entry.
      // Interactions:
      // • Name Input (Type -> Name)
      // • Icon Picker (Tap -> Select Icon)
      // • 'Next' Button (Tap -> Rule Builder)
      _TestRoute('🔧 Rule Builder', AppRoutes.ruleBuilder),

      // Purpose: Interface to define the logic and criteria for smart collections.
      // Flow: Create Collection -> 'Define Rules'.
      // Navigate via: Step 2 of collection creation wizard.
      // Data Passed: Draft Collection object.
      // Database: None (Validation only).
      // Interactions:
      // • 'Add Rule' (Tap -> New Condition Row)
      // • Logic Toggle (AND/OR) (Tap -> Switch)
      _TestRoute(' Collection Details', AppRoutes.collectionDetails),
      // Purpose: Detailed view of items contained within a specific smart collection.
      // Flow: Smart Collections -> Tap Collection Item.
      // Navigate via: Tapping a collection card.
      // Data Passed: Collection ID/Object.
      // Database: Dynamically queries items matching Rules.
      // Interactions:
      // • Item List (Tap -> Open Item)
      // • 'Edit Rules' (Tap -> Modify Collection)

      // ===== REMINDERS & ALARMS (10) =====
      _TestRoute('⏰ Reminders List', AppRoutes.remindersList),

      // Purpose: Repeated entry for Reminders List.
      // Flow: See 'Reminders List' above.
      _TestRoute('🔔 Alarms', AppRoutes.alarms),

      // Purpose: Management screen for standard wake-up or time-based alarms.
      // Flow: Reminders List -> 'Alarms' Tab.
      // Navigate via: Segmented control in Reminders screen.
      // Data Passed: None.
      // Database: CRUD Alarms table.
      // Interactions:
      // • Alarm Toggle (Switch -> On/Off)
      // • FAB (Tap -> Set Alarm)
      _TestRoute('📅 Calendar Integration', AppRoutes.calendarIntegration),

      // Purpose: View to sync and display events from external calendars.
      // Flow: Settings -> Integrations -> Calendar.
      // Navigate via: Setup flow for calendar sync.
      // Data Passed: None.
      // Database: Stores OAuth tokens (securely).
      // Interactions:
      // • 'Connect Google Calendar' (Tap -> Auth Flow)
      // • Sync Toggle (Switch -> Enable/Disable)
      _TestRoute('🤖 Smart Reminders', AppRoutes.smartReminders),

      // Purpose: Intelligent reminders that trigger based on context or probability.
      // Flow: Reminders -> 'Smart' Section.
      // Navigate via: Special section in Reminders List.
      // Data Passed: None.
      // Database: Reads user patterns to generate suggestions.
      // Interactions:
      // • 'Enable AI Suggestions' (Switch -> On/Off)
      // • List of Suggestions (Tap -> Accept/Reject)
      _TestRoute(' Location Reminder', AppRoutes.locationReminder),

      // Purpose: Setup screen for reminders triggered by entering or leaving a geofence.
      // Flow: Reminder Editor -> 'Location' Trigger.
      // Navigate via: Selecting 'Location' instead of 'Time.
      // Data Passed: Reminder Object.
      // Database: Saves coordinates and radius.
      // Interactions:
      // • Map View (Pan/Zoom -> Select Spot)
      // • Search Place (Input -> Find Location)
      // • Radius Slider (Slide -> Adjust Geofence)
      _TestRoute(
        '🗺️ Location Reminder (Coming Soon)',
        AppRoutes.locationReminderComingSoon,
      ),

      // Purpose: Placeholder for upcoming location-based features.
      // Flow: Integrated Features -> Location Demo.
      // Navigate via: Future feature preview.
      // Data Passed: None.
      // Database: None.
      // Interactions:
      // • 'Notify Me When Available' (Tap -> Subscribe)
      _TestRoute('📌 Saved Locations', AppRoutes.savedLocations),

      // Purpose: Manage favorite or frequently used locations for reminders.
      // Flow: Location Reminder -> 'Saved Places'.
      // Navigate via: Managing pinned locations.
      // Data Passed: None.
      // Database: CRUD SavedLocations table.
      // Interactions:
      // • 'Add Home/Work' (Tap -> Quick Save)
      // • List Items (Swipe -> Delete)
      _TestRoute('📝 Reminder Templates', AppRoutes.reminderTemplates),

      // Purpose: Create and manage templates for quickly setting common reminders.
      // Flow: Reminders -> Menu -> Templates.
      // Navigate via: 'Manage Templates' option.
      // Data Passed: None.
      // Database: CRUD ReminderTemplates table.
      // Interactions:
      // • Template Card (Tap -> Use)
      // • 'Create Template' (Tap -> Editor)
      _TestRoute(
        '💡 Suggestion Recommendations',
        AppRoutes.suggestionRecommendations,
      ),

      // Purpose: AI-driven suggestions for tasks or reminders based on user habits.
      // Flow: Integrated Features -> AI & Insights -> Smart Recommendations.
      // Navigate via: 'Smart Recommendations' card in Integrated Features Hub.
      // Data Passed: Usage context (implicit).
      // Database: Analyzes historical data to inference.
      // Interactions:
      // • Suggestion Card (Swipe Right -> Apply, Left -> Dismiss)
      _TestRoute('📊 Reminder Patterns', AppRoutes.reminderPatterns),
      // Purpose: Visual analysis of when and how often reminders are set or completed.
      // Flow: Integrated Features -> AI & Insights -> Reminder Patterns.
      // Navigate via: 'Reminder Patterns' card in Integrated Features Hub.
      // Data Passed: Time range.
      // Database: Aggregates timestamp data from Alarms.
      // Interactions:
      // • Time of Day Chart (Tap -> Segment Detail)

      // ===== ANALYTICS & INSIGHTS (3) =====
      _TestRoute('📊 Frequency Analytics', AppRoutes.frequencyAnalytics),

      // Purpose: Breakdown of how frequently the app or specific features are used.
      // Flow: Analytics Dashboard -> 'Frequency'.
      // Navigate via: Drill-down from main analytics.
      // Data Passed: None.
      // Database: Reads usage logs.
      // Interactions:
      // • Tab Switcher (Day/Week/Month)
      _TestRoute('📈 Engagement Metrics', AppRoutes.engagementMetrics),

      // Purpose: Metrics showing user engagement depth and retention.
      // Flow: Analytics Dashboard -> 'Engagement'.
      // Navigate via: Drill-down from main analytics.
      // Data Passed: None.
      // Database: Aggregates session data.
      // Interactions:
      // • Score Display (Tap -> Explanation)
      _TestRoute('📉 Media Analytics', AppRoutes.mediaAnalytics),
      // Purpose: Stats regarding the types and volume of media stored in the app.
      // Flow: Profile -> Storage / Media.
      // Navigate via: Storage management screen.
      // Data Passed: None.
      // Database: Scans file system / media store.
      // Interactions:
      // • 'Clear Cache' Button (Tap -> Free Space)
      // • Category Pie Chart (Tap -> Filter Media)

      // ===== MEDIA & ATTACHMENTS (10) =====
      _TestRoute('📷 Media Picker', AppRoutes.mediaPicker),

      // Purpose: Interface to select photos or videos from the device library.
      // Flow: Note/Todo Editor -> Attach Icon -> 'Photo/Video'.
      // Navigate via: Attachment action sheet.
      // Data Passed: Selection limit, type filter.
      // Database: None (Device Storage).
      // Interactions:
      // • Grid Images (Tap -> Multi-select)
      // • 'Done' Button (Tap -> Attach)
      _TestRoute('🎙️ Audio Recorder', AppRoutes.audioRecorder),

      // Purpose: Tool for recording voice notes or audio clips.
      // Flow: Note Editor -> Attach Icon -> 'Audio' -> Record.
      // Navigate via: Microphone button in editor.
      // Data Passed: Output path (optional).
      // Database: Saves file metadata to DB.
      // Interactions:
      // • Record/Stop Button (Tap -> Toggle)
      // • Playback Controls (Tap -> Preview)
      _TestRoute('🖼️ Full Media Gallery', AppRoutes.fullMediaGallery),

      // Purpose: A comprehensive gallery view of all media assets in the app.
      // Flow: Integrated Features -> Media Gallery.
      // Navigate via: 'Media Gallery' tab in Integrated Features.
      // Data Passed: Filter/Sort options.
      // Database: Queries MediaItems table.
      // Interactions:
      // • Media Grid (Tap -> Viewer)
      // • Select Mode (Long Press -> Manage)
      _TestRoute('🎬 Video Trimming', AppRoutes.videoTrimming),

      // Purpose: Editor to trim and adjust video clips.
      // Flow: Media Gallery -> Open Video -> Edit.
      // Navigate via: Edit button on video preview.
      // Data Passed: Video File Path.
      // Database: None (ffmpeg processing).
      // Interactions:
      // • Trimmer Handle (Drag -> Set Start/End)
      // • 'Save Copy' (Tap -> Export)
      _TestRoute('👁️ Media Viewer', AppRoutes.mediaViewer),

      // Purpose: Full-screen viewer for images and videos.
      // Flow: Media Gallery/Note -> Tap Image.
      // Navigate via: Tapping any media thumbnail.
      // Data Passed: List of MediaItems, Initial Index.
      // Database: None.
      // Interactions:
      // • Swipe (Left/Right -> Prev/Next)
      // • Share Icon (Tap -> Share Sheet)
      _TestRoute('🎨 Media Filter', AppRoutes.mediaFilter),

      // Purpose: Apply visual filters and effects to images.
      // Flow: Media Viewer -> Edit -> Filters.
      // Navigate via: Filter tool in image editor.
      // Data Passed: Image Path.
      // Database: None.
      // Interactions:
      // • Filter Carousel (Tap -> Apply Effect)
      // • Intensity Slider (Drag -> Adjust)
      _TestRoute('📁 Media Organization', AppRoutes.mediaOrganization),

      // Purpose: Tools to organize media into folders or albums.
      // Flow: Full Media Gallery -> 'Organize' / 'Albums'.
      // Navigate via: Management mode in gallery.
      // Data Passed: None.
      // Database: Updates Media Folder structure.
      // Interactions:
      // • 'New Folder' (Tap -> Create)
      // • Drag & Drop (Drag -> Move Files)
      _TestRoute('🔍 Media Search Results', AppRoutes.mediaSearchResults),

      // Purpose: Results view specifically for media searches.
      // Flow: Full Media Gallery -> Search.
      // Navigate via: Search bar within gallery context.
      // Data Passed: Search Query.
      // Database: Queries MediaItems metadata.
      // Interactions:
      // • Result Grid (Tap -> Open)
      _TestRoute('📸 Document Scan', AppRoutes.documentScan),

      // Purpose: Camera interface optimized for scanning physical documents.
      // Flow: Note Editor -> Attach -> 'Scan Document'.
      // Navigate via: Scanner option in attachment menu.
      // Data Passed: None.
      // Database: None (Camera API).
      // Interactions:
      // • Capture Button (Tap -> Take Photo)
      // • Crop Handles (Drag -> Adjust Corners)
      _TestRoute('✨ OCR Text Extraction', AppRoutes.ocrExtraction),
      // Purpose: Tool to extract text from images using Optical Character Recognition.
      // Flow: Document Scan -> 'Extract Text'.
      // Navigate via: Post-scan processing option.
      // Data Passed: Image Path.
      // Database: None (ML Kit).
      // Interactions:
      // • 'Copy to Note' (Tap -> Insert)

      // ===== DOCUMENT & CREATIVE (3) =====
      _TestRoute('🎨 Drawing Canvas', AppRoutes.drawingCanvas),

      // Purpose: A freeform canvas for sketching, drawing, and handwritten notes.
      // Flow: Note Editor -> Attach -> 'Sketch'.
      // Navigate via: Drawing option in attachment menu.
      // Data Passed: Existing drawing (optional).
      // Database: Saves as image file + metadata.
      // Interactions:
      // • Pen/Brush/Eraser (Tap -> Select Tool)
      // • Color Palette (Tap -> Change Color)
      _TestRoute('📄 PDF Preview', AppRoutes.pdfPreview),

      // Purpose: Viewer for PDF documents.
      // Flow: Note -> Tap PDF Attachment.
      // Navigate via: Opening a PDF file.
      // Data Passed: PDF File Path.
      // Database: None.
      // Interactions:
      // • Page Scroller (Scroll -> Navigate)
      // • Search Icon (Tap -> Find Text)
      _TestRoute('✍️ PDF Annotation', AppRoutes.pdfAnnotation),
      // Purpose: Tools to highlight, draw on, and annotate PDF files.
      // Flow: PDF Preview -> 'Annotate'.
      // Navigate via: Edit mode in PDF viewer.
      // Data Passed: PDF PDF Path.
      // Database: Saves annotations to file.
      // Interactions:
      // • Marker Tool (Drag -> Highlight Text)
      // • 'Save' (Tap -> Overwrite File)

      // ===== TEMPLATES (2) =====
      _TestRoute('🎨 Template Gallery', AppRoutes.templateGallery),

      // Purpose: A library of pre-made templates for notes and tasks.
      // Flow: Integrated Features -> AI & Insights -> Template Gallery.
      // Navigate via: 'Template Gallery' card in Integrated Features Hub.
      // Data Passed: None.
      // Database: Reads static/dynamic templates.
      // Interactions:
      // • Category Tabs (Tap -> Filter)
      // • Template Preview (Tap -> See Detail)
      // • 'Use Template' (Tap -> Clone to Editor)
      _TestRoute('✏️ Template Editor', AppRoutes.templateEditor),
      // Purpose: Builder to create new custom templates.
      // Flow: Template Gallery -> 'Create New'.
      // Navigate via: FAB in Template Gallery.
      // Data Passed: Template ID (optional).
      // Database: Saves new Template definition.
      // Interactions:
      // • Variable Placeholder (Tap -> Insert Dynamic Field)
      // • Save (Tap -> Add to Gallery)

      // ===== QUICK ACTIONS (3) =====
      _TestRoute('🚀 Quick Add', AppRoutes.quickAdd),

      // Purpose: Fast interface to add a new item without navigating away.
      // Flow: Enhanced Reminders -> 'Quick Add'.
      // Navigate via: Quick Add button in reminders header.
      // Data Passed: Context/Parent ID.
      // Database: Creates new Note/Todo/Reminder.
      // Interactions:
      // • Input Field (Type -> Content)
      // • 'Add' Icon (Tap -> Confirm)
      _TestRoute('✅ Quick Add Confirmation', AppRoutes.quickAddConfirmation),

      // Purpose: Feedback screen confirming an item was successfully added.
      // Flow: Quick Add -> Save -> Success.
      // Navigate via: Automatically shown after successful quick add.
      // Data Passed: Created Item ID.
      // Database: None.
      // Interactions:
      // • 'Undo' Button (Tap -> Revert)
      // • 'View Item' (Tap -> Go to Details)
      _TestRoute('⚡ Universal Quick Add', AppRoutes.universalQuickAdd),
      // Purpose: A powerful input bar that accepts natural language to create various items.
      // Flow: Global Command Palette -> Type Command.
      // Navigate via: Shortcut (e.g., Ctrl+K) or Shake-to-add.
      // Data Passed: None.
      // Database: AI parsing -> DB creation.
      // Interactions:
      // • Command List (Scroll -> Browse)
      // • Enter (Tap -> Execute Command)

      // ===== SETTINGS & PREFERENCES (8) =====
      _TestRoute('⚙️ Settings', AppRoutes.settings),

      // Purpose: Repeated entry for Settings.
      // Flow: See 'Settings' above.
      _TestRoute('🎨 Advanced Settings', AppRoutes.advancedSettings),

      // Purpose: Granular configuration options for power users.
      // Flow: Settings -> 'Advanced'.
      // Navigate via: Advanced section in main settings.
      // Data Passed: None.
      // Database: Writes to SharedPrefs.
      // Interactions:
      // • Sliders/Switches (Interact -> Adjust UX)
      _TestRoute('🎤 Voice Settings', AppRoutes.voiceSettings),

      // Purpose: Settings for voice control and text-to-speech features.
      // Flow: Settings -> 'Voice & Input'.
      // Navigate via: Voice section in main settings.
      // Data Passed: None.
      // Database: Writes to SharedPrefs.
      // Interactions:
      // • Language Selector (Tap -> Pick Language)
      _TestRoute(' Font Settings', AppRoutes.fontSettings),

      // Purpose: Customize typography, font sizes, and text styles.
      // Flow: Settings -> 'Appearance' -> 'Typography'.
      // Navigate via: Font config in Appearance settings.
      // Data Passed: None.
      // Database: Writes to SharedPrefs.
      // Interactions:
      // • Font Size Slider (Drag -> Scale Text)
      // • Font Family (Tap -> Change Typeface)
      _TestRoute('🏷️ Tag Management', AppRoutes.tagManagement),

      // Purpose: Manage the taxonomy of tags used across the app.
      // Flow: Settings -> 'Tags' or Menu -> 'Tags'.
      // Navigate via: Tag manager in settings.
      // Data Passed: None.
      // Database: CRUD Tags table.
      // Interactions:
      // • Tag List (Tap -> Edit)
      // • 'New Tag' (Tap -> Create)
      _TestRoute('💾 Backup & Export', AppRoutes.backupExport),

      // Purpose: Tools to backup data and export it to other formats.
      // Flow: Settings -> 'Data & Storage' -> 'Backup'.
      // Navigate via: Backup options in Data settings.
      // Data Passed: None.
      // Database: Exports DB file / Generates JSON.
      // Interactions:
      // • 'Create Backup' (Tap -> Save Local/Cloud)
      // • 'Export as JSON/CSV' (Tap -> Share File)
      _TestRoute(' Biometric Lock', AppRoutes.biometricLock),

      // Purpose: Setup for securing the app with fingerprint or Face ID.
      // Flow: Settings -> 'Privacy & Security' -> 'Biometrics'.
      // Navigate via: Security setup.
      // Data Passed: None.
      // Database: Uses SecureStorage for token.
      // Interactions:
      // • 'Enable FaceID' (Switch -> Authenticate & On)
      _TestRoute('🔢 PIN Setup', AppRoutes.pinSetup),
      // Purpose: Setup for securing the app with a numeric passcode.
      // Flow: Settings -> 'Privacy & Security' -> 'App Lock'.
      // Navigate via: PIN config in security settings.
      // Data Passed: None.
      // Database: Uses SecureStorage for Hash.
      // Interactions:
      // • Keypad (Tap Digits -> Set PIN)

      // ===== ADVANCED FEATURES (3) =====
      _TestRoute('🎯 Integrated Features', AppRoutes.integratedFeatures),

      // Purpose: A hub showcasing experimental or beta features designated for future release.
      // Flow: Enhanced Reminders -> 'AI & Insights' or Settings -> 'Labs'.
      // Navigate via: AI Hub button or Developer Options.
      // Data Passed: None.
      // Database: None (Menu).
      // Integrated Features:
      // 1. Media Gallery (Browse/Organize)
      // 2. Drawing Canvas (Sketch/Note)
      // 3. Collections Manager (Group Items)
      // 4. Kanban Board (Task Flow)
      // 5. AI & Insights (Smart Tools)
      // Interactions:
      // • Feature Grid (Tap -> Launch Experiment)
      _TestRoute('📱 Home Widgets', AppRoutes.homeWidgets),

      // Purpose: Configuration for home screen widgets on the device.
      // Flow: OS Home Screen (Long Press) -> Config.
      // Navigate via: External widget configuration (simulation).
      // Data Passed: Widget ID.
      // Database: Reads shared data.
      // Interactions:
      // • Preview List (Tap -> See Widget Styles)
      _TestRoute('🎨 Cross-Feature Demo', '/cross-feature-demo'),
      // Purpose: A demo showing how different features interact with each other.
      // Flow: Developer Settings -> 'Demo Mode'.
      // Navigate via: Special debug option.
      // Data Passed: Scenario config.
      // Database: Writes test data.
      // Interactions:
      // • 'Run Scenario' (Tap -> Auto-drive UI)

      // ===== ONBOARDING (2) =====
      _TestRoute(' Splash Screen', AppRoutes.splash),

      // Purpose: The initial launch screen displaying the app logo.
      // Flow: App Launch (Cold Start).
      // Navigate via: First screen shown on open.
      // Data Passed: None.
      // Database: Initializes DB connection.
      // Interactions:
      // • None (Auto-navigates)
      _TestRoute('👋 Onboarding', AppRoutes.onboarding),
      // Purpose: The introductory tutorial flow for new users.
      // Flow: Splash -> Onboarding (if first run).
      // Navigate via: First time setup flow.
      // Data Passed: None.
      // Database: Writes 'isFirstRun' flag.
      // Interactions:
      // • 'Next' / 'Skip' (Tap -> Advance)
      // • 'Get Started' (Tap -> Finish & Go Home)
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXL),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🛠️ Developer Test Links',
                          style: AppTypography.heading3(
                            context,
                            AppColors.textPrimary(context),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Navigate to any screen instantly (${testRoutes.length} screens)',
                          style: AppTypography.captionSmall(context),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.background(context),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMD,
                          ),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 20.sp,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: AppColors.divider(context), height: 1),
          // List of routes
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              itemCount: testRoutes.length,
              itemBuilder: (context, index) {
                final route = testRoutes[index];
                return _buildTestLinkTile(context, route, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestLinkTile(BuildContext context, _TestRoute route, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, route.routePath);
          },
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.label,
                        style: AppTypography.bodyMedium(
                          context,
                          AppColors.textPrimary(context),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        route.routePath,
                        style: AppTypography.captionSmall(
                          context,
                        ).copyWith(color: AppColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Test Route Data Model
class _TestRoute {
  final String label;
  final String routePath;

  _TestRoute(this.label, this.routePath);
}
