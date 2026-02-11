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
  static const String markdownNoteEditor = '/notes/markdown-editor';
  static const String archivedNotes = '/notes/archived';
  static const String globalSearch = '/global-search';
  static const String searchFilter = '/search-filter';

  // ==================== Smart Collections Module ====================
  static const String smartCollections = '/collections';
  static const String createCollection = '/collections/create';
  static const String ruleBuilder = '/collections/rule-builder';
  static const String collectionDetails = '/collections/details';
  static const String collectionManagement = '/collections/manage';

  // ==================== Media Module ====================
  static const String mediaPicker = '/media/picker';
  static const String audioRecorder = '/audio/recorder';
  static const String fullMediaGallery = '/media/gallery';
  static const String videoTrimming = '/media/trim';

  // ==================== Reminders Module ====================
  static const String remindersList = '/reminders';
  static const String calendarIntegration = '/calendar-integration';
  static const String smartReminders = '/reminders/smart';
  static const String locationReminder = '/reminders/location';
  static const String savedLocations = '/locations/saved';
  static const String alarms = '/alarms';
  static const String reminderTemplates = '/reminders/templates';
  static const String createReminder = '/reminders/create';
  static const String editReminder = '/reminders/edit';

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
  static const String reflectionAnswer = '/reflection/answer';
  static const String reflectionHistory = '/reflection/history';
  static const String reflectionCarousel = '/reflection/carousel';
  static const String reflectionQuestions = '/reflection/questions';

  // ==================== Focus & Productivity ====================
  static const String focusSession = '/focus-session';
  static const String focusCelebration = '/focus-celebration';
  static const String dailyHighlight = '/daily-highlight';
  static const String editDailyHighlight = '/edit-daily-highlight';
  static const String dailyHighlightSummary = '/daily-highlight-summary';

  // ==================== Document & Scanning ====================
  static const String documentScan = '/document-scan';
  static const String ocrExtraction = '/ocr-extraction';
  static const String drawingCanvas = '/drawing';
  static const String pdfAnnotation = '/pdf/annotate';

  // ==================== Backup & Export ====================
  static const String backupExport = '/backup-export';
  static const String backupExportComplete = '/backup-export-complete';

  // ==================== App Settings & Privacy ====================
  static const String appSettings = '/app-settings';
  static const String privacy = '/privacy';
  static const String voiceSettings = '/voice-settings';
  static const String fontSettings = '/font-settings';
  static const String advancedSettings = '/settings/advanced';
  static const String tagManagement = '/tags';

  // ==================== Advanced Search ====================
  static const String advancedSearch = '/search/advanced';
  static const String searchResults = '/search/results';
  static const String advancedFilters = '/filters/advanced';
  static const String searchOperators = '/search/operators';
  static const String sortCustomization = '/sort';

  // ==================== Quick Actions ====================
  static const String quickAdd = '/quick-add';
  static const String quickAddConfirmation = '/quick-add-confirmation';
  static const String universalQuickAdd = '/universal-quick-add';

  // ==================== Advanced Features Integration ====================
  static const String integratedFeatures = '/integrated-features';
  static const String mediaGallery = '/media-gallery';
  static const String collectionsManager = '/collections-manager';
  static const String kanbanBoard = '/kanban-board';
  static const String mediaFilter = '/media/filter';
  static const String mediaOrganization = '/media/organization';
  static const String mediaSearchResults = '/media/search-results';
  static const String mediaAnalytics = '/media/analytics';

  static const String suggestionRecommendations = '/reminders/suggestions';
  static const String reminderPatterns = '/reminders/patterns';
  static const String frequencyAnalytics = '/reminders/frequency';
  static const String engagementMetrics = '/reminders/engagement';

  static const String templateGallery = '/templates/gallery';
  static const String templateEditor = '/templates/editor';

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
