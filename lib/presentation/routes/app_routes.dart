/// App Routes
/// Centralized route definitions for the entire app

class AppRoutes {
  AppRoutes._();

  // ==================== Onboarding & Auth ====================
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // ==================== Main Navigation ====================
  static const String home = '/home';
  static const String todayDashboard = '/today';
  static const String search = '/search';
  static const String globalSearch = '/search/global';
  static const String settings = '/settings';
  static const String profile = '/profile';

  // ==================== Notes Module ====================
  static const String notesList = '/notes';
  static const String enhancedNotesList = '/notes/enhanced';
  static const String noteEditor = '/notes/editor';
  static const String enhancedNoteEditor = '/notes/editor/enhanced';
  static const String noteDetail = '/notes/detail';
  static const String notesArchive = '/notes/archive';
  static const String notesTrash = '/notes/trash';
  static const String notesCategories = '/notes/categories';

  // ==================== Reminders/Alarms Module ====================
  static const String remindersList = '/reminders';
  static const String reminderEditor = '/reminders/editor';
  static const String reminderDetail = '/reminders/detail';
  static const String alarmsList = '/alarms';
  static const String alarmEditor = '/alarms/editor';

  // ==================== Todos Module ====================
  static const String todosList = '/todos';
  static const String todoEditor = '/todos/editor';
  static const String todoDetail = '/todos/detail';
  static const String todosCompleted = '/todos/completed';

  // ==================== Reflection Module ====================
  static const String reflectionsList = '/reflections';
  static const String reflectionEditor = '/reflections/editor';
  static const String reflectionDetail = '/reflections/detail';
  static const String reflectionInsights = '/reflections/insights';
  static const String reflectionCalendar = '/reflections/calendar';
  static const String moodTracking = '/reflections/mood-tracking';

  // ==================== Focus & Productivity ====================
  static const String focusSession = '/focus';
  static const String focusSessionActive = '/focus/active';
  static const String focusSessionActiveEnhanced = '/focus/active-enhanced';
  static const String focusSessionComplete = '/focus/complete';
  static const String pomodoroTimer = '/pomodoro';

  // ==================== Quick Actions ====================
  static const String quickAdd = '/quick-add';
  static const String quickAddConfirmation = '/quick-add/confirmation';
  static const String universalQuickAdd = '/universal-quick-add';
  static const String quickNote = '/quick/note';
  static const String quickTodo = '/quick/todo';
  static const String quickReminder = '/quick/reminder';
  static const String quickReflection = '/quick/reflection';

  // ==================== Media & Attachments ====================
  static const String mediaGallery = '/media/gallery';
  static const String mediaViewer = '/media/viewer';
  static const String voiceRecorder = '/voice-recorder';
  static const String audioPlayer = '/audio-player';

  // ==================== Settings & Preferences ====================
  static const String settingsTheme = '/settings/theme';
  static const String settingsNotifications = '/settings/notifications';
  static const String settingsSecurity = '/settings/security';
  static const String settingsBackup = '/settings/backup';
  static const String settingsAbout = '/settings/about';

  // ==================== Utility Screens ====================
  static const String errorPage = '/error';
  static const String notFound = '/404';
  static const String maintenance = '/maintenance';
}
