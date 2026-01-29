/// Centralized route name constants for the MyNotes application.
class AppRoutes {
  AppRoutes._();

  // ==================== Onboarding & Auth ====================
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';

  // ==================== Main Navigation ====================
  static const String home = '/home';
  static const String mainHome = '/main-home';
  static const String todayDashboard = '/today';
  static const String search = '/search';
  static const String settings = '/settings';

  // ==================== Notes Module ====================
  static const String notesList = '/notes';
  static const String noteEditor = '/notes/editor';
  static const String advancedNoteEditor = '/notes/advanced-editor';
  static const String globalSearch = '/global-search';
  static const String searchFilter = '/search-filter';

  // ==================== Media Module ====================
  static const String mediaPicker = '/media/picker';
  static const String audioRecorder = '/audio/recorder';

  // ==================== Reminders Module ====================
  static const String remindersList = '/reminders';
  static const String calendarIntegration = '/calendar-integration';

  // ==================== Todos Module ====================
  static const String todosList = '/todos';
  static const String todoFocus = '/todos/focus';
  static const String advancedTodo = '/todos/advanced';
  static const String recurringTodoSchedule = '/todos/recurring-schedule';

  // ==================== Reflection Module ====================
  static const String analytics = '/analytics';
  static const String reflectionEditor = '/reflections/editor';
  static const String reflection = '/reflection';
  static const String reflectionHome = '/reflection/home';

  // ==================== Focus & Productivity ====================
  static const String focusSession = '/focus-session';
  static const String focusCelebration = '/focus-celebration';
  static const String dailyHighlight = '/daily-highlight';
  static const String editDailyHighlight = '/edit-daily-highlight';
  static const String dailyHighlightSummary = '/daily-highlight-summary';

  // ==================== Document & Scanning ====================
  static const String documentScan = '/document-scan';
  static const String ocrExtraction = '/ocr-extraction';

  // ==================== Backup & Export ====================
  static const String backupExport = '/backup-export';
  static const String backupExportComplete = '/backup-export-complete';

  // ==================== App Settings & Privacy ====================
  static const String appSettings = '/app-settings';
  static const String privacy = '/privacy';
  static const String voiceSettings = '/voice-settings';
  static const String fontSettings = '/font-settings';

  // ==================== Quick Actions ====================
  static const String quickAdd = '/quick-add';
  static const String quickAddConfirmation = '/quick-add-confirmation';
  static const String universalQuickAdd = '/universal-quick-add';

  // ==================== Media & Utility ====================
  static const String mediaViewer = '/media/viewer';
  static const String pdfPreview = '/pdf/preview';
  static const String biometricLock = '/security/lock';
  static const String pinSetup = '/security/pin-setup';

  // ==================== Help & Support ====================
  static const String emptyStateNotesHelp = '/help/empty-notes';
  static const String emptyStateTodosHelp = '/help/empty-todos';
  static const String locationReminderComingSoon =
      '/location-reminder-coming-soon';

  // ==================== Command Palette ====================
  static const String commandPalette = '/command-palette';

  // ==================== Widgets ====================
  static const String homeWidgets = '/widgets';
}
